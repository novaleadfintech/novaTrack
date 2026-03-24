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
    personnelKey,
    bulletinCategorieKey,
    paieClause,
    numeroMatricule,
    periodPaie,
    moyenPaiement,
    numeroCompte,
    operateur,
    classeKey,
    echelonKey,
    grillepaieCategorieKey,
  }) =>
    await salarieModel.createSalarie({
      personnelKey: personnelKey,
      bulletinCategorieKey: bulletinCategorieKey,
      periodPaie: periodPaie,
      paieClause: paieClause,
      moyenPaiement: moyenPaiement,
      numeroMatricule: numeroMatricule,
      numeroCompte: numeroCompte,
      operateur: operateur,
      classeKey: classeKey,
      echelonKey: echelonKey,
      grillepaieCategorieKey: grillepaieCategorieKey,
    }),

  updateSalarie: async ({
    key,
    personnelKey,
    bulletinCategorieKey,
    periodPaie,
    paieClause,
    numeroCompte,
    operateur,
    moyenPaiement,
    classeKey,
    echelonKey,
    grillepaieCategorieKey,
    numeroMatricule,
  }) =>
    await salarieModel.updateSalarie({
      key: key,
      personnelKey,
      bulletinCategorieKey,
      periodPaie,
      numeroCompte,
      operateur,
      moyenPaiement,
      paieClause,
      classeKey,
      echelonKey,
      grillepaieCategorieKey,
      numeroMatricule,
    }),

  deleteSalarie: async ({ key }) =>
    await salarieModel.deleteSalarie({ key: key }),
};

export default salarieResolvers;
