import Proforma from "../../models/facturation/proforma.js";

const proformaModel = new Proforma();

const proformaResolvers = {
  proformas: async ({ skip, perPage }) =>
    await proformaModel.getAllProformas({
      skip: skip,
      perPage: perPage,
    }),
  archivedProformas: async () =>
    await proformaModel.getArchivedProforma(),

  proforma: async ({ key }) => await proformaModel.getProforma({ key: key }),

  proformaByClient: async ({ clientId }) =>
    await proformaModel.proformaByClient({ clientId: clientId }),

  createProforma: async ({
    dateEtablissementProforma,
    garantyTime,
    dateEnvoie,
    etat,
    ligneProformas,
    tva,
    clientId,
  }) =>
    await proformaModel.createProforma({
      dateEtablissementProforma: dateEtablissementProforma,
      garantyTime: garantyTime,
      dateEnvoie: dateEnvoie,
      etat: etat,
      tva: tva,
      clientId: clientId,
      ligneProformas: ligneProformas,
    }),

  updateProforma: async ({
    key,
    dateEtablissementProforma,
    garantyTime,
    dateEnvoie,
    reduction,
    tva,
    clientId,
    status,
  }) =>
    await proformaModel.updateProforma({
      key: key,
      dateEtablissementProforma: dateEtablissementProforma,
      garantyTime: garantyTime,
      dateEnvoie: dateEnvoie,
      reduction: reduction,
      tva: tva,
      clientId: clientId,
      status: status,
    }),

  deleteProforma: async ({ key }) =>
    await proformaModel.deleteProforma({ key: key }),

  validerProforma: async ({
    key,
    dateEtablissementFacture,
    facturesAcompte,
    banquesIds,
  }) =>
    await proformaModel.validerProforma({
      key: key,
      dateEtablissementFacture: dateEtablissementFacture,
      banquesIds: banquesIds,
      facturesAcompte: facturesAcompte,
    }),

  ajouterLigneProforma: async ({
    proformaId,
    serviceId,
    designation,
    quantite,
    dureeLivraison,
    unit,
    remise,
    fraisDivers,
  }) =>
    await proformaModel.ajouterLigneProforma({
      proformaId: proformaId,
      serviceId: serviceId,
      designation: designation,
      unit,
      quantite: quantite,
      dureeLivraison: dureeLivraison,
      remise: remise,
      fraisDivers: fraisDivers,
    }),
};

export default proformaResolvers;
