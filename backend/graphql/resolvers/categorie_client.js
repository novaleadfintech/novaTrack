import Categorie from "../../models/client/categorie.js";

const categorieModel = new Categorie();

const categorieResolvers = {
  categories: async ({ perPage, skip }) =>
    categorieModel.getCategories({ skip: skip, perPage: perPage }),

  categorie: async ({ key }) => categorieModel.getCategorie({ key: key }),

  createCategorie: async ({ libelle }) =>
    categorieModel.createCategorie({ libelle: libelle }),

  updateCategorie: async ({ key, libelle }) =>
    categorieModel.updateCategorie({ key: key, libelle: libelle }),

  deleteCateforie: async ({ key }) =>
    categorieModel.deleteCateforie({ key: key }),
};

export default categorieResolvers;
