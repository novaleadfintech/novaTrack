import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import Service, {Nature} from "./service.js";
import { isValidValue } from "../../utils/util.js";
import Utils from "./utils.js";

const ligneProformaCollection = db.collection("ligneProformas");
const proformaCollection = db.collection("proformas");
const serviceModel = new Service();
const utils = new Utils();
class LigneProforma {
  constructor() {}

  getLigneProforma = async ({ key }) => {
    try {
      const ligneProforma = await ligneProformaCollection.document(key);

      if (!ligneProforma) {
        throw new Error("Ligne de proforma introuvable.");
      }

      const fraisDivers = ligneProforma.fraisDivers ?? [];
      const prixSupplementaire = ligneProforma.prixSupplementaire ?? 0;

      let prixRecalcule;

      if (!ligneProforma.service || ligneProforma.service.tarif.length === 0) {
        prixRecalcule = ligneProforma.service.prix + prixSupplementaire;
      } else {
        const tarif = ligneProforma.service.tarif.find((tarif) => {
          if (tarif["maxQuantity"] == null) {
            return ligneProforma.quantite >= tarif["minQuantity"];
          } else {
            return (
              ligneProforma.quantite >= tarif["minQuantity"] &&
              ligneProforma.quantite <= tarif["maxQuantity"]
            );
          }
        });

        if (tarif) {
          prixRecalcule = tarif.prix + prixSupplementaire;
          
        } else {
          prixRecalcule = ligneProforma.service.prix + prixSupplementaire;
        }
      }

      const montantLigneProforma = this.calculerMontantLigneProforma({
        prix: prixRecalcule,
        quantite: ligneProforma.quantite,
        remise: ligneProforma.remise,
      });

      return {
        ...ligneProforma,
        fraisDivers: fraisDivers,
        montant: montantLigneProforma,
      };
    } catch (err) {
      throw new Error(
        `Erreur lors de la récupération de la ligne de proforma : ${err.message}`
      );
    }
  };

  getLigneProformaByProforma = async ({ proformaId }) => {
    try {
      const ligneProformas = await ligneProformaCollection
        .edges(proformaId)
        ;
     return await Promise.all(
          ligneProformas.edges .sort((a, b) => a.timeStamp - b.timeStamp)
            .map(async (ligneProformaEdge) => {
          const fraisDivers = ligneProformaEdge.fraisDivers ?? [];
          const prixSupplementaire = ligneProformaEdge.prixSupplementaire ?? 0;

          let prixRecalcule;
          if (ligneProformaEdge.service.nature === Nature.unique) {
        prixRecalcule = ligneProformaEdge.service.prix + prixSupplementaire;
      } else {
            const tarif = ligneProformaEdge.service.tarif.find((tarif) => {
              return tarif.maxQuantity == null
                ? ligneProformaEdge.quantite >= tarif.minQuantity
                : ligneProformaEdge.quantite >= tarif.minQuantity &&
                  ligneProformaEdge.quantite <= tarif.maxQuantity;
            });
            prixRecalcule = tarif ? tarif.prix + prixSupplementaire : prixSupplementaire;
          }
           
          const montantLigneProforma = this.calculerMontantLigneProforma({
            prix: prixRecalcule,
            quantite: ligneProformaEdge.quantite,
            // remise: ligneProformaEdge.remise,
          });
              // ligneProformaEdge.service.prix = prixRecalcule;
          return {
            ...ligneProformaEdge,
            fraisDivers: fraisDivers,
            montant: montantLigneProforma,
          };
        })
      );
    } catch (err) {
      throw new Error(
        "Erreur lors de la récupération des lignes de proforma : " + err.message
      );
    }
  };

  /*  getLigneProformasByProformaId =async ({serviceId})=>{
    const query = await db.query(
      aql`FOR ligneProforma IN ${ligneProformaCollection} FILTER ligneProforma._from == ${serviceId} AND ligneProforma._to == ${proformaId} RETURN ligneProforma`
    );
  } */

  updateProformasInLigneProforma = async (serviceId) => {
    const query = await db.query(
      aql`
          FOR ligneProforma IN ${ligneProformaCollection}
          FILTER ligneProforma._from == ${serviceId}
          LET proforma = DOCUMENT(ligneProforma._to)
          FILTER proforma.garantyTime == 0
          RETURN ligneProforma
        `
    );

    const ligneProformas = await query.all();

    await Promise.all(
      ligneProformas.map(async (ligneProforma) => {
        const updatedData = {
          service: await serviceModel.getService({ key: serviceId }),
        };

        await this.updateLigneProformaProformas({
          key: ligneProforma._id,
          updatedData,
        });
      })
    );
  };

  ajouterLigneProforma = async ({
    proformaId,
    serviceId,
    designation,
    unit,
    quantite = 1,
    prixSupplementaire = 0.0,
    dureeLivraison,
    remise = 0.0,
    fraisDivers,
  }) => {
    isValidValue({ value: [designation, quantite,] });
    const service = await serviceModel.getService({ key: serviceId });
    const doublon = await db.query(
      aql`FOR ligneProforma IN ${ligneProformaCollection} FILTER ligneProforma._from == ${serviceId} AND ligneProforma._to == ${proformaId} RETURN ligneProforma`
    );
    if (doublon.hasNext) {
      throw new Error(
        "Ajout impossible! Ce service est dejà enregistré sur cette proforma"
      );
    }
    if (service.prix * quantite <= remise) {
      throw new Error("Attention!!! La remise dépasse le montant du service");
    }
    const newLigneProforma = {
      _from: serviceId,
      _to: proformaId,
      designation: designation,
      quantite: quantite,
      prixSupplementaire: prixSupplementaire,
      dureeLivraison: dureeLivraison,
      remise: remise,
      unit: unit,
      fraisDivers: fraisDivers,
      timeStamp: Date.now(),
      service: service,
    };

    try {
      await ligneProformaCollection.save(newLigneProforma);
      return "OK";
    } catch (err) {
      throw new Error("Erreur lors du traitement" + err);
    }
  };

  updateLigneProforma = async ({
    key,
    designation,
    quantite,
    serviceId,
    unit,
    prixSupplementaire,
    dureeLivraison,
    remise,
    fraisDivers,
  }) => {
    
    const session = await db.beginTransaction({
 write: ["proformas", "ligneProformas"], // Définition des collections à modifier
});
    try {
    const updateField = {};
    if (serviceId !== undefined) {
      const service = await serviceModel.getService({ key: serviceId });
      updateField._from = serviceId;
      updateField.service = service;
    }
    if (designation !== undefined) {
      updateField.designation = designation;
    }

    if (dureeLivraison !== undefined) {
      updateField.dureeLivraison = dureeLivraison;
    }
    if (unit !== undefined) {
      updateField.unit = unit;
    }
    if (prixSupplementaire !== undefined) {
      updateField.prixSupplementaire = prixSupplementaire;
    }
    if (remise !== undefined) {
      updateField.designation = designation;
    }
    if (fraisDivers !== undefined) {
      fraisDivers.map((frais) => {
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
        await ligneProformaCollection.update(key, updateField);

        const ligneProforma = await this.getLigneProforma({ key: key });
        if (!ligneProforma || !ligneProforma._to) {
          throw new Error("Impossible de récupérer la facture liée.");
        }

        const proforma = await proformaCollection.document(ligneProforma._to);
        if (!proforma) {
          throw new Error("Facture introuvable.");
        }

        const lignesProformas = await this.getLigneProformaByProforma({ proformaId: proforma._id });
        lignesProformas.forEach((ligne) => {
         if (ligne._id === key) {
            if (ligne.service.nature === Nature.unique) {
              ligne.montant = ligne.service.prix * quantite;
            } else {
              const tarif = ligne.service.tarif.find((tarif) => {
                return tarif.maxQuantity == null
                  ? quantite >= tarif.minQuantity
                  : quantite >= tarif.minQuantity && quantite <= tarif.maxQuantity;
              });
              ligne.montant = (tarif ? tarif.prix : 0) * quantite;
            }
            ligne.quantite = ligne.quantite;
          }
        });
        
        montantTotal = utils.calculerMontantTotal({
          lignes: lignesProformas,
          reduction: proforma.reduction,
          tauxTVA: proforma.tauxTVA,
          tva: proforma.tva,
        });
        if (montantTotal <=  0) {
          throw new Error("Le montant total du proforma semble être inférieur ou égal à zéro.");
        }
      });
    }
    await session.commit();
    return "OK";
    
    } catch (err) {
      await session.abort();
      throw new Error("Erreur lors du traitement " + err);
    }
  };
  //une methode à utiliser pour la tache cron
  updateLigneProformaProformas = async ({ key }) => {
    const ligneProforma = await this.getLigneProforma({ key: key });
    const service = await serviceModel.getService({
      key: ligneProforma._from,
    });
    await ligneProformaCollection.update(key, { service: service });
    return "OK";
  };

  deleteLigneProforma = async ({ key }) => {
    const ligneProforma = await this.getLigneProforma({ key: key });
    const allligneProforma = await this.getLigneProformaByProforma({
      proformaId: ligneProforma._to,
    });
    if (allligneProforma.length == 1) {
      throw new Error(
        "Vous ne pouvez pas retirer tous les demandes sur ce proforma"
      );
    } else {
      try {
        await ligneProformaCollection.remove(key);
      } catch (err) {
        throw new Error("Erreur lors de la suppression");
      }
    }
    return "OK";
  };

  deleteAllByProforma = async ({ proformaId }) => {
    try {
      const ligneProformas = await ligneProformaCollection.edges(proformaId);
      await ligneProformaCollection.removeAll(ligneProformas.edges);
      return "OK";
    } catch (err) {
      throw new Error("Erreur lors de la suppression");
    }
  };

  calculerMontantLigneProforma({ prix, quantite, remise=0 }) {
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

export default LigneProforma;
