import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import RubriqueBulletin from "./rubrique_bulletin.js";
import CategoriePaie from "./categorie_paie.js";
const rubriqueCategorieCollection = db.collection("categoriePaieRubriques");

const rubriqueBulletin = new RubriqueBulletin();
const categoriePaieModel = new CategoriePaie();

class RubriqueCategorie {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await rubriqueCategorieCollection.exists())) {
      rubriqueCategorieCollection.create({
        type: CollectionType.EDGE_COLLECTION,
      });
    }
  }

  getRubriqueBulletinByCategoriePaie = async ({ categoriePaieId }) => {
    try {
      const rubriqueCategorieEdges = await rubriqueCategorieCollection.edges(
        categoriePaieId
      );
      const rubriqueConfiforCategorie = rubriqueCategorieEdges.edges;

      // Attendre la récupération des rubriques
      const result = await Promise.all(
        rubriqueConfiforCategorie.map(async (rubriqueCategorie) => {
          const rubrique = await rubriqueBulletin.getRubriqueBulletin({
            key: rubriqueCategorie._from,
          });

          return {
            ...rubriqueCategorie,
            rubrique: rubrique,
          };
        })
      );

      // Trier les résultats par timeStamp croissant
      result.sort((a, b) => {
        const tA = a.rubrique?.timeStamp ?? 0;
        const tB = b.rubrique?.timeStamp ?? 0;
        return tA - tB;
      });
      console.log(result);
      return result;
    } catch (e) {
      console.log(e);
      throw new Error(e);
    }
  };

  getRubriqueBulletinByCategoriePaieForConfiguration = async ({
    categoriePaieId,
  }) => {
    try {
      const rubriqueCategorieEdges = await rubriqueCategorieCollection.edges(
        categoriePaieId
      );

      const rubriqueConfiforCategorie = rubriqueCategorieEdges.edges;
      const allRubriques = await rubriqueBulletin.getAllRubriqueBulletin();

      const result = allRubriques.map((rubrique) => {
        const config = rubriqueConfiforCategorie.find(
          (conf) => conf._from === rubrique._id
        );
        return {
          rubriqueCategorie: {
            rubrique,
            value: config ? config.value : null,
          },
          isChecked: !!config,
        };
      });

      // Trier par timeStamp croissant
      result.sort((a, b) => {
        const tA = a.rubriqueCategorie.rubrique?.timeStamp ?? 0;
        const tB = b.rubriqueCategorie.rubrique?.timeStamp ?? 0;
        return tA - tB;
      });
      return result;
    } catch (e) {
      throw new Error(e);
    }
  };

  createRubriqueCategorie = async ({ rubriqueId, categorieId, value }) => {
    isValidValue({ value: [rubriqueId, categorieId] });
    try {
      await rubriqueBulletin.isExistRubriqueBulletin({ key: rubriqueId });
      await categoriePaieModel.isExistCategoriePaie({ key: categorieId });

      if (
        !!!(await this.getRubriqueCategorieByLink({
          categorieId: categorieId,
          rubriqueId: rubriqueId,
        }))
      ) {
        const newRubriqueCategrie = {
          _from: rubriqueId,
          _to: categorieId,
          value: value,
        };
        await rubriqueCategorieCollection.save(newRubriqueCategrie);
      }
      return "OK";
    } catch (e) {
      throw new Error(e);
    }
  };

  getRubriqueCategorieByLink = async ({ rubriqueId, categorieId }) => {
    const query = await db.query(aql`
      FOR doc IN ${rubriqueCategorieCollection}
        FILTER doc._from == ${rubriqueId} AND doc._to == ${categorieId}
        LIMIT 1
        RETURN doc
    `);

    if (query.hasNext) {
      return await query.next();
    }
  };

  updateRubriqueCategorie = async ({ rubriqueId, categorieId, value }) => {
    try {
      const data = await this.getRubriqueCategorieByLink({
        categorieId: categorieId,
        rubriqueId: rubriqueId,
      });
      if (data) {
        await rubriqueCategorieCollection.update(data._id, { value: value });
      }
      return "OK";
    } catch (e) {
      throw new Error(e);
    }
  };

  deleteRubriqueCategorie = async ({ rubriqueId, categorieId }) => {
    try {
      const data = await this.getRubriqueCategorieByLink({
        categorieId: categorieId,
        rubriqueId: rubriqueId,
      });
      if (!!data) {
        await rubriqueCategorieCollection.remove(data._id);
      }
      return "OK";
    } catch (e) {
      throw new Error(e);
    }
  };
}

export default RubriqueCategorie;
