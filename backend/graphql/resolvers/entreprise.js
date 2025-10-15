import Entreprise from "../../models/entreprise.js";

const entrepriseModel = new Entreprise();
const entrepriseResolvers = {
  entreprise: async () => await entrepriseModel.getEntreprise(),

  getValeurIndiciaire: async () => await entrepriseModel.getValeurIndiciaire(),

  createEntreprise: async ({
    logo,
    adresse,
    email,
    ville,
    telephone,
    valeurIndiciaire,
    raisonSociale,
    pays,
    tamponSignature,
    nomDG,
  }) =>
    await entrepriseModel.createEntreprise({
      adresse: adresse,
      ville: ville,
      email: email,
      logo: logo,
      valeurIndiciaire: valeurIndiciaire,
      telephone: telephone,
      nomDG: nomDG,
      pays: pays,
      tamponSignature: tamponSignature,
      raisonSociale: raisonSociale,
    }),

  updateEntreprise: async ({
    key,
    logo,
    adresse,
    email,
    raisonSociale,
    pays,
    valeurIndiciaire,
    ville,
    telephone,
    tamponSignature,
    nomDG,
  }) =>
    await entrepriseModel.updateEntreprise({
      key: key,
      adresse: adresse,
      ville: ville,
      email: email,
      telephone: telephone,
      valeurIndiciaire: valeurIndiciaire,
      tamponSignature: tamponSignature,
      raisonSociale: raisonSociale,
      nomDG: nomDG,
      pays: pays,
      logo: logo,
    }),
};

export default entrepriseResolvers;
