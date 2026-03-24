import paieCategorieGrille from "../../models/grille_salariale/categoriePaieGrille.js";

const paieCategorieGrilleModel = new paieCategorieGrille();

const paieCategorieGrilleResolvers = {
  categoriesPaieGrille: async ({ perPage, skip }) =>
    paieCategorieGrilleModel.getAllpaieCategorieGrille({
      skip: skip,
      perPage: perPage,
    }),

  paieCategorieGrille: async ({ key }) =>
    paieCategorieGrilleModel.getpaieCategorieGrille({ key: key }),

  createpaieCategorieGrille: async ({ libelle, classes }) =>
    paieCategorieGrilleModel.createpaieCategorieGrille({
      libelle: libelle,
      classes: classes,
    }),

  updatepaieCategorieGrille: async ({ key, libelle }) =>
    paieCategorieGrilleModel.updatepaieCategorieGrille({
      key: key,
      libelle: libelle,
    }),

  deletepaieCategorieGrille: async ({ key }) =>
    paieCategorieGrilleModel.deletepaieCategorieGrille({ key: key }),
};

export default paieCategorieGrilleResolvers;
