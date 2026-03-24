import partnerCategorie from "../../models/client/partner_categorie.js";

const categorieModel = new partnerCategorie();

const categorieResolvers = {
  partnerCategories: async ({ perPage, skip }) =>
    categorieModel.getCategories({ skip: skip, perPage: perPage }),

  partnerCategorie: async ({ key }) =>
    categorieModel.getCategorie({ key: key }),

  createPartnerCategorie: async ({ libelle }) =>
    categorieModel.createPartnerCategorie({ libelle: libelle }),

  updatePartnerCategorie: async ({ key, libelle }) =>
    categorieModel.updatePartnerCategorie({ key: key, libelle: libelle }),

  deleteCateforie: async ({ key }) =>
    categorieModel.deleteCateforie({ key: key }),
};

export default categorieResolvers;
