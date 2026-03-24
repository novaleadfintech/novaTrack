import Facture from "../../models/facturation/facture.js";
import getUserFromToken from "../../utils/decode_token.js";
import { hasPermission } from "../middleware/permission_middleware.js";
import PermissionAlias from "../middleware/permisson_alias.js";

const factureModel = new Facture();

const factureResolvers = {
  // Query resolvers
  paidFactures: async ({ skip, perPage }) =>
    await factureModel.getAllPaidFactures({
      skip: skip,
      perPage: perPage,
    }),
  /* NotPaidfactures: async ({ skip, perPage }) =>
    await factureModel.getNotPaidFactures({
      skip: skip,
      perPage: perPage,
    }), */
  unpaidFacture: async ({ skip, perPage }) =>
    await factureModel.getAllFactureToBePaid({
      skip: skip,
      perPage: perPage,
    }),

  blockedInvoice: async ({ skip, perPage }) =>
    await factureModel.getAllBlockedInvoice({
      skip: skip,
      perPage: perPage,
    }),

  payementFacture: async ({ skip, perPage }) =>
    await factureModel.getAllPayementFacture({
      skip: skip,
      perPage: perPage,
    }),
  newRecurrentFacture: async ({ skip, perPage }) =>
    await factureModel.getNewRecurrentFacture({
      skip: skip,
      perPage: perPage,
    }),
  facture: async ({ key }) => await factureModel.getFacture({ key: key }),

  factureByClient: async ({ clientKey }) =>
    await factureModel.factureByClient({ clientKey: clientKey }),

  recurrentFactureByClient: async ({ clientKey }) =>
    await factureModel.recurrentFactureByClient({ clientKey: clientKey }),

  //mutation
  createFacture: async ({
    dateEtablissementFacture,
    type,
    datePayementEcheante,
    dateDebutFacturation,
    facturesAcompte,
    tva,
    delaisPayment,
    clientKey,
    ligneFactures,
    generatePeriod,
    banquesKeys,
  }) =>
    await factureModel.createFacture({
      dateEtablissementFacture: dateEtablissementFacture,
      type: type,
      datePayementEcheante: datePayementEcheante,
      dateDebutFacturation: dateDebutFacturation,
      tva: tva,
      delaisPayment: delaisPayment,
      clientKey: clientKey,
      facturesAcompte: facturesAcompte,
      generatePeriod: generatePeriod,
      ligneFactures: ligneFactures,
      banquesKeys: banquesKeys,
    }),

  updateFacture: async (
    {
      key,
      dateEtablissementFacture,
      datePayementEcheante,
      dateDebutFacturation,
      reduction,
      facturesAcompte,
      delaisPayment,
      tva,
      commentaire,
      clientKey,
      generatePeriod,
      banquesKeys,
    },
    context,
  ) => {
    const user = context.user;
    return await factureModel.updateFacture({
      key: key,
      dateEtablissementFacture: dateEtablissementFacture,
      datePayementEcheante: datePayementEcheante,
      dateDebutFacturation: dateDebutFacturation,
      reduction: reduction,
      facturesAcompte: facturesAcompte,
      tva: tva,
      delaisPayment: delaisPayment,
      commentaire: {
        ...commentaire,
        editer: user._key,
      },
      clientKey: clientKey,
      generatePeriod: generatePeriod,
      banquesKeys: banquesKeys,
    });
  },
  updateFactureAccompte: async (
    {
      key,
      datePayementEcheante,
      dateEnvoieFacture,
      canPenalty,
      rang,
      isSent,
      commentaire,
    },
    context,
  ) => {
    if (canPenalty && !hasPermission(PermissionAlias.exonorerFacturePenalty)) {
      throw new Error(
        "Accès refusé : vous n'avez pas la permission requise pour effectuer cette action",
      );
    }
    return await factureModel.updateFactureAccompte({
      key: key,
      datePayementEcheante: datePayementEcheante,
      dateEnvoieFacture: dateEnvoieFacture,
      isSent: isSent,
      canPenalty: canPenalty,
      commentaire: commentaire,
      rang: rang,
    });
  },
  deleteFacture: async ({ key }) =>
    await factureModel.deleteFacture({ key: key }),

  stopperService: async ({ secretekey }) =>
    await factureModel.stopperService({ secretekey: secretekey }),

  restartService: async ({ factureKey, secretekey }) =>
    await factureModel.restartService({
      factureKey: factureKey,
      secretekey: secretekey,
    }),

  ajouterPayement: async ({
    key,
    montant,
    moyenPayement,
    pieceJustificative,
    referenceTransaction,
    userKey,
    clientKey,
    bankKey,
    dateOperation,
  }) =>
    await factureModel.ajouterPayement({
      key: key,
      montant: montant,
      moyenPayement: moyenPayement,
      referenceTransaction: referenceTransaction,
      pieceJustificative: pieceJustificative,
      userKey: userKey,
      clientKey: clientKey,
      bankKey: bankKey,
      dateOperation: dateOperation,
    }),

  ajouterLigneFacture: async ({
    factureKey,
    serviceKey,
    designation,
    quantite,
    dureeLivraison,
    prixSupplementaire,
    unit,
    remise,
    fraisDivers,
  }) =>
    await factureModel.ajouterLigneFacture({
      factureKey: factureKey,
      serviceKey: serviceKey,
      designation: designation,
      unit: unit,
      prixSupplementaire: prixSupplementaire,
      quantite: quantite,
      dureeLivraison: dureeLivraison,
      remise: remise,
      fraisDivers: fraisDivers,
    }),
};

export default factureResolvers;
