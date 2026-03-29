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
     try {
      await factureModel.regenerateFacture();
    } catch {}
  });

  // Tâche cron pour mettre à jour les éléments lorsque la date de garantie passe
  cron.schedule("* * * * *", async () => {
     try {
      await ProformaModel.autoArchiveProforma();
    } catch (err) {
      console.error(err);
    }
  });
  cron.schedule("* * * * *", async () => {
     await bulletinModel.duplicateBulletinsMonthly();
  });

  cron.schedule("* * * * *", async () => {
     await factureModel.blockServiceAutomatically();
  });

  /* cron.schedule("0 23,0,1,2 * * *", async () => {
     await duplicateBulletinsMonthly();
  }); */
};

export default tachCron;

