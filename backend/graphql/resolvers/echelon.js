import Echelon from "../../models/grille_salariale/echelon.js";

const echelonModel = new Echelon();

const echelonResolvers = {
   echelons: async ({ perPage, skip }) =>
    echelonModel.getEchelons({ skip: skip, perPage: perPage }),

   echelon: async ({ key }) => echelonModel.getEchelon({ key: key }),

   createEchelon: async ({ libelle }) =>
    echelonModel.createEchelon({ libelle: libelle }),

   updateEchelon: async ({ key, libelle }) =>
    echelonModel.updateEchelon({ key: key, libelle: libelle }),

   deleteEchelon: async ({ key }) => echelonModel.deleteEchelon({ key: key }),
};

export default echelonResolvers;
