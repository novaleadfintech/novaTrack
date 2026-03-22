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
    categorieBulletinId,
    paieClause,
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
      categorieBulletinId: categorieBulletinId,
      periodPaie: periodPaie,
      paieClause: paieClause,
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
    categorieBulletinId,
    periodPaie,
    paieClause,
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
      categorieBulletinId,
      periodPaie,
      numeroCompte,
      operateur,
      moyenPaiement,
      paieClause,
      classeId,
      echelonId,
      grilleCategoriePaieId,
      numeroMatricule,
    }),

  deleteSalarie: async ({ key }) =>
    await salarieModel.deleteSalarie({ key: key }),
};

export default salarieResolvers;
