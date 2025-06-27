import LigneFacture from "../../models/facturation/ligneFacture.js";

const ligneFactureModel = new LigneFacture();

const ligneFactureResolvers = {
  ligneFactureByFacture: async ({ factureId }) =>
    await ligneFactureModel.getLigneFactureByFacture({ factureId: factureId }),

  updateLigneFacture: async ({
    key,
    designation,
    quantite,
    unit,
    serviceId,
    dureeLivraison,
    prixSupplementaire,
    remise,
    fraisDivers,
  }) =>
    await ligneFactureModel.updateLigneFacture({
      key: key,
      serviceId: serviceId,
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

  deleteAllByFacture: async ({ factureId }) =>
    await ligneFactureModel.deleteAllByFacture({ factureId: factureId }),
};

export default ligneFactureResolvers;
