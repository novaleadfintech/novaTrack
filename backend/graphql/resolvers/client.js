import GraphqlUpload from "graphql-upload/GraphQLUpload.mjs";
import Client from "../../models/client/client.js";

const clientModel = new Client();

const clientResolvers = {
  // Récupérer tous les clients avec pagination
  clients: async ({ skip, perPage, etat, nature }) =>
    await clientModel.getAllClients({
      perPage: perPage,
      skip: skip,
      etat: etat,
      nature: nature,
    }),

  // Récupérer un client par son ID
  client: async ({ key }) => await clientModel.getClient({ key: key }),

  // Récupérer tous les clients moraux par son ID
  clientMoraux: async ({ skip, perPage }) =>
    await clientModel.getClientMoraux({ perPage: perPage, skip: skip }),
  unarchivedClientsAndProspects: ({ skip, perPage }) =>
    clientModel.getUnarchivedClientsAndProspects({
      skip: skip,
      perPage: perPage,
    }),
  //recuperer tous les clients physiques
  clientPhysiques: async ({ skip, perPage }) =>
    await clientModel.getClientPhysiques({ skip: skip, perPage: perPage }),

  // creer un client moral
  Upload: GraphqlUpload,
  createClientMoral: async ({
    raisonSociale,
    logo,
    email,
    nature,
    telephone,
    adresse,
    pays,
    categorieId,
    etat = "unarchived",
    responsable,
  }) =>
    await clientModel.createClientMoral({
      adresse: adresse,
      categorieId: categorieId,
      email: email,
      logo: logo,
      nature: nature,
      pays: pays,
      raisonSociale: raisonSociale,
      responsable: responsable,
      telephone: telephone,
      etat: etat,
    }),

  // Créer un nouveau client physique
  createClientPhysique: async ({
    nom,
    prenom,
    sexe,
    email,
    telephone,
    pays,
    nature,
    adresse,
    etat = "unarchived",
  }) =>
    await clientModel.createClientPhysique({
      nom: nom,
      adresse: adresse,
      email: email,
      pays: pays,
      prenom: prenom,
      sexe: sexe,
      nature: nature,
      telephone: telephone,
      etat: etat,
    }),

  //Mettre jour un client moral
  updateClientMoral: async ({
    key,
    raisonSociale,
    logo,
    email,
    nature,
    telephone,
    adresse,
    pays,
    categorieId,
    responsable,
  }) =>
    await clientModel.updateClientMoral({
      key: key,
      adresse: adresse,
      categorieId: categorieId,
      email: email,
      nature: nature,
      logo: logo,
      pays: pays,
      raisonSociale: raisonSociale,
      responsable: responsable,
      telephone: telephone,
    }),

  // Mettre à jour un client existant
  updateClientPhysique: async ({
    key,
    nom,
    prenom,
    sexe,
    nature,
    email,
    pays,
    telephone,
    adresse,
  }) =>
    await clientModel.updateClientPhysique({
      key: key,
      adresse: adresse,
      email: email,
      nom: nom,
      pays: pays,
      nature: nature,
      prenom: prenom,
      sexe: sexe,
      telephone: telephone,
    }),

  // Archiver un client par son ID
  archivedClient: async ({ key }) =>
    await clientModel.archivedClient({ key: key }),

  // Réactiver un client archivé par son ID
  unarchivedClient: async ({ key }) =>
    await clientModel.unarchivedClient({ key: key }),
};

export default clientResolvers;
