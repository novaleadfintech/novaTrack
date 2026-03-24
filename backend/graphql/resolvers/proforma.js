import Proforma from "../../models/facturation/proforma.js";

const proformaModel = new Proforma();

const proformaResolvers = {
  proformas: async ({ skip, perPage }) =>
    await proformaModel.getAllProformas({
      skip: skip,
      perPage: perPage,
    }),
  archivedProformas: async () => await proformaModel.getArchivedProforma(),

  proforma: async ({ key }) => await proformaModel.getProforma({ key: key }),

  proformaByClient: async ({ clientKey }) =>
    await proformaModel.proformaByClient({ clientKey: clientKey }),

  createProforma: async ({
    dateEtablissementProforma,
    garantyTime,
    dateEnvoie,
    etat,
    ligneProformas,
    tva,
    clientKey,
  }) =>
    await proformaModel.createProforma({
      dateEtablissementProforma: dateEtablissementProforma,
      garantyTime: garantyTime,
      dateEnvoie: dateEnvoie,
      etat: etat,
      tva: tva,
      clientKey: clientKey,
      ligneProformas: ligneProformas,
    }),

  updateProforma: async ({
    key,
    dateEtablissementProforma,
    garantyTime,
    dateEnvoie,
    reduction,
    tva,
    clientKey,
    status,
  }) =>
    await proformaModel.updateProforma({
      key: key,
      dateEtablissementProforma: dateEtablissementProforma,
      garantyTime: garantyTime,
      dateEnvoie: dateEnvoie,
      reduction: reduction,
      tva: tva,
      clientKey: clientKey,
      status: status,
    }),

  deleteProforma: async ({ key }) =>
    await proformaModel.deleteProforma({ key: key }),

  valkeyerProforma: async ({
    key,
    dateEtablissementFacture,
    facturesAcompte,
    banquesKeys,
  }) =>
    await proformaModel.valkeyerProforma({
      key: key,
      dateEtablissementFacture: dateEtablissementFacture,
      banquesKeys: banquesKeys,
      facturesAcompte: facturesAcompte,
    }),

  ajouterLigneProforma: async ({
    proformaKey,
    serviceKey,
    designation,
    quantite,
    dureeLivraison,
    unit,
    remise,
    fraisDivers,
  }) =>
    await proformaModel.ajouterLigneProforma({
      proformaKey: proformaKey,
      serviceKey: serviceKey,
      designation: designation,
      unit,
      quantite: quantite,
      dureeLivraison: dureeLivraison,
      remise: remise,
      fraisDivers: fraisDivers,
    }),
};

export default proformaResolvers;
