import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import Personnel from "../../models/habilitation/personnel.js";
import BulletinCategorie from "./categorie_bulletin.js";
import paieCategorieGrille from "./../grille_salariale/categoriePaieGrille.js";
import Classe from "./../grille_salariale/classe.js";
import Echelon from "./../grille_salariale/echelon.js";

const salarieCollection = db.collection("salaries");

const PersonnelModel = new Personnel();
const BulletinCategorieModel = new BulletinCategorie();
const paieCategorieGrilleModel = new paieCategorieGrille();
const ClasseModel = new Classe();
const EchelonModel = new Echelon();

// const RubriqueModel = new Rubrique();

class Salarie {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await salarieCollection.exists())) {
      await salarieCollection.create();
    }
  }

  getAllSalarie = async ({ skip, perPage }) => {
    let limit = aql``;
    if (perPage !== undefined && skip !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    try {
      const query = await db.query(
        aql`
            FOR salarie IN ${salarieCollection}
            SORT salarie.timeStamp DESC
            ${limit}
            RETURN salarie
          `,
      );
      if (query.hasNext) {
        const salaries = await query.all();
        const result = await Promise.all(
          salaries.map(async (salarie) => {
            try {
              const personnel = await PersonnelModel.getPersonnel({
                key: salarie.personnelKey,
              });
              const bulletinCategorie =
                await BulletinCategorieModel.getBulletinCategorie({
                  key: salarie.bulletinCategorieKey,
                });
              const grillepaieCategorie =
                await paieCategorieGrilleModel.getpaieCategorieGrille({
                  key: salarie.grillepaieCategorieKey,
                });
              let classe;
              let echelon;
              if (grillepaieCategorie != null) {
                if (grillepaieCategorie.classes) {
                  console.log(grillepaieCategorie.classes);
                  classe = grillepaieCategorie.classes.find(
                    (c) => c && c._key == salarie.classeKey,
                  );
                }
                if (classe && Array.isArray(classe.echelonIndiciciaires)) {
                  echelon = classe.echelonIndiciciaires.find(
                    (e) =>
                      e && e.echelon && e.echelon._key === salarie.echelonKey,
                  )?.echelon;
                }
              }
              return {
                ...salarie,
                personnel: personnel ?? null,
                bulletinCategorie: bulletinCategorie ?? null,
                grillepaieCategorie: grillepaieCategorie ?? null,
                classe: classe ?? null,
                echelon: echelon ?? null,
              };
            } catch (innerError) {
              console.error(
                `Erreur lors de l'enrichissement du salarié ${salarie._key}:`,
                innerError,
              );
              return null;
            }
          }),
        );
        return result.filter((r) => r !== null);
      } else {
        return [];
      }
    } catch (err) {
      console.error(err);
      throw new Error("Erreur lors de la récupération des salariés");
    }
  };

  getAllActiveSalarieByPeriod = async ({
    skip,
    perPage,
    dateDebut,
    dateFin,
  }) => {
    try {
      let limit = aql``;
      if (perPage !== undefined && skip !== undefined) {
        limit = aql`LIMIT ${skip}, ${perPage}`;
      }

      // 🔹 Récupération des salariés actifs
      const query = await db.query(aql`
      FOR salarie IN ${salarieCollection}
         SORT salarie.timeStamp DESC
        ${limit}
        RETURN salarie
    `);

      if (!query.hasNext) {
        return [];
      }

      const salaries = await query.all();

      const result = await Promise.all(
        salaries.map(async (salarie) => {
          try {
            const personnel = await PersonnelModel.getPersonnel({
              key: salarie.personnelKey,
            });
            if (dateDebut && dateFin && personnel) {
              const debut =
                personnel.dateDebut +
                (personnel.dureeEssai ?? 0) * 24 * 60 * 60 * 1000;
              const fin = personnel.dateFin;

              // Vérifier s'il y a un chevauchement entre la période demandée et le contrat
              // Il y a chevauchement SI :
              // - Le contrat commence avant la fin de la période ET
              // - Le contrat se termine après le début de la période (ou n'a pas de fin)

              if (fin != null) {
                // Si le contrat a une date de fin
                if (debut > dateFin || fin < dateDebut) {
                  // Pas de chevauchement
                  return null;
                }
              } else {
                // Si le contrat n'a pas de date de fin (contrat en cours)
                if (debut > dateFin) {
                  // Le contrat commence après la période demandée
                  return null;
                }
              }
            }

            const bulletinCategorie =
              await BulletinCategorieModel.getBulletinCategorie({
                key: salarie.bulletinCategorieKey,
              });
            let grillepaieCategorie;
            if (salarie.grillepaieCategorieKey) {
              grillepaieCategorie =
                await paieCategorieGrilleModel.getpaieCategorieGrille({
                  key: salarie.grillepaieCategorieKey,
                });
            }

            let classe = null;
            let echelon = null;

            if (
              grillepaieCategorie &&
              Array.isArray(grillepaieCategorie.classes)
            ) {
              classe = grillepaieCategorie.classes.find(
                (c) => c && c._key === salarie.classeKey,
              );

              if (classe && Array.isArray(classe.echelonIndiciciaires)) {
                const foundEchelon = classe.echelonIndiciciaires.find(
                  (e) =>
                    e && e.echelon && e.echelon._key === salarie.echelonKey,
                );
                echelon = foundEchelon ? foundEchelon.echelon : null;
              }
            }

            return {
              ...salarie,
              personnel: personnel ?? null,
              bulletinCategorie: bulletinCategorie ?? null,
              grillepaieCategorie: grillepaieCategorie ?? null,
              classe: classe ?? null,
              echelon: echelon ?? null,
            };
          } catch (innerError) {
            console.error(
              `Erreur lors de l'enrichissement du salarié ${salarie._key}:`,
              innerError,
            );
            return null;
          }
        }),
      );

      return result.filter((r) => r !== null);
    } catch (err) {
      console.error("Erreur lors de la récupération des salariés:", err);
      throw new Error(
        "Une erreur est survenue lors du chargement des salariés actifs.",
      );
    }
  };

  getSalarie = async ({ key }) => {
    try {
      const salarie = await salarieCollection.document(key);
      const personnel = await PersonnelModel.getPersonnel({
        key: salarie.personnelKey,
      });
      const bulletinCategorie =
        await BulletinCategorieModel.getBulletinCategorie({
          key: salarie.bulletinCategorieKey,
        });
      let grillepaieCategorie;
      if (salarie.grillepaieCategorieKey) {
        grillepaieCategorie =
          await paieCategorieGrilleModel.getpaieCategorieGrille({
            key: salarie.grillepaieCategorieKey,
          });
      }

      let classe = null;
      let echelon = null;

      if (grillepaieCategorie && Array.isArray(grillepaieCategorie.classes)) {
        classe = grillepaieCategorie.classes.find(
          (c) => c && c._key === salarie.classeKey,
        );

        if (classe && Array.isArray(classe.echelonIndiciciaires)) {
          const foundEchelon = classe.echelonIndiciciaires.find(
            (e) => e && e.echelon && e.echelon._key === salarie.echelonKey,
          );
          echelon = foundEchelon ? foundEchelon.echelon : null;
        }
      }

      return {
        ...salarie,
        personnel: personnel ?? null,
        bulletinCategorie: bulletinCategorie ?? null,
        grillepaieCategorie: grillepaieCategorie ?? null,
        classe: classe ?? null,
        echelon: echelon ?? null,
      };
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de la récupération du salaire",
      );
    }
  };

  createSalarie = async ({
    personnelKey,
    bulletinCategorieKey,
    periodPaie,
    paieClause,
    numeroMatricule,
    numeroCompte,
    operateur,
    classeKey,
    echelonKey,
    moyenPaiement,
    grillepaieCategorieKey,
  }) => {
    isValkeyValue({
      value: [
        personnelKey,
        bulletinCategorieKey,
        paieClause,
        moyenPaiement,
        classeKey,
        numeroMatricule,
        operateur,
        echelonKey,
        grillepaieCategorieKey,
      ],
    });

    await PersonnelModel.isExistPersonnel({ key: personnelKey });
    await BulletinCategorieModel.isExistBulletinCategorie({
      key: bulletinCategorieKey,
    });
    await paieCategorieGrilleModel.isExistpaieCategorieGrille({
      key: grillepaieCategorieKey,
    });
    await ClasseModel.isExistClasse({ key: classeKey });
    await EchelonModel.isExistEchelon({ key: echelonKey });
    const query = await db.query(
      aql`
          FOR salarie IN ${salarieCollection}
          FILTER salarie.personnelKey == ${personnelKey}
          RETURN salarie
        `,
    );
    if (query.hasNext) {
      throw new Error("Le salarie existe déjà pour ce personnel");
    }
    const newSalarie = {
      personnelKey: personnelKey,
      bulletinCategorieKey: bulletinCategorieKey,
      dateEnregistrement: Date.now(),
      paieClause: paieClause,
      periodPaie: periodPaie,
      classeKey: classeKey,
      moyenPaiement: moyenPaiement,
      numeroMatricule: numeroMatricule,
      numeroCompte: numeroCompte,
      operateur: operateur,
      echelonKey: echelonKey,
      grillepaieCategorieKey: grillepaieCategorieKey,
      timeStamp: Date.now(),
    };
    try {
      await salarieCollection.save(newSalarie);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la création du salarie");
    }
  };

  updateSalarie = async ({
    key,
    personnelKey,
    bulletinCategorieKey,
    periodPaie,
    moyenPaiement,
    paieClause,
    numeroCompte,
    operateur,
    classeKey,
    echelonKey,
    grillepaieCategorieKey,
    numeroMatricule,
  }) => {
    const updateField = {};
    if (personnelKey !== undefined) {
      await PersonnelModel.isExistPersonnel({ key: personnelKey });
      updateField.personnelKey = personnelKey;
    }

    if (bulletinCategorieKey !== undefined) {
      await BulletinCategorieModel.isExistBulletinCategorie({
        key: bulletinCategorieKey,
      });
      updateField.bulletinCategorieKey = bulletinCategorieKey;
    }

    if (paieClause !== undefined) {
      updateField.paieClause = paieClause;
    }

    if (moyenPaiement !== undefined) {
      updateField.moyenPaiement = moyenPaiement;
    }
    if (numeroCompte !== undefined) {
      updateField.numeroCompte = numeroCompte;
    }
    if (operateur !== undefined) {
      updateField.operateur = operateur;
    }
    if (classeKey !== undefined) {
      await ClasseModel.isExistClasse({ key: classeKey });
      updateField.classeKey = classeKey;
    }
    if (echelonKey !== undefined) {
      await EchelonModel.isExistEchelon({ key: echelonKey });
      updateField.echelonKey = echelonKey;
    }
    if (grillepaieCategorieKey !== undefined) {
      await paieCategorieGrilleModel.isExistpaieCategorieGrille({
        key: grillepaieCategorieKey,
      });
      updateField.grillepaieCategorieKey = grillepaieCategorieKey;
    }

    if (numeroMatricule !== undefined) {
      updateField.numeroMatricule = numeroMatricule;
    }

    isValidValue({ value: updateField });
    if (periodPaie !== undefined) {
      updateField.periodPaie = periodPaie;
    }
    try {
      await salarieCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      console.error(err);
      throw new Error("Erreur lors de la mise à jour du salarie");
    }
  };

  deleteSalarie = async ({ key }) => {
    try {
      await salarieCollection.remove(key);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la suppression du salarie");
    }
  };

  isExistSalarie = async ({ key }) => {
    const exist = await salarieCollection.documentExists(key);
    if (!exist) {
      throw new Error("Ce salrié est inexistante!");
    }
  };
}

export default Salarie;
