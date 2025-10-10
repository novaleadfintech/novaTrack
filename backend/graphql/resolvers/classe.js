import Classe from "../../models/grille_salariale/classe.js";

const classeModel = new Classe();

const classeResolvers = {
  classes: async ({ perPage, skip }) =>
    classeModel.getAllClasse({ skip: skip, perPage: perPage }),

  classe: async ({ key }) => classeModel.getClasse({ key: key }),

  createClasse: async ({ libelle, echelonIndiciciaires }) =>
    classeModel.createClasse({
      libelle: libelle,
      echelonIndiciciaires: echelonIndiciciaires,
    }),

  updateClasse: async ({ key, libelle }) =>
    classeModel.updateClasse({ key: key, libelle: libelle }),

  deleteClasse: async ({ key }) => classeModel.deleteClasse({ key: key }),
};

export default classeResolvers;
