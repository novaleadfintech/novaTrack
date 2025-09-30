import cron from "node-cron";
import Facture from "../models/facturation/facture.js";
const factureModel = new Facture();
const ProformaModel = new Proforma();
import Bulletin from "../models/bulletin_paie/bulletin.js";
import Proforma from "../models/facturation/proforma.js";
const bulletinModel = new Bulletin();

// Tâche cron pour générer une facture tout les minuites
const tachCron = () => {
  cron.schedule("* * * * *", async () => {
    // console.log("Vérification des facture à dupliquer...");
    try {
      await factureModel.regenerateFacture();
    } catch {}
  });

  // Tâche cron pour mettre à jour les éléments lorsque la date de garantie passe
  cron.schedule("* * * * *", async () => {
    // console.log("Vérification des service à mettre à jour...");
    try {
      await ProformaModel.autoArchiveProforma();
    } catch (err) {
      console.error(err);
    }
  });
  cron.schedule("* * * * *", async () => {
    // console.log("Vérification des bulletins à dupliquer...");
    await bulletinModel.duplicateBulletinsMonthly();
  });

  cron.schedule("* * * * *", async () => {
    // console.log("arreter le regéneration des factures recuurentes....");
    await factureModel.blockServiceAutomatically();
  });

  /* cron.schedule("0 23,0,1,2 * * *", async () => {
    console.log("Vérification des bulletins à dupliquer...");
    await duplicateBulletinsMonthly();
  }); */
};

export default tachCron;

