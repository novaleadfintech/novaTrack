import LigneFacture from "../../models/facturation/ligneFacture.js";

const ligneFactureModel = new LigneFacture();

const ligneFactureResolvers = {
  ligneFactureByFacture: async ({ factureKey }) =>
    await ligneFactureModel.getLigneFactureByFacture({
      factureKey: factureKey,
    }),

  updateLigneFacture: async ({
    key,
    designation,
    quantite,
    unit,
    serviceKey,
    dureeLivraison,
    prixSupplementaire,
    remise,
    fraisDivers,
  }) =>
    await ligneFactureModel.updateLigneFacture({
      key: key,
      serviceKey: serviceKey,
      designation: designation,
      unit: unit,
      prixSupplementaire: prixSupplementaire,
      dureeLivraison: dureeLivraison,
      fraisDivers: fraisDivers,
      quantite: quantite,
      remise: remise,
    }),

  deleteLigneFacture: async ({ key }) =>
    await ligneFactureModel.deleteLigneFacture({ key: key }),

  deleteAllByFacture: async ({ factureKey }) =>
    await ligneFactureModel.deleteAllByFacture({ factureKey: factureKey }),
};

export default ligneFactureResolvers;
