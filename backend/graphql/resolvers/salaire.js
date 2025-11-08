import Salarie from "../../models/bulletin_paie/salarie.js";

const salarieModel = new Salarie();

const salarieResolvers = {
  salaries: async ({ perPage, skip }) => {
    return await salarieModel.getAllSalarie({
      skip: skip,
      perPage: perPage,
    });
  },

  salarie: async ({ key }) => await salarieModel.getSalarie({ key: key }),

  createSalarie: async ({
    personnelId,
    categoriePaieId,
    paieManner,
    numeroMatricule,
    periodPaie,
    moyenPaiement,
    numeroCompte,
    operateur,
    classeId,
    echelonId,
    grilleCategoriePaieId,
  }) =>
    await salarieModel.createSalarie({
      personnelId: personnelId,
      categoriePaieId: categoriePaieId,
      periodPaie: periodPaie,
      paieManner: paieManner,
      moyenPaiement: moyenPaiement,
      numeroMatricule: numeroMatricule,
      numeroCompte: numeroCompte,
      operateur: operateur,
      classeId: classeId,
      echelonId: echelonId,
      grilleCategoriePaieId: grilleCategoriePaieId,
    }),

  updateSalarie: async ({
    key,
    personnelId,
    categoriePaieId,
    periodPaie,
    paieManner,
    numeroCompte,
    operateur,
    moyenPaiement,
    classeId,
    echelonId,
    grilleCategoriePaieId,
    numeroMatricule,
  }) =>
    await salarieModel.updateSalarie({
      key: key,
      personnelId,
      categoriePaieId,
      periodPaie,
      numeroCompte,
      operateur,
      moyenPaiement,
      paieManner,
      classeId,
      echelonId,
      grilleCategoriePaieId,
      numeroMatricule,
    }),

  deleteSalarie: async ({ key }) =>
    await salarieModel.deleteSalarie({ key: key }),
};

export default salarieResolvers;
