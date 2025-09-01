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
    userId,
    referenceFacture,
    dateOperation,
    clientId,
  }) => {
    return await debtModel.createDebt({
      libelle,
      montant,
      pieceJustificative,
      userId,
      referenceFacture,
      dateOperation,
      clientId,
    });
  },

  updateDebt: async ({
    key,
    libelle,
    montant,
    dateOperation,
    referenceFacture,
    pieceJustificative,
    clientId,
  }) => {
    return await debtModel.updateDebt({
      key,
      libelle,
      montant,
      dateOperation,
      referenceFacture,
      pieceJustificative,
      clientId,
    });
  },

  deleteDebt: async ({ key }) => await debtModel.deleteDebt({ key: key }),
};

export default debtResolvers;
