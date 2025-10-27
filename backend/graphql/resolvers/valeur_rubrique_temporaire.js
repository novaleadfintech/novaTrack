import ValeurRubriqueTemporaireService from "../../models/bulletin_paie/valeur_rubrique_temporaire.js";
const valeurRubriqueTemporaireModel = new ValeurRubriqueTemporaireService();
const valeurRubriqueTemporaireResolvers = {
  valeurRubriqueTemporaireBySalarie: async ({ salarieId }) =>
    await valeurRubriqueTemporaireModel.getBySalarieId(salarieId),

  createValeurRubriqueTemporaire: async ({ salarieId, rubriques }) => {
     return await valeurRubriqueTemporaireModel.createVariablesPaies({
      salarieId,
      rubriques,
    });
  },

  updateValeurRubriqueTemporaire: async ({ salarieId, rubriques }) =>
    await valeurRubriqueTemporaireModel.updateBySalarieId(salarieId, rubriques),

  deleteValeurRubriqueTemporaire: async ({ salarieId }) =>
    await valeurRubriqueTemporaireModel.deleteBySalarieId(salarieId),

  valeurTemporaireExists: async ({ salarieId }) =>
    await valeurRubriqueTemporaireModel.existsForSalarie(salarieId),
};

export default valeurRubriqueTemporaireResolvers;
