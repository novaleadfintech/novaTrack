import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidEmail, isValidValue } from "../../utils/util.js";
import Categorie from "./categorie.js";
import { uploadFile } from "../../utils/fichier.js";
import path from "path";
import { StatusFacture } from "../facturation/utils.js";

const EtatClient = {
  archived: "archived",
  unarchived: "unarchived",
};

const NatureClient = {
  prospect: "prospect",
  client: "client",
  fournisseur: "fournisseur",
};

const clientCollection = db.collection("clients");
const factureCollection = db.collection("factures");
const categorieModel = new Categorie();

const locateClientFolder = "client";
class Client {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await clientCollection.exists())) {
      clientCollection.create();
    }
    if (!(await factureCollection.exists())) {
      factureCollection.create();
    }
  }

  // Récupérer tous les clients avec pagination
  getAllClients = async ({ skip, perPage, etat, nature }) => {
    try {
      let limit = aql``;
      let filtre = aql``;
      if (skip !== undefined && perPage != undefined) {
        limit = aql`LIMIT ${skip}, ${perPage}`;
      }
      if (etat != undefined) {
        filtre = aql`FILTER client.etat == ${etat}`;
        if (nature != undefined) {
          filtre = aql`FILTER client.etat == ${etat} AND client.nature == ${nature}`;
        }
      }
      const query = await db.query(
        aql`
            FOR client IN ${clientCollection}
            LET sortKey = client.raisonSociale != null ? client.raisonSociale : client.nom
            SORT sortKey ASC
            ${limit} ${filtre}
            RETURN client`,
        { fullCount: true }
      );
      if (query.hasNext) {
        const clients = await query.all();
        return Promise.all(
          clients.map(async (client) => {
            return {
              ...client,
              fullCount: query.extra.stats.fullCount,
              logo: client.logo
                ? process.env.FILE_PREFIX +
                  `${locateClientFolder}/` +
                  client.logo
                : null,
              __typename: client.raisonSociale
                ? "ClientMoral"
                : "ClientPhysique",
              categorie: client.raisonSociale
                ? await categorieModel.getCategorie({
                    key: client.categorieId,
                  })
                : null,
            };
          })
        );
      } else {
        return [];
      }
    } catch (error) {
      throw new Error("Erreur lors de la récupération des clients");
    }
  };

  getUnarchivedClientsAndProspects = async ({ skip, perPage }) => {
    try {
      let limit = aql``;
      let filtre = aql``;
      if (skip !== undefined && perPage != undefined) {
        limit = aql`LIMIT ${skip}, ${perPage}`;
      }

      filtre = aql`FILTER client.etat == ${EtatClient.unarchived} AND (client.nature == ${NatureClient.client} OR client.nature == ${NatureClient.prospect})`;
      const query = await db.query(
        aql`
            FOR client IN ${clientCollection}
            LET sortKey = client.raisonSociale != null ? client.raisonSociale : client.nom
            SORT sortKey ASC
            ${limit} ${filtre}
            RETURN client`,
        { fullCount: true }
      );
      if (query.hasNext) {
        const clients = await query.all();
        return Promise.all(
          clients.map(async (client) => {
            return {
              ...client,
              fullCount: query.extra.stats.fullCount,
              logo: client.logo
                ? process.env.FILE_PREFIX +
                  `${locateClientFolder}/` +
                  client.logo
                : null,
              __typename: client.raisonSociale
                ? "ClientMoral"
                : "ClientPhysique",
              categorie: client.raisonSociale
                ? await categorieModel.getCategorie({
                    key: client.categorieId,
                  })
                : null,
            };
          })
        );
      } else {
        return [];
      }
    } catch (error) {
      throw new Error("Erreur lors de la récupération des clients");
    }
  };

  // Récupérer un client par son ID
  getClient = async ({ key }) => {
    try {
      const client = await clientCollection.document(key);
      return {
        ...client,
        logo: client.logo
          ? process.env.FILE_PREFIX + `${locateClientFolder}/` + client.logo
          : null,
        __typename: client.raisonSociale ? "ClientMoral" : "ClientPhysique",
        categorie: client.raisonSociale
          ? await categorieModel.getCategorie({
              key: client.categorieId,
            })
          : null,
      };
    } catch (error) {
      throw new Error(`Ce client est introuvable > ` + error.message);
    }
  };

  // Récupérer tous les clients moraux
  getClientMoraux = async ({ skip, perPage }) => {
    try {
      let limit = aql``;
      if (skip !== undefined && perPage != undefined) {
        limit = aql` LIMIT ${skip}, ${perPage}`;
      }
      const query = await db.query(
        aql`
        FOR client IN ${clientCollection}
        FILTER client.raisonSociale
        LET sortKey = client.raisonSociale != null ? client.raisonSociale : client.nom
            SORT sortKey ASC
        ${limit}       
        RETURN client`,
        { fullCount: true }
      );
      if (query.hasNext) {
        const clients = await query.all();
        return Promise.all(
          clients.map(async (client) => ({
            ...client,
            logo: client.logo ? process.env.FILE_PREFIX : null,
            filePath,
            categorie:
              client.nom ??
              (await categorieModel.getCategorie({ key: client.categorieId })),
            fullCount: query.extra.stats.fullCount,
          }))
        );
      } else {
        return [];
      }
    } catch (error) {
      throw new Error("Erreur lors de la récupération des clients");
    }
  };
  getClientPhysiques = async ({ skip, perPage }) => {
    try {
      let limit = aql``;
      if (skip !== undefined && perPage != undefined) {
        limit = aql` LIMIT ${skip}, ${perPage}`;
      }
      const query = await db.query(
        aql`
        FOR client IN ${clientCollection}
        FILTER client.nom
        LET sortKey = client.raisonSociale != null ? client.raisonSociale : client.nom
        SORT sortKey ASC
        ${limit}       
        RETURN client`,
        { fullCount: true }
      );

      if (query.hasNext) {
        const clients = await query.all();
        return clients.map((client) => ({
          ...client,
          fullCount: query.extra.stats.fullCount,
        }));
      } else {
        return [];
      }
    } catch (error) {
      throw new Error("Erreur lors de la récupération des clients");
    }
  };

  createClientMoral = async ({
    raisonSociale,
    logo,
    email,
    telephone,
    adresse,
    pays,
    nature,
    categorieId,
    etat = EtatClient.unarchived,
    responsable,
  }) => {
    // Validation des champs obligatoires
    isValidValue({
      value: [raisonSociale, pays, categorieId, nature],
    });
    if (nature !== NatureClient.fournisseur) {
      isValidValue({
        value: [email, telephone, pays, responsable, logo, adresse],
      });
      isValidEmail({ email: email });
      isValidEmail({ email: responsable.email });
    }
    // Vérifier les types des champs

    await categorieModel.isExistCategorie({ key: categorieId });

    try {
      let filePath = null;
      if (logo && logo.file) {
        const file = await logo.file;
        const filename = file.filename;
        const createReadStream = file.createReadStream;
        const mimetype = file.mimetype;

        if (filename !== undefined && filename !== null) {
          isValidValue({ value: [filename, mimetype] });
          const extension = path.extname(filename);
          const valid_raisonSociale = raisonSociale.replace(/ /g, "_");
          const uniquefilename = `${Date.now()}_${valid_raisonSociale}${extension}`;
          filePath = await uploadFile({
            createReadStream: createReadStream,
            locateFolder: locateClientFolder,
            mimetype: mimetype,
            uniquefilename: uniquefilename,
          });

          if (filePath == null) {
            throw new Error();
          }
        }
      } else {
        if (nature !== NatureClient.fournisseur)
          throw new Error("Veuillez uploader le logo");
      }

      const clientMoral = {
        raisonSociale: raisonSociale,
        logo: filePath?.replace(/\\/g, "/"),
        email: email,
        telephone: telephone,
        adresse: adresse,
        pays: pays,
        etat: etat,
        nature: nature,
        categorieId: categorieId,
        responsable: responsable,
        dateEnregistrement: Date.now(),
      };
      await clientCollection.save(clientMoral);
      return "OK";
    } catch (error) {
      throw new Error(error);
    }
  };

  createClientPhysique = async ({
    nom,
    prenom,
    sexe,
    email,
    telephone,
    nature,
    pays,
    adresse,
    etat = EtatClient.unarchived,
  }) => {
    // Validation des champs obligatoires
    isValidValue({
      value: [nom, prenom, sexe, pays],
    });
    if (nature !== NatureClient.fournisseur) {
      isValidValue({
        value: [email, telephone, adresse],
      });
      isValidEmail({ email: email });
    }
    // Validation du format de l'email
    const ClientPhysique = {
      nom: nom,
      prenom: prenom,
      sexe: sexe,
      email: email,
      telephone: telephone,
      adresse: adresse,
      nature: nature,
      pays: pays,
      etat: etat,
      dateEnregistrement: Date.now(),
    };

    try {
      await clientCollection.save(ClientPhysique);
      return "OK";
    } catch (error) {
      throw new Error("Erreur lors de la création du client");
    }
  };

  updateClientMoral = async ({
    key,
    raisonSociale,
    logo,
    email,
    pays,
    telephone,
    nature,
    adresse,
    categorieId,
    responsable,
  }) => {
    try {
      const updateField = {};
      const client = await this.getClient({ key });

      if (raisonSociale !== undefined) {
        updateField.raisonSociale = raisonSociale;
      }

      // Vérifie la nature pour appliquer la logique
      const isFournisseur =
        nature === NatureClient.fournisseur ||
        client.nature === NatureClient.fournisseur;

      // Gestion de l'upload du logo
      if (logo?.file) {
        const file = logo.file;
        const { createReadStream, filename, mimetype } = file;

        if (filename) {
          const validName = (raisonSociale || client.raisonSociale).replace(
            / /g,
            "_"
          );
          const extension = path.extname(filename);
          const uniqueFilename = `${Date.now()}_${validName}${extension}`;

          const filePath = await uploadFile({
            createReadStream,
            locateFolder: locateClientFolder,
            uniquefilename: uniqueFilename,
            mimetype,
          });

          if (!filePath) {
            throw new Error("Échec de l'upload du logo.");
          }

          updateField.logo = filePath.replace(/\\/g, "/");
        }
      } else if (!isFournisseur && logo !== undefined) {
        // logo est requis si ce n’est pas un fournisseur
        throw new Error("Veuillez uploader le logo");
      }

      if (categorieId !== undefined) {
        await categorieModel.isExistCategorie({ key: categorieId });
        updateField.categorieId = categorieId;
      }

      if (nature !== undefined) {
        updateField.nature = nature;
      }

      // Validation conditionnelle
      if (!isFournisseur) {
        isValidValue({
          value: [
            email,
            telephone,
            pays,
            responsable,
            logo || client.logo,
            adresse,
          ],
        });

        if (email !== undefined) {
          isValidEmail({ email });
          updateField.email = email;
        }

        if (responsable !== undefined) {
          updateField.responsable = responsable;
          isValidEmail({ email: responsable.email });
        }
      }

      if (telephone !== undefined) {
        updateField.telephone = telephone;
      }

      if (adresse !== undefined) {
        updateField.adresse = adresse;
      }

      if (pays !== undefined) {
        updateField.pays = pays;
      }

      // isValidValue({ value: updateField }); // Vérifie les champs présents

      await clientCollection.update(key, updateField);

      return "OK";
    } catch (err) {
      throw new Error(
        "Erreur lors de la mise à jour du client : " + err.message
      );
    }
  };

  // Mettre à jour un client existant
  updateClientPhysique = async ({
    key,
    nom,
    prenom,
    sexe,
    nature,
    pays,
    email,
    telephone,
    adresse,
  }) => {
    try {
      const updateField = {};
      // Vérifier et mettre à jour chaque champ
      if (nom !== undefined) {
        updateField.nom = nom;
      }

      if (prenom !== undefined) {
        updateField.prenom = prenom;
      }

      if (sexe !== undefined) {
        updateField.sexe = sexe;
      }

      if (email !== undefined) {
        isValidEmail({ email: email });
        updateField.email = email;
      }

      if (telephone !== undefined) {
        updateField.telephone = telephone;
      }

      if (nature !== undefined) {
        updateField.nature = nature;
      }

      if (adresse !== undefined) {
        updateField.adresse = adresse;
      }

      if (pays !== undefined) {
        updateField.pays = pays;
      }

      isValidValue({ value: updateField });

      await clientCollection.update(key, updateField);
      return "OK";
    } catch (error) {
      throw new Error("Erreur lors de la mise à jour du client ");
    }
  };

  // Archiver un client par son ID
  archivedClient = async ({ key }) => {
    const query = await db.query(
      aql`FOR facture IN ${factureCollection} 
       FILTER facture.client._id == ${key} AND facture.status != ${StatusFacture.paid}
        LIMIT 1
        RETURN facture`
    );

    if (query.hasNext) {
      throw new Error(
        "Ce client à des factures à payer. Il ne peux donc pas être archivé."
      );
    }
    try {
      const updateField = { etat: EtatClient.archived };
      await clientCollection.update(key, updateField);
      return "OK";
    } catch (error) {
      throw new Error("Erreur lors de l'archivage du client");
    }
  };

  // Réactiver un client archivé par son ID
  unarchivedClient = async ({ key }) => {
    try {
      const updateField = { etat: EtatClient.unarchived };
      await clientCollection.update(key, updateField);
      return "OK";
    } catch (error) {
      throw new Error("Erreur lors du désarchivage du client");
    }
  };

  isExistClient = async ({ key }) => {
    const exist = await clientCollection.documentExists(key);
    if (!exist) {
      throw new Error("Cette facture n'existe pas!");
    }
  };
}

export default Client;
export { locateClientFolder, NatureClient, EtatClient };
