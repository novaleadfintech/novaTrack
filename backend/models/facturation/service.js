import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
const serviceCollection = db.collection("services");

const EtatService = {
  archived: "archived",
  unarchived: "unarchived",
};
export const Nature = {
  unique: "unique",
  multiple: "multiple",
};

class Service {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await serviceCollection.exists())) {
      serviceCollection.create();
    }
  }

  //récuperer tous les services
  getAllServices = async ({ skip, perPage, etat }) => {
    let limit = aql``;
    let filtre = aql``;
    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    if (etat != undefined) {
      filtre = aql`FILTER service.etat == ${etat}`;
    }
    const query = await db.query(
      aql`FOR service IN ${serviceCollection} SORT service.libelle ASC ${filtre} ${limit} RETURN service`,
      { fullCount: true }
    );
    if (query.hasNext) {
      const services = await query.all();
      return services.map(async (service) => {
        return {
          fullCount: query.extra.stats.fullCount,
          ...service,
        };
      });
    } else {
      return [];
    }
  };

  // recupérer un service avec sa clé
  getService = async ({ key }) => {
    try {
      return await serviceCollection.document(key);
    } catch {
      throw new Error(`service inexistant`);
    }
  };

  //creer un nouveau service
  createService = async ({
    libelle,
    tarif,
    etat = "unarchived",
    type,
    nature,
    prix,
    description,
    country,
  }) => {
    //verifier le remplissage des champs
    isValidValue({ value: [libelle, type, etat, country, nature] });

    if (description != undefined) {
      isValidValue({ value: description });
    } else {
      description = null;
    }

    if (nature == Nature.multiple) {
      const { maxQuantity, ...othertarifData } = tarif;
      isValidValue({ value: othertarifData });
    }

    if (nature == Nature.unique) {
      isValidValue({ value: prix });
    }

    let service = {
      libelle: libelle,
      tarif: tarif,
      prix: prix,
      type: type,
      etat: etat,
      nature: nature,
      description: description,
      country: country,
      timeStamp: Date.now(),
    };
    try {
      await serviceCollection.save(service);
      return "OK";
    } catch {
      throw new Error("Une erreur s'est produite lors de l'enregistrement");
    }
  };

  updateService = async ({
    key,
    libelle,
    tarif,
    type,
    nature,
    prix,
    description,
    country,
  }) => {
    let updateField = {};

    if (libelle !== undefined) {
      updateField.libelle = libelle;
    }

    if (type !== undefined) {
      updateField.type = type;
    }

    if (prix !== undefined) {
      updateField.prix = prix;
    }

    if (country !== undefined) {
      updateField.country = country;
    }

    isValidValue({ value: updateField });

    if (description !== undefined) {
      updateField.description = description != "" ? description : null;
    }

    if (tarif !== undefined) {
      if (tarif.length != 0) {
        const { maxQuantity, ...othertarifData } = tarif;
        isValidValue({ value: othertarifData });
      }
      updateField.tarif = tarif;
    }

    if (nature !== undefined) {
      updateField.nature = nature;
      if (nature == Nature.multiple) {
        updateField.prix = null;
      }
      if (nature == Nature.unique) {
        updateField.tarif = null;
      }
    }

    try {
      // const updatedService = result.new;
      // setTimeout(async () => {
      //   try {
      //     const query = await db.query(
      //       aql`
      //         FOR ligneProforma IN ${ligneProformaCollection}
      //           FILTER ligneProforma._from == ${updatedService._id}
      //           LET proforma = DOCUMENT(ligneProforma._to)
      //           FILTER proforma.garantyTime == 0
      //           OR (${Date.now()} - proforma.dateEnvoie) >= proforma.garantyTime
      //           RETURN ligneProforma
      //       `
      //     );
      //     const ligneProformas = await query.all();
      //     await Promise.all(
      //       ligneProformas.map(async (ligneProforma) => {
      //         const updatedData = {
      //           service: updatedService,
      //         };

      //         ligneProformaCollection.update(ligneProforma._id, updatedData);
      //       })
      //     );
      //     print("Ok");
      //   } catch (error) {}
      // }, 0);
      await serviceCollection.update(key, updateField);
      return "OK";
    } catch (error) {
      throw new Error("Une erreur s'est produite lors de la mise à jour");
    }
  };

  //archiver un service
  archivedService = async ({ key }) => {
    try {
      const updateField = { etat: EtatService.archived };
      await serviceCollection.update(key, updateField);
      return "OK";
    } catch {
      throw new Error("Une erreur s'est produite lors de la mise à jour");
    }
  };

  //desarchiver un service
  unarchivedService = async ({ key }) => {
    try {
      const updateField = { etat: EtatService.unarchived };
      await serviceCollection.update(key, updateField);
      return "OK";
    } catch {
      throw new Error("Une erreur s'est produite lors de la mise à jour");
    }
  };

  isExistService = async ({ key }) => {
    const exist = await serviceCollection.documentExists(key);
    if (!exist) {
      throw new Error("Ce service n'existe pas!");
    }
  };
}

export default Service;
