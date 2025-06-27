import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const libelleFluxCollection = db.collection("libelleFlux");

class LibelleFlux {
  constructor() {}

  getLibelleFlux = async ({ skip, perPage, type }) => {
    let limit = aql``;
    let filter = aql``;

    if (perPage != undefined && skip != undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    if (type != undefined) {
      filter = aql`FILTER libelleFlux.type == ${type}`;
    }
    try {
      const query = await db.query(
        aql`
          FOR libelleFlux IN ${libelleFluxCollection}
          ${filter}
          SORT libelleFlux.timestamp DESC
         ${limit}
          RETURN libelleFlux
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

  /* getLibelleFlux = async ({ key }) => {
    try {
      return await libelleFluxCollection.document(key);
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la récupération du libellé"
      );
    }
  }; */

  createLibelleFlux = async ({ libelle, type, reference }) => {
    isValidValue({ value: [libelle, type] });

    const newLibelleFlux = {
      libelle: libelle,
      type: type,
      timestamp: Date.now(),
    };
    try {
      await libelleFluxCollection.save(newLibelleFlux);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de l'enregistrement du libellé"
      );
    }
  };

  updateLibelleFlux = async ({ key, libelle, reference }) => {
    const updateField = {};
    if (libelle != undefined) {
      updateField.libelle = libelle;
    }
    if (reference != undefined) {
      updateField.reference = reference;
    }
    isValidValue({ value: updateField });
    try {
      await libelleFluxCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la mise à jour du libellé"
      );
    }
  };

  deleteLibelle = async ({ key }) => {
    try {
      await libelleFluxCollection.remove(key);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la suppression du libellé"
      );
    }
  };

  isExistLibelleFlux = async ({ key }) => {
    const exist = await libelleFluxCollection.documentExists(key);
    if (!exist) {
      throw new Error("Cette libellé est inexistante!");
    }
  };
}

export default LibelleFlux;
