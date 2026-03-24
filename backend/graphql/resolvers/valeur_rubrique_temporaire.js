import ValeurRubriqueTemporaireService from "../../models/bulletin_paie/valeur_rubrique_temporaire.js";
const valeurRubriqueTemporaireModel = new ValeurRubriqueTemporaireService();
const valeurRubriqueTemporaireResolvers = {
  valeurRubriqueTemporaireBySalarie: async ({ salarieKey }) =>
    await valeurRubriqueTemporaireModel.getBySalarieKey(salarieKey),

  createValeurRubriqueTemporaire: async ({
    salarieKey,
    rubriques,
    primesExceptionnelles,
  }) => {
    return await valeurRubriqueTemporaireModel.createVariablesPaies({
      salarieKey,
      rubriques,
      primesExceptionnelles,
    });
  },

  updateValeurRubriqueTemporaire: async ({ salarieKey, rubriques }) =>
    await valeurRubriqueTemporaireModel.updateBySalarieKey(salarieKey, rubriques),

  deleteValeurRubriqueTemporaire: async ({ salarieKey }) =>
    await valeurRubriqueTemporaireModel.deleteBySalarieKey(salarieKey),

  valeurTemporaireExists: async ({ salarieKey }) =>
    await valeurRubriqueTemporaireModel.existsForSalarie(salarieKey),
};

export default valeurRubriqueTemporaireResolvers;
