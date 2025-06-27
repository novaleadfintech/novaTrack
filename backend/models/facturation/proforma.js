import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import LigneProforma from "./ligneProforma.js";
import Client, { locateClientFolder } from "../client/client.js";
import { isValidValue } from "../../utils/util.js";
import Service from "./service.js";
import Facture from "./facture.js";
import Banque, { locateBanqueFolder } from "../banque.js";
import Utils, { StatusFacture } from "./utils.js";
const ligneProformaCollection = db.collection("ligneProformas");
const ligneFactureCollection = db.collection("ligneFactures");
const proformaCollection = db.collection("proformas");
const entrepriseCollection = db.collection("entreprise");
const factureCollection = db.collection("factures");
const ligneProformaModel = new LigneProforma();
const serviceModel = new Service();
const utils = new Utils();
const factureModel = new Facture();
const BanqueModel = new Banque();
const clientModel = new Client();
//const tauxTVA = 18;

const statusProforma = {
  wait: "wait",
  cancel: "cancel",
  validated: "validated",
  archived: "archived",
};

const TypeFacture = {
  punctual: "punctual",
};

class Proforma {
  constructor() {}

  getAllProformas = async ({ skip, perPage }) => {
    let limit = aql``;
    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const query = await db.query(
      aql`FOR proforma IN ${proformaCollection} FILTER proforma.status == ${statusProforma.wait} SORT proforma._key DESC ${limit} RETURN proforma`
    );

    if (query.hasNext) {
      const proformas = await query.all();

      return Promise.all(
        proformas.map(async (proforma) => {
          const proformaCopy = { ...proforma };
          const path =
            process.env.FILE_PREFIX +
            `${locateClientFolder}/` +
            proformaCopy.client.logo;
          proformaCopy.client.logo = path;
          const ligneProformas =
            await ligneProformaModel.getLigneProformaByProforma({
              proformaId: proformaCopy._id,
            });
          const montantTotal = utils.calculerMontantTotal({
            lignes: ligneProformas,
            reduction: proformaCopy.reduction,
            tva: proformaCopy.tva,
            tauxTVA: proformaCopy.tauxTVA ?? 0,
          });
          return {
            ...proformaCopy,
            fullCount: await query.extra.stats.fullCount,
            ligneProformas: ligneProformas,
            montant: montantTotal,
          };
        })
      );
    } else {
      return [];
    }
  };
  getArchivedProforma = async () => {
    // let limit = aql``;
    // if (skip !== undefined && perPage !== undefined) {
    //   limit = aql`LIMIT ${skip}, ${perPage}`;
    // }

    const query = await db.query(
      aql`FOR proforma IN ${proformaCollection} FILTER proforma.status != ${statusProforma.wait} SORT proforma._key DESC RETURN proforma`
    );

    if (query.hasNext) {
      const proformas = await query.all();

      return Promise.all(
        proformas.map(async (proforma) => {
          const proformaCopy = { ...proforma };
          const path =
            process.env.FILE_PREFIX +
            `${locateClientFolder}/` +
            proformaCopy.client.logo;
          proformaCopy.client.logo = path;
          const ligneProformas =
            await ligneProformaModel.getLigneProformaByProforma({
              proformaId: proformaCopy._id,
            });
          const montantTotal = utils.calculerMontantTotal({
            lignes: ligneProformas,
            reduction: proformaCopy.reduction,
            tva: proformaCopy.tva,
            tauxTVA: proformaCopy.tauxTVA ?? 0,
          });
          return {
            ...proformaCopy,
            fullCount: await query.extra.stats.fullCount,
            ligneProformas: ligneProformas,
            montant: montantTotal,
          };
        })
      );
    } else {
      return [];
    }
  };

  getProforma = async ({ key }) => {
    try {
      const proforma = await proformaCollection.document(key);

      // Récupérer les lignes de services associées à la proforma
      const ligneProformas =
        await ligneProformaModel.getLigneProformaByProforma({
          proformaId: proforma._id,
        });

      // Calculer le montant total de la proforma en utilisant les lignes de service
      const montantTotal = utils.calculerMontantTotal({
        lignes: ligneProformas,
        reduction: proforma.reduction || 0,
        tva: proforma.tva || false,
        tauxTVA: proforma.tauxTVA ?? 0,
      });

      return {
        ...proforma,
        ligneProformas: ligneProformas,
        montant: montantTotal,
      };
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la récupération : " + err.message
      );
    }
  };

  proformaByClient = async ({ clientId }) => {
    let filtre = aql``;

    if (clientId !== undefined) {
      filtre = aql`FILTER proforma.client._id == ${clientId}`;
    }
    const query = await db.query(
      aql`FOR proforma IN ${proformaCollection} SORT proforma._key DESC ${filtre} RETURN proforma`
    );
    if (query.hasNext) {
      const proformas = await query.all();
      return await Promise.all(
        proformas.map(async (proforma) => {
          const proformaCopy = { ...proforma };

          const path = process.env.FILE_PREFIX + proformaCopy.client.logo;
          proformaCopy.client.logo = path;

          const ligneProformas =
            await ligneProformaModel.getLigneProformaByProforma({
              proformaId: proformaCopy._id,
            });
          const montantTotal = utils.calculerMontantTotal({
            lignes: ligneProformas,
            reduction: proformaCopy.reduction,
            tva: proformaCopy.tva,
            tauxTVA: proformaCopy.tauxTVA ?? 0,
          });

          return {
            ...proformaCopy,
            fullCount: await query.extra.stats.fullCount,
            ligneProformas: ligneProformas,
            montant: montantTotal,
          };
        })
      );
    } else {
      return [];
    }
  };

  createProforma = async ({
    dateEtablissementProforma = Date.now(),
    garantyTime = 0,
    dateEnvoie,
    tva = false,
    clientId,
    ligneProformas,
  }) => {
    let entreprise;
    if (!ligneProformas || ligneProformas.length == 0) {
      throw new Error(
        "Vous devez fournir une ligne de service pour créer un proforma."
      );
    }
    const query = await db.query(
      aql`FOR entreprise IN ${entrepriseCollection} LIMIT 1 RETURN entreprise`
    );
    const session = await db.beginTransaction({
      write: ["proformas", "ligneProformas"],
    });

    try {
      if (query.hasNext) {
        entreprise = await query.next();
      } else {
        throw new Error(
          "Aucune donnée de l'entreprise n'est configurer, veuillez contacter l'administrateur"
        );
      }
      isValidValue({
        value: [dateEtablissementProforma, tva, clientId, ligneProformas],
      });

      const client = await clientModel.getClient({ key: clientId });
      if (!client) throw new Error("Client non trouvé.");

      if (client.logo) {
        client.logo = client.logo.replace(
          process.env.FILE_PREFIX + `${locateClientFolder}/`,
          ""
        );
      }

      const { categorie, ...otherClientInfo } = client;

      const newProforma = {
        reference: await this.generateNewProformaReference(),
        dateEtablissementProforma: dateEtablissementProforma,
        reduction: { unite: null, valeur: null },
        garantyTime: garantyTime,
        dateEnvoie: dateEnvoie,
        tva: tva,
        tauxTVA: entreprise.pays.tauxTVA,
        status: statusProforma.wait,
        client: otherClientInfo,
        dateEnregistrement: Date.now(),
      };

      const montantTotal = utils.calculerMontantTotal({
        lignes: ligneProformas,
        reduction: 0,
        tauxTVA: entreprise.pays.tauxTVA ?? 0,
        tva: tva ?? false,
      });
      if (montantTotal <= 0) {
        throw new Error(
          "Le montant total de la facture semble être inférieur ou égal à zéro."
        );
      }

      await session.step(async () => {
        const proformaInsertResult = await proformaCollection.save(
          newProforma,
          {
            returnNew: true,
          }
        );
        ligneProformas.forEach(async (ligneProforma) => {
          const { serviceId, ...lignePro } = ligneProforma;
          const service = await serviceModel.getService({ key: serviceId });
          // if (service.prix * ligneProforma.quantite <= ligneProforma.remise) {
          //   throw new Error(
          //     "Attention!!! La remise dépasse le montant du service"
          //   );
          // }
          const newLigneProforma = {
            _from: serviceId,
            _to: proformaInsertResult._id,
            service: service,
            // remise: lignePro.remise ?? 0,
            ...lignePro,
          };

          await ligneProformaCollection.save(newLigneProforma);
        });
      });

      await session.commit();
      return "OK";
    } catch (err) {
      await session.abort();
      throw new Error(
        "Une erreur s'est produite lors de la création du proforma.\n" + err
      );
    }
  };

  validerProforma = async ({
    key,
    dateEtablissementFacture = Date.now(),
    banquesIds,
    facturesAcompte,
  }) => {
    const proforma = await this.getProforma({ key: key });
    if (!proforma) {
      throw new Error("Proforma non trouvé.");
    }
    if (proforma.isvalidaded === true) {
      throw new Error("Ce proforma est déjà validé.");
    }

    const {
      dateEtablissementProforma,
      garantie,
      dateEnvoie,
      tauxTVA,
      ligneProformas,
      client,
      tva,
      reduction,
      ...otherProformaData
    } = proforma;

    if (!ligneProformas || ligneProformas.length === 0) {
      throw new Error("Aucune demande n'est sur ce Proforma.");
    }

    const session = await db.beginTransaction({
      write: ["factures", "ligneFactures", "proformas"],
    });

    try {
      // Nettoyage du logo
      if (client.logo) {
        client.logo = client.logo.replace(
          process.env.FILE_PREFIX + `${locateClientFolder}/`,
          ""
        );
      }

      const { categorie, ...otherClientInfo } = client;

      const oldPenalties = await factureModel.getOldPenaltiesForClient({
        clientId: client._id,
      });

      // Injection dans le premier acompte
      const updatedAcomptes = (facturesAcompte || []).map((acompte, index) => {
        if (index === 0 && oldPenalties.length > 0) {
          return {
            ...acompte,
            oldPenalties,
          };
        }
        return acompte;
      });

      const newFacture = {
        reference: await factureModel.generateNewFactureReference(),
        datePayementEcheante: Date.now() + 5 * 24 * 60 * 60 * 1000,
        reduction: reduction,
        tva: tva,
        tauxTVA: tauxTVA,
        type: TypeFacture.punctual,
        client: otherClientInfo,
        dateEtablissementFacture: dateEtablissementFacture,
        dateEnregistrement: Date.now(),
        status: StatusFacture.tobepaid,
        isConvertFromProforma: true,
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
        facturesAcompte: updatedAcomptes,
      };

      await session.step(async () => {
        const factureInsertResult = await factureCollection.save(newFacture, {
          returnNew: true,
        });

        for (const lignePro of ligneProformas) {
          const { _to, _id, _key, _rev, ...otherLigneFac } = lignePro;
          const newLigneFacture = {
            _to: factureInsertResult._id,
            ...otherLigneFac,
          };
          await ligneFactureCollection.save(newLigneFacture);
        }
      });

      await proformaCollection.update(key, {
        status: statusProforma.validated,
      });

      await session.commit();
      return "OK";
    } catch (err) {
      await session.abort();
      throw new Error(
        "Une erreur s'est produite lors de la validation de la Proforma : " +
          err.message
      );
    }
  };

  updateProforma = async ({
    key,
    dateEtablissementProforma,
    dateEnvoie,
    reduction,
    tva,
    clientId,
    garantyTime,
    status,
  }) => {
    const updateField = {};

    if (dateEtablissementProforma !== undefined) {
      updateField.dateEtablissementProforma = dateEtablissementProforma;
    }
    if (dateEnvoie !== undefined) {
      updateField.dateEnvoie = dateEnvoie;
    }

    if (tva !== undefined) {
      updateField.tva = tva;
    }
    if (garantyTime !== undefined) {
      updateField.garantyTime = garantyTime;
    }
    if (status !== undefined) {
      updateField.status = status;
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
    // Validation des champs mis à jour
    isValidValue({ value: updateField });
    if (reduction !== undefined) {
      const proforma = await this.getProforma({ key: key });
      if (
        proforma.montant <=
        utils.reduction({
          lignes: proforma.ligneProformas,
          reduction: reduction,
        })
      ) {
        throw new Error(
          "Attention!!! Le montant de la facture est inférieur à sa réduction"
        );
      }
      updateField.reduction = reduction;
    }
    // Mise à jour dans la collection proforma
    try {
      await proformaCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la mise à jour de la proforma"
      );
    }
  };

  isInvoicePaidTotaly = ({ proforma }) => {
    const montantTotalProforma = utils.calculerMontantTotal({
      lignes: proforma.ligneProformas,
      reduction: proforma.reduction,
      tva: proforma.tva,
      tauxTVA: proforma.tauxTVA ?? 0,
    });
    const sommePaiements = this.calculerMontantPaye({
      payements: proforma.payements,
    });
    return sommePaiements == montantTotalProforma;
  };

  deleteProforma = async ({ key }) => {
    try {
      const proforma = await this.getProforma({ key: key });
      if (proforma.payements.length !== 0) {
        throw new Error();
      }
    } catch {
      throw new Error("Suppression impossible");
    }
    try {
      await ligneProformaModel.deleteAllByProforma({ proformaId: key });
      await proformaCollection.remove(key);
      return "OK";
    } catch (err) {
      throw new Error("Une erreur s'est produite lors la suppression");
    }
  };

  ajouterLigneProforma = async ({
    proformaId,
    serviceId,
    designation,
    prixSupplementaire = 0.0,
    quantite = 1,
    unit,
    dureeLivraison,
    remise = 0.0,
    fraisDivers,
  }) => {
    await this.isExistProforma({ key: proformaId });
    await ligneProformaModel.ajouterLigneProforma({
      proformaId: proformaId,
      serviceId: serviceId,
      designation: designation,
      dureeLivraison: dureeLivraison,
      prixSupplementaire: prixSupplementaire,
      unit: unit,
      fraisDivers: fraisDivers,
      quantite: quantite,
      remise: remise,
    });
    return "OK";
  };

  isExistProforma = async ({ key }) => {
    const exist = await proformaCollection.documentExists(key);
    if (!exist) {
      throw new Error("Cette proforma n'existe pas!");
    }
  };

  calculerMontantPaye = ({ payements }) => {
    return payements
      .map((payement) => payement.montant)
      .reduce((total, montant) => total + montant, 0);
  };

  ///_____________________________________________________
  // ici c'est la fonction qui selectionne  tout les proformat et leur ligne  et fait la mis ç jour les prix

  // cronUpdateServices = async () => {
  //   try {
  //     const query = await db.query(
  //       aql`
  //       FOR ligneProforma IN ${ligneProformaCollection}
  //       LET proforma = DOCUMENT(ligneProforma._to)
  //       proforma.garantyTime != 0
  //       AND ${Date.now()} - proforma.dateEnvoie >= proforma.garantyTime
  //       RETURN ligneProforma
  //     `
  //     );
  //     const ligneProformas = await query.all();
  //     await Promise.all(
  //       ligneProformas.map(async (ligneProforma) => {
  //         const updatedData = {
  //           service: await serviceModel.getService({
  //             key: ligneProforma._from,
  //           }),
  //         };

  //         ligneProformaCollection.update(ligneProforma._id, updatedData);
  //       })
  //     );
  //   } catch (e) {}
  // };

  autoArchiveProforma = async () => {
    try {
      const query = await db.query(
        aql`
      FOR proforma IN ${proformaCollection}
      FILTER proforma.garantyTime != 0 
      AND proforma.status == ${statusProforma.wait}
      AND ${Date.now()} - proforma.dateEnvoie >= proforma.garantyTime
      RETURN proforma
    `
      );
      const proformas = await query.all();
      await Promise.all(
        proformas.map(async (proforma) => {
          await proformaCollection.update(proforma._id, {
            status: statusProforma.archived,
          });
        })
      );
    } catch (e) {
      console.error("Erreur lors de la mise à jour des proformas :", e);
    }
  };

  //01/DG/07/24
  generateNewProformaReference = async () => {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth() + 1;
    const lastTwoDigitsYear = currentYear.toString().slice(-2);

    const startOfMonth = new Date(currentYear, currentMonth - 1, 1).getTime();

    const query = await db.query(
      aql`
        FOR proforma IN ${proformaCollection}
        SORT proforma.dateEnregistrement DESC
        LIMIT 1
        FILTER proforma.dateEnregistrement >= ${startOfMonth}
        RETURN proforma        
      `
    );
    let count = 0;
    if (query.hasNext) {
      const oldproforma = await query.next();
      const oldReference = oldproforma.reference;
      const firstTwoLetters = oldReference.substring(oldReference.length - 2);
      count = parseInt(firstTwoLetters);
    }
    return `DG/PRO/${lastTwoDigitsYear}/${String(currentMonth).padStart(
      2,
      "0"
    )}/${String((count ?? 0) + 1).padStart(2, "0")}`;
  };
}

export default Proforma;
