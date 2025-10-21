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
    paiementPlaceId,
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
      paiementPlaceId: paiementPlaceId,
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
    paiementPlace,
    moyenPaiement,
  }) =>
    await salarieModel.updateSalarie({
      key: key,
      personnelId,
      categoriePaieId,
      periodPaie,
      numeroCompte,
      paiementPlace,
      moyenPaiement,
      paieManner,
    }),

  deleteSalarie: async ({ key }) =>
    await salarieModel.deleteSalarie({ key: key }),
};

export default salarieResolvers;
