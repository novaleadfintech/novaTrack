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
  constructor() {}
  getAllFluxFinanciers = async ({ perPage, skip, type }) => {
    try {
      let limit = aql``;
      let filtre = aql``;
      if (perPage !== undefined && skip !== undefined) {
        limit = aql`LIMIT ${skip}, ${perPage}`;
      }
      if (type !== undefined) {
        limit = aql`FILTER fluxFinancier.type == ${type}`;
      }
      filtre = aql`FILTER fluxFinancier.status==${FluxFinancierStatus.wait}
        OR fluxFinancier.status==${FluxFinancierStatus.returne}`;
      const query = await db.query(
        aql`FOR fluxFinancier IN ${fluxFinancierCollection} SORT fluxFinancier.dateEnregistrement DESC ${limit} ${filtre} RETURN fluxFinancier`
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
              })
            );
          }
          return {
            ...fluxFinancier,
            validate: validate,
            user: await userModel.getUser({ key: fluxFinancier.userId }),
            client:
              fluxFinancier.clientId == null
                ? null
                : await clientModel.getClient({
                    key: fluxFinancier.clientId,
                  }),

            pieceJustificative:
              fluxFinancier.pieceJustificative !== null
                ? process.env.FILE_PREFIX +
                  `${locateFinanceFolder}/` +
                  fluxFinancier.pieceJustificative
                : null,
          };
        })
      );
    } catch (err) {
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
      `
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
              })
            );
          }

          return {
            ...fluxFinancier,
            validate: validate,
            user: await userModel.getUser({ key: fluxFinancier.userId }),
            client:
              fluxFinancier.clientId == null
                ? null
                : await clientModel.getClient({
                    key: fluxFinancier.clientId,
                  }),

            pieceJustificative: fluxFinancier.pieceJustificative
              ? process.env.FILE_PREFIX +
                `${locateFinanceFolder}/` +
                fluxFinancier.pieceJustificative
              : null,
          };
        })
      );
    } catch (err) {
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
      `
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
              })
            );
          }
          return {
            ...fluxFinancier,
            validate: validate,
            user: await userModel.getUser({ key: fluxFinancier.userId }),
            client:
              fluxFinancier.clientId == null
                ? null
                : await clientModel.getClient({
                    key: fluxFinancier.clientId,
                  }),

            pieceJustificative: fluxFinancier.pieceJustificative
              ? process.env.FILE_PREFIX +
                `${locateFinanceFolder}/` +
                fluxFinancier.pieceJustificative
              : null,
          };
        })
      );
    } catch (err) {
      return [];
    }
  };
  getFluxFinanciersByDateAndBank = async ({ debut, fin, banque, status }) => {
    try {
      const filtre = aql`
      FILTER fluxFinancier.bank._id == ${banque}
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
      `
      );

      const fluxFinanciers = await query.all();
      console.log(fluxFinanciers);
      return Promise.all(
        fluxFinanciers.map(async (fluxFinancier) => {
          return {
            ...fluxFinancier,
            user: await userModel.getUser({ key: fluxFinancier.userId }),
            client:
              fluxFinancier.clientId == null
                ? null
                : await clientModel.getClient({
                    key: fluxFinancier.clientId,
                  }),

            pieceJustificative:
              fluxFinancier.pieceJustificative !== null
                ? process.env.FILE_PREFIX +
                  `${locateFinanceFolder}/` +
                  fluxFinancier.pieceJustificative
                : null,
          };
        })
      );
    } catch (err) {
      console.error(
        `Erreur lors de la récupération des flux financiers: ${err.message}`
      );
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
        aql`FOR fluxFinancier IN ${fluxFinancierCollection} ${filtre} SORT fluxFinancier.dateOperation ASC RETURN fluxFinancier`
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
              })
            );
          }
          return {
            ...fluxFinancier,
            validate: validate,
            client:
              fluxFinancier.clientId == null
                ? null
                : await clientModel.getClient({
                    key: fluxFinancier.clientId,
                  }),
            pieceJustificative:
              fluxFinancier.pieceJustificative !== null
                ? process.env.FILE_PREFIX +
                  `${locateFinanceFolder}/` +
                  fluxFinancier.pieceJustificative
                : null,
          };
        })
      );
    } catch (err) {
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
          })
        );
      }
      return {
        ...fluxFinancier,
        validate: validate,
        user: await userModel.getUser({ key: fluxFinancier.userId }),
        client:
          fluxFinancier.clientId == null
            ? null
            : await clientModel.getClient({ key: fluxFinancier.clientId }),
        pieceJustificative:
          fluxFinancier.pieceJustificative !== null
            ? process.env.FILE_PREFIX +
              `${locateFinanceFolder}/` +
              fluxFinancier.pieceJustificative
            : null,
      };
    } catch (e) {
      throw new Error("Cette opération financière est inexistante");
    }
  };

  getFluxFiancierbyDecouvert = async ({ decouvertId }) => {
    let precision = aql`SORT payement.dateEnregistrement DESC`;
    if (decouvertId !== undefined) {
      precision = aql`FILTER payement.decouvertId == ${decouvertId} SORT payement.dateEnregistrement ASC`;
    }
    const query = await db.query(
      aql`FOR payement IN ${fluxFinancierCollection} ${precision} RETURN payement`
    );

    if (query.hasNext) {
      const fluxFinancier = await query.next();
      console.log(fluxFinancier);
      let validate;
      if (fluxFinancier.validate != null) {
        validate = fluxFinancier.validate ?? [];
        await Promise.all(
          validate.map(async (valid) => {
            valid.validater = await userModel.getUser({ key: valid.validater });
          })
        );
      }
      return {
        ...fluxFinancier,
        validate: validate,
        user: await userModel.getUser({ key: fluxFinancier.userId }),
        client:
          fluxFinancier.clientId == null
            ? null
            : await clientModel.getClient({ key: fluxFinancier.clientId }),
        pieceJustificative:
          fluxFinancier.pieceJustificative !== null
            ? process.env.FILE_PREFIX +
              `${locateFinanceFolder}/` +
              fluxFinancier.pieceJustificative
            : null,
      };
    }
  };

  getFluxFiancierbyFacture = async ({ factureId }) => {
    let precision = aql`SORT payement.dateEnregistrement DESC`;
    if (factureId !== undefined) {
      precision = aql`FILTER payement.factureId == ${factureId} AND ( payement.status != ${FluxFinancierStatus.reject}) SORT payement.dateEnregistrement ASC`;
    }
    const query = await db.query(
      aql`FOR payement IN ${fluxFinancierCollection} ${precision}  RETURN payement`
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
              })
            );
          }

          return {
            ...payement,
            validate: validate,
            user: await userModel.getUser({ key: payement.userId }),
            client:
              payement.clientId == null
                ? null
                : await clientModel.getClient({ key: payement.clientId }),
            pieceJustificative:
              payement.pieceJustificative !== null
                ? process.env.FILE_PREFIX +
                  `${locateFinanceFolder}/` +
                  payement.pieceJustificative
                : null,
          };
        })
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
    userId,
    clientId,
    factureId,
    decouvertId,
    isFromSystem = false,
    bankId,
    bulletinId,
    dateOperation = Date.now(),
  }) => {
    console.log(
      libelle,
      montant,
      moyenPayement,
      userId,
      // clientId,
      bankId,
      referenceTransaction
    );
    isValidValue({
      value: [
        libelle,
        montant,
        moyenPayement,
        userId,
        // clientId,
        bankId,
        referenceTransaction,
      ],
    });

    const session = await db.beginTransaction({
      write: ["fluxFinanciers", "banques"],
    });

    if (clientId != undefined) {
      await clientModel.isExistClient({ key: clientId });
    }
    const query = await db.query(
      aql`FOR flux IN ${fluxFinancierCollection} FILTER flux.referenceTransaction == ${referenceTransaction} LIMIT 1 RETURN flux`
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
      const banque = await BanqueModel.getBanque({ key: bankId });
      const { logo, ...otherdata } = banque;
      if (logo != null) {
        otherdata.logo = logo.replace(
          process.env.FILE_PREFIX + `${locateBanqueFolder}/`,
          ""
        );
      }

      await userModel.isExistUser({ key: userId });

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
        userId: userId,
        clientId: clientId,
        status: FluxFinancierStatus.wait,
        factureId: factureId,
        bank: otherdata,
        isFromSystem: isFromSystem,
        decouvertId: decouvertId,
        dateOperation: dateOperation,
        bulletinId: bulletinId,
      };

      await session.step(async () => {
        await this.updateBanqueTheoriqueSolde({
          bankId: bankId,
          type: type,
          montant: montant,
        });

        await fluxFinancierCollection.save(newFluxfinancier);
      });

      await session.commit();
      return "OK";
    } catch (err) {
      await session.abort();
      throw new Error(
        "Une erreur s'est produite lors de l'enregistrement : " + err.message
      );
    }
  };

  updateFluxFinancier = async ({
    key,
    libelle,
    montant,
    bankId,
    clientId,
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
      if (flux.isFromSystem==true) {
        throw new Error("Ce flux financier n'est pas modifiable");
      }
      const ancienMontant = flux.montant;
      const ancienneBanqueId = flux.bank?._id;
      const montantUtilise = montant ?? ancienMontant;

      await session.step(async () => {
        if (flux.status === FluxFinancierStatus.wait) {
          if (bankId) {
            const nouvelleBanqueId = bankId;
            // const ancienneBanque = await BanqueModel.getBanque({ key: ancienneBanqueId });
            const nouvelleBanque = await BanqueModel.getBanque({
              key: nouvelleBanqueId,
            });
            if (flux.type === FluxFinancierType.input) {
              await this.updateBanqueTheoriqueSolde({
                bankId: ancienneBanqueId,
                montant: ancienMontant,
                type: FluxFinancierType.output,
              });
              await this.updateBanqueTheoriqueSolde({
                bankId: nouvelleBanqueId,
                montant: montantUtilise,
                type: FluxFinancierType.input,
              });
            } else if (flux.type === FluxFinancierType.output) {
              await this.updateBanqueTheoriqueSolde({
                bankId: ancienneBanqueId,
                montant: ancienMontant,
                type: FluxFinancierType.input,
              });
              await this.updateBanqueTheoriqueSolde({
                bankId: nouvelleBanqueId,
                montant: montantUtilise,
                type: FluxFinancierType.output,
              });
            }

            const { logo, ...otherdata } = nouvelleBanque;
            if (logo) {
              otherdata.logo = logo.replace(
                process.env.FILE_PREFIX + `${locateBanqueFolder}/`,
                ""
              );
            }
            updateField.bank = otherdata;
          }
        } else {
          bankId = flux.bank._id;
          if (flux.type === FluxFinancierType.input) {
            await this.updateBanqueTheoriqueSolde({
              bankId: bankId,
              montant: montantUtilise,
              type: FluxFinancierType.input,
            });
          } else if (flux.type === FluxFinancierType.output) {
            await this.updateBanqueTheoriqueSolde({
              bankId: bankId,
              montant: montantUtilise,
              type: FluxFinancierType.output,
            });
          }
          updateField.status = FluxFinancierStatus.wait;
        }

        if (libelle !== undefined) updateField.libelle = libelle;
        if (clientId !== undefined) {
          await clientModel.isExistClient({ key: clientId });
          updateField.clientId = clientId;
        }
        if (montant !== undefined) updateField.montant = montant;
        if (moyenPayement !== undefined)
          updateField.moyenPayement = moyenPayement;
        if (referenceTransaction !== undefined)
          updateField.referenceTransaction = referenceTransaction;
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
      await session.abort();
      throw new Error("Erreur lors de la mise à jour > " + err.message);
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

      if (flux.status === FluxFinancierStatus.valid) {
        throw new Error(
          "Impossible de supprimer un flux financier déjà validé."
        );
      }

      await session.step(async () => {
        await fluxFinancierCollection.remove(key);
      });

      await session.commit();
      return "OK";
    } catch (err) {
      await session.abort();
      throw new Error(
        "Une erreur s'est produite lors de la suppression : " + err.message
      );
    }
  };

  async updateBanqueTheoriqueSolde({ bankId, type, montant }) {
    const banque = await BanqueModel.getBanque({ key: bankId });

    if (type === FluxFinancierType.output) {
      await BanqueModel.resetBanqueAmount({
        key: banque._id,
        soldeTheorique: banque.soldeTheorique - montant,
      });
    } else {
      await BanqueModel.resetBanqueAmount({
        key: banque._id,
        soldeTheorique: banque.soldeTheorique + montant,
      });
    }
  }

  async updateBanqueReelSolde({ bankId, type, montant }) {
    const banque = await BanqueModel.getBanque({ key: bankId });
    const sommeBanquaire = banque.soldeReel;
    if (type == FluxFinancierType.output) {
      if (sommeBanquaire >= montant) {
        await BanqueModel.resetBanqueAmount({
          key: banque._id,
          soldeReel: banque.soldeReel - montantRestant,
        });
      } else {
        throw new Error(
          "Fonds insuffisants pour couvrir le montant total de cette sortie financière."
        );
      }
    } else {
      await BanqueModel.resetBanqueAmount({
        key: banque._id,
        soldeReel: banque.soldeReel + montant,
      });
    }
  }

  deleteFluxFinancierByFacture = async ({ key }) => {
    try {
      await fluxFinancierCollection.remove(key);
      return "OK";
    } catch (err) {
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
        (flux) => flux.validate != null && flux.validate.validateStatus === true
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
      throw new Error("Erreur lors du calcul du bilan financier" + err.message);
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
      console.log(yearResult);
      return yearResult;
    } catch (err) {
      throw new Error(`Erreur lors de la récupération du bilan` + err.message);
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
      `
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
          currentMonth
        ).padStart(2, "0")}/${lastTwoDigitsYear}`
      : `${String(count + 1).padStart(2, "0")}/DG/SO/${String(
          currentMonth
        ).padStart(2, "0")}/${lastTwoDigitsYear}`;
  };
}

export default FluxFinancier;
export { FluxFinancierType, FluxFinancierStatus, locateFinanceFolder };
