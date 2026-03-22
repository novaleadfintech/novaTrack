import CategorieBulletin from "../../models/bulletin_paie/categorie_bulletin.js";

const categorieBulletinModel = new CategorieBulletin();

const categorieBulletinResolvers = {
  categoriesBulletin: async ({ perPage, skip }) => {
    return await categorieBulletinModel.getAllCategorieBulletin({
      perPage,
      skip,
    });
  },

  categorieBulletin: async ({ key }) => {
    return await categorieBulletinModel.getCategorieBulletin({ key });
  },

  createCategorieBulletin: async ({ categorieBulletin, paieClause }) => {
    return await categorieBulletinModel.createCategorieBulletin({
      categorieBulletin,
      paieClause,
    });
  },

  updateCategorieBulletin: async ({ key, categorieBulletin, paieClause }) => {
    return await categorieBulletinModel.updateCategorieBulletin({
      key,
      categorieBulletin,
      paieClause,
    });
  },

  deleteCategorieBulletin: async ({ key }) => {
    return await categorieBulletinModel.deleteCategorieBulletin({ key });
  },
};

export default categorieBulletinResolvers;
