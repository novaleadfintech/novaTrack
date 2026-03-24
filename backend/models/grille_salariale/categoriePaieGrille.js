import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const paieCategorieGrilleCollection = db.collection("grillepaieCategories");

class paieCategorieGrille {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await paieCategorieGrilleCollection.exists())) {
      await paieCategorieGrilleCollection.create();
    }
  }

  async getAllpaieCategorieGrille({ perPage, skip }) {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const query = await db.query(
      aql`FOR paieCategorie IN ${paieCategorieGrilleCollection} 
          SORT paieCategorie.libelle ASC ${limit} 
          RETURN paieCategorie`,
      { fullCount: true },
    );
    if (query.hasNext) {
      return await query.all();
    } else {
      return [];
    }
  }

  async getpaieCategorieGrille({ key }) {
    try {
      const paieCategorie = await paieCategorieGrilleCollection.document(key);
      return paieCategorie;
    } catch (err) {
      console.error(err);
      return null;
      // throw new Error(`La catégorie de paie est introuvable`);
    }
  }

  async isExistpaieCategorieGrille({ key }) {
    try {
      await paieCategorieGrilleCollection.documentExists(key);
      return true;
    } catch (err) {
      console.error(err);

      throw new Error(`La categorie de paie est introuvable`);
    }
  }

  async createpaieCategorieGrille({ libelle, classes }) {
    // Validation des données
    isValidValue({ value: libelle });
    isValidValue({ value: classes });

    // Vérification que la catégorie n'existe pas déjà
    const existingCategorie = await db.query(aql`
      FOR paieCategorie IN ${paieCategorieGrilleCollection}
      FILTER paieCategorie.libelle == ${libelle}
      LIMIT 1
      RETURN paieCategorie
    `);
    if (existingCategorie.hasNext) {
      throw new Error(`Une catégorie de paie avec ce nom existe déjà.`);
    }

    // Création de la catégorie
    const paieCategorie = {
      libelle: libelle,
      classes: classes,
      timeStamp: Date.now(),
    };

    try {
      await paieCategorieGrilleCollection.save(paieCategorie);
      return "OK";
    } catch (error) {
      console.log(
        "---------------------------------------------------------------------",
      );
      console.error(error);

      throw new Error(`Erreur lors de la création de la catégorie de paie`);
    }
  }

  async updatepaieCategorieGrille({ key, paieCategorieGrille }) {
    // Vérification que la catégorie existe
    await this.isExistpaieCategorieGrille({ key });

    const updateField = {};

    if (paieCategorieGrille !== undefined) {
      // Vérification que le nouveau nom n'existe pas déjà
      const existingCategorie = await db.query(aql`
        FOR paieCategorie IN ${paieCategorieGrilleCollection}
        FILTER paieCategorie.paieCategorieGrille == ${paieCategorieGrille}
        AND paieCategorie._key != ${key}
        LIMIT 1
        RETURN paieCategorie
      `);

      if (existingCategorie.hasNext) {
        throw new Error(`Une catégorie de paie avec ce nom existe déjà.`);
      }

      updateField.paieCategorieGrille = paieCategorieGrille;
    }

    if (Object.keys(updateField).length === 0) {
      return "Aucune modification n'a été effectuée";
    }

    // updateField.dateModification = Date.now();

    try {
      await paieCategorieGrilleCollection.update(key, updateField);
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error(
        `Une erreur s'est produite lors de la mise à jour de la catégorie de paie`,
      );
    }
  }

  async deletepaieCategorieGrille({ key }) {
    try {
      await this.isExistpaieCategorieGrille({ key });

      const existingCategorie = await db.query(aql`
        FOR bulletinCategorieRubrique IN ${paieCategorieGrilleCollection}
        FILTER bulletinCategorieRubrique.serviceKey == ${key}
        LIMIT 1
        RETURN bulletinCategorieRubrique
      `);

      if (existingCategorie.hasNext) {
        throw new Error(
          `Une catégorie est déjà utiliser, vous ne pourvez donc pas le supprimer.`,
        );
      }

      await paieCategorieGrilleCollection.remove(key);
      return "OK";
    } catch (error) {
      console.error(error);

      throw new Error(`Erreur lors de la suppression de la catégorie de paie`);
    }
  }
}

export default paieCategorieGrille;
