import bulletinCategorie from "../../models/bulletin_paie/categorie_bulletin.js";

const bulletinCategorieModel = new bulletinCategorie();

const bulletinCategorieResolvers = {
  bulletinCategories: async ({ perPage, skip }) => {
    return await bulletinCategorieModel.getAllBulletinCategorie({
      perPage,
      skip,
    });
  },

  bulletinCategorie: async ({ key }) => {
    return await bulletinCategorieModel.getBulletinCategorie({ key });
  },

  createBulletinCategorie: async ({ bulletinCategorie, paieClause }) => {
    return await bulletinCategorieModel.createBulletinCategorie({
      bulletinCategorie,
      paieClause,
    });
  },

  updateBulletinCategorie: async ({ key, bulletinCategorie, paieClause }) => {
    return await bulletinCategorieModel.updateBulletinCategorie({
      key,
      bulletinCategorie,
      paieClause,
    });
  },

  deleteBulletinCategorie: async ({ key }) => {
    return await bulletinCategorieModel.deleteBulletinCategorie({ key });
  },
};

export default bulletinCategorieResolvers;
