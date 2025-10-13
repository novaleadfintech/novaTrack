import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const categoriePaieGrilleCollection = db.collection("grilleCategoriePaies");

class CategoriePaieGrille {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await categoriePaieGrilleCollection.exists())) {
      categoriePaieGrilleCollection.create();
    }
  }

  async getAllCategoriePaieGrille({ perPage, skip }) {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const query = await db.query(
      aql`FOR categorie IN ${categoriePaieGrilleCollection} 
          SORT categorie.libelle ASC ${limit} 
          RETURN categorie`,
      { fullCount: true }
    );
    if (query.hasNext) {
      return await query.all();
    } else {
      return [];
    }
  }

  async getCategoriePaieGrille({ key }) {
    try {
      const categorie = await categoriePaieGrilleCollection.document(key);
      return categorie;
    } catch (err) {
      console.error(err);
      throw new Error(`La catégorie de paie est introuvable`);
    }
  }

  async isExistCategoriePaieGrille({ key }) {
    try {
      await categoriePaieGrilleCollection.documentExists(key);
      return true;
    } catch (err) {
      console.error(err);

      throw new Error(`La categorie de paie est introuvable`);
    }
  }

  async createCategoriePaieGrille({ libelle, classes }) {
    console.log(classes);
    console.log(libelle);
    // Validation des données
    isValidValue({ value: libelle });
    isValidValue({ value: classes });

    // Vérification que la catégorie n'existe pas déjà
    const existingCategorie = await db.query(aql`
      FOR categorie IN ${categoriePaieGrilleCollection}
      FILTER categorie.libelle == ${libelle}
      LIMIT 1
      RETURN categorie
    `);
    console.log(existingCategorie);
    if (existingCategorie.hasNext) {
      throw new Error(`Une catégorie de paie avec ce nom existe déjà.`);
    }

    // Création de la catégorie
    const categorie = {
      libelle: libelle,
      classes: classes,
      timeStamp: Date.now(),
    };

    try {
      const result = await categoriePaieGrilleCollection.save(categorie);
      return "OK";
    } catch (error) {
      console.log(
        "---------------------------------------------------------------------"
      );
      console.error(error);

      throw new Error(`Erreur lors de la création de la catégorie de paie`);
    }
  }

  async updateCategoriePaieGrille({ key, categoriePaieGrille }) {
    // Vérification que la catégorie existe
    await this.isExistCategoriePaieGrille({ key });

    const updateField = {};

    if (categoriePaieGrille !== undefined) {
      // Vérification que le nouveau nom n'existe pas déjà
      const existingCategorie = await db.query(aql`
        FOR categorie IN ${categoriePaieGrilleCollection}
        FILTER categorie.categoriePaieGrille == ${categoriePaieGrille}
        AND categorie._key != ${key}
        LIMIT 1
        RETURN categorie
      `);

      if (existingCategorie.hasNext) {
        throw new Error(`Une catégorie de paie avec ce nom existe déjà.`);
      }

      updateField.categoriePaieGrille = categoriePaieGrille;
    }

    if (Object.keys(updateField).length === 0) {
      return "Aucune modification n'a été effectuée";
    }

    // updateField.dateModification = Date.now();

    try {
      await categoriePaieGrilleCollection.update(key, updateField);
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error(
        `Une erreur s'est produite lors de la mise à jour de la catégorie de paie`
      );
    }
  }

  async deleteCategoriePaieGrille({ key }) {
    try {
      await this.isExistCategoriePaieGrille({ key });

      const existingCategorie = await db.query(aql`
        FOR categorieRubrique IN ${categoriePaieGrilleCollection}
        FILTER categorieRubrique._from == ${key}
        LIMIT 1
        RETURN categorieRubrique
      `);

      if (existingCategorie.hasNext) {
        throw new Error(
          `Une catégorie est déjà utiliser, vous ne pourvez donc pas le supprimer.`
        );
      }

      await categoriePaieGrilleCollection.remove(key);
      return "OK";
    } catch (error) {
      console.error(error);

      throw new Error(`Erreur lors de la suppression de la catégorie de paie`);
    }
  }
}

export default CategoriePaieGrille;
