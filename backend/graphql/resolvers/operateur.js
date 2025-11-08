import Operateur from "../../models/bulletin_paie/operateur.js";

const operateur = new Operateur();

const operateurResolvers = {
  operateurs: async ({ perPage, skip }) =>
    await operateur.getAllOperateur({
      skip: skip,
      perPage: perPage,
    }),

  operateur: async ({ key }) => await operateur.getOperateur({ key: key }),

  createOperateur: async ({ libelle }) =>
    await operateur.createOperateur({
      libelle: libelle,
    }),

  updateOperateur: async ({ key, libelle }) =>
    await operateur.updateOperateur({
      key: key,
      libelle: libelle,
    }),

  deleteOperateur: async ({ key }) =>
    await operateur.deleteOperateur({ key: key }),
};

export default operateurResolvers;
