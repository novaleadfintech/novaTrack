import { aql } from "arangojs";
import db from "../db/database_connection.js";
import { isValidValue } from "../utils/util.js";

const moyenPaiementCollection = db.collection("moyenPaiements");

class MoyenPaiement {
  async getAllMoyenPaiement({ perPage, skip }) {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const query = await db.query(
      aql`FOR moyen IN ${moyenPaiementCollection} 
          SORT moyen.timestamp DESC ${limit} 
          RETURN moyen`,
      { fullCount: true }
    );

    if (query.hasNext) {
      return await query.all();
    } else {
      return [];
    }
  }

  async getMoyenPaiement({ key }) {
    try {
      const moyen = await moyenPaiementCollection.document(key);
      return moyen;
    } catch (err) {
      throw new Error(`Cet moyen de paiement est introuvable`);
    }
  }

  async isExistMoyenPaiement({ key }) {
    try {
      await moyenPaiementCollection.documentExists(key);
      return true;
    } catch (err) {
      throw new Error(`Cet moyen de paiement est introuvable`);
    }
  }

  async createMoyenPaiement({ libelle , type}) {
    // Validation des données
    isValidValue({ value: libelle });

    // Vérification que la catégorie n'existe pas déjà
    const existingCategorie = await db.query(aql`
      FOR moyen IN ${moyenPaiementCollection}
      FILTER moyen.libelle == ${libelle}
      LIMIT 1
      RETURN moyen
    `);

    if (existingCategorie.hasNext) {
      throw new Error(`Un moyen de paiement avec ce nom existe déjà.`);
    }

    // Création de la catégorie
    const moyen = {
      libelle,
      type: type,
      timestamp: Date.now(),
    };

    try {
      const result = await moyenPaiementCollection.save(moyen);
      return "OK";
    } catch (error) {
      throw new Error(
        `Erreur lors de la création du moyen de paiement : ${error}`
      );
    }
  }

  async updateMoyenPaiement({ key, libelle, type }) {
    // Vérification que la catégorie existe
    await this.isExistMoyenPaiement({ key });

    const updateField = {};

    if (libelle !== undefined) {
      // Vérification que le nouveau nom n'existe pas déjà
      const existingCategorie = await db.query(aql`
        FOR moyen IN ${moyenPaiementCollection}
        FILTER moyen.libelle == ${libelle}
        AND moyen._id != ${key}
        LIMIT 1
        RETURN moyen
      `);

      if (existingCategorie.hasNext) {
        throw new Error(`un moyen de paiement avec ce nom existe déjà.`);
      }

      updateField.libelle = libelle;
    }

    if (type !== undefined) {
      updateField.type = type;
    }

    if (Object.keys(updateField).length === 0) {
      return "Aucune modification n'a été effectuée";
    }

    // updateField.dateModification = Date.now();

    try {
      await moyenPaiementCollection.update(key, updateField);
      return "OK";
    } catch (e) {
      throw new Error(
        `Une erreur s'est produite lors de la mise à jour du moyen de paiement : ${e}`
      );
    }
  }

  async deleteMoyenPaiement({ key }) {
    try {
      await this.isExistMoyenPaiement({ key });
      await moyenPaiementCollection.remove(key);
      return "OK";
    } catch (error) {
      throw new Error(
        `Erreur lors de la suppression du moyen de paiement : ${error}`
      );
    }
  }
}

export default MoyenPaiement;
