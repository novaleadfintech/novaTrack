import Personnel from "../../models/habilitation/personnel.js";

const personnelModel = new Personnel();

const personnelResolvers = {
  //recuperer tous les personnels
  personnels: async ({ skip, perPage, etat }) =>
    await personnelModel.getAllPersonnel({
      perPage: perPage,
      skip: skip,
      etat: etat,
    }),

  //récuperer un personnel
  personnel: async ({ key }) => await personnelModel.getPersonnel({ key: key }),

  //création de personnel
  createPersonnel: async ({
    nom,
    prenom,
    email,
    pays,
    telephone,
    adresse,
    sexe,
    etat,
    poste,
    situationMatrimoniale,
    dateNaissance,
    dateDebut,
    dateFin,
    nombreEnfant,
    nombrePersonneCharge,
    typePersonnel,
    typeContrat,
    dureeEssai,
    personnePrevenir,
    commentaire,
  }) =>
    await personnelModel.createPersonnel({
      adresse: adresse,
      commentaire: commentaire,
      email: email,
      nom: nom,
      pays: pays,
      poste: poste,
      prenom: prenom,
      sexe: sexe,
      dateNaissance: dateNaissance,
      dateDebut: dateDebut,
      dateFin: dateFin,
      nombreEnfant: nombreEnfant,
      nombrePersonneCharge: nombrePersonneCharge,
      typePersonnel: typePersonnel,
      typeContrat: typeContrat,
      dureeEssai: dureeEssai,
      personnePrevenir: personnePrevenir,
      situationMatrimoniale: situationMatrimoniale,
      telephone: telephone,
      etat: etat,
    }),

  //Mettre à jour les donnée des personnels
  updatePersonnel: async ({
    key,
    nom,
    prenom,
    email,
    pays,
    telephone,
    adresse,
    dateNaissance,
    dateDebut,
    dateFin,
    nombreEnfant,
    nombrePersonneCharge,
    typePersonnel,
    typeContrat,
    personnePrevenir,
    sexe,
    poste,
    dureeEssai,
    situationMatrimoniale,
    commentaire,
  }) =>
    await personnelModel.updatePersonnel({
      key: key,
      adresse: adresse,
      commentaire: commentaire,
      email: email,
      pays: pays,
      nom: nom,
      poste: poste,
      prenom: prenom,
      sexe: sexe,
      dateNaissance: dateNaissance,
      dateDebut: dateDebut,
      dateFin: dateFin,
      nombreEnfant: nombreEnfant,
      nombrePersonneCharge: nombrePersonneCharge,
      typePersonnel: typePersonnel,
      typeContrat: typeContrat,
      personnePrevenir: personnePrevenir,
      situationMatrimoniale: situationMatrimoniale,
      telephone: telephone,
      dureeEssai: dureeEssai,
    }),

  archivedPersonnel: async ({ key }) =>
    await personnelModel.archivedPersonnel({ key: key }),

  unarchivedPersonnel: async ({ key }) =>
    await personnelModel.unarchivedPersonnel({ key: key }),
};

export default personnelResolvers;
