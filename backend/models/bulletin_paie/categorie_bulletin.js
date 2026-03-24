import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const bulletinCategorieCollection = db.collection("bulletinCategories");
const bulletinCategorieRubriqueCollection = db.collection(
  "bulletinCategorieRubriques",
);

class BulletinCategorie {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await bulletinCategorieCollection.exists())) {
      await bulletinCategorieCollection.create();
    }
    if (!(await bulletinCategorieRubriqueCollection.exists())) {
      await bulletinCategorieRubriqueCollection.create();
    }
  }
  async getAllBulletinCategorie({ perPage, skip }) {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const query = await db.query(
      aql`FOR bulletincategorie IN ${bulletinCategorieCollection} 
          SORT bulletincategorie.timeStamp DESC ${limit} 
          RETURN bulletincategorie`,
      { fullCount: true },
    );

    if (query.hasNext) {
      return await query.all();
    } else {
      return [];
    }
  }

  async getBulletinCategorie({ key }) {
    try {
      const bulletincategorie = await bulletinCategorieCollection.document(key);
      return bulletincategorie;
    } catch (err) {
      console.error(err);
      throw new Error(`La catégorie de bulletin est introuvable`);
    }
  }

  async isExistBulletinCategorie({ key }) {
    try {
      await bulletinCategorieCollection.documentExists(key);
      return true;
    } catch (err) {
      console.error(err);
      throw new Error(`La bulletincategorie de bulletin est introuvable`);
    }
  }

  async createBulletinCategorie({ bulletinCategorie, paieClause }) {
    // Validation des données
    isValidValue({ value: [bulletinCategorie] });

    // Vérification que la catégorie n'existe pas déjà
    const existingCategorie = await db.query(aql`
      FOR bulletincategorie IN ${bulletinCategorieCollection}
      FILTER bulletincategorie.bulletinCategorie == ${bulletinCategorie}
      LIMIT 1
      RETURN bulletincategorie
    `);

    if (existingCategorie.hasNext) {
      throw new Error(`Une catégorie de bulletin avec ce nom existe déjà.`);
    }

    // Création de la catégorie
    const bulletincategorie = {
      bulletinCategorie,
      paieClause,
      timeStamp: Date.now(),
    };

    try {
      const result = await bulletinCategorieCollection.save(bulletincategorie);
      return "OK";
    } catch (error) {
      console.error(error);

      throw new Error(`Erreur lors de la création de la catégorie de bulletin`);
    }
  }

  async updateBulletinCategorie({ key, bulletinCategorie, paieClause }) {
    // Vérification que la catégorie existe
    await this.isExistBulletinCategorie({ key });

    const updateField = {};

    if (bulletinCategorie !== undefined) {
      // Vérification que le nouveau nom n'existe pas déjà
      const existingCategorie = await db.query(aql`
        FOR bulletincategorie IN ${bulletinCategorieCollection}
        FILTER bulletincategorie.bulletinCategorie == ${bulletinCategorie}
        AND bulletincategorie._keyy != ${key}
        LIMIT 1
        RETURN bulletincategorie
      `);
 
      if (existingCategorie.hasNext) {
        throw new Error(`Une catégorie de bulletin avec ce nom existe déjà.`);
      }

      updateField.bulletinCategorie = bulletinCategorie;
    }

    if (paieClause !== undefined) {
      updateField.paieClause = paieClause;
    }

    if (Object.keys(updateField).length === 0) {
      return "Aucune modification n'a été effectuée";
    }

    // updateField.dateModification = Date.now();

    try {
      await bulletinCategorieCollection.update(key, updateField);
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error(
        `Une erreur s'est produite lors de la mise à jour de la catégorie de bulletin`,
      );
    }
  }

  async deleteBulletinCategorie({ key }) {
    try {
      await this.isExistBulletinCategorie({ key });

      const existingCategorie = await db.query(aql`
        FOR bulletinCategorieRubrique IN ${bulletinCategorieRubriqueCollection}
        FILTER bulletinCategorieRubrique.rubriqueKey == ${key}
        LIMIT 1
        RETURN bulletinCategorieRubrique
      `);

      if (existingCategorie.hasNext) {
        throw new Error(
          `Une catégorie est déjà utiliser, vous ne pourvez donc pas le supprimer.`,
        );
      }

      await bulletinCategorieCollection.remove(key);
      return "OK";
    } catch (error) {
      console.error(error);

      throw new Error(
        `Erreur lors de la suppression de la catégorie de bulletin`,
      );
    }
  }
}

export default BulletinCategorie;
