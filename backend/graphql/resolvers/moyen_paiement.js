import MoyenPaiement from "../../models/moyen_paiement.js";

const moyenPaiementModel = new MoyenPaiement();

const moyenPaiementResolvers = {
  moyensPaiement: async ({ perPage, skip }) => {
    return await moyenPaiementModel.getAllMoyenPaiement({
      perPage: perPage,
      skip: skip,
    });
  },

  moyenPaiement: async ({ key }) => {
    return await moyenPaiementModel.getMoyenPaiement({ key: key });
  },

  createMoyenPaiement: async ({ libelle, type }) => {
    return await moyenPaiementModel.createMoyenPaiement({
      libelle: libelle,
      type: type,
    });
  },

  updateMoyenPaiement: async ({ key, libelle, type }) => {
    return await moyenPaiementModel.updateMoyenPaiement({
      key: key,
      libelle: libelle,
      type: type,
    });
  },

  deleteMoyenPaiement: async ({ key }) => {
    return await moyenPaiementModel.deleteMoyenPaiement({ key: key });
  },
};

export default moyenPaiementResolvers;
