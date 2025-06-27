import Entreprise from "../../models/entreprise.js";

const entrepriseModel = new Entreprise();
const entrepriseResolvers = {
  entreprise: async () => await entrepriseModel.getEntreprise(),

  createEntreprise: async (
   { logo,
    adresse,
    email,
    ville,
    telephone,
    raisonSociale,
    pays,
    tamponSignature,
    nomDG,}
  ) => await entrepriseModel.createEntreprise({adresse: adresse, ville: ville, email: email,logo: logo,telephone: telephone,nomDG: nomDG, pays: pays, tamponSignature: tamponSignature, raisonSociale: raisonSociale,}),
  
  updateEntreprise: async (
   { key,
    logo,
    adresse,
    email,
    raisonSociale,
      pays,
    ville,
    telephone,
    tamponSignature,
    nomDG,}
  ) => await entrepriseModel.updateEntreprise({ key:key, adresse: adresse,ville: ville, email: email, telephone: telephone, tamponSignature: tamponSignature, raisonSociale:raisonSociale, nomDG: nomDG, pays: pays, logo:logo}),
};

export default entrepriseResolvers;
