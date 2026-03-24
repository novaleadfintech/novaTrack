 import BulletinPaie from "../../models/bulletin_paie/bulletin.js";

const bulletinPaieModel = new BulletinPaie();

const bulletinPaieResolvers = {
  currentBulletinsPaie: async ({ perPage, skip, etat }) => {
    return await bulletinPaieModel.getAllCurrentBulletins({
      perPage,
      skip,
      etat,
    });
  },

  generateBulletinsForPeriod: async ({ dateDebut, dateFin }) => {
    return await bulletinPaieModel.generateBulletinsForPeriod({
      dateDebut: dateDebut,
      dateFin: dateFin,
    });
  },

  currentValidateBulletin: async ({ perPage, skip }) => {
    return await bulletinPaieModel.getAllCurrentValidateBulletins({
      perPage,
      skip,
    });
  },

  archiveBulletinsPaie: async ({ perPage, skip, etat }) => {
    return await bulletinPaieModel.getAllArchiveBulletins({
      perPage,
      skip,
      etat,
    });
  },

  previousBulletinsPaie: async ({ salarieKey }) => {
    return await bulletinPaieModel.getPreviousBulletin({
      salarieKey: salarieKey,
    });
  },

  bulletinPaie: async ({ key }) => {
    return await bulletinPaieModel.getBulletin({ key });
  },

  createBulletinPaie: async ({
    moyenPayement,
    debutPeriodePaie,
    finPeriodePaie,
    dateEdition,
    referencePaie,
    banqueKey,
    salarieKey,
    rubriques,
  }) => {
    return await bulletinPaieModel.createBulletin({
      moyenPayement,
      debutPeriodePaie,
      finPeriodePaie,
      referencePaie,
      dateEdition,
      banqueKey,
      salarieKey,
      rubriques,
    });
  },

  updateBulletinPaie: async ({
    key,
    moyenPayement,
    debutPeriodePaie,
    finPeriodePaie,
    dateEdition,
    banqueKey,
    referencePaie,
    salarieKey,
    rubriques,
  }) => {
    return await bulletinPaieModel.updateBulletin({
      key,
      moyenPayement,
      debutPeriodePaie,
      finPeriodePaie,
      dateEdition,
      referencePaie,
      banqueKey,
      salarieKey,
      rubriques,
    });
  },

  validerBulletin: async ({ key, validate, datePayement }) => {
    return await bulletinPaieModel.validateBulletin({
      datePayement: datePayement,
      key: key,
      validate: validate,
    });
  },
  // deleteBulletinPaie: async ({ key }) => {
  //   return await bulletinPaieModel.deleteBulletin({ key });
  // },
};

export default bulletinPaieResolvers;
