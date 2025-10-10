import CategoriePaieGrille from "../../models/grille_salariale/categoriePaieGrille.js";

const categoriePaieGrilleModel = new CategoriePaieGrille();

const categoriePaieGrilleResolvers = {
  categoriesPaieGrille: async ({ perPage, skip }) =>
    categoriePaieGrilleModel.getAllCategoriePaieGrille({
      skip: skip,
      perPage: perPage,
    }),

  categoriePaieGrille: async ({ key }) =>
    categoriePaieGrilleModel.getCategoriePaieGrille({ key: key }),

  createCategoriePaieGrille: async ({ libelle }) =>
    categoriePaieGrilleModel.createCategoriePaieGrille({
      libelle: libelle,
      classes: classes,
    }),

  updateCategoriePaieGrille: async ({ key, libelle }) =>
    categoriePaieGrilleModel.updateCategoriePaieGrille({
      key: key,
      libelle: libelle,
    }),

  deleteCategoriePaieGrille: async ({ key }) =>
    categoriePaieGrilleModel.deleteCategoriePaieGrille({ key: key }),
};

export default categoriePaieGrilleResolvers;
