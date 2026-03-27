import GraphQLUpload from "graphql-upload/GraphQLUpload.mjs";
import FluxFinancier from "../../models/flux_financier/flux_financier.js";
import Facture from "../../models/facturation/facture.js";
import getUserFromToken from "../../utils/decode_token.js";

const fluxFiancierModel = new FluxFinancier();
const factureModel = new Facture();

const fluxFinancierResolvers = {
  fluxFinanciers: async ({ perPage, skip, type }) =>
    await fluxFiancierModel.getAllFluxFinanciers({ perPage, skip, type }),

  debtFluxFinanciers: async ({ perPage, skip }) =>
    await fluxFiancierModel.getAllDebtFluxFinanciers({ perPage, skip }),

  archiveFluxFinanciers: async ({ perPage, skip }) =>
    await fluxFiancierModel.getArchiveFluxFinanciers({ perPage, skip }),

  unValidatedFluxFinanciers: async ({ perPage, skip, type }) =>
    await fluxFiancierModel.unValidatedFluxFinanciers({ perPage, skip, type }),

  fluxFinancier: async ({ key }) =>
    await fluxFiancierModel.getFluxFinancier({ key }),

  fluxFinanciersByBank: async ({ debut, fin, banque, status }) =>
    await fluxFiancierModel.getFluxFinanciersByDateAndBank({
      banque: banque,
      fin: fin,
      debut: debut,
      status: status,
    }),

  fluxFiancierbyFacture: async ({ factureKey }) =>
    await fluxFiancierModel.getFluxFiancierbyFacture({ factureKey }),

  yearBilan: async ({ year }) => {
    const result = await fluxFiancierModel.getYearBilan({ year });
    return result.map(([mois, input, output]) => ({
      mois,
      input,
      output,
    }));
  },

  Upload: GraphQLUpload,
  createFluxFinancier: async (
    {
      reference,
      libelle,
      type,
      montant,
      moyenPayement,
      referenceTransaction,
      pieceJustificative,
      dateOperation,
      partiePrenante,
      clientKey,
      userKey,
      factureKey,
      bankKey,
    },
    context,
  ) => {
    const user = context.user;
    return await fluxFiancierModel.createFluxFinancier({
      factureKey: factureKey,
      libelle: libelle,
      reference: reference,
      montant: montant,
      clientKey: clientKey,
      partiePrenante: partiePrenante,
      referenceTransaction: referenceTransaction,
      moyenPayement: moyenPayement,
      pieceJustificative: pieceJustificative,
      type: type,
      userKey: user._key,
      dateOperation: dateOperation,
      bankKey: bankKey,
    });
  },

  updateFluxFinancier: async (
    {
      key,
      libelle,
      type,
      referenceTransaction,
      montant,
      commentaire,
      moyenPayement,
      partiePrenante,
      clientKey,
      pieceJustificative,
      dateOperation,
      bankKey,
    },
    context,
  ) => {
    const user = context.user;
    const fluxFinancier = await fluxFiancierModel.getFluxFinancier({ key });

    // Vérifier si l'utilisateur est le créateur
    if (fluxFinancier.user._key !== user_key) {
      throw new Error("Seul le créateur peut modifier ce flux financier");
    }

    // Vérifier si le flux n'est pas déjà validé
    if (fluxFinancier.validate && fluxFinancier.validate.validateStatus) {
      throw new Error("Impossible de modifier un flux financier déjà validé");
    }

    return await fluxFiancierModel.updateFluxFinancier({
      key: key,
      libelle: libelle,
      montant: montant,
      referenceTransaction: referenceTransaction,
      commentaire: commentaire,
      moyenPayement: moyenPayement,
      pieceJustificative: pieceJustificative,
      partiePrenante: partiePrenante,
      type: type,
      clientKey: clientKey,
      dateOperation: dateOperation,
      bankKey: bankKey,
    });
  },
  deleteFluxFinancier: async ({ key }, context) => {
    const user = context.user;
    const fluxFinancier = await fluxFiancierModel.getFluxFinancier({ key });

    if (fluxFinancier.user._key !== user_key) {
      throw new Error("Seul le créateur peut supprimer ce flux financier");
    }

    if (fluxFinancier.validate && fluxFinancier.validate.validateStatus) {
      throw new Error("Impossible de supprimer un flux financier déjà validé");
    }

    return await fluxFiancierModel.deleteFluxFinancier({ key });
  },

  validateFluxFinancier: async ({ key, validate, commentaire }, context) => {
    const user = context.user;
    const fluxFinancier = await fluxFiancierModel.getFluxFinancier({ key });

    if (fluxFinancier.user._key === user_key) {
      throw new Error(
        "Vous étes celui qui a enregistré ce flux financier, vous ne pouvez plus le valider.",
      );
    }

    // Ajouter l'utilisateur connecté au commentaire
    const commentaireWithUser = commentaire
      ? {
          ...commentaire,
          editer: user._key,
        }
      : undefined;

    return await factureModel.validateFluxFinancier({
      key: key,
      validate: {
        ...validate,
        validater: user._key,
      },
    });
  },

  bilan: async ({ begin, end, type }) =>
    await fluxFiancierModel.getBilan({ begin: begin, end: end, type: type }),
  // yearsBilan: async ({ year }) =>
  //   await fluxFiancierModel.getYearBilan({ year: year }),
};

export default fluxFinancierResolvers;
