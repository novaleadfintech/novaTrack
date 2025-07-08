import Poste from "../../models/habilitation/poste.js";

const poste = new Poste();

const posteResolvers = {
  postes: async ({ perPage, skip }) =>
    await poste.getAllPoste({
      skip: skip,
      perPage: perPage,
    }),

  poste: async ({ key }) => await poste.getPoste({ key: key }),

  createPoste: async ({ libelle }) =>
    await poste.createPoste({
      libelle: libelle,
    }),

  updatePoste: async ({ key, libelle }) =>
    await poste.updatePoste({
      key: key,
      libelle: libelle,
    }),

  deletePoste: async ({ key }) => await poste.deletePoste({ key: key }),
};

export default posteResolvers;
