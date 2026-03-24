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
    salarieKey,
    banqueKey,
    referenceTransaction,
    moyenPayement,
    userKey,
  }) => {
    return await decouverteModel.createDecouverte({
      justification,
      montant,
      dureeReversement,
      salarieKey,
      referenceTransaction,
      banqueKey,
      moyenPayement,
      userKey,
    });
  },

  updateDecouverte: async ({
    key,
    justification,
    montant,
    montantRestant,
    dureeReversement,
    salarieKey,
    referenceTransaction,
    banqueKey,
    moyenPayement,
  }) => {
    return await decouverteModel.updateDecouverte({
      key,
      justification,
      montant,
      montantRestant,
      dureeReversement,
      salarieKey,
      banqueKey,
      referenceTransaction,
      moyenPayement,
    });
  },

  deleteDecouverte: async ({ key }) =>
    await decouverteModel.deleteDecouverte({ key: key }),
};

export default decouverteResolvers;
