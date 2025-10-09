import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const echelonCollection = db.collection("echelons");
const classCollection = db.collection("classes");

class Echelon {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await echelonCollection.exists())) {
      echelonCollection.create();
    }
    if (!(await echelonCollection.exists())) {
      echelonCollection.create();
    }
  }
  async getAllEchelon({ perPage, skip }) {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const query = await db.query(
      aql`FOR echelon IN ${echelonCollection} 
          SORT echelon.libelle ASC ${limit} 
          RETURN echelon`,
      { fullCount: true }
    );

    if (query.hasNext) {
      return await query.all();
    } else {
      return [];
    }
  }

  async getEchelon({ key }) {
    try {
      const echelon = await echelonCollection.document(key);
      return echelon;
    } catch (err) {
      console.error(err);
      throw new Error(`L"échelon est introuvable`);
    }
  }

  async isExistEchelon({ key }) {
    try {
      await echelonCollection.documentExists(key);
      return true;
    } catch (err) {
      console.error(err);
      throw new Error(`L'échelon est introuvable`);
    }
  }

  async createEchelon({ libelle }) {
    isValidValue({ value: libelle });
    const existingEchelon = await db.query(aql`
      FOR echelon IN ${echelonCollection}
      FILTER echelon.libelle == ${libelle}
      LIMIT 1
      RETURN echelon
    `);

    if (existingEchelon.hasNext) {
      throw new Error(`Une catégorie de paie avec ce nom existe déjà.`);
    }

    // Création de la catégorie
    const echelon = {
      libelle: libelle,
      timeStamp: Date.now(),
    };

    try {
      const result = await echelonCollection.save(echelon);
      return "OK";
    } catch (error) {
      console.error(error);

      throw new Error(`Erreur lors de la création de la catégorie de paie`);
    }
  }

  async updateEchelon({ key, libelle }) {
    // Vérification que la catégorie existe
    await this.isExistEchelon({ key });

    const updateField = {};

    if (libelle !== undefined) {
      // Vérification que le nouveau nom n'existe pas déjà
      const existingEchelon = await db.query(aql`
        FOR echelon IN ${echelonCollection}
        FILTER echelon.libelle == ${libelle}
        AND echelon._key != ${key}
        LIMIT 1
        RETURN echelon
      `);

      if (existingEchelon.hasNext) {
        throw new Error(`Un échelon avec ce nom existe déjà.`);
      }

      updateField.libelle = libelle;
    }

    if (Object.keys(updateField).length === 0) {
      return "Aucune modification n'a été effectuée";
    }

    // updateField.dateModification = Date.now();

    try {
      await echelonCollection.update(key, updateField);
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error(
        `Une erreur s'est produite lors de la mise à jour de l'échelon`
      );
    }
  }

  async deleteEchelon({ key }) {
    try {
      await this.isExistEchelon({ key });

      const existingEchelon = await db.query(aql`
        FOR classe IN ${classCollection}
            FOR echelon IN classe.echelonIndices
                FILTER echelon._id == ${key}
        LIMIT 1
        RETURN classe
      `);

      if (existingEchelon.hasNext) {
        throw new Error(`Impsossible de supprimer cet échelon.`);
      }

      await echelonCollection.remove(key);
      return "OK";
    } catch (error) {
      console.error(error);
      throw new Error(`Erreur lors de la suppression de l'échelon`);
    }
  }
}

export default Echelon;
