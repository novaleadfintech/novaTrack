import { aql } from "arangojs/aql.js";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import { deleteFile, uploadFile } from "../../utils/fichier.js";
import User from "../habilitation/user.js";
import Client from "../client/client.js";

import Banque, { locateBanqueFolder } from "../banque.js";
import path from "path";

const fluxFinancierCollection = db.collection("fluxFinanciers");
const userModel = new User();
const BanqueModel = new Banque();
const clientModel = new Client();

const FluxFinancierType = {
  input: "input",
  output: "output",
};
const FluxFinancierStatus = {
  wait: "wait",
  reject: "reject",
  valid: "valid",
  returne: "returne",
};
const locateFinanceFolder = "finance";

class FluxFinancier {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await fluxFinancierCollection.exists())) {
      await fluxFinancierCollection.create();
    }
  }
  getAllFluxFinanciers = async ({ perPage, skip, type }) => {
    try {
      let limit = aql``;
      let filtreType = aql``; // Variable séparée pour le filtre de type
      let filtreStatus = aql``;

      // Gestion de la pagination
      if (perPage !== undefined && skip !== undefined) {
        limit = aql`LIMIT ${skip}, ${perPage}`;
      }

      // Gestion du filtre par type
      if (type !== undefined) {
        filtreType = aql`FILTER fluxFinancier.type == ${type}`;
      }

      // Filtre par statut
      filtreStatus = aql`FILTER fluxFinancier.status == ${FluxFinancierStatus.wait}
  OR fluxFinancier.status == ${FluxFinancierStatus.returne}`;

      // Requête avec l'ordre correct des clauses
      const query = await db.query(
        aql`FOR fluxFinancier IN ${fluxFinancierCollection} 
      ${filtreType}
      ${filtreStatus}
      SORT fluxFinancier.dateEnregistrement DESC 
      ${limit} 
      RETURN fluxFinancier`,
      );

      const fluxFinanciers = await query.all();
      return Promise.all(
        fluxFinanciers.map(async (fluxFinancier) => {
          let validate;
          if (fluxFinancier.validate != null) {
            validate = fluxFinancier.validate ?? [];
            await Promise.all(
              validate.map(async (valid) => {
                valid.validater = await userModel.getUser({
                  key: valid.validater,
                });
              }),
            );
          }
          return {
            ...fluxFinancier,
            validate: validate,
            user: await userModel.getUser({ key: fluxFinancier.userKey }),
            client:
              fluxFinancier.clientKey == null
                ? null
                : await clientModel.getClient({
                    key: fluxFinancier.clientKey,
                  }),

            pieceJustificative:
              fluxFinancier.pieceJustificative !== null
                ? process.env.FILE_PREFIX +
                  `${locateFinanceFolder}/` +
                  fluxFinancier.pieceJustificative
                : null,
          };
        }),
      );
    } catch (err) {
      console.error(err);

      return [];
    }
  };
  getAllDebtFluxFinanciers = async ({ perPage, skip }) => {
    try {
      let limit = aql``;
      let filtre = aql``;
      if (perPage !== undefined && skip !== undefined) {
        limit = aql`LIMIT ${skip}, ${perPage}`;
      }

      filtre = aql`FILTER fluxFinancier.type == ${FluxFinancierType.output} AND fluxFinancier.status==${FluxFinancierStatus.valid}
        AND fluxFinancier.type == ${FluxFinancierType.output} AND (fluxFinancier.montant - fluxFinancier.montantPaye)>0`;
      const query = await db.query(
        aql`FOR fluxFinancier IN ${fluxFinancierCollection} SORT fluxFinancier.dateEnregistrement DESC ${limit} ${filtre} RETURN fluxFinancier`,
      );
      const fluxFinanciers = await query.all();
      return Promise.all(
        fluxFinanciers.map(async (fluxFinancier) => {
          let validate;
          if (fluxFinancier.validate != null) {
            validate = fluxFinancier.validate ?? [];
            await Promise.all(
              validate.map(async (valid) => {
                valid.validater = await userModel.getUser({
                  key: valid.validater,
                });
              }),
            );
          }
          return {
            ...fluxFinancier,
            validate: validate,
            user: await userModel.getUser({ key: fluxFinancier.userKey }),
            client:
              fluxFinancier.clientKey == null
                ? null
                : await clientModel.getClient({
                    key: fluxFinancier.clientKey,
                  }),

            pieceJustificative:
              fluxFinancier.pieceJustificative !== null
                ? process.env.FILE_PREFIX +
                  `${locateFinanceFolder}/` +
                  fluxFinancier.pieceJustificative
                : null,
          };
        }),
      );
    } catch (err) {
      console.error(err);

      return [];
    }
  };

  unValidatedFluxFinanciers = async ({ perPage, skip }) => {
    try {
      let limit = aql``;
      let filtre = aql``;

      if (perPage !== undefined && skip !== undefined) {
        limit = aql`LIMIT ${skip}, ${perPage}`;
      }

      const query = await db.query(
        aql`
        FOR fluxFinancier IN ${fluxFinancierCollection}  
        FILTER fluxFinancier.status==${FluxFinancierStatus.wait}
        SORT fluxFinancier.dateOperation ASC  
        ${limit}  
        RETURN fluxFinancier
      `,
      );

      const fluxFinanciers = await query.all();
      return Promise.all(
        fluxFinanciers.map(async (fluxFinancier) => {
          let validate;
          if (fluxFinancier.validate != null) {
            validate = fluxFinancier.validate ?? [];
            await Promise.all(
              validate.map(async (valid) => {
                valid.validater = await userModel.getUser({
                  key: valid.validater,
                });
              }),
            );
          }

          return {
            ...fluxFinancier,
            validate: validate,
            user: await userModel.getUser({ key: fluxFinancier.userKey }),
            client:
              fluxFinancier.clientKey == null
                ? null
                : await clientModel.getClient({
                    key: fluxFinancier.clientKey,
                  }),

            pieceJustificative: fluxFinancier.pieceJustificative
              ? process.env.FILE_PREFIX +
                `${locateFinanceFolder}/` +
                fluxFinancier.pieceJustificative
              : null,
          };
        }),
      );
    } catch (err) {
      console.error(err);

      return [];
    }
  };
  getArchiveFluxFinanciers = async ({ perPage, skip }) => {
    try {
      let limit = aql``;
      let filtre = aql``;

      if (perPage !== undefined && skip !== undefined) {
        limit = aql`LIMIT ${skip}, ${perPage}`;
      }

      const query = await db.query(
        aql`
        FOR fluxFinancier IN ${fluxFinancierCollection}  
        ${filtre}
        FILTER fluxFinancier.status==${FluxFinancierStatus.valid}
        OR fluxFinancier.status==${FluxFinancierStatus.reject}
        SORT fluxFinancier.dateOperation ASC  
        ${limit}  
        RETURN fluxFinancier
      `,
      );

      const fluxFinanciers = await query.all();

      return Promise.all(
        fluxFinanciers.map(async (fluxFinancier) => {
          let validate;
          if (fluxFinancier.validate != null) {
            validate = fluxFinancier.validate ?? [];
            await Promise.all(
              validate.map(async (valid) => {
                valid.validater = await userModel.getUser({
                  key: valid.validater,
                });
              }),
            );
          }
          return {
            ...fluxFinancier,
            validate: validate,
            user: await userModel.getUser({ key: fluxFinancier.userKey }),
            client:
              fluxFinancier.clientKey == null
                ? null
                : await clientModel.getClient({
                    key: fluxFinancier.clientKey,
                  }),

            pieceJustificative: fluxFinancier.pieceJustificative
              ? process.env.FILE_PREFIX +
                `${locateFinanceFolder}/` +
                fluxFinancier.pieceJustificative
              : null,
          };
        }),
      );
    } catch (err) {
      console.error(err);

      return [];
    }
  };
  getFluxFinanciersByDateAndBank = async ({ debut, fin, banque, status }) => {
    try {
      const filtre = aql`
      FILTER fluxFinancier.bank._key == ${banque}
      AND fluxFinancier.dateOperation >= ${debut}
      AND fluxFinancier.dateOperation <= ${fin}
      ${
        status !== undefined
          ? aql`AND fluxFinancier.status == ${status}`
          : aql``
      }
    `;

      const query = await db.query(
        aql`
        FOR fluxFinancier IN ${fluxFinancierCollection}
        ${filtre}
        SORT fluxFinancier.dateOperation ASC
        RETURN fluxFinancier
      `,
      );

      const fluxFinanciers = await query.all();
      return Promise.all(
        fluxFinanciers.map(async (fluxFinancier) => {
          return {
            ...fluxFinancier,
            user: await userModel.getUser({ key: fluxFinancier.userKey }),
            client:
              fluxFinancier.clientKey == null
                ? null
                : await clientModel.getClient({
                    key: fluxFinancier.clientKey,
                  }),

            pieceJustificative:
              fluxFinancier.pieceJustificative !== null
                ? process.env.FILE_PREFIX +
                  `${locateFinanceFolder}/` +
                  fluxFinancier.pieceJustificative
                : null,
          };
        }),
      );
    } catch (err) {
      console.error(`Erreur lors de la récupération des flux financiers`, err);
      return [];
    }
  };

  getAllFluxFinanciersbyPeriod = async ({ begin, end, type }) => {
    try {
      let filtre = aql``;
      if (begin !== undefined && end !== undefined) {
        filtre = aql`FILTER fluxFinancier.dateOperation >= ${begin} AND fluxFinancier.dateOperation <= ${end} AND AND fluxFinancier.status == ${FluxFinancierStatus.valid}`;
      }
      if (type !== undefined) {
        filtre = aql`
          ${filtre}
          FILTER fluxFinancier.type == ${type}
        `;
      }
      const query = await db.query(
        aql`FOR fluxFinancier IN ${fluxFinancierCollection} ${filtre} SORT fluxFinancier.dateOperation ASC RETURN fluxFinancier`,
      );
      const fluxFinanciers = await query.all();

      return Promise.all(
        fluxFinanciers.map(async (fluxFinancier) => {
          let validate;
          if (fluxFinancier.validate != null) {
            validate = fluxFinancier.validate ?? [];
            await Promise.all(
              validate.map(async (valid) => {
                valid.validater = await userModel.getUser({
                  key: valid.validater,
                });
              }),
            );
          }
          return {
            ...fluxFinancier,
            validate: validate,
            client:
              fluxFinancier.clientKey == null
                ? null
                : await clientModel.getClient({
                    key: fluxFinancier.clientKey,
                  }),
            pieceJustificative:
              fluxFinancier.pieceJustificative !== null
                ? process.env.FILE_PREFIX +
                  `${locateFinanceFolder}/` +
                  fluxFinancier.pieceJustificative
                : null,
          };
        }),
      );
    } catch (err) {
      console.error(err);

      return [];
    }
  };

  getFluxFinancier = async ({ key }) => {
    try {
      const fluxFinancier = await fluxFinancierCollection.document(key);
      let validate;
      if (fluxFinancier.validate != null) {
        validate = fluxFinancier.validate ?? [];
        await Promise.all(
          validate.map(async (valid) => {
            valid.validater = await userModel.getUser({ key: valid.validater });
          }),
        );
      }
      return {
        ...fluxFinancier,
        validate: validate,
        user: await userModel.getUser({ key: fluxFinancier.userKey }),
        client:
          fluxFinancier.clientKey == null
            ? null
            : await clientModel.getClient({ key: fluxFinancier.clientKey }),
        pieceJustificative:
          fluxFinancier.pieceJustificative !== null
            ? process.env.FILE_PREFIX +
              `${locateFinanceFolder}/` +
              fluxFinancier.pieceJustificative
            : null,
      };
    } catch (e) {
      console.error(e);
      throw new Error("Cette opération financière est inexistante");
    }
  };

  getFluxFiancierbyDecouvert = async ({ decouvertKey }) => {
    let precision = aql`SORT payement.dateEnregistrement DESC`;
    if (decouvertKey !== undefined) {
      precision = aql`FILTER payement.decouvertKey == ${decouvertKey} SORT payement.dateEnregistrement ASC`;
    }
    const query = await db.query(
      aql`FOR payement IN ${fluxFinancierCollection} ${precision} RETURN payement`,
    );

    if (query.hasNext) {
      const fluxFinancier = await query.next();
      let validate;
      if (fluxFinancier.validate != null) {
        validate = fluxFinancier.validate ?? [];
        await Promise.all(
          validate.map(async (valid) => {
            valid.validater = await userModel.getUser({ key: valid.validater });
          }),
        );
      }
      return {
        ...fluxFinancier,
        validate: validate,
        user: await userModel.getUser({ key: fluxFinancier.userKey }),
        client:
          fluxFinancier.clientKey == null
            ? null
            : await clientModel.getClient({ key: fluxFinancier.clientKey }),
        pieceJustificative:
          fluxFinancier.pieceJustificative !== null
            ? process.env.FILE_PREFIX +
              `${locateFinanceFolder}/` +
              fluxFinancier.pieceJustificative
            : null,
      };
    }
  };

  getFluxFiancierbyforFactureInformation = async ({ factureKey }) => {
    let precision = aql`SORT payement.dateEnregistrement DESC`;
    if (factureKey !== undefined) {
      precision = aql`FILTER payement.factureKey == ${factureKey} SORT payement.dateEnregistrement ASC`;
    }
    const query = await db.query(
      aql`FOR payement IN ${fluxFinancierCollection} ${precision}  RETURN payement`,
    );

    if (query.hasNext) {
      const payements = await query.all();
      return Promise.all(
        payements.map(async (payement) => {
          let validate;
          if (payement.validate == null) {
            validate = payement.validate ?? [];
            await Promise.all(
              validate.map(async (valid) => {
                valid.validater = await userModel.getUser({
                  key: valid.validater,
                });
              }),
            );
          }

          return {
            ...payement,
            validate: validate,
            user: await userModel.getUser({ key: payement.userKey }),
            client:
              payement.clientKey == null
                ? null
                : await clientModel.getClient({ key: payement.clientKey }),
            pieceJustificative:
              payement.pieceJustificative !== null
                ? process.env.FILE_PREFIX +
                  `${locateFinanceFolder}/` +
                  payement.pieceJustificative
                : null,
          };
        }),
      );
    } else {
      return [];
    }
  };

  getFluxFiancierbyFacture = async ({ factureKey }) => {
    let precision = aql`SORT payement.dateEnregistrement DESC`;
    if (factureKey !== undefined) {
      precision = aql`FILTER payement.factureKey == ${factureKey} AND payement.status != ${FluxFinancierStatus.reject}  SORT payement.dateEnregistrement ASC`;
    }
    const query = await db.query(
      aql`FOR payement IN ${fluxFinancierCollection} ${precision}  RETURN payement`,
    );

    if (query.hasNext) {
      const payements = await query.all();
      return Promise.all(
        payements.map(async (payement) => {
          let validate;
          if (payement.validate == null) {
            validate = payement.validate ?? [];
            await Promise.all(
              validate.map(async (valid) => {
                valid.validater = await userModel.getUser({
                  key: valid.validater,
                });
              }),
            );
          }

          return {
            ...payement,
            validate: validate,
            user: await userModel.getUser({ key: payement.userKey }),
            client:
              payement.clientKey == null
                ? null
                : await clientModel.getClient({ key: payement.clientKey }),
            pieceJustificative:
              payement.pieceJustificative !== null
                ? process.env.FILE_PREFIX +
                  `${locateFinanceFolder}/` +
                  payement.pieceJustificative
                : null,
          };
        }),
      );
    } else {
      return [];
    }
  };

  createFluxFinancier = async ({
    libelle,
    type,
    montant,
    moyenPayement,
    pieceJustificative,
    referenceTransaction,
    userKey,
    partiePrenante,
    clientKey,
    factureKey,
    decouvertKey,
    isFromSystem = false,
    bankKey,
    bulletinKey,
    dateOperation = Date.now(),
  }) => {
    isValidValue({
      value: [
        libelle,
        montant,
        moyenPayement,
        userKey,
        // clientKey,
        bankKey,
        referenceTransaction,
      ],
    });

    const session = await db.beginTransaction({
      write: ["fluxFinanciers", "banques"],
    });

    if (clientKey != undefined) {
      await clientModel.isExistClient({ key: clientKey });
    }

    const query = await db.query(
      aql`FOR flux IN ${fluxFinancierCollection} FILTER flux.status != ${FluxFinancierStatus.reject} AND flux.referenceTransaction == ${referenceTransaction} LIMIT 1 RETURN flux`,
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
            locateFolder: locateFinanceFolder,
            mimetype: mimetype,
            uniquefilename: uniquefilename,
          });

          if (!filePath) {
            throw new Error("Erreur lors de l'upload du fichier");
          }
        }
      }
      // Étape 2 : Vérifier l'existence des sources de paiement
      const banque = await BanqueModel.getBanque({ key: bankKey });
      const { logo, ...otherdata } = banque;
      if (logo != null) {
        otherdata.logo = logo.replace(
          process.env.FILE_PREFIX + `${locateBanqueFolder}/`,
          "",
        );
      }

      await userModel.isExistUser({ key: userKey });

      // Étape 3 : Créer le flux financier
      const newFluxfinancier = {
        reference: await this.generateNewFuxFinancierReference({ type: type }),
        libelle: libelle,
        referenceTransaction: referenceTransaction,
        type: type,
        montant: montant,
        moyenPayement: moyenPayement,
        dateEnregistrement: Date.now(),
        pieceJustificative: filePath ? filePath.replace(/\\/g, "/") : null,
        userKey: userKey,
        partiePrenante: partiePrenante,
        clientKey: clientKey,
        status: FluxFinancierStatus.wait,
        factureKey: factureKey,
        bank: otherdata,
        isFromSystem: isFromSystem,
        decouvertKey: decouvertKey,
        dateOperation: dateOperation,
        bulletinKey: bulletinKey,
      };

      await session.step(async () => {
        await this.updateBanqueTheoriqueSolde({
          bankKey: bankKey,
          type: type,
          montant: montant,
        });

        await fluxFinancierCollection.save(newFluxfinancier);
      });

      await session.commit();
      return "OK";
    } catch (err) {
      console.error(err);

      await session.abort();
      throw new Error("Une erreur s'est produite lors de l'enregistrement");
    }
  };

  updateFluxFinancier = async ({
    key,
    libelle,
    montant,
    bankKey,
    partiePrenante,
    clientKey,
    referenceTransaction,
    moyenPayement,
    pieceJustificative,
    dateOperation,
  }) => {
    const updateField = {};
    const session = await db.beginTransaction({
      write: ["fluxFinanciers", "banques"],
    });

    try {
      const flux = await this.getFluxFinancier({ key: key });
      if (!flux) throw new Error("Flux financier introuvable.");
      if (flux.isFromSystem == true) {
        throw new Error("Ce flux financier n'est pas modifiable");
      }
      const ancienMontant = flux.montant;
      const ancienneBanqueKey = flux.bank?._key;
      const montantUtilise = montant ?? ancienMontant;

      await session.step(async () => {
        if (flux.status === FluxFinancierStatus.wait) {
          if (bankKey) {
            const nouvelleBanqueKey = bankKey;
            // const ancienneBanque = await BanqueModel.getBanque({ key: ancienneBanqueKey });
            const nouvelleBanque = await BanqueModel.getBanque({
              key: nouvelleBanqueKey,
            });
            if (flux.type === FluxFinancierType.input) {
              await this.updateBanqueTheoriqueSolde({
                bankKey: ancienneBanqueKey,
                montant: ancienMontant,
                type: FluxFinancierType.output,
              });
              await this.updateBanqueTheoriqueSolde({
                bankKey: nouvelleBanqueKey,
                montant: montantUtilise,
                type: FluxFinancierType.input,
              });
            } else if (flux.type === FluxFinancierType.output) {
              await this.updateBanqueTheoriqueSolde({
                bankKey: ancienneBanqueKey,
                montant: ancienMontant,
                type: FluxFinancierType.input,
              });
              await this.updateBanqueTheoriqueSolde({
                bankKey: nouvelleBanqueKey,
                montant: montantUtilise,
                type: FluxFinancierType.output,
              });
            }

            const { logo, ...otherdata } = nouvelleBanque;
            if (logo) {
              otherdata.logo = logo.replace(
                process.env.FILE_PREFIX + `${locateBanqueFolder}/`,
                "",
              );
            }
            updateField.bank = otherdata;
          }
        } else {
          bankKey = flux.bank._key;
          if (flux.type === FluxFinancierType.input) {
            await this.updateBanqueTheoriqueSolde({
              bankKey: bankKey,
              montant: montantUtilise,
              type: FluxFinancierType.input,
            });
          } else if (flux.type === FluxFinancierType.output) {
            await this.updateBanqueTheoriqueSolde({
              bankKey: bankKey,
              montant: montantUtilise,
              type: FluxFinancierType.output,
            });
          }
          updateField.status = FluxFinancierStatus.wait;
        }

        if (libelle !== undefined) updateField.libelle = libelle;
         if (clientKey !== undefined) {
          (await clientKey) != null ??
            clientModel.isExistClient({ key: clientKey });
          updateField.clientKey = clientKey;
        }
        if (partiePrenante !== undefined)
          updateField.partiePrenante = partiePrenante;
        if (montant !== undefined) updateField.montant = montant;
        if (moyenPayement !== undefined)
          updateField.moyenPayement = moyenPayement;
        if (referenceTransaction !== undefined) {
          const query = await db.query(
            aql`FOR flux IN ${fluxFinancierCollection} FILTER flux.status != ${FluxFinancierStatus.reject} AND flux.referenceTransaction == ${referenceTransaction} LIMIT 1 RETURN flux`,
          );

          if (query.hasNext) {
            throw new Error("Cette reférence est déjà existant");
          }
          updateField.referenceTransaction = referenceTransaction;
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

          if (flux.pieceJustificative != undefined) {
            const oldFilePath = flux?.pieceJustificative;
            const oldFileExtension = oldFilePath
              ? path.extname(oldFilePath)
              : null;
            const newFileExtension = path.extname(filename);
            const trueOldFilePath = oldFilePath.replace(
              process.env.FILE_PREFIX + `${locateFinanceFolder}/`,
              "",
            );

            if (newFileExtension !== oldFileExtension) {
              deleteFile({
                filePath: oldFilePath.replace(process.env.FILE_PREFIX, ""),
              });
            }
            uniquefilename = trueOldFilePath.replace(
              oldFileExtension,
              newFileExtension,
            );
          } else {
            const valid_name = "preuve".replace(/ /g, "_");
            const extension = path.extname(filename);
            uniquefilename = `${Date.now()}_${valid_name}${extension}`;
          }
          const filePath = await uploadFile({
            createReadStream: createReadStream,
            locateFolder: locateFinanceFolder,
            mimetype: mimetype,
            uniquefilename: uniquefilename,
          });

          if (!filePath) {
            throw new Error("Échec de l'upload du fichier.");
          }
          updateField.pieceJustificative = filePath;
        }
        await fluxFinancierCollection.update(key, updateField);
      });

      await session.commit();
      return "OK";
    } catch (err) {
      console.error(err);

      await session.abort();
      throw new Error("Erreur lors de la mise à jour");
    }
  };

  deleteFluxFinancier = async ({ key }) => {
    const session = await db.beginTransaction({
      write: ["fluxFinanciers"],
    });

    try {
      const flux = await this.getFluxFinancier({ key });

      if (!flux) {
        throw new Error("Flux financier introuvable.");
      }

      if (flux.status !== FluxFinancierStatus.wait) {
        throw new Error(
          "Impossible de supprimer un flux financier déjà validé.",
        );
      }

      await session.step(async () => {
        await fluxFinancierCollection.remove(key);
      });

      await session.commit();
      return "OK";
    } catch (err) {
      console.error(err);

      await session.abort();
      throw new Error("Une erreur s'est produite lors de la suppression");
    }
  };

  async updateBanqueTheoriqueSolde({ bankKey, type, montant }) {
    const banque = await BanqueModel.getBanque({ key: bankKey });

    if (type === FluxFinancierType.output) {
      await BanqueModel.resetBanqueAmount({
        key: banque._key,
        soldeTheorique: banque.soldeTheorique - montant,
      });
    } else {
      await BanqueModel.resetBanqueAmount({
        key: banque._key,
        soldeTheorique: banque.soldeTheorique + montant,
      });
    }
  }

  async updateBanqueReelSolde({ bankKey, type, montant }) {
    const banque = await BanqueModel.getBanque({ key: bankKey });
    const sommeBanquaire = banque.soldeReel;
    if (type == FluxFinancierType.output) {
      if (sommeBanquaire >= montant) {
        await BanqueModel.resetBanqueAmount({
          key: banque._key,
          soldeReel: banque.soldeReel - montantRestant,
        });
      } else {
        throw new Error(
          "Fonds insuffisants pour couvrir le montant total de cette sortie financière.",
        );
      }
    } else {
      await BanqueModel.resetBanqueAmount({
        key: banque._key,
        soldeReel: banque.soldeReel + montant,
      });
    }
  }

  deleteFluxFinancierByFacture = async ({ key }) => {
    try {
      await fluxFinancierCollection.remove(key);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Une erreur s'est produite lors de la suppression");
    }
  };

  getBilan = async ({ begin, end, type }) => {
    if (begin == null || end == null) {
      begin = Date.now() - 30 * 24 * 60 * 60 * 1000;
      end = Date.now() + 30 * 24 * 60 * 60 * 1000;
    }
    try {
      let fluxs = await this.getAllFluxFinanciersbyPeriod({
        begin: begin,
        end: end,
        type: type,
      });
      let fluxFinanciers = fluxs.filter(
        (flux) =>
          flux.validate != null && flux.validate.validateStatus === true,
      );
      let total = 0;
      let input = 0;
      let output = 0;
      fluxFinanciers.forEach((flux) => {
        if (flux.type === FluxFinancierType.input) {
          input += flux.montant;
          total += flux.montant;
        } else if (flux.type === FluxFinancierType.output) {
          output += flux.montant;
          total -= flux.montant;
        }
      });
      return {
        output,
        input,
        total,
        fluxFinanciers,
      };
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors du calcul du bilan financier");
    }
  };

  getYearBilan = async ({ year }) => {
    if (year == null) {
      year = new Date().getFullYear();
    }
    try {
      const query = aql`
        FOR flux IN ${fluxFinancierCollection}
          FILTER DATE_YEAR(flux.dateOperation) == ${year}
          COLLECT mois = DATE_MONTH(flux.dateOperation) INTO groupTransactions
          LET input = SUM(
            FOR t IN groupTransactions[*].flux
            FILTER t.type == ${FluxFinancierType.input}
            AND(t.validate != null AND t.validate.validateStatus == true)
            RETURN t.montant
          )
          LET output = SUM(
            FOR t IN groupTransactions[*].flux
            FILTER t.type == ${FluxFinancierType.output}
            AND (t.validate != null AND t.validate.validateStatus == true)
            RETURN t.montant
          )
          RETURN [mois-1, input, output]
      `;

      const cursor = await db.query(query);
      const yearResult = await cursor.all();
      return yearResult;
    } catch (err) {
      console.error(err);

      throw new Error(`Erreur lors de la récupération du bilan`);
    }
  };

  generateNewFuxFinancierReference = async ({ type }) => {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth() + 1;
    const lastTwoDigitsYear = currentYear.toString().slice(-2);

    const startOfMonth = new Date(currentYear, currentMonth - 1, 1).getTime();

    const query = await db.query(
      aql`
        FOR flux IN ${fluxFinancierCollection}
        FILTER flux.dateEnregistrement >= ${startOfMonth}
        LIMIT 1
        SORT flux.dateEnregistrement DESC
        RETURN flux        
      `,
    );

    let count = 0;
    if (query.hasNext) {
      const oldflux = await query.next();
      const oldReference = oldflux.reference;
      const firstTwoLetters = oldReference.substring(0, 2);
      count = parseInt(firstTwoLetters);
    }
    return type == FluxFinancierType.input
      ? `${String(count + 1).padStart(2, "0")}/DG/ENT/${String(
          currentMonth,
        ).padStart(2, "0")}/${lastTwoDigitsYear}`
      : `${String(count + 1).padStart(2, "0")}/DG/SO/${String(
          currentMonth,
        ).padStart(2, "0")}/${lastTwoDigitsYear}`;
  };
}

export default FluxFinancier;
export { FluxFinancierType, FluxFinancierStatus, locateFinanceFolder };
