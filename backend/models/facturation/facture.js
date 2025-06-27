import crypto from "crypto";
import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import LigneFacture from "./ligneFacture.js";
import FluxFinancier, {
  FluxFinancierStatus,
  FluxFinancierType,
} from "../flux_financier/flux_financier.js";
import Client, { locateClientFolder } from "../client/client.js";
import { isValidValue } from "../../utils/util.js";
import Service from "./service.js";
import Banque, { locateBanqueFolder } from "../banque.js";
import User from "../habilitation/user.js";
import Utils, { StatusFacture } from "./utils.js";
import {
  stopServiceEmail,
  reccurentInvoiceReadyEmail,
} from "../../utils/send_email.js";
import ClientFactureGlobaLValue from "./client_facture_global_value_model.js";
// import verifyLigneHasInterval from "./ligne.js";
const ligneFactureCollection = db.collection("ligneFactures");
const entrepriseCollection = db.collection("entreprise");
const factureCollection = db.collection("factures");
const fluxFinancierCollection = db.collection("fluxFinanciers");
const utils = new Utils();
const fluxFinancierModel = new FluxFinancier();
const ligneFactureModel = new LigneFacture();
const clientModel = new Client();
const serviceModel = new Service();
const BanqueModel = new Banque();
const userModel = new User();
const clientFactureGlobaLValueModel = new ClientFactureGlobaLValue();
const dailyPenaltyPercentage = 0.01;
const TypeFacture = {
  recurrent: "recurrent",
  punctual: "punctual",
};

class Facture {
  constructor() {}

  /* getAllFactures = async ({ skip, perPage }) => {
    let limit = aql``;
    let filtre = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    const query = await db.query(
      aql`FOR facture IN ${factureCollection} SORT facture._key DESC ${filtre} ${limit} RETURN facture`
    );

    if (query.hasNext) {
      const factures = await query.all();
      return Promise.all(
        factures.map(async (facture) => {
          const factureCopy = { ...facture };
          const path = process.env.FILE_PREFIX + `${locateClientFolder}/` + factureCopy.client.logo;
          factureCopy.client.logo = path;
          const ligneFactures =
            await ligneFactureModel.getLigneFactureByFacture({
              factureId: factureCopy._id,
            });
          const banques = factureCopy.banques ?? [];
          const payements = await fluxFinancierModel.getFluxFiancierbyFacture({
            factureId: factureCopy._id,
          });

          const montantTotal = utils.calculerMontantTotal({
            ligneFactures: ligneFactures,
            reductionFacture: factureCopy.reduction,
            tva: factureCopy.tva,
            tauxTVA: factureCopy.tauxTVA,
          });
          return {
            ...factureCopy,
            fullCount: await query.extra.stats.fullCount,
            ligneFactures: ligneFactures,
            payements: payements,
            montant: montantTotal,
            banques: banques,
          };
        })
      );
    } else {
      return [];
    }
  }; */

  getAllPaidFactures = async ({ skip, perPage }) => {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    let filtre = aql`FILTER facture.status == ${StatusFacture.paid}`;

    const query = await db.query(
      aql`FOR facture IN ${factureCollection} SORT facture.dateEnregistrement DESC ${filtre} ${limit} RETURN facture`
    );

    if (query.hasNext) {
      const factures = await query.all();

      return Promise.all(
        factures.map(async (facture) => {
          const factureCopy = { ...facture };
          const path =
            process.env.FILE_PREFIX +
            `${locateClientFolder}/` +
            factureCopy.client.logo;
          factureCopy.client.logo = path;

          const ligneFactures =
            await ligneFactureModel.getLigneFactureByFacture({
              factureId: factureCopy._id,
            });
          const banques = factureCopy.banques ?? [];
          if (banques.length != 0) {
            banques.map((banque) => {
              banque.logo =
                banque.logo != null
                  ? process.env.FILE_PREFIX +
                    `${locateBanqueFolder}/` +
                    banque.logo
                  : null;
            });
          }
          const payements = await fluxFinancierModel.getFluxFiancierbyFacture({
            factureId: factureCopy._id,
          });

          // Calculer le montant total de la facture
          const montantTotal = utils.calculerMontantTotal({
            lignes: ligneFactures,
            reduction: factureCopy.reduction,
            tva: factureCopy.tva,
            tauxTVA: factureCopy.tauxTVA ?? 0,
          });

          return {
            ...factureCopy,
            fullCount: await query.extra.stats.fullCount,
            ligneFactures: ligneFactures,
            payements: payements,
            montant: montantTotal,
            banques: banques,
          };
        })
      );
    } else {
      return [];
    }
  };

  getAllBlockedInvoice = async ({ skip, perPage }) => {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    let filtre = aql`FILTER facture.status == ${StatusFacture.blocked}`;

    const query = await db.query(
      aql`FOR facture IN ${factureCollection} SORT facture.dateEnregistrement DESC ${filtre} ${limit} RETURN facture`
    );

    if (query.hasNext) {
      const factures = await query.all();

      return Promise.all(
        factures.map(async (facture) => {
          const factureCopy = { ...facture };
          const path =
            process.env.FILE_PREFIX +
            `${locateClientFolder}/` +
            factureCopy.client.logo;
          factureCopy.client.logo = path;

          const ligneFactures =
            await ligneFactureModel.getLigneFactureByFacture({
              factureId: factureCopy._id,
            });
          const banques = factureCopy.banques ?? [];
          if (banques.length != 0) {
            banques.map((banque) => {
              banque.logo =
                banque.logo != null
                  ? process.env.FILE_PREFIX +
                    `${locateBanqueFolder}/` +
                    banque.logo
                  : null;
            });
          }
          const payements = await fluxFinancierModel.getFluxFiancierbyFacture({
            factureId: factureCopy._id,
          });

          // Calculer le montant total de la facture
          const montantTotal = utils.calculerMontantTotal({
            lignes: ligneFactures,
            reduction: factureCopy.reduction,
            tva: factureCopy.tva,
            tauxTVA: factureCopy.tauxTVA ?? 0,
          });

          return {
            ...factureCopy,
            fullCount: await query.extra.stats.fullCount,
            ligneFactures: ligneFactures,
            payements: payements,
            montant: montantTotal,
            banques: banques,
          };
        })
      );
    } else {
      return [];
    }
  };

  getAllFactureToBePaid = async ({ skip, perPage }) => {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const filtre = aql`
    FILTER facture.status != ${StatusFacture.paid} AND facture.isDeletable != true
  `;

    const query = await db.query(
      aql`FOR facture IN ${factureCollection} 
        ${filtre} 
        SORT facture.dateEnregistrement DESC 
        ${limit} 
        RETURN facture`
    );

    if (query.hasNext) {
      const factures = await query.all();
      return Promise.all(
        factures.map(async (facture) => {
          let factureCopy = { ...facture };

          // Mise à jour du logo du client
          const path =
            process.env.FILE_PREFIX +
            `${locateClientFolder}/` +
            factureCopy.client.logo;
          factureCopy.client.logo = path;

          // Récupérer les lignes de factures associées
          const ligneFactures =
            await ligneFactureModel.getLigneFactureByFacture({
              factureId: factureCopy._id,
            });

          // Mise à jour des logos des banques associées
          const banques = factureCopy.banques ?? [];
          if (banques.length !== 0) {
            banques.map((banque) => {
              banque.logo =
                banque.logo != null
                  ? process.env.FILE_PREFIX +
                    `${locateBanqueFolder}/` +
                    banque.logo
                  : null;
            });
          }

          // Récupérer les flux financiers associés à la facture
          const payements = await fluxFinancierModel.getFluxFiancierbyFacture({
            factureId: factureCopy._id,
          });

          // Calculer le montant total de la facture
          const montantTotal = utils.calculerMontantTotal({
            lignes: ligneFactures,
            reduction: factureCopy.reduction,
            tva: factureCopy.tva,
            tauxTVA: factureCopy.tauxTVA ?? 0,
          });

          return {
            ...factureCopy,
            fullCount: await query.extra.stats.fullCount,
            ligneFactures: ligneFactures,
            payements: payements,
            montant: montantTotal,
            banques: banques,
          };
        })
      );
    } else {
      return [];
    }
  };
  getAllPayementFacture = async ({ skip, perPage }) => {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const filtre = aql`
    FILTER facture.status != ${StatusFacture.paid} 
      AND facture.isDeletable != true 

    LET accompteFiltre = (
        FOR acompte IN facture.facturesAcompte
        FILTER acompte.isPaid == false 
          AND acompte.datePayementEcheante != null
        SORT acompte.datePayementEcheante ASC
        RETURN acompte
    )

    FILTER LENGTH(accompteFiltre) > 0

    SORT accompteFiltre[0].datePayementEcheante ASC
`;

    const query = await db.query(
      aql`
    FOR facture IN ${factureCollection}
      ${filtre}
      SORT accompteFiltre[0].datePayementEcheante ASC, facture.dateEnregistrement DESC
      ${limit}
      RETURN facture
  `
    );

    if (query.hasNext) {
      const factures = await query.all();

      return Promise.all(
        factures.map(async (facture) => {
          let factureCopy = { ...facture };

          // Mise à jour du logo du client
          const path =
            process.env.FILE_PREFIX +
            `${locateClientFolder}/` +
            factureCopy.client.logo;
          factureCopy.client.logo = path;

          // Récupérer les lignes de factures associées
          const ligneFactures =
            await ligneFactureModel.getLigneFactureByFacture({
              factureId: factureCopy._id,
            });

          // Mise à jour des logos des banques associées
          const banques = factureCopy.banques ?? [];
          if (banques.length !== 0) {
            banques.map((banque) => {
              banque.logo =
                banque.logo != null
                  ? process.env.FILE_PREFIX +
                    `${locateBanqueFolder}/` +
                    banque.logo
                  : null;
            });
          }

          // Récupérer les flux financiers associés à la facture
          const payements = await fluxFinancierModel.getFluxFiancierbyFacture({
            factureId: factureCopy._id,
          });

          const montantTotal = utils.calculerMontantTotal({
            lignes: ligneFactures,
            reduction: factureCopy.reduction,
            tva: factureCopy.tva,
            tauxTVA: factureCopy.tauxTVA ?? 0,
          });

          return {
            ...factureCopy,
            fullCount: await query.extra.stats.fullCount,
            ligneFactures: ligneFactures,
            payements: payements,
            montant: montantTotal,
            banques: banques,
          };
        })
      );
    } else {
      return [];
    }
  };
  getNewRecurrentFacture = async ({ skip, perPage }) => {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const filtre = aql`
    FILTER facture.isDeletable == true
  `;

    const query = await db.query(
      aql`FOR facture IN ${factureCollection} 
        ${filtre} 
        SORT facture.dateEnregistrement DESC 
        ${limit} 
        RETURN facture`
    );

    if (query.hasNext) {
      const factures = await query.all();

      return Promise.all(
        factures.map(async (facture) => {
          let factureCopy = { ...facture };

          const path =
            process.env.FILE_PREFIX +
            `${locateClientFolder}/` +
            factureCopy.client.logo;
          factureCopy.client.logo = path;

          const ligneFactures =
            await ligneFactureModel.getLigneFactureByFacture({
              factureId: factureCopy._id,
            });

          const banques = factureCopy.banques ?? [];
          if (banques.length !== 0) {
            banques.map((banque) => {
              banque.logo =
                banque.logo != null
                  ? process.env.FILE_PREFIX +
                    `${locateBanqueFolder}/` +
                    banque.logo
                  : null;
            });
          }

          const payements = await fluxFinancierModel.getFluxFiancierbyFacture({
            factureId: factureCopy._id,
          });

          const montantTotal = utils.calculerMontantTotal({
            lignes: ligneFactures,
            reduction: factureCopy.reduction,
            tva: factureCopy.tva,
            tauxTVA: factureCopy.tauxTVA ?? 0,
          });

          return {
            ...factureCopy,
            fullCount: await query.extra.stats.fullCount,
            ligneFactures: ligneFactures,
            payements: payements,
            montant: montantTotal,
            banques: banques,
          };
        })
      );
    } else {
      return [];
    }
  };

  /*  getAllFactureToBePaid = async ({ skip, perPage }) => {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const filtre = aql`
    FILTER facture.status == ${StatusFacture.unpaid} 
    AND LENGTH(
      FOR acompte IN facture.facturesAcompte
      FILTER acompte.datePayementEcheante != null 
        AND acompte.isPaid == false
      RETURN acompte
    ) > 0
  `;

    const query = await db.query(
      aql`FOR facture IN ${factureCollection} 
        ${filtre} 
        SORT facture.dateEnregistrement DESC 
        ${limit} 
        RETURN facture`
    );

    if (query.hasNext) {
      const factures = await query.all();

      return Promise.all(
        factures.map(async (facture) => {
          const factureCopy = { ...facture };

          // Mise à jour du logo du client
          const path = process.env.FILE_PREFIX +
            `${locateClientFolder}/`+ factureCopy.client.logo;
          factureCopy.client.logo = path;

          // Récupérer les lignes de factures associées
          const ligneFactures =
            await ligneFactureModel.getLigneFactureByFacture({
              factureId: factureCopy._id,
            });

          // Mise à jour des logos des banques associées
          const banques = factureCopy.banques ?? [];
          if (banques.length !== 0) {
            banques.map((banque) => {
              banque.logo =
                banque.logo != null
                  ? process.env.FILE_PREFIX+
            `${locateBanqueFolder}/` + banque.logo
                  : null;
            });
          }

          // Récupérer les flux financiers associés à la facture
          const payements = await fluxFinancierModel.getFluxFiancierbyFacture({
            factureId: factureCopy._id,
          });

          // Calculer le montant total de la facture
          const montantTotal = utils.calculerMontantTotal({
            ligneFactures: ligneFactures,
            reductionFacture: factureCopy.reduction,
            tva: factureCopy.tva,
            tauxTVA: factureCopy.tauxTVA,
            oldPenalties: factureCopy.oldPenalties ?? [],
          });

          return {
            ...factureCopy,
            fullCount: await query.extra.stats.fullCount,
            ligneFactures: ligneFactures,
            payements: payements,
            montant: montantTotal,
            banques: banques,
          };
        })
      );
    } else {
      return [];
    }
  }; */

  getFacture = async ({ key }) => {
    try {
      console.log(1);
      const facture = await factureCollection.document(key);
      console.log(2);

      // Récupérer les lignes de services associées à la facture
      const ligneFactures = await ligneFactureModel.getLigneFactureByFacture({
        factureId: facture._id,
      });
      console.log(4);

      const montantTotal = utils.calculerMontantTotal({
        lignes: ligneFactures,
        reduction: facture.reduction || 0,
        tva: facture.tva || false,
        tauxTVA: facture.tauxTVA ?? 0,
      });
      return {
        ...facture,
        ligneFactures: ligneFactures,
        payements: await fluxFinancierModel.getFluxFiancierbyFacture({
          factureId: facture._id,
        }),
        montant: montantTotal,
      };
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la récupération : " + err.message
      );
    }
  };

  factureByClient = async ({ clientId }) => {
    let filtre = aql``;

    if (clientId !== undefined) {
      filtre = aql`FILTER facture.client._id == ${clientId}`;
    }
    const query = await db.query(
      aql`FOR facture IN ${factureCollection} SORT facture._key DESC ${filtre} RETURN facture`
    );
    if (query.hasNext) {
      const factures = await query.all();
      return await Promise.all(
        factures.map(async (facture) => {
          const factureCopy = { ...facture };

          const path = process.env.FILE_PREFIX + factureCopy.client.logo;
          factureCopy.client.logo = path;

          const ligneFactures =
            await ligneFactureModel.getLigneFactureByFacture({
              factureId: factureCopy._id,
            });

          const payements = await fluxFinancierModel.getFluxFiancierbyFacture({
            factureId: factureCopy._id,
          });
          const banques = factureCopy.banques ?? [];
          const montantTotal = utils.calculerMontantTotal({
            lignes: ligneFactures,
            reduction: factureCopy.reduction,
            tva: factureCopy.tva,
            tauxTVA: factureCopy.tauxTVA ?? 0,
          });

          return {
            ...factureCopy,
            fullCount: await query.extra.stats.fullCount,
            ligneFactures: ligneFactures,
            payements: payements,
            montant: montantTotal,
            banques: banques,
          };
        })
      );
    } else {
      return [];
    }
  };

  createFacture = async ({
    type = TypeFacture.punctual,
    datePayementEcheante,
    dateDebutFacturation,
    tva = false,
    clientId,
    facturesAcompte,
    generatePeriod,
    delaisPayment,
    dateEtablissementFacture = Date.now(),
    banquesIds,
    ligneFactures,
  }) => {
    if (!ligneFactures || ligneFactures.length === 0) {
      throw new Error(
        "Vous devez fournir une ligne de service pour créer une facture."
      );
    }

    const entrepriseQuery = await db.query(
      aql`FOR entreprise IN ${entrepriseCollection} LIMIT 1 RETURN entreprise`
    );

    const session = await db.beginTransaction({
      write: ["factures", "ligneFactures"],
    });

    try {
      const entreprise = entrepriseQuery.hasNext
        ? await entrepriseQuery.next()
        : (() => {
            throw new Error("Aucune donnée de l'entreprise n'est configurée.");
          })();

      isValidValue({ value: [type, clientId, ligneFactures, banquesIds] });

      const client = await clientModel.getClient({ key: clientId });
      if (!client) throw new Error("Client non trouvé.");

      if (client.logo) {
        client.logo = client.logo.replace(
          process.env.FILE_PREFIX + `${locateClientFolder}/`,
          ""
        );
      }

      const { categorie, ...otherClientInfo } = client;

      // Récupération des pénalités impayées
      const oldPenalties =
        type !== TypeFacture.recurrent
          ? await this.getOldPenaltiesForClient({ clientId })
          : [];

      // Préparation de la nouvelle facture
      const newFacture = {
        reference: await this.generateNewFactureReference(),
        type,
        datePayementEcheante,
        reduction: { unite: null, valeur: null },
        tva,
        tauxTVA: entreprise.pays.tauxTVA,
        dateDebutFacturation,
        client: otherClientInfo,
        dateEtablissementFacture,
        dateEnregistrement: Date.now(),
        status: StatusFacture.tobepaid,
        banques: await Promise.all(
          banquesIds.map(async (banqueId) => {
            const banque = await BanqueModel.getBanque({ key: banqueId });
            return {
              ...banque,
              logo: banque.logo?.replace(
                process.env.FILE_PREFIX + `${locateBanqueFolder}/`,
                ""
              ),
            };
          })
        ),
        facturesAcompte: facturesAcompte.map((acompte, index) => {
          if (
            index === 0 &&
            oldPenalties.length > 0 &&
            type !== TypeFacture.recurrent
          ) {
            return { ...acompte, oldPenalties };
          }
          return acompte;
        }),
      };

      if (type === TypeFacture.recurrent) {
        newFacture.regenerate = true;
        isValidValue({ value: generatePeriod });
        newFacture.generatePeriod = generatePeriod;
        newFacture.isDeletable = true;
        newFacture.delaisPayment = delaisPayment;
        newFacture.secreteKey = crypto.randomBytes(32).toString("hex");
      }

      const montantTotal = ligneFactureModel.calculerMontantLigneFacture({});
      if (montantTotal <= 0) {
        throw new Error("Le montant total de la facture est invalide.");
      }

      await session.step(async () => {
        const factureInsertResult = await factureCollection.save(newFacture, {
          returnNew: true,
        });

        await Promise.all(
          ligneFactures.map(async (ligneFacture) => {
            const { serviceId, ...lignePro } = ligneFacture;
            const service = await serviceModel.getService({ key: serviceId });
            const newLigneFacture = {
              _from: serviceId,
              _to: factureInsertResult._id,
              service,
              ...lignePro,
            };
            await ligneFactureCollection.save(newLigneFacture);
          })
        );
      });

      await session.commit();
      return "OK";
    } catch (err) {
      await session.abort();
      throw err;
    }
  };

  updateFactureAccompte = async ({
    key,
    datePayementEcheante,
    dateEnvoieFacture,
    rang,
    isSent,
    canPenalty,
    commentaire,
  }) => {
    const facture = await this.getFacture({ key: key });
    if (!facture) {
      throw new Error("Facture non trouvée");
    }
    const acompte = facture.facturesAcompte.find((a) => a.rang === rang);

    if (acompte) {
      if (datePayementEcheante != undefined)
        acompte.datePayementEcheante = datePayementEcheante;
      if (dateEnvoieFacture != undefined)
        acompte.dateEnvoieFacture = dateEnvoieFacture;
      if (isSent != undefined) acompte.isSent = isSent;
      if (canPenalty != undefined) acompte.canPenalty = canPenalty;
      await factureCollection.update(key, {
        facturesAcompte: facture.facturesAcompte,
      });
    } else {
      throw new Error(`Acompte avec rang ${rang} non trouvé`);
    }
    if (commentaire != undefined) {
      commentaire.message =
        "Justification de la modification du délai de paiement de l'acompte N° " +
        rang +
        " de la facture " +
        facture.reference +
        " : " +
        commentaire.message;
      await this.updateFacture({ key: key, commentaire: commentaire });
    }
    return "OK";
  };

  updateFacture = async ({
    key,
    datePayementEcheante,
    reduction,
    facturesAcompte,
    tva,
    clientId,
    commentaire,
    delaisPayment,
    dateEtablissementFacture,
    dateDebutFacturation,
    generatePeriod,
    banquesIds,
  }) => {
    const updateField = {};
    const facture = await this.getFacture({ key: key });

    // if (facture.status !== StatusFacture.tobepaid) {

    //   throw new Error(
    //     "Les données de cette facture ne peuve plus subir de modification."
    //   );
    // }
    // Vérifie si l'une des factures d'acompte a une date de paiement définie
    const acomptePaye = (facture.factureAcompte || []).some(
      (f) => f.datePayementEcheante
    );
    if (acomptePaye) {
      throw new Error("La facture ne peut pas être mise à jour.");
    }
    if (datePayementEcheante !== undefined) {
      updateField.datePayementEcheante = datePayementEcheante;
    }
    if (reduction !== undefined && reduction.valeur != 0) {
      if (
        facture.montant <=
        utils.reduction({
          ligneFactures: facture.ligneFactures,
          reductionFacture: reduction,
        })
      ) {
        throw new Error(
          "Attention!!! Le montant de la facture est inférieur à sa réduction"
        );
      }
      updateField.reduction = reduction;
    }
    if (tva !== undefined) {
      updateField.tva = tva;
    }
    if (clientId !== undefined) {
      const client = await clientModel.getClient({ key: clientId });

      if (client.logo !== undefined && client.logo != null) {
        client.logo = client.logo.replace(
          process.env.FILE_PREFIX + `${locateClientFolder}/`,
          ""
        );
      }
      const { categorie, ...otherClientInfo } = client;
      updateField.client = otherClientInfo;
    }

    if (dateEtablissementFacture !== undefined) {
      updateField.dateEtablissementFacture = dateEtablissementFacture;
    }

    if (generatePeriod !== undefined) {
      updateField.generatePeriod = generatePeriod;
    }

    if (delaisPayment !== undefined) {
      updateField.delaisPayment = delaisPayment;
    }

    if (dateDebutFacturation !== undefined) {
      updateField.dateDebutFacturation = dateDebutFacturation;
    }

    if (facturesAcompte !== undefined) {
      updateField.facturesAcompte = facture.facturesAcompte.map((item) => {
        const newItem = facturesAcompte.find((f) => f.rang === item.rang);
        if (newItem) {
          return {
            ...item,
            ...(newItem.pourcentage !== undefined && {
              pourcentage: newItem.pourcentage,
            }),
            ...(newItem.canPenalty !== undefined && {
              canPenalty: newItem.canPenalty,
            }),
            ...(newItem.dateEnvoieFacture !== undefined && {
              dateEnvoieFacture: newItem.dateEnvoieFacture,
            }),
            ...(newItem.datePayementEcheante !== undefined && {
              datePayementEcheante: newItem.datePayementEcheante,
            }),
          };
        }
        return item;
      });
    }

    if (banquesIds !== undefined) {
      updateField.banques = await Promise.all(
        banquesIds.map(async (banqueId) => {
          const banque = await BanqueModel.getBanque({ key: banqueId });
          return {
            ...banque,
            logo: banque.logo?.replace(
              process.env.FILE_PREFIX + `${locateBanqueFolder}/`,
              ""
            ),
          };
        })
      );
    }

    if (commentaire !== undefined) {
      const commentaires = facture.commentaires || [];
      if (commentaires.length > 0) {
        commentaire.editer = await userModel.getUser({
          key: commentaire.editer,
        });
      }
      commentaires.push(commentaire);
      updateField.commentaires = commentaires;
    }

    isValidValue({ value: updateField });

    try {
      await factureCollection.update(key, updateField);
      return "OK";
    } catch {
      throw new Error("Une erreur s'est produite lors de la mise à jour");
    }
  };

  changeStatusFacture = async ({ key, status }) => {
    const updateField = { status: status };
    try {
      await factureCollection.update(key, updateField);
      return "OK";
    } catch {
      throw new Error("Une erreur s'est produite lors de la validation");
    }
  };

  calculerMontantPaye = ({ payements, montantactuelle = 0 }) => {
    return payements
      .map((payement) => payement.montant)
      .reduce((total, montant) => total + montant, montantactuelle);
  };

  isInvoicePaidTotaly = ({ facture, montantactuelle }) => {
    const montantTotalFacture = facture.montant;
    const sommePaiements = this.calculerMontantPaye({
      payements: facture.payements,
      montantactuelle: montantactuelle,
    });
    return sommePaiements == montantTotalFacture;
  };

  deleteFacture = async ({ key }) => {
    try {
      const facture = await this.getFacture({ key: key });
      if (facture.payements.length !== 0) {
        throw new Error("Cette facture a une fois été payée");
      }
    } catch (err) {
      throw new Error("Suppression impossible" + err);
    }
    try {
      await ligneFactureModel.deleteAllByFactureByForce({ factureId: key });
      await factureCollection.remove(key);
      return "OK";
    } catch (err) {
      throw new Error("Une erreur s'est produite lors la suppression");
    }
  };

  ajouterLigneFacture = async ({
    factureId,
    serviceId,
    designation,
    quantite = 1,
    prixSupplementaire = 0.0,
    unit,
    dureeLivraison,
    remise = 0.0,
    fraisDivers,
  }) => {
    //await this.isExistFacture({ key: factureId });
    await ligneFactureModel.ajouterLigneFacture({
      factureId: factureId,
      serviceId: serviceId,
      designation: designation,
      prixSupplementaire: prixSupplementaire,
      dureeLivraison: dureeLivraison,
      unit: unit,
      fraisDivers: fraisDivers,
      quantite: quantite,
      remise: remise,
    });
    return "OK";
  };

  isExistFacture = async ({ key }) => {
    const exist = await factureCollection.documentExists(key);
    if (!exist) {
      throw new Error("Cette facture n'existe pas!");
    }
  };

  applyPenalty = async ({ facture, acomptePaye, dateOperation }) => {
    const penaltyAmount = this.calculatePenalty({
      dateOperation: dateOperation,
      datePayementEcheante: acomptePaye.datePayementEcheante,
      montant: (facture.montant * acomptePaye.pourcentage) / 100,
    });

    let acompteSuivant = null;

    if (penaltyAmount > 0) {
      const differenceInMillis =
        dateOperation - acomptePaye.datePayementEcheante;
      const daysDifference = Math.max(
        0,
        Math.floor(differenceInMillis / (1000 * 60 * 60 * 24))
      );

      acomptePaye.penalty = {
        montant: penaltyAmount,
        isPaid: false,
        nombreRetard: daysDifference,
      };

      acompteSuivant = facture.facturesAcompte.find(
        (a) =>
          (a.datePayementEcheante !== null ||
            a.datePayementEcheante !== undefined) &&
          a.rang === acomptePaye.rang + 1
      );

      if (acompteSuivant) {
        const oldPenalty = {
          libelle: `Retard de ${daysDifference} jours sur la facture ${facture.reference}-${acomptePaye.rang}`,
          montant: penaltyAmount,
          nbreRetard: daysDifference,
        };

        acompteSuivant.oldPenalties = acompteSuivant.oldPenalties || [];
        acompteSuivant.oldPenalties.push(oldPenalty);

        acomptePaye.penalty.isPaid = true;
      }
    }

    const updatedAcomptes = facture.facturesAcompte.map((acompte) => {
      if (acompte.rang === acomptePaye.rang) {
        return { ...acompte, ...acomptePaye };
      } else if (acompteSuivant && acompte.rang === acompteSuivant.rang) {
        return { ...acompte, ...acompteSuivant };
      }
      return acompte;
    });

    await factureCollection.update(facture._id, {
      facturesAcompte: updatedAcomptes,
    });
  };

  getOldPenaltiesForClient = async ({ clientId }) => {
    const query = await db.query(aql`
      FOR facture IN ${factureCollection}
        FILTER LENGTH(facture.facturesAcompte) > 0 
        AND facture.client._id == ${clientId}
        FOR acompte IN facture.facturesAcompte
          FILTER acompte.penalty.isPaid == false
          RETURN {
            facturePrincipale: facture,
            acompteImpaye: acompte
          }
    `);

    const facturesPenal = query.hasNext ? await query.all() : [];

    const oldPenalties = facturesPenal.map(
      ({ facturePrincipale, acompteImpaye }) => ({
        libelle: `Retard de ${acompteImpaye.penalty.nombreRetard} jours du paiement de la facture d'acompte N° ${facturePrincipale.reference}-${acompteImpaye.rang}`,
        nbreRetard: acompteImpaye.penalty.nombreRetard,
        montant: acompteImpaye.penalty.montant,
      })
    );

    // Marquer les pénalités comme payées
    await Promise.all(
      facturesPenal.map(async ({ facturePrincipale, acompteImpaye }) => {
        const index = facturePrincipale.facturesAcompte.findIndex(
          (acompte) => acompte.rang === acompteImpaye.rang
        );

        if (index !== -1) {
          facturePrincipale.facturesAcompte[index].penalty.isPaid = true;
          await factureCollection.update(facturePrincipale._id, {
            facturesAcompte: facturePrincipale.facturesAcompte,
          });
        }
      })
    );

    return oldPenalties;
  };

  ajouterPayement = async ({
    key,
    montant,
    moyenPayement,
    pieceJustificative,
    referenceTransaction,
    userId,
    bankId,
    clientId,
    dateOperation = Date.now(),
  }) => {
    let libelle;
    isValidValue({ value: [montant, referenceTransaction, userId] });
    const transaction = await db.beginTransaction({
      write: ["factures", "fluxFinanciers"],
    });

    try {
      await clientModel.isExistClient({ key: clientId });

      const facture = await this.getFacture({ key: key });
      const count = facture.payements.length;

      if (!facture) {
        throw new Error("Facture introuvable.");
      }

      if (this.isInvoicePaidTotaly({ facture: facture })) {
        throw new Error("Cette facture est déjà soldée.");
      }

      libelle =
        facture.facturesAcompte.length === 1
          ? `Encaissement de la facture ${facture.reference}`
          : `Encaissement n°${count + 1} de la facture ${facture.reference}`;

      const type = FluxFinancierType.input;

      await fluxFinancierModel.createFluxFinancier(
        {
          factureId: facture._id,
          libelle: libelle,
          reference: await fluxFinancierModel.generateNewFuxFinancierReference({
            type: FluxFinancierType.input,
          }),
          type: type,
          montant: montant,
          isFromSystem: true,
          moyenPayement: moyenPayement,
          referenceTransaction: referenceTransaction,
          pieceJustificative: pieceJustificative,
          userId: userId,
          clientId: clientId,
          bankId: bankId,
          dateOperation: dateOperation,
        },
        transaction
      );

      const acomptePaye = facture.facturesAcompte.find(
        (a) => a.rang === count + 1
      );

      if (!acomptePaye) {
        throw new Error("Aucun acompte correspondant trouvé.");
      }

      acomptePaye.isPaid = true;

      if (facture.status != StatusFacture.blocked) {
        await this.applyPenalty({
          acomptePaye: acomptePaye,
          dateOperation: dateOperation,
          facture: facture,
        });
      } else {
        if (facture.blocked == true) {
          await this.restartService({
            factureId: facture._id,
            secretekey: facture.secreteKey,
            dateRestart: dateOperation,
          });
        }
      }

      if (
        this.isInvoicePaidTotaly({
          facture: facture,
          montantactuelle: montant,
        })
      ) {
        await this.changeStatusFacture({
          key: facture._id,
          status: StatusFacture.paid,
        });
      } else {
        if (facture.status !== StatusFacture.partialpaid) {
          await this.changeStatusFacture({
            key: facture._id,
            status: StatusFacture.partialpaid,
          });
        }
      }
      await transaction.commit();
      return "OK";
    } catch (err) {
      await transaction.abort();
      throw new Error(`Erreur lors du traitement du paiement > ${err.message}`);
    }
  };

  async validateFluxFinancier({ key, validate }) {
    const session = await db.beginTransaction({
      write: ["fluxFinanciers", "banques", "factures"],
    });
    let status;
    try {
      isValidValue({ value: validate });

      const flux = await fluxFinancierModel.getFluxFinancier({ key });

      await userModel.isExistUser({ key: validate.validater });
      const banque = await BanqueModel.getBanque({ key: flux.bank._id });
      const sommeBanquaire = banque.soldeReel;

      if (validate.isValidValue !== FluxFinancierStatus.wait) {
        if (validate.validateStatus === FluxFinancierStatus.valid) {
          await BanqueModel.resetBanqueAmount({
            key: banque._id,
            soldeReel: sommeBanquaire + flux.montant,
          });
          if (flux.factureId || flux.factureId != null) {
            const facture = await this.getFacture({ key: flux.factureId });
            if (
              this.isInvoicePaidTotaly({
                facture: facture,
                montantactuelle: flux.montant,
              })
            ) {
              await this.changeStatusFacture({
                key: facture._id,
                status: StatusFacture.paid,
              });
            } else {
              if (facture.status !== StatusFacture.partialpaid) {
                await this.changeStatusFacture({
                  key: facture._id,
                  status: StatusFacture.partialpaid,
                });
              }
            }
          }
          status = FluxFinancierStatus.valid;
        } else {
          await BanqueModel.resetBanqueAmount({
            key: banque._id,
            soldeTheorique: banque.soldeTheorique - flux.montant,
          });

          status = validate.validateStatus;
        }
      }
      let newValidate =
        flux.validate?.map((validate) => ({
          ...validate,
          validater: validate.validater?._id,
        })) ?? [];
      newValidate.push(validate);
      await session.step(async () => {
        await fluxFinancierCollection.update(key, {
          validate: newValidate,
          status: status,
        });
      });

      await session.commit();
      return "OK";
    } catch (err) {
      await session.abort();
      throw new Error(err.message);
    }
  }

  calculatePenalty = ({ dateOperation, datePayementEcheante, montant }) => {
    const dateOp = new Date(dateOperation);
    const datePayEch = new Date(datePayementEcheante);

    const differenceInMillis = dateOp - datePayEch;

    const daysDifference = Math.max(
      0,
      Math.floor(differenceInMillis / (1000 * 60 * 60 * 24))
    );

    const penaltyAmount = daysDifference * (dailyPenaltyPercentage * montant);

    return penaltyAmount;
  };

  getAllCreanceTobePaid = async ({ begin, end }) => {
    const clientFactures = {};
    const creances = [];
    const todayMidnight = new Date();
    todayMidnight.setHours(0, 0, 0, 0);

    const now = todayMidnight.getTime();
    // Définition du filtre des dates
    let dateFiltre = aql``;
    if (begin !== undefined && end !== undefined) {
      dateFiltre = aql`
            acompte.datePayementEcheante >= ${begin} 
            AND acompte.datePayementEcheante <= ${end}
        `;
    } else {
      dateFiltre = aql`
            acompte.datePayementEcheante >= ${now}
        `;
    }

    // Récupération des factures avec tri sur la plus ancienne datePayementEcheante
    const query = await db.query(aql`
        FOR facture IN ${factureCollection}
            FILTER facture.status != ${StatusFacture.paid}
            LET accompteFiltre = (
                FOR acompte IN facture.facturesAcompte
                FILTER acompte.isPaid == false 
                    AND (acompte.datePayementEcheante == null OR (${dateFiltre}))
                SORT acompte.datePayementEcheante ASC
                RETURN acompte
            )
            FILTER LENGTH(accompteFiltre) > 0
            RETURN { 
                id: facture._id,
            }
    `);

    if (query.hasNext) {
      const facturesData = await query.all();

      // Tri des factures par date la plus ancienne avant traitement
      facturesData.sort(
        (a, b) => (a.oldestDate || Infinity) - (b.oldestDate || Infinity)
      );

      for (const { id: factureid } of facturesData) {
        let facture = await this.getFacture({ key: factureid });

        facture.facturesAcompte = facture.facturesAcompte
          .filter((acompte) => {
            if (acompte.isPaid) return false;
            if (acompte.datePayementEcheante == null) return true;
            if (acompte.datePayementEcheante >= now) return true;
            if (begin !== undefined && end !== undefined) {
              return (
                acompte.datePayementEcheante >= begin &&
                acompte.datePayementEcheante <= end
              );
            }
            return false;
          })
          .sort((a, b) => {
            if (a.datePayementEcheante == null) return 1;
            if (b.datePayementEcheante == null) return -1; // Null en dernier
            return (
              new Date(a.datePayementEcheante) -
              new Date(b.datePayementEcheante)
            );
          });

        if (facture.ligneFactures.length > 0) {
          const clientId = facture.client._id;
          if (!clientFactures[clientId]) {
            clientFactures[clientId] = [];
          }
          clientFactures[clientId].push(facture);
        }
      }

      for (const clientId in clientFactures) {
        const factures = clientFactures[clientId];
        const client = factures[0].client;
        let montantRestant = 0;
        for (const facture of factures) {
          const montantPaye = this.calculerMontantPaye({
            payements: facture.payements,
          });
          montantRestant += facture.montant - montantPaye;
        }

        creances.push({
          client: client,
          factures: factures,
          montantRestant: montantRestant,
        });
      }
    }
    return creances;
  };

  getDailyClaim = async () => {
    const clientFactures = {};
    const creances = [];
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const endOfDay = new Date(today);
    endOfDay.setHours(23, 59, 59, 999);

    const filtre = aql`
    acompte.datePayementEcheante != null AND acompte.datePayementEcheante >= ${today.getTime()} 
    AND acompte.datePayementEcheante <= ${endOfDay.getTime()}
  `;

    const query = await db.query(aql`
    FOR facture IN ${factureCollection}
      FILTER facture.status != ${StatusFacture.paid}
      AND LENGTH(
        FOR acompte IN facture.facturesAcompte
        FILTER acompte.isPaid == false 
          AND ${filtre}
        RETURN acompte
      ) > 0
      RETURN facture._id
  `);

    if (query.hasNext) {
      const facturesId = await query.all();
      for (const factureid of facturesId) {
        const facture = await this.getFacture({ key: factureid });
        if (facture.ligneFactures.length > 0) {
          const clientId = facture.client._id;
          if (!clientFactures[clientId]) {
            clientFactures[clientId] = [];
          }
          clientFactures[clientId].push(facture);
        }
      }

      for (const clientId in clientFactures) {
        const factures = clientFactures[clientId];
        const client = factures[0].client;
        let montantRestant = 0;
        for (const facture of factures) {
          const montantPaye = this.calculerMontantPaye({
            payements: facture.payements,
            montantactuelle: 0,
          });
          montantRestant += facture.montant - montantPaye;
        }
        creances.push({
          client: client,
          factures: factures,
          montantRestant: montantRestant,
        });
      }
    }
    return creances;
  };

  getAllUnpaidCreance = async ({ begin, end }) => {
    const clientFactures = {};
    const creances = [];
    const todayMidnight = new Date();
    todayMidnight.setHours(0, 0, 0, 0);

    const now = todayMidnight.getTime();
    // Vérification et définition du filtre des dates
    if (end !== undefined && end > now) {
      throw new Error(
        "La date de fin doit être inférieure à la date d'aujourd'hui"
      );
    }

    let filtre = aql``;
    if (begin !== undefined && end !== undefined) {
      filtre = aql`
          acompte.datePayementEcheante >= ${begin} 
            AND acompte.datePayementEcheante <= ${end}
        `;
    } else {
      filtre = aql`
            acompte.datePayementEcheante < ${now}
        `;
    }

    // Récupération des factures avec acomptes impayés et en retard
    const query = await db.query(aql`
        FOR facture IN ${factureCollection}
            FILTER facture.status != ${StatusFacture.paid}
            LET accompteFiltre = (
                FOR acompte IN facture.facturesAcompte
                FILTER acompte.isPaid == false 
                    AND acompte.datePayementEcheante != null
                    AND (${filtre})
                RETURN acompte
            )
            FILTER LENGTH(accompteFiltre) > 0
            RETURN { id: facture._id }
    `);

    if (query.hasNext) {
      const facturesData = await query.all();

      for (const { id: factureid } of facturesData) {
        let facture = await this.getFacture({ key: factureid });
        facture.facturesAcompte = facture.facturesAcompte.filter((acompte) => {
          if (acompte.isPaid) return false;
          if (
            acompte.datePayementEcheante === undefined ||
            acompte.datePayementEcheante === null
          )
            return false; // Exclure les dates invalides
          if (begin !== undefined && end !== undefined) {
            return (
              acompte.datePayementEcheante >= begin &&
              acompte.datePayementEcheante <= end
            );
          }
          return true;
        });
        if (facture.ligneFactures.length > 0) {
          const clientId = facture.client._id;
          if (!clientFactures[clientId]) {
            clientFactures[clientId] = [];
          }
          clientFactures[clientId].push(facture);
        }
      }

      for (const clientId in clientFactures) {
        const factures = clientFactures[clientId];
        const client = factures[0].client;
        let montantRestant = 0;

        for (const facture of factures) {
          const montantPaye = this.calculerMontantPaye({
            payements: facture.payements,
          });
          montantRestant += facture.montant - montantPaye;
        }

        creances.push({
          client: client,
          factures: factures,
          montantRestant: montantRestant,
        });
      }
    }

    return creances;
  };

  stopperService = async ({ secretekey }) => {
    try {
      const query = await db.query(
        aql`FOR facture IN ${factureCollection} FILTER facture.secreteKey == ${secretekey} AND facture.regenerate == true RETURN facture`
      );
      if (query.hasNext) {
        const factures = await query.all();
        factures.forEach(async (facture) => {
          await factureCollection.update(facture._id, {
            regenerate: false,
          });
        });
      }
      return "OK";
    } catch {
      throw new Error(
        "La regeneration de cette facture n'a pas pu etre stoppée!"
      );
    }
  };
  //Je dois l'utiliser pour blocker automatiquement.
  blockerService = async ({ secretekey }) => {
    try {
      const query = await db.query(
        aql`FOR facture IN ${factureCollection} FILTER facture.secreteKey == ${secretekey} AND facture.regenerate == true RETURN facture`
      );
      if (query.hasNext) {
        const factures = await query.all();
        factures.forEach(async (facture) => {
          await factureCollection.update(facture._id, {
            regenerate: false,
            blocked: true,
          });
          await this.changeStatusFacture({
            key: facture._id,
            status: StatusFacture.blocked,
          });
        });
      }
      return "OK";
    } catch {
      throw new Error(
        "La regeneration de cette facture n'a pas pu etre stoppée!"
      );
    }
  };

  restartService = async ({
    factureId,
    secretekey,
    dateRestart = Date.now(),
  }) => {
    try {
      const query = await db.query(
        aql`FOR facture IN ${factureCollection} FILTER facture._id == ${factureId} AND facture.secreteKey == ${secretekey} AND facture.regenerate == false SORT facture.dateEnregistrement DESC LIMIT 1 RETURN facture`
      );
      if (query.hasNext) {
        const facture = await query.next();
        await factureCollection.update(facture._id, {
          regenerate: true,
          blocked: false,
          dateDebutFacturation: dateRestart,
        });
      }
      return "OK";
    } catch (e) {
      throw new Error(
        "La regeneration de cette facture n'a pas pu etre activé!" + e
      );
    }
  };

  blockServiceAutomatically = async () => {
    console.log("Début du blocage automatique des services");
    try {
      console.log("awe na wo");
      const todayMidnight = new Date();
      console.log("awo je dire que wo");

      // todayMidnight.setHours(0, 0, 0, 0);
      const now = Date.now();
      console.log("ça continue");

      const query = await db.query(aql`
        FOR facture IN ${factureCollection}
        FILTER facture.regenerate == true AND (facture.status != ${StatusFacture.paid} AND facture.status != ${StatusFacture.blocked})
        LET accompteFiltre = (
          FOR acompte IN facture.facturesAcompte
          FILTER acompte.isPaid == false 
            AND acompte.datePayementEcheante != null
            AND (acompte.datePayementEcheante <= ${now})
          RETURN acompte
        )
        FILTER LENGTH(accompteFiltre) > 0 
        RETURN facture
      `);

      const results = [];

      if (query.hasNext) {
        console.log("au moins j'ai selectionné");

        const factures = await query.all();
        for (const facture of factures) {
          // Récupérer la config client (nbreJrMaxPenalty)

          const nbreJrMaxPenalty =
            (await clientFactureGlobaLValueModel.clientFactureGlobalValueByClient(
              { clientId: facture.client._id }
            )) ?? 0;
          // Vérification : est-ce qu’un acompte est au-delà du délai de grâce ?
          const hasExpired = facture.facturesAcompte.some((acompte) => {
            const limiteTimestamp =
              acompte.datePayementEcheante + nbreJrMaxPenalty * 86400000;
            return limiteTimestamp <= now;
          });

          if (hasExpired) {
            results.push(facture);
          }
        }
      }
      for (const facture of results) {
        // await this.stopperService({ secretekey: facture.secreteKey });
        await stopServiceEmail({
          facture: await this.getFacture({ key: facture._id }),
        });
        await this.applyPenalty({
          acomptePaye: facture.facturesAcompte[0],
          dateOperation: Date.now(),
          facture: facture,
        });
        await this.blockerService({ secretekey: facture.secreteKey });
      }
      console.log("Factures à bloquer :", results);
    } catch (e) {
      console.log(e);
    }
  };

  regenerateFacture = async () => {
    const status = StatusFacture.tobepaid;
    const session = await db.beginTransaction({
      write: ["factures", "ligneFactures"],
    });

    try {
      const query = await db.query(aql`
        FOR facture IN ${factureCollection}
          FILTER facture.regenerate == true
          AND DATE_NOW() - facture.dateDebutFacturation >= facture.generatePeriod
          RETURN facture
      `);

      if (!query.hasNext) return;

      const factures = await query.all();

      for (const facture of factures) {
        const { _id, _key, _rev, isDeletable, ...fact } = facture;

        const oldPenalties = await this.getOldPenaltiesForClient({
          clientId: facture.client._id,
        });

        if (fact.facturesAcompte && fact.facturesAcompte.length > 0) {
          fact.facturesAcompte[0] = {
            ...fact.facturesAcompte[0],
            oldPenalties,
            dateEnvoieFacture: Date.now(),
          };
        } else {
          fact.facturesAcompte = [
            {
              oldPenalties,
              isPaid: false,
              rang: 1,
              pourcentage: 100,
              dateEnvoieFacture: Date.now(),
            },
          ];
        }

        const newFacture = {
          ...fact,
          status,
          reference: await this.generateNewFactureReference(),
          dateEnregistrement: Date.now(),
          dateDebutFacturation: Date.now(),
          dateEtablissementFacture: Date.now(),
        };

        await session.step(async () => {
          const factureInsertResult = await factureCollection.save(newFacture, {
            returnNew: true,
          });
          console.log(factureInsertResult);
          const returnFacture = factureInsertResult.new;

          const ligneFactures =
            await ligneFactureModel.getLigneFactureByFacture({
              factureId: facture._id,
            });

          await Promise.all(
            ligneFactures.map(async (ligneFacture) => {
              const {
                _from,
                designation,
                unit,
                quantite,
                dureeLivraison,
                remise,
                fraisDivers,
                prixSupplementaire,
              } = ligneFacture;

              await this.ajouterLigneFacture({
                designation,
                dureeLivraison,
                factureId: returnFacture._id,
                unit,
                fraisDivers,
                serviceId: _from,
                quantite,
                remise,
                prixSupplementaire,
              });
            })
          );

          if (!facture.isDeletable) {
            await factureCollection.update(facture._id, { regenerate: false });
          } else {
            await this.deleteFacture({ key: facture._id });
          }
          console.log("---------------------------------------------");

          console.log(returnFacture._id);
          console.log("---------------------------------------------");
        });
      }
      await session.commit();
      await reccurentInvoiceReadyEmail({
        facture: await this.getFacture({ key: returnFacture._id }),
      }).catch(() => {
        throw new Error("Échec d'envoi d'e-mail");
      });
      console.log("Factures régénérées avec succès.");
    } catch (error) {
      await session.abort();
      console.error("Erreur lors de la régénération des factures :", error);
    }
  };

  //01/DG/FAC/07/24
  generateNewFactureReference = async () => {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth() + 1;
    const lastTwoDigitsYear = currentYear.toString().slice(-2);

    const startOfMonth = new Date(currentYear, currentMonth - 1, 1).getTime();

    const query = await db.query(
      aql`
      FOR facture IN ${factureCollection}
      SORT facture.dateEnregistrement DESC
      LIMIT 1
      FILTER facture.dateEnregistrement >= ${startOfMonth}
      RETURN facture
    `
    );

    let count = 0;
    if (query.hasNext) {
      const oldfacture = await query.next();
      const oldReference = oldfacture.reference;
      const firstTwoLetters = oldReference.substring(oldReference.length - 2);
      count = parseInt(firstTwoLetters);
    }

    // Correction ici : Assurer l'incrémentation correcte
    const newCount = (count ?? 0) + 1;

    console.log(
      `DG/FAC/${lastTwoDigitsYear}/${String(currentMonth).padStart(
        2,
        "0"
      )}/${String(newCount).padStart(2, "0")}`
    );

    return `DG/FAC/${lastTwoDigitsYear}/${String(currentMonth).padStart(
      2,
      "0"
    )}/${String(newCount).padStart(2, "0")}`;
  };
}

export const chexkAndChangeStatus = async ({ factureId }) => {
  const factureModel = new Facture();
  const facture = await factureModel.getFacture({ key: factureId });
  if (
          this.isInvoicePaidTotaly({
            facture: facture,
            montantactuelle: montant,
          })
        ) {
          await this.changeStatusFacture({
            key: facture._id,
            status: StatusFacture.paid,
          });
        } else {
          if (facture.status !== StatusFacture.partialpaid) {
            await this.changeStatusFacture({
              key: facture._id,
              status: StatusFacture.partialpaid,
            });
          }
        } };
export default Facture;
