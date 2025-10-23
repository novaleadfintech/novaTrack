import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import Personnel from "../../models/habilitation/personnel.js";
import CategoriePaie from "./categorie_paie.js";
import CategoriePaieGrille from "./../grille_salariale/categoriePaieGrille.js";
import Rubrique from "./rubrique_bulletin.js";
import Classe from "./../grille_salariale/classe.js";
import Echelon from "./../grille_salariale/echelon.js";
import GrilleCategoriePaie from "./../grille_salariale/categoriePaieGrille.js";

const salarieCollection = db.collection("salaries");

const PersonnelModel = new Personnel();
const CategoriePaieModel = new CategoriePaie();
const CategoriePaieGrilleModel = new CategoriePaieGrille();
const ClasseModel = new Classe();
const EchelonModel = new Echelon();

// const RubriqueModel = new Rubrique();

class Salarie {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await salarieCollection.exists())) {
      salarieCollection.create();
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
        `
      );
      if (query.hasNext) {
        const salaries = await query.all();
        return Promise.all(
          salaries.map(async (salarie) => {
            const personnel = await PersonnelModel.getPersonnel({
              key: salarie.personnelId,
            });
            const categoriePaie = await CategoriePaieModel.getCategoriePaie({
              key: salarie.categoriePaieId,
            });
            const grilleCategoriePaie =
              await CategoriePaieGrilleModel.getCategoriePaieGrille({
                key: salarie.grilleCategoriePaieId,
              });
            let classe;
            let echelon;
            if (grilleCategoriePaie != null) {
              if (grilleCategoriePaie.classes) {
                console.log(grilleCategoriePaie.classes);
                classe = grilleCategoriePaie.classes.find(
                  (c) => c && c._id == salarie.classeId
                );
              }
              if (classe && Array.isArray(classe.echelonIndiciciaires)) {
                echelon = classe.echelonIndiciciaires.find(
                  (e) => e && e.echelon && e.echelon._id === salarie.echelonId
                )?.echelon;
              }
            }
            console.log(echelon);
            // const RubriqueModel = new Rubrique();
            // const rubrique = await RubriqueModel.getRubriqueBulletin({
            //   key: salarie.rubriqueId,
            // });
            return {
              ...salarie,
              personnel: personnel,
              categoriePaie: categoriePaie,
              grilleCategoriePaie: grilleCategoriePaie,
              classe: classe,
              echelon: echelon,
            };
          })
        );
      } else {
        return [];
      }
    } catch (err) {
      console.error(err);
      throw new Error("Erreur lors de la récupération des salariés: ");
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
              key: salarie.personnelId,
            });
            if (dateDebut && dateFin && personnel) {
              const debut = personnel.dateDebut;
              const fin = personnel.dateFin;
              if (fin != null) {
                if (debut > dateDebut || fin < dateFin) {
                  return null;
                }
              }
            }

            const categoriePaie = await CategoriePaieModel.getCategoriePaie({
              key: salarie.categoriePaieId,
            });

            const grilleCategoriePaie =
              await CategoriePaieGrilleModel.getCategoriePaieGrille({
                key: salarie.grilleCategoriePaieId,
              });

            let classe = null;
            let echelon = null;

            if (
              grilleCategoriePaie &&
              Array.isArray(grilleCategoriePaie.classes)
            ) {
              classe = grilleCategoriePaie.classes.find(
                (c) => c && c._id === salarie.classeId
              );

              if (classe && Array.isArray(classe.echelonIndiciciaires)) {
                const foundEchelon = classe.echelonIndiciciaires.find(
                  (e) => e && e.echelon && e.echelon._id === salarie.echelonId
                );
                echelon = foundEchelon ? foundEchelon.echelon : null;
              }
            }

            return {
              ...salarie,
              personnel: personnel ?? null,
              categoriePaie: categoriePaie ?? null,
              grilleCategoriePaie: grilleCategoriePaie ?? null,
              classe: classe ?? null,
              echelon: echelon ?? null,
            };
          } catch (innerError) {
            console.error(
              `Erreur lors de l'enrichissement du salarié ${salarie._key}:`,
              innerError
            );
            return null;
          }
        })
      );

      return result.filter((r) => r !== null);
    } catch (err) {
      console.error("Erreur lors de la récupération des salariés:", err);
      throw new Error(
        "Une erreur est survenue lors du chargement des salariés actifs."
      );
    }
  };

  getSalarie = async ({ key }) => {
    try {
      const salarie = await salarieCollection.document(key);
      const personnel = await PersonnelModel.getPersonnel({
        key: salarie.personnelId,
      });
      const categoriePaie = await CategoriePaieModel.getCategoriePaie({
        key: salarie.categoriePaieId,
      });
      return {
        ...salarie,
        personnel: personnel,
        categoriePaie: categoriePaie,
      };
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de la récupération du salaire"
      );
    }
  };

  createSalarie = async ({
    personnelId,
    categoriePaieId,
    periodPaie,
    paieManner,
    numeroMatricule,
    numeroCompte,
    paiementPlace,
    classeId,
    echelonId,
    moyenPaiement,
    grilleCategoriePaieId,
  }) => {
    isValidValue({
      value: [
        personnelId,
        categoriePaieId,
        paieManner,
        moyenPaiement,
        classeId,
        numeroMatricule,
        paiementPlace,
        echelonId,
        grilleCategoriePaieId,
      ],
    });

    await PersonnelModel.isExistPersonnel({ key: personnelId });
    await CategoriePaieModel.isExistCategoriePaie({ key: categoriePaieId });
    await CategoriePaieGrilleModel.isExistCategoriePaieGrille({
      key: grilleCategoriePaieId,
    });
    await ClasseModel.isExistClasse({ key: classeId });
    await EchelonModel.isExistEchelon({ key: echelonId });
    const query = await db.query(
      aql`
          FOR salarie IN ${salarieCollection}
          FILTER salarie.personnelId == ${personnelId}
          RETURN salarie
        `
    );
    if (query.hasNext) {
      throw new Error("Le salarie existe déjà pour ce personnel");
    }
    const newSalarie = {
      personnelId: personnelId,
      categoriePaieId: categoriePaieId,
      dateEnregistrement: Date.now(),
      paieManner: paieManner,
      periodPaie: periodPaie,
      classeId: classeId,
      moyenPaiement: moyenPaiement,
      numeroMatricule: numeroMatricule,
      numeroCompte: numeroCompte,
      paiementPlace: paiementPlace,
      echelonId: echelonId,
      grilleCategoriePaieId: grilleCategoriePaieId,
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
    personnelId,
    categoriePaieId,
    periodPaie,
    moyenPaiement,
    paieManner,
  }) => {
    const updateField = {};
    if (personnelId !== undefined) {
      await PersonnelModel.isExistPersonnel({ key: personnelId });
      updateField.personnelId = personnelId;
    }

    if (categoriePaieId !== undefined) {
      await CategoriePaieModel.isExistCategoriePaie({ key: categoriePaieId });
      updateField.categoriePaieId = categoriePaieId;
    }

    if (paieManner !== undefined) {
      updateField.paieManner = paieManner;
    }

    if (moyenPaiement !== undefined) {
      updateField.moyenPaiement = moyenPaiement;
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
