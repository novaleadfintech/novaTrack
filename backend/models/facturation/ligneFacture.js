import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import Utils from "./utils.js";
import Service, {Nature} from "./service.js";
import { isValidValue } from "../../utils/util.js";
const utils = new Utils();
const serviceModel = new Service();
const ligneFactureCollection = db.collection("ligneFactures");
const factureCollection = db.collection("factures");

class LigneFacture {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await ligneFactureCollection.exists())) {
      await ligneFactureCollection.create();
    }
    if (!(await factureCollection.exists())) {
      await factureCollection.create();
    }
  }

  getLigneFacture = async ({ key }) => {
    try {
      const ligneFacture = await ligneFactureCollection.document(key);
      const fraisDivers = ligneFacture.fraisDivers ?? [];
      const prixSupplementaire = ligneFacture.prixSupplementaire ?? 0;

      let prixRecalcule;
      if (ligneFacture.service.tarif.length === 0) {
        prixRecalcule = ligneFacture.service.prix + prixSupplementaire;
      } else {
        const tarif = ligneFacture.service.tarif.find((tarif) => {
          if (tarif["maxQuantity"] == null) {
            return ligneFacture.quantite >= tarif["minQuantity"];
          } else {
            return (
              ligneFacture.quantite >= tarif["minQuantity"] &&
              ligneFacture.quantite <= tarif["maxQuantity"]
            );
          }
        });

        if (tarif) {
          prixRecalcule = tarif.prix + prixSupplementaire;
        } else {
          prixRecalcule = ligneFacture.service.prix + prixSupplementaire;
        }
      }
      const montantLigneFacture = this.calculerMontantLigneFacture({
        prix: prixRecalcule,
        quantite: ligneFacture.quantite,
        remise: ligneFacture.remise,
      });

      return {
        ...ligneFacture,
        fraisDivers: fraisDivers,
        montant: montantLigneFacture,
      };
    } catch (err) {
      console.error(err);

      throw new Error(`Document introuvable`);
    }
  };

  getLigneFactureByFacture = async ({ factureKey }) => {
    try {
      const cursor = await db.query(aql`
        FOR ligneFacture IN ${ligneFactureCollection}
          FILTER ligneFacture.factureKey == ${factureKey}
          RETURN ligneFacture
      `);
      const ligneFactures = await cursor.all();

      return await Promise.all(
        ligneFactures
          .sort((a, b) => a.timeStamp - b.timeStamp) // Trie les lignes par timeStamp
          .map(async (ligneFactureEdge) => {
            if (!ligneFactureEdge || !ligneFactureEdge.service) {
              throw new Error("Ligne de facture invalide ou service manquant.");
            }

            const fraisDivers = ligneFactureEdge.fraisDivers ?? [];
            const prixSupplementaire = ligneFactureEdge.prixSupplementaire ?? 0;

            let prixRecalcule = prixSupplementaire;

            // Vérifie si le service a des tarifs définis
            if (ligneFactureEdge.service.nature === Nature.unique) {
              prixRecalcule += ligneFactureEdge.service.prix;
            } else {
              const tarif = ligneFactureEdge.service.tarif.find((tarif) =>
                tarif.maxQuantity == null
                  ? ligneFactureEdge.quantite >= tarif.minQuantity
                  : ligneFactureEdge.quantite >= tarif.minQuantity &&
                    ligneFactureEdge.quantite <= tarif.maxQuantity,
              );

              prixRecalcule += tarif ? tarif.prix : 0;
            }

            // Calcul du montant total de la ligne de facture
            const montantLigneFacture = this.calculerMontantLigneFacture({
              prix: prixRecalcule,
              quantite: ligneFactureEdge.quantite ?? 0,
              // remise: ligneFactureEdge.remise ?? 0,
            });

            return {
              ...ligneFactureEdge,
              montant: montantLigneFacture,
              fraisDivers,
            };
          }),
      );
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la récupération des lignes de service");
    }
  };

  /*  getLigneFacturesByFactureKey =async ({serviceKey})=>{
    const query = await db.query(
      aql`FOR ligneFacture IN ${ligneFactureCollection} FILTER ligneFacture.serviceKey == ${serviceKey} AND ligneFacture.factureKey == ${factureKey} RETURN ligneFacture`
    );
  } */

  updateFacturesInLigneFacture = async (serviceKey) => {
    const query = await db.query(
      aql`
          FOR ligneFacture IN ${ligneFactureCollection}
          FILTER ligneFacture.serviceKey == ${serviceKey}
          LET facture = DOCUMENT(ligneFacture.factureKey)
          FILTER facture.garantyTime == 0
          RETURN ligneFacture
        `,
    );

    const ligneFactures = await query.all();

    await Promise.all(
      ligneFactures.map(async (ligneFacture) => {
        const updatedData = {
          service: await serviceModel.getFacture({ key: serviceKey }),
        };

        await this.updateLigneFactureFactures({
          key: ligneFacture._key,
          updatedData,
        });
      }),
    );
  };

  ajouterLigneFacture = async ({
    factureKey,
    serviceKey,
    designation,
    unit,
    prixSupplementaire = 0.0,
    quantite = 1,
    dureeLivraison,
    remise = 0.0,
    fraisDivers,
  }) => {
    isValidValue({ value: [designation, quantite] });
    const service = await serviceModel.getService({ key: serviceKey });
    const doublon = await db.query(
      aql`FOR ligneFacture IN ${ligneFactureCollection} FILTER ligneFacture.serviceKey == ${serviceKey} AND ligneFacture.factureKey == ${factureKey} RETURN ligneFacture`,
    );
    if (doublon.hasNext) {
      throw new Error(
        "Ajout impossible! Ce service est dejà enregistré sur cette facture",
      );
    }
    if (service.prix * quantite <= remise) {
      throw new Error("Attention!!! La remise dépasse le montant du service");
    }
    const newLigneFacture = {
      serviceKey: serviceKey,
      factureKey: factureKey,
      designation: designation,
      quantite: quantite,
      dureeLivraison: dureeLivraison,
      remise: remise,
      prixSupplementaire: prixSupplementaire,
      unit: unit,
      timeStamp: Date.now(),
      fraisDivers: fraisDivers,
      service: service,
    };

    try {
      await ligneFactureCollection.save(newLigneFacture);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors du traitement");
    }
  };

  updateLigneFacture = async ({
    key,
    designation,
    quantite,
    serviceKey,
    unit,
    dureeLivraison,
    remise,
    prixSupplementaire,
    fraisDivers,
  }) => {
    const session = await db.beginTransaction({
      write: ["factures", "ligneFactures"], // Définition des collections à modifier
    });
    try {
      const updateField = {};

      if (serviceKey !== undefined) {
        const service = await serviceModel.getService({ key: serviceKey });
        updateField.serviceKey = serviceKey;
        updateField.service = service;
      }
      if (designation !== undefined) updateField.designation = designation;

      if (dureeLivraison !== undefined)
        updateField.dureeLivraison = dureeLivraison;
      if (unit !== undefined) updateField.unit = unit;
      if (prixSupplementaire !== undefined)
        updateField.prixSupplementaire = prixSupplementaire;
      if (remise !== undefined) updateField.remise = remise;

      if (fraisDivers !== undefined) {
        fraisDivers.forEach((frais) => {
          for (const key in frais) {
            isValidValue({ value: key });
          }
        });
        updateField.fraisDivers = fraisDivers;
      }

      if (quantite !== undefined) {
        updateField.quantite = quantite;
        isValidValue({ value: quantite });

        let montantTotal = 0;

        await session.step(async () => {
          await ligneFactureCollection.update(key, updateField);

          const ligneFacture = await this.getLigneFacture({ key: key });
          if (!ligneFacture || !ligneFacture.factureKey) {
            throw new Error("Impossible de récupérer la facture liée.");
          }

          const facture = await factureCollection.document(
            ligneFacture.factureKey,
          );
          if (!facture) {
            throw new Error("Facture introuvable.");
          }

          const lignesFactures = await this.getLigneFactureByFacture({
            factureKey: facture._key,
          });
          lignesFactures.forEach((ligne) => {
            if (ligne._key === key) {
              if (ligne.service.nature === Nature.unique) {
                ligne.montant = ligne.service.prix * quantite;
              } else {
                const tarif = ligne.service.tarif.find((tarif) => {
                  return tarif.maxQuantity == null
                    ? quantite >= tarif.minQuantity
                    : quantite >= tarif.minQuantity &&
                        quantite <= tarif.maxQuantity;
                });
                ligne.montant = (tarif ? tarif.prix : 0) * quantite;
              }
              ligne.quantite = ligne.quantite;
            }
          });
          montantTotal = utils.calculerMontantTotal({
            lignes: lignesFactures,
            reduction: facture.reduction,
            tauxTVA: facture.tauxTVA,
            tva: facture.tva,
          });
          if (montantTotal <= 0) {
            throw new Error(
              "Le montant total de la facture semble être inférieur ou égal à zéro.",
            );
          }
        });
      }
      await session.commit();
      return "OK";
    } catch (err) {
      console.error(err);

      await session.abort();
      throw new Error("Erreur lors du traitement");
    }
  };

  //une methode à utiliser pour la tache cron
  updateLigneFactureFactures = async ({ key }) => {
    const ligneFacture = await this.getLigneFacture({ key: key });
    const service = await serviceModel.getService({
      key: ligneFacture.serviceKey,
    });
    await ligneFactureCollection.update(key, { service: service });
    return "OK";
  };

  deleteLigneFacture = async ({ key }) => {
    const ligneFacture = await this.getLigneFacture({ key: key });
    const allLigneFacture = await this.getLigneFactureByFacture({
      factureKey: ligneFacture.factureKey,
    });
    if (allLigneFacture.length == 1) {
      throw new Error(
        "Vous ne pouvez pas retirer tous les demandes sur cette facture",
      );
    } else {
      try {
        await ligneFactureCollection.remove(key);
      } catch (err) {
        console.error(err);

        throw new Error("Erreur lors de la suppression");
      }
    }
    return "OK";
  };

  deleteAllByFacture = async ({ factureKey }) => {
    try {
      const cursor = await db.query(aql`
        FOR ligneFacture IN ${ligneFactureCollection}
          FILTER ligneFacture.factureKey == ${factureKey}
          RETURN ligneFacture
      `);
      const ligneFactures = await cursor.all();
      // if (ligneFactures.length == 1) {
      //   throw new Error(
      //     "Suppression impossible : cette facture ne peut rester sans service!"
      //   );
      // }
      await ligneFactureCollection.removeAll(ligneFactures);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la suppression");
    }
  };

  deleteAllByFactureByForce = async ({ factureKey }) => {
    try {
      const cursor = await db.query(aql`
        FOR ligneFacture IN ${ligneFactureCollection}
          FILTER ligneFacture.factureKey == ${factureKey}
          RETURN ligneFacture
      `);
      const ligneFactures = await cursor.all();
      await ligneFactureCollection.removeAll(ligneFactures);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la suppression");
    }
  };

  calculerMontantLigneFacture({ prix, quantite, remise = 0 }) {
    let total = prix * quantite - remise;

    /* if (fraisDivers.length > 0) {
      fraisDivers.forEach((frais) => {
        if (frais.tva) {
          total += frais.montant * (1 + tauxTVA / 100);
        } else {
          total += frais.montant;
        }
      });
    } */
    return total;
  }
}

export default LigneFacture;
