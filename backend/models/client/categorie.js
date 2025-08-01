import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const categorieCollection = db.collection("categories");

class Categorie {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await categorieCollection.exists())) {
      categorieCollection.create();
    }
  }

  getCategories = async ({ skip, perPage }) => {
    let limit = aql``;
    if (perPage != undefined && skip != undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    try {
      const query = await db.query(
        aql`FOR categorie IN ${categorieCollection} SORT categorie.libelle ASC ${limit} RETURN categorie`
      );
      if (query.hasNext) {
        return await query.all();
      } else {
        return [];
      }
    } catch (err) {
      throw new Error("Erreur lors de la récupération");
    }
  };

  getCategorie = async ({ key }) => {
    try {
      return await categorieCollection.document(key);
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la récupération du catégorie"
      );
    }
  };

  createCategorie = async ({ libelle }) => {
    isValidValue({ value: libelle });
    const newCategorie = { libelle: libelle };
    try {
      await categorieCollection.save(newCategorie);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de l'a création de cette catégorie'"
      );
    }
  };

  updateCategorie = async ({ key, libelle }) => {
    isValidValue({ value: libelle });
    const updateField = { libelle: libelle };
    try {
      await categorieCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la mise à jour de cette catégorie"
      );
    }
  };

  deleteCateforie = async ({ key }) => {
    try {
      await categorieCollection.remove(key);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la suppression de cette catégorie"
      );
    }
  };

  isExistCategorie = async ({ key }) => {
    const exist = await categorieCollection.documentExists(key);
    if (!exist) {
      throw new Error("Cette catégorie est inexistante!");
    }
  };
}

export default Categorie;
