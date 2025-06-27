import { aql } from "arangojs";
import path from "path";
import db from "../db/database_connection.js";
import { isValidValue } from "../utils/util.js";
import { uploadFile, deleteFile } from "../utils/fichier.js";


const banqueCollection = db.collection("banques");
const locateBanqueFolder = "banque";

const CanauxPaiement = {
  caisse: "caisse",
  operateurMobile: "operateurMobile",
  banque: "banque",
};
class Banque {
  constructor() {}
  getAllBanques = async ({ skip, perPage }) => {
    let limit = aql``;
    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    const query = await db.query(
      aql`FOR banque IN ${banqueCollection} SORT banque.timeStamp DESC ${limit} RETURN banque`,
      { fullCount: true }
    );
    if (query.hasNext) {
      const banques = await query.all();
      return Promise.all(
        banques.map(async (banque) => {
          return {
            ...banque,
            soldeTheorique: banque.soldeTheorique ?? 0,
            soldeReel: banque.soldeReel ?? 0,
            fullCount: query.extra.stats.fullCount,
            logo:
              banque.logo !== null
                ? process.env.FILE_PREFIX +
                  `${locateBanqueFolder}/` +
                  banque.logo
                : null,
          };
        })
      );
    } else {
      return [];
    }
  };

  getBanque = async ({ key }) => {
    try {
      const banque = await banqueCollection.document(key);
      return {
        ...banque,
        soldeTheorique: banque.soldeTheorique ?? 0,
        soldeReel: banque.soldeReel ?? 0,
        logo:
          banque.logo != null
            ? process.env.FILE_PREFIX + `${locateBanqueFolder}/` + banque.logo
            : null,
      };
    } catch {
      throw new Error(`Banque inexistante`);
    }
  };

  createBanque = async ({
    name,
    codeBanque,
    soldeReel = 0,
    logo,
    country,
    type,
    codeBIC,
    numCompte,
    codeGuichet,
    cleRIB,
  }) => {
    isValidValue({
      value: [name, country, type],
    });

    if (type == CanauxPaiement.banque) {
      isValidValue({
        value: [codeBanque, codeGuichet, cleRIB, codeBIC, numCompte],
      });
    }
    if (type == CanauxPaiement.operateurMobile) {
      isValidValue({
        value: numCompte,
      });
    }
    let filePath = null;
    if (logo && logo.file) {
      const { file } = await logo;
      const { filename, createReadStream, mimetype } = file;
      if (filename) {
        isValidValue({ value: [filename, mimetype] });
        const valid_name = name.replace(/ /g, "_");
        const extension = path.extname(filename);
        const uniquefilename = `${Date.now()}_${valid_name}${extension}`;
        filePath = await uploadFile({
          createReadStream: createReadStream,
          locateFolder: locateBanqueFolder,
          mimetype: mimetype,
          uniquefilename: uniquefilename,
        });

        if (filePath == null) {
          throw new Error();
        }
      }
    }

    let banque = {
      name: name,
      codeBanque: codeBanque,
      soldeReel: soldeReel,
      soldeTheorique: soldeReel,
      logo: filePath,
      type: type,
      codeBIC: codeBIC,
      numCompte: numCompte,
      codeGuichet: codeGuichet,
      cleRIB: cleRIB,
      country: country,
      timeStamp: Date.now(),
    };
    try {
      await banqueCollection.save(banque);
      return "OK";
    } catch {
      throw new Error("Une erreur s'est produite lors de l'enregistrement");
    }
  };

  updateBanque = async ({
    key,
    name,
    codeBanque,
    logo,
    country,
    type,
    codeBIC,
    numCompte,
    codeGuichet,
    cleRIB,
  }) => {
    let updateField = {};

    if (name !== undefined) {
      updateField.name = name;
    }

    if (codeBanque !== undefined) {
      updateField.codeBanque = codeBanque;
    }

    if (codeGuichet !== undefined) {
      updateField.codeGuichet = codeGuichet;
    }
    if (codeBIC !== undefined) {
      updateField.codeBIC = codeBIC;
    }

    if (type !== undefined) {
      updateField.type = type;
    }

    if (numCompte !== undefined) {
      updateField.numCompte = numCompte;
    }

    if (country !== undefined) {
      updateField.country = country;
    }

    if (cleRIB !== undefined) {
      updateField.cleRIB = cleRIB;
    }
    console.log(updateField);
    isValidValue({ value: updateField });
    console.log(logo);
    if (logo == null) {
      updateField.logo = null;
    } else if (
      logo !== undefined &&
      logo !== null &&
      logo !== "__unchanged__"
    ) {
      let filePath;
      let resolvedLogo;

      try {
        resolvedLogo = await logo;
      } catch (err) {
        resolvedLogo = null;
      }

      // Certains clients envoient directement { createReadStream, filename, mimetype }
      // d'autres mettent dans .file
      const fileObject = resolvedLogo?.file ?? (await resolvedLogo.promise);

      if (fileObject?.createReadStream && fileObject?.filename) {
        const { createReadStream, filename, mimetype } = fileObject;

        try {
          isValidValue({ value: [filename, mimetype] });

          const valid_name = name.replace(/ /g, "_");
          const extension = path.extname(filename);
          const uniquefilename = `${Date.now()}_${valid_name}${extension}`;

          filePath = await uploadFile({
            createReadStream,
            locateFolder: locateBanqueFolder,
            mimetype,
            uniquefilename,
          });

          if (!filePath) throw new Error("Échec de l'upload");

          updateField.logo = filePath;
        } catch (uploadError) {
          console.error("⛔ Échec de l'upload :", uploadError);
          throw new Error("Échec de l'upload du fichier.");
        }
      }
    }

    try {
      await banqueCollection.update(key, updateField);
      return "OK";
    } catch (error) {
      throw new Error("Une erreur s'est produite lors de la mise à jour");
    }
  };

  resetBanqueAmount = async ({ key, soldeReel, soldeTheorique }) => {
    const updateField = {};
    if (soldeReel) {
      updateField.soldeReel = soldeReel;
    }
    if (soldeTheorique) {
      updateField.soldeTheorique = soldeTheorique;
    }
    try {
      await banqueCollection.update(key, updateField);
      return "OK";
    } catch (e) {
      throw new Error(
        "Une erreur s'est produite lors de la réinitiation du solde bancaire > " +
          e.message
      );
    }
  };
  //archiver un banque
  deleteBanque = async ({ key }) => {
    try {
      const updateField = { etat: EtatBanque.archived };
      await banqueCollection.update(key, updateField);
      return "OK";
    } catch {
      throw new Error("Une erreur s'est produite lors de la mise à jour");
    }
  };

  isExistBanque = async ({ key }) => {
    const exist = await banqueCollection.documentExists(key);
    if (!exist) {
      throw new Error("Ce banque n'existe pas!");
    }
  };
}

export default Banque;
export { locateBanqueFolder };
