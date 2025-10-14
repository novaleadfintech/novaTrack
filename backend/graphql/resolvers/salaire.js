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
    periodPaie,
    classeId,
    echelonId,
    grilleCategoriePaieId,
  }) =>
    await salarieModel.createSalarie({
      personnelId: personnelId,
      categoriePaieId: categoriePaieId,
      periodPaie: periodPaie,
      paieManner: paieManner,
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
  }) =>
    await salarieModel.updateSalarie({
      key: key,
      personnelId,
      categoriePaieId,
      periodPaie,
      paieManner,
    }),

  deleteSalarie: async ({ key }) =>
    await salarieModel.deleteSalarie({ key: key }),
};

export default salarieResolvers;
