import LigneProforma from "../../models/facturation/ligneProforma.js";

const ligneProformaModel = new LigneProforma();

const ligneProformaResolvers = {
  ligneProformaByProforma: async ({ proformaKey }) =>
    await ligneProformaModel.getLigneProformaByProforma({
      proformaKey: proformaKey,
    }),

  updateLigneProforma: async ({
    key,
    designation,
    quantite,
    unit,
    serviceKey,
    prixSupplementaire,
    dureeLivraison,
    remise,
    fraisDivers,
  }) =>
    await ligneProformaModel.updateLigneProforma({
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

  deleteLigneProforma: async ({ key }) =>
    await ligneProformaModel.deleteLigneProforma({ key: key }),

  deleteAllByProforma: async ({ factureKey }) =>
    await ligneProformaModel.deleteAllByProforma({ factureKey: factureKeyy }),
};

export default ligneProformaResolvers;
