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

  previousBulletinsPaie: async ({ salarieId }) => {
    return await bulletinPaieModel.getPreviousBulletin({
      salarieId: salarieId,
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
    banqueId,
    salarieId,
    rubriques,
  }) => {
    return await bulletinPaieModel.createBulletin({
      moyenPayement,
      debutPeriodePaie,
      finPeriodePaie,
      referencePaie,
      dateEdition,
      banqueId,
      salarieId,
      rubriques,
    });
  },

  updateBulletinPaie: async ({
    key,
    moyenPayement,
    debutPeriodePaie,
    finPeriodePaie,
    dateEdition,
    banqueId,
    referencePaie,
    salarieId,
    rubriques,
  }) => {
    return await bulletinPaieModel.updateBulletin({
      key,
      moyenPayement,
      debutPeriodePaie,
      finPeriodePaie,
      dateEdition,
      referencePaie,
      banqueId,
      salarieId,
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
