import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const categoriePaieCollection = db.collection("categoriePaies");
const categoriePaieRubriqueCollection = db.collection("categoriePaieRubriques");

class CategoriePaie {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await categoriePaieCollection.exists())) {
      categoriePaieCollection.create();
    }
    if (!(await categoriePaieRubriqueCollection.exists())) {
      categoriePaieRubriqueCollection.create();
    }
  }
  async getAllCategoriePaie({ perPage, skip }) {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const query = await db.query(
      aql`FOR categorie IN ${categoriePaieCollection} 
          SORT categorie.timeStamp DESC ${limit} 
          RETURN categorie`,
      { fullCount: true }
    );

    if (query.hasNext) {
      return await query.all();
    } else {
      return [];
    }
  }

  async getCategoriePaie({ key }) {
    try {
      const categorie = await categoriePaieCollection.document(key);
      return categorie;
    } catch (err) {
      throw new Error(`La catégorie de paie est introuvable`);
    }
  }

  async isExistCategoriePaie({ key }) {
    try {
      await categoriePaieCollection.documentExists(key);
      return true;
    } catch (err) {
      throw new Error(`La categorie de paie est introuvable`);
    }
  }

  async createCategoriePaie({ categoriePaie }) {
    // Validation des données
    isValidValue({ value: [categoriePaie] });

    // Vérification que la catégorie n'existe pas déjà
    const existingCategorie = await db.query(aql`
      FOR categorie IN ${categoriePaieCollection}
      FILTER categorie.categoriePaie == ${categoriePaie}
      LIMIT 1
      RETURN categorie
    `);

    if (existingCategorie.hasNext) {
      throw new Error(`Une catégorie de paie avec ce nom existe déjà.`);
    }

    // Création de la catégorie
    const categorie = {
      categoriePaie,
      timeStamp: Date.now(),
    };

    try {
      const result = await categoriePaieCollection.save(categorie);
      return "OK";
    } catch (error) {
      throw new Error(
        `Erreur lors de la création de la catégorie de paie : ${error}`
      );
    }
  }

  async updateCategoriePaie({ key, categoriePaie }) {
    // Vérification que la catégorie existe
    await this.isExistCategoriePaie({ key });

    const updateField = {};

    if (categoriePaie !== undefined) {
      // Vérification que le nouveau nom n'existe pas déjà
      const existingCategorie = await db.query(aql`
        FOR categorie IN ${categoriePaieCollection}
        FILTER categorie.categoriePaie == ${categoriePaie}
        AND categorie._key != ${key}
        LIMIT 1
        RETURN categorie
      `);

      if (existingCategorie.hasNext) {
        throw new Error(`Une catégorie de paie avec ce nom existe déjà.`);
      }

      updateField.categoriePaie = categoriePaie;
    }

    if (Object.keys(updateField).length === 0) {
      return "Aucune modification n'a été effectuée";
    }

    // updateField.dateModification = Date.now();

    try {
      await categoriePaieCollection.update(key, updateField);
      return "OK";
    } catch (e) {
      throw new Error(
        `Une erreur s'est produite lors de la mise à jour de la catégorie de paie : ${e}`
      );
    }
  }

  async deleteCategoriePaie({ key }) {
    try {
      await this.isExistCategoriePaie({ key });

      const existingCategorie = await db.query(aql`
        FOR categorieRubrique IN ${categoriePaieRubriqueCollection}
        FILTER categorieRubrique._from == ${key}
        LIMIT 1
        RETURN categorieRubrique
      `);

      if (existingCategorie.hasNext) {
        throw new Error(
          `Une catégorie est déjà utiliser, vous ne pourvez donc pas le supprimer.`
        );
      }

      await categoriePaieCollection.remove(key);
      return "OK";
    } catch (error) {
      throw new Error(
        `Erreur lors de la suppression de la catégorie de paie : ${error}`
      );
    }
  }
}

export default CategoriePaie;
