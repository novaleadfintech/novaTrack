import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const categorieBulletinCollection = db.collection("categorieBulletins");
const categorieBulletinRubriqueCollection = db.collection(
  "categorieBulletinRubriques",
);

class CategorieBulletin {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await categorieBulletinCollection.exists())) {
    await  categorieBulletinCollection.create();
    }
    if (!(await categorieBulletinRubriqueCollection.exists())) {
     await categorieBulletinRubriqueCollection.create();
    }
  }
  async getAllCategorieBulletin({ perPage, skip }) {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const query = await db.query(
      aql`FOR categorie IN ${categorieBulletinCollection} 
          SORT categorie.timeStamp DESC ${limit} 
          RETURN categorie`,
      { fullCount: true },
    );

    if (query.hasNext) {
      return await query.all();
    } else {
      return [];
    }
  }

  async getCategorieBulletin({ key }) {
    try {
      const categorie = await categorieBulletinCollection.document(key);
      return categorie;
    } catch (err) {
      console.error(err);
      throw new Error(`La catégorie de bulletin est introuvable`);
    }
  }

  async isExistCategorieBulletin({ key }) {
    try {
      await categorieBulletinCollection.documentExists(key);
      return true;
    } catch (err) {
      console.error(err);
      throw new Error(`La categorie de bulletin est introuvable`);
    }
  }

  async createCategorieBulletin({ categorieBulletin, paieClause }) {
    // Validation des données
    isValidValue({ value: [categorieBulletin] });

    // Vérification que la catégorie n'existe pas déjà
    const existingCategorie = await db.query(aql`
      FOR categorie IN ${categorieBulletinCollection}
      FILTER categorie.categorieBulletin == ${categorieBulletin}
      LIMIT 1
      RETURN categorie
    `);

    if (existingCategorie.hasNext) {
      throw new Error(`Une catégorie de bulletin avec ce nom existe déjà.`);
    }

    // Création de la catégorie
    const categorie = {
      categorieBulletin,
      paieClause,
      timeStamp: Date.now(),
    };

    try {
      const result = await categorieBulletinCollection.save(categorie);
      return "OK";
    } catch (error) {
      console.error(error);

      throw new Error(`Erreur lors de la création de la catégorie de bulletin`);
    }
  }

  async updateCategorieBulletin({ key, categorieBulletin, paieClause }) {
    // Vérification que la catégorie existe
    await this.isExistCategorieBulletin({ key });

    const updateField = {};

    if (categorieBulletin !== undefined) {
      // Vérification que le nouveau nom n'existe pas déjà
      const existingCategorie = await db.query(aql`
        FOR categorie IN ${categorieBulletinCollection}
        FILTER categorie.categorieBulletin == ${categorieBulletin}
        AND categorie._id != ${key}
        LIMIT 1
        RETURN categorie
      `);
      console.log(key);
      console.log(await existingCategorie.next());

      if (existingCategorie.hasNext) {
        throw new Error(`Une catégorie de bulletin avec ce nom existe déjà.`);
      }

      updateField.categorieBulletin = categorieBulletin;
    }

    if (paieClause !== undefined) {
      updateField.paieClause = paieClause;
    }

    if (Object.keys(updateField).length === 0) {
      return "Aucune modification n'a été effectuée";
    }

    // updateField.dateModification = Date.now();

    try {
      await categorieBulletinCollection.update(key, updateField);
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error(
        `Une erreur s'est produite lors de la mise à jour de la catégorie de bulletin`,
      );
    }
  }

  async deleteCategorieBulletin({ key }) {
    try {
      await this.isExistCategorieBulletin({ key });

      const existingCategorie = await db.query(aql`
        FOR categorieBulletinRubrique IN ${categorieBulletinRubriqueCollection}
        FILTER categorieBulletinRubrique._from == ${key}
        LIMIT 1
        RETURN categorieBulletinRubrique
      `);

      if (existingCategorie.hasNext) {
        throw new Error(
          `Une catégorie est déjà utiliser, vous ne pourvez donc pas le supprimer.`,
        );
      }

      await categorieBulletinCollection.remove(key);
      return "OK";
    } catch (error) {
      console.error(error);

      throw new Error(
        `Erreur lors de la suppression de la catégorie de bulletin`,
      );
    }
  }
}

export default CategorieBulletin;
