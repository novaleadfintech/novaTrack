import CategorieBulletin from "../../models/bulletin_bulletin/categorie_bulletin.js";

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

  createCategorieBulletin: async ({ categorieBulletin }) => {
    return await categorieBulletinModel.createCategorieBulletin({
      categorieBulletin,
    });
  },

  updateCategorieBulletin: async ({ key, categorieBulletin }) => {
    return await categorieBulletinModel.updateCategorieBulletin({
      key,
      categorieBulletin,
    });
  },

  deleteCategorieBulletin: async ({ key }) => {
    return await categorieBulletinModel.deleteCategorieBulletin({ key });
  },
};

export default categorieBulletinResolvers;
