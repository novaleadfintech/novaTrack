import LigneProforma from "../../models/facturation/ligneProforma.js";

const ligneProformaModel = new LigneProforma();

const ligneProformaResolvers = {
  ligneProformaByProforma: async ({ proformaId }) =>
    await ligneProformaModel.getLigneProformaByProforma({ proformaId: proformaId }),

  updateLigneProforma: async ({
    key,
    designation,
    quantite,
    unit,
    serviceId,
    prixSupplementaire,
    dureeLivraison,
    remise,
    fraisDivers,
  }) =>
    await ligneProformaModel.updateLigneProforma({
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

  deleteLigneProforma: async ({ key }) =>
    await ligneProformaModel.deleteLigneProforma({ key: key }),

  deleteAllByProforma: async ({ factureId }) =>
    await ligneProformaModel.deleteAllByProforma({ factureId: factureId }),
};

export default ligneProformaResolvers;
