import Decouverte from "../../models/bulletin_paie/decouvert.js";

const decouverteModel = new Decouverte();

const decouverteResolvers = {
  decouvertes: async ({ skip, perPage }) => {
    return await decouverteModel.getAllDecouvertes({
      perPage: perPage,
      skip: skip,
    });
  },

  decouverte: async ({ key }) =>
    await decouverteModel.getDecouverte({ key: key }),

  createDecouverte: async ({
    justification,
    montant,
    dureeReversement,
    salarieId,
    banqueId,
    referenceTransaction,
    moyenPayement,
    userId,
  }) => {
    return await decouverteModel.createDecouverte({
      justification,
      montant,
      dureeReversement,
      salarieId,
      referenceTransaction,
      banqueId,
      moyenPayement,
      userId,
    });
  },

  updateDecouverte: async ({
    key,
    justification,
    montant,
    montantRestant,
    dureeReversement,
    salarieId,
    referenceTransaction,
    banqueId,
    moyenPayement,
  }) => {
    return await decouverteModel.updateDecouverte({
      key,
      justification,
      montant,
      montantRestant,
      dureeReversement,
      salarieId,
      banqueId,
      referenceTransaction,
      moyenPayement,
    });
  },

  deleteDecouverte: async ({ key }) =>
    await decouverteModel.deleteDecouverte({ key: key }),
};

export default decouverteResolvers;
