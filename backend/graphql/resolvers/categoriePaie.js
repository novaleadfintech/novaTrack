import CategoriePaie from "../../models/bulletin_paie/categorie_paie.js";

const categoriePaieModel = new CategoriePaie();

const categoriePaieResolvers = {
  categoriesPaie: async ({ perPage, skip }) => {
    return await categoriePaieModel.getAllCategoriePaie({
      perPage,
      skip,
    });
  },

  categoriePaie: async ({ key }) => {
    return await categoriePaieModel.getCategoriePaie({ key });
  },

  createCategoriePaie: async ({ categoriePaie }) => {
    return await categoriePaieModel.createCategoriePaie({
      categoriePaie,
    });
  },

  updateCategoriePaie: async ({ key, categoriePaie }) => {
    return await categoriePaieModel.updateCategoriePaie({
      key,
      categoriePaie,
    });
  },

  deleteCategoriePaie: async ({ key }) => {
    return await categoriePaieModel.deleteCategoriePaie({ key });
  },
};

export default categoriePaieResolvers;
