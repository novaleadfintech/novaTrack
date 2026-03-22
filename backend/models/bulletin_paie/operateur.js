import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const operateurCollection = db.collection("operateurs");
class Operateur {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await operateurCollection.exists())) {
    await  operateurCollection.create();
    }
  }

  getAllOperateur = async ({ skip, perPage }) => {
    let limit = aql``;
    if (perPage != undefined && skip != undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    try {
      const query = await db.query(
        aql`
          FOR operateur IN ${operateurCollection}
          SORT operateur.timeStamp DESC
        ${limit}
          RETURN operateur
        `
      );

      if (query.hasNext) {
        return await query.all();
      } else {
        return [];
      }
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la récupération");
    }
  };

  getOperateur = async ({ key }) => {
    try {
      return await operateurCollection.document(key);
    } catch (err) {
      console.error(err);

      throw new Error("L'operateur que vous recherchez n'existe pas!");
    }
  };

  createOperateur = async ({ libelle }) => {
    isValidValue({ value: [libelle] });

    const newOperateur = {
      libelle: libelle,
      timeStamp: Date.now(),
    };
    try {
      await operateurCollection.save(newOperateur);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de l'enregistrement du operateur"
      );
    }
  };

  updateOperateur = async ({ key, libelle }) => {
    const updateField = {};
    if (libelle != undefined) {
      updateField.libelle = libelle;
    }

    isValidValue({ value: updateField });
    try {
      await operateurCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de la mise à jour du operateur"
      );
    }
  };

  deleteOperateur = async ({ key }) => {
    try {
      // Suppression de la operateur
      await operateurCollection.remove(key);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(
        err.message ||
          "Une erreur s'est produite lors de la suppression de l'operateur"
      );
    }
  };

  isExistOperateur = async ({ key }) => {
    const exist = await operateurCollection.documentExists(key);
    if (!exist) {
      throw new Error("Cette operateur est inexistante!");
    }
  };
}

export default Operateur;
