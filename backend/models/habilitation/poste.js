import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const posteCollection = db.collection("postes");
class Poste {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await posteCollection.exists())) {
      posteCollection.create();
    }
  }

  getAllPoste = async ({ skip, perPage }) => {
    let limit = aql``;
    if (perPage != undefined && skip != undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    try {
      const query = await db.query(
        aql`
          FOR poste IN ${posteCollection}
          SORT poste.timeStamp DESC
        ${limit}
          RETURN poste
        `
      );

      if (query.hasNext) {
        return await query.all();
      } else {
        return [];
      }
    } catch (err) {
      throw new Error("Erreur lors de la récupération" + err);
    }
  };

  getPoste = async ({ key }) => {
    try {
      return await posteCollection.document(key);
    } catch (err) {
      throw new Error(
        "La poste bulletin que vous recherchez n'existe pas! " + err
      );
    }
  };

  createPoste = async ({ libelle }) => {
    isValidValue({ value: [libelle] });

    const newPoste = {
      libelle: libelle,
      timeStamp: Date.now(),
    };
    try {
      await posteCollection.save(newPoste);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de l'enregistrement du poste"
      );
    }
  };

  updatePoste = async ({ key, libelle }) => {
    const updateField = {};
    if (libelle != undefined) {
      updateField.libelle = libelle;
    }

    isValidValue({ value: updateField });
    try {
      await posteCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la mise à jour du poste"
      );
    }
  };

  deletePoste = async ({ key }) => {
    try {
      // Suppression de la poste
      await posteCollection.remove(key);
      return "OK";
    } catch (err) {
      throw new Error(
        err.message ||
          "Une erreur s'est produite lors de la suppression de la poste"
      );
    }
  };

  isExistPoste = async ({ key }) => {
    const exist = await posteCollection.documentExists(key);
    if (!exist) {
      throw new Error("Cette poste est inexistante!");
    }
  };
}

export default Poste;
