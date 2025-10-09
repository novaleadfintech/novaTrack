import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import Echelon from "./echelon.js";
const classeCollection = db.collection("classes");
const categoriePaieGrilleCollection = db.collection("categoriePaieGrille");

const EchelonModel = new Echelon();
class Classe {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await classeCollection.exists())) {
      classeCollection.create();
    }
    if (!(await classeCollection.exists())) {
      classeCollection.create();
    }
  }
  async getAllClasse({ perPage, skip }) {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const query = await db.query(
      aql`FOR classe IN ${classeCollection} 
          SORT classe.timeStamp DESC ${limit} 
          RETURN classe`,
      { fullCount: true }
    );

    if (query.hasNext) {
      return await query.all();
    } else {
      return [];
    }
  }

  async getClasse({ key }) {
    try {
      const classe = await classeCollection.document(key);
      return classe;
    } catch (err) {
      console.error(err);
      throw new Error(`La classe est introuvable`);
    }
  }

  async isExistClasse({ key }) {
    try {
      await classeCollection.documentExists(key);
      return true;
    } catch (err) {
      console.error(err);

      throw new Error(`La classe est introuvable`);
    }
  }

  async createClasse({ libelle, echelonIndices }) {
    isValidValue({ value: libelle });
    isValidValue({ value: echelonIndices });

    for (const echelon of echelonIndices) {
      const exists = await EchelonModel.isExistEchelon({ key: echelon.id });
      if (!exists) {
        throw new Error(
          `L'échelon avec l'ID ${echelon.echelonId} n'existe pas`
        );
      }
    }

    // Vérification que la classe n'existe pas déjà
    const existingCategorie = await db.query(aql`
      FOR classe IN ${classeCollection}
      FILTER classe.libelle == ${libelle}
      LIMIT 1
      RETURN classe
    `);

    if (existingCategorie.hasNext) {
      throw new Error(`Une classe avec ce nom existe déjà.`);
    }

    // Création de la classe
    const classe = {
      libelle: libelle,
      echelonIndiciaires: echelonIndices,
      timeStamp: Date.now(),
    };

    try {
      // const result =
      await classeCollection.save(classe);
      return "OK";
    } catch (error) {
      console.error(error);
      throw new Error(`Erreur lors de la création de la classe`);
    }
  }

  async updateClasse({ key, libelle, echelonIndices }) {
    // Vérification que la classe existe
    await this.isExistClasse({ key });

    const updateField = {};

    if (libelle !== undefined) {
      // Vérification que le nouveau nom n'existe pas déjà
      const existingCategorie = await db.query(aql`
        FOR classe IN ${classeCollection}
        FILTER classe.libelle == ${libelle}
        AND classe._key != ${key}
        LIMIT 1
        RETURN classe
      `);

      if (existingCategorie.hasNext) {
        throw new Error(`Une classe avec ce nom existe déjà.`);
      }

      updateField.libelle = libelle;
    }

    if (echelonIndices !== undefined) {
      for (const echelon of echelonIndices) {
        const exists = await EchelonModel.isExistEchelon({ key: echelon.id });
        if (!exists) {
          throw new Error(`L'échelon ${echelon.libelle} n'existe pas`);
        }
      }
      isValidValue({ value: echelonIndices });
      updateField.echelonIndices = echelonIndices;
    }

    if (Object.keys(updateField).length === 0) {
      return "Aucune modification n'a été effectuée";
    }

    // updateField.dateModification = Date.now();

    try {
      await classeCollection.update(key, updateField);
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error(
        `Une erreur s'est produite lors de la mise à jour de la classe`
      );
    }
  }

  async deleteClasse({ key }) {
    try {
      await this.isExistClasse({ key });

      const existingCategorie = await db.query(aql`
        FOR categorie IN ${categoriePaieGrilleCollection}
            FOR classe IN categorie.classes
                FILTER classe._id == ${key}
        LIMIT 1
        RETURN categorie
      `);

      if (existingCategorie.hasNext) {
        throw new Error(`impossible de supprimer cette classe`);
      }
      await classeCollection.remove(key);
      return "OK";
    } catch (error) {
      console.error(error);
      throw new Error(`Erreur lors de la suppression de la classe`);
    }
  }
}

export default Classe;
