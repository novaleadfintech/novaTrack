import { aql } from "arangojs/aql.js";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import { deleteFile, uploadFile } from "../../utils/fichier.js";
import User from "../habilitation/user.js";
import Client from "../client/client.js";

import path from "path";

const debtCollection = db.collection("debts");
const userModel = new User();
const clientModel = new Client();

const DebtStatus = {
  paid: "paid",
  unpaid: "unpaid",
};

const locateDebtFolder = "debt";

class Debt {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await debtCollection.exists())) {
      debtCollection.create();
    }
  }

  getAllDebts = async ({ perPage, skip }) => {
    try {
      let limit = aql``;
      let filtreStatus = aql``;

      // Gestion de la pagination
      if (perPage !== undefined && skip !== undefined) {
        limit = aql`LIMIT ${skip}, ${perPage}`;
      }

      // Filtre par statut
      filtreStatus = aql`FILTER debt.status == ${DebtStatus.unpaid}`;
      // Requête avec l'ordre correct des clauses
      const query = await db.query(
        aql`FOR debt IN ${debtCollection} 
       ${filtreStatus}
      SORT debt.dateOperation DESC 
      ${limit} 
      RETURN debt`
      );

      const debts = await query.all();
      console.log(debts);
      return Promise.all(
        debts.map(async (debt) => {
          return {
            ...debt,
            user: await userModel.getUser({ key: debt.userId }),
            client:
              debt.clientId == null
                ? null
                : await clientModel.getClient({
                    key: debt.clientId,
                  }),

            pieceJustificative:
              debt.pieceJustificative !== null
                ? process.env.FILE_PREFIX +
                  `${locateDebtFolder}/` +
                  debt.pieceJustificative
                : null,
          };
        })
      );
    } catch (err) {
      console.error(err);

      return [];
    }
  };

  getArchiveDebts = async ({ perPage, skip }) => {
    try {
      let limit = aql``;
      let filtre = aql``;

      if (perPage !== undefined && skip !== undefined) {
        limit = aql`LIMIT ${skip}, ${perPage}`;
      }

      const query = await db.query(
        aql`
        FOR debt IN ${debtCollection}  
        ${filtre}
        FILTER debt.status==${DebtStatus.paid}
         SORT debt.dateOperation ASC  
        ${limit}  
        RETURN debt
      `
      );

      const debts = await query.all();

      return Promise.all(
        debts.map(async (debt) => {
          return {
            ...debt,
            user: await userModel.getUser({ key: debt.userId }),
            client:
              debt.clientId == null
                ? null
                : await clientModel.getClient({
                    key: debt.clientId,
                  }),

            pieceJustificative: debt.pieceJustificative
              ? process.env.FILE_PREFIX +
                `${locateDebtFolder}/` +
                debt.pieceJustificative
              : null,
          };
        })
      );
    } catch (err) {
      console.error(err);

      return [];
    }
  };

  getDebt = async ({ key }) => {
    try {
      const debt = await debtCollection.document(key);
      return {
        ...debt,
        user: await userModel.getUser({ key: debt.userId }),
        client:
          debt.clientId == null
            ? null
            : await clientModel.getClient({ key: debt.clientId }),
        pieceJustificative:
          debt.pieceJustificative !== null
            ? process.env.FILE_PREFIX +
              `${locateDebtFolder}/` +
              debt.pieceJustificative
            : null,
      };
    } catch (e) {
      console.error(e);
      throw new Error("Cette opération financière est inexistante");
    }
  };

  createDebt = async ({
    libelle,
    montant,
    pieceJustificative,
    referenceFacture,
    userId,
    clientId,
    dateOperation = Date.now(),
  }) => {
    isValidValue({
      value: [
        libelle,
        montant,
        userId,
        // clientId,
        referenceFacture,
      ],
    });

    const session = await db.beginTransaction({
      write: ["debts", "banques"],
    });

    if (clientId != undefined) {
      await clientModel.isExistClient({ key: clientId });
    }
    const query = await db.query(
      aql`FOR debt IN ${debtCollection} FILTER debt.referenceFacture == ${referenceFacture} LIMIT 1 RETURN debt`
    );

    if (query.hasNext) {
      throw new Error("Cette reférence est déjà existant");
    }
    let filePath = null;

    try {
      // Étape 1 : Gestion du fichier justificatif
      if (pieceJustificative && pieceJustificative.file) {
        const { file } = pieceJustificative;
        const { filename, createReadStream, mimetype } = file;

        if (filename) {
          isValidValue({ value: [filename, mimetype] });

          const valid_name = "preuve".replace(/ /g, "_");
          const extension = path.extname(filename);
          const uniquefilename = `${Date.now()}_${valid_name}${extension}`;

          filePath = await uploadFile({
            createReadStream: createReadStream,
            locateFolder: locateDebtFolder,
            mimetype: mimetype,
            uniquefilename: uniquefilename,
          });

          if (!filePath) {
            throw new Error("Erreur lors de l'upload du fichier");
          }
        }
      }

      await userModel.isExistUser({ key: userId });

      // Étape 3 : Créer le debt financier
      const newDebt = {
        libelle: libelle,
        referenceFacture: referenceFacture,
        montant: montant,
        status: DebtStatus.unpaid,
        dateEnregistrement: Date.now(),
        pieceJustificative: filePath ? filePath.replace(/\\/g, "/") : null,
        userId: userId,
        clientId: clientId,
        dateOperation: dateOperation,
      };

      await session.step(async () => {
        // await this.updateBanqueTheoriqueSolde({
        //   bankId: bankId,
        //   type: type,
        //   montant: montant,
        // });

        await debtCollection.save(newDebt);
      });

      await session.commit();
      return "OK";
    } catch (err) {
      console.error(err);

      await session.abort();
      throw new Error("Une erreur s'est produite lors de l'enregistrement");
    }
  };

  updateDebt = async ({
    key,
    libelle,
    montant,
    clientId,
    referenceFacture,
    pieceJustificative,
    dateOperation,
    status,
  }) => {
    const updateField = {};
    const session = await db.beginTransaction({
      write: ["debts", "banques"],
    });

    try {
      const debt = await this.getDebt({ key: key });
      if (!debt) throw new Error("Dette introuvable.");

      await session.step(async () => {
        if (libelle !== undefined) updateField.libelle = libelle;
        if (clientId !== undefined) {
          await clientModel.isExistClient({ key: clientId });
          updateField.clientId = clientId;
        }
        if (montant !== undefined) updateField.montant = montant;

        if (referenceFacture !== undefined) {
          const query = await db.query(
            aql`FOR debt IN ${debtCollection} FILTER debt.referenceFacture == ${referenceFacture} AND debt._id != ${key} LIMIT 1 RETURN debt`
          );

          if (query.hasNext) {
            throw new Error("Cette reférence est déjà existant");
          }
          updateField.referenceFacture = referenceFacture;
        }
        if (dateOperation) updateField.dateOperation = dateOperation;
        if (pieceJustificative?.file == null) {
          updateField.pieceJustificative = null;
        } else if (
          pieceJustificative?.file &&
          pieceJustificative !== "__unchanged__"
        ) {
          const { createReadStream, filename, mimetype } =
            await pieceJustificative.file;
          let uniquefilename;

          if (debt.pieceJustificative != undefined) {
            const oldFilePath = debt?.pieceJustificative;
            const oldFileExtension = oldFilePath
              ? path.extname(oldFilePath)
              : null;
            const newFileExtension = path.extname(filename);
            const trueOldFilePath = oldFilePath.replace(
              process.env.FILE_PREFIX + `${locateDebtFolder}/`,
              ""
            );

            if (newFileExtension !== oldFileExtension) {
              deleteFile({
                filePath: oldFilePath.replace(process.env.FILE_PREFIX, ""),
              });
            }
            uniquefilename = trueOldFilePath.replace(
              oldFileExtension,
              newFileExtension
            );
          } else {
            const valid_name = "preuve".replace(/ /g, "_");
            const extension = path.extname(filename);
            uniquefilename = `${Date.now()}_${valid_name}${extension}`;
          }
          const filePath = await uploadFile({
            createReadStream: createReadStream,
            locateFolder: locateDebtFolder,
            mimetype: mimetype,
            uniquefilename: uniquefilename,
          });

          if (!filePath) {
            throw new Error("Échec de l'upload du fichier.");
          }
          updateField.pieceJustificative = filePath;
        }
        updateField.status = status;
        await debtCollection.update(key, updateField);
      });

      await session.commit();
      return "OK";
    } catch (err) {
      console.error(err);

      await session.abort();
      throw new Error("Erreur lors de la mise à jour");
    }
  };

  deleteDebt = async ({ key }) => {
    const session = await db.beginTransaction({
      write: ["debts"],
    });

    try {
      const debt = await this.getDebt({ key });

      if (!debt) {
        throw new Error("Dette introuvable.");
      }
      await session.step(async () => {
        await debtCollection.remove(key);
      });

      await session.commit();
      return "OK";
    } catch (err) {
      console.error(err);

      await session.abort();
      throw new Error("Une erreur s'est produite lors de la suppression");
    }
  };
}

export default Debt;
export { DebtStatus, locateDebtFolder };
