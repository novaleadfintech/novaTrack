import Facture from "../../models/facturation/facture.js";

const factureModel = new Facture();
const creanceResolvers = {
  unpaidCreances: async ({ begin, end }) =>
    await factureModel.getAllUnpaidCreance({ begin, end }),
  creancesTobePay: async ({ begin, end }) =>
    await factureModel.getAllCreanceTobePaid({ begin, end }),
  getDailyClaim: async () => await factureModel.getDailyClaim(),
};

export default creanceResolvers;