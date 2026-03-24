import Debt from "../../models/flux_financier/debt.js";
const debtModel = new Debt();

const debtResolvers = {
  debts: async ({ skip, perPage }) => {
    return await debtModel.getAllDebts({
      perPage: perPage,
      skip: skip,
    });
  },

  debt: async ({ key }) => await debtModel.getDebt({ key: key }),

  createDebt: async ({
    libelle,
    montant,
    pieceJustificative,
    userKey,
    partiePrenante,
    datePayementUlterieur,
    referenceFacture,
    dateOperation,
    clientKey,
  }) => {
    return await debtModel.createDebt({
      libelle,
      montant,
      pieceJustificative,
      userKey,
      partiePrenante,
      datePayementUlterieur,
      referenceFacture,
      dateOperation,
      clientKey,
    });
  },

  updateDebt: async ({
    key,
    libelle,
    montant,
    dateOperation,
    referenceFacture,
    status,
    partiePrenante,
    datePayementUlterieur,
    pieceJustificative,
    clientKey,
  }) => {
    return await debtModel.updateDebt({
      key,
      libelle,
      montant,
      dateOperation,
      referenceFacture,
      partiePrenante,
      datePayementUlterieur,
      status: status,
      pieceJustificative,
      clientKey,
    });
  },

  deleteDebt: async ({ key }) => await debtModel.deleteDebt({ key: key }),
};

export default debtResolvers;
