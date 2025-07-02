import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import Personnel from "../../models/habilitation/personnel.js";
import CategoriePaie from "./categorie_paie.js";
import Rubrique from "./rubrique_bulletin.js";

const salarieCollection = db.collection("salaries");

const PersonnelModel = new Personnel();
const CategoriePaieModel = new CategoriePaie();
class Salarie {
  constructor() {}

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
            // const rubrique = await RubriqueModel.getRubriqueBulletin({
            //   key: salarie.rubriqueId,
            // });

            return {
              ...salarie,
              personnel: personnel,
              categoriePaie: categoriePaie,
            };
          })
        );
      } else {
        return [];
      }
    } catch (err) {
      throw new Error("Erreur lors de la récupération des salariés: " + err);
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
      throw new Error(
        "Une erreur s'est produite lors de la récupération du salaire" + err
      );
    }
  };

  createSalarie = async ({
    personnelId,
    categoriePaieId,
    periodPaie,
    paieManner,
  }) => {
    isValidValue({
      value: [personnelId, categoriePaieId, paieManner],
    });
    await PersonnelModel.isExistPersonnel({ key: personnelId });
    await CategoriePaieModel.isExistCategoriePaie({ key: categoriePaieId });
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
      timeStamp: Date.now(),
    };
    try {
      await salarieCollection.save(newSalarie);
      return "OK";
    } catch (err) {
      throw new Error("Erreur lors de la création du salarie : " + err);
    }
  };

  updateSalarie = async ({
    key,
    personnelId,
    categoriePaieId,
    periodPaie,
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

    isValidValue({ value: updateField });
    if (periodPaie !== undefined) {
      updateField.periodPaie = periodPaie;
    }
    try {
      await salarieCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      throw new Error("Erreur lors de la mise à jour du salarie: " + err);
    }
  };

  deleteSalarie = async ({ key }) => {
    try {
      await salarieCollection.remove(key);
      return "OK";
    } catch (err) {
      throw new Error("Erreur lors de la suppression du salarie: " + err);
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
