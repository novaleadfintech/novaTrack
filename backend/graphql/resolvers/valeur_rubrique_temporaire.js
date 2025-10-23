import valeurRubriqueTemporaireService from "../../services/valeur_rubrique_temporaire_service.js";

const valeurRubriqueTemporaireResolvers = {
  valeurRubriqueTemporaireBySalarie: async ({ salarieId }) =>
    await valeurRubriqueTemporaireService.getBySalarieId(salarieId),

  createValeurRubriqueTemporaire: async ({ salarieId, rubriques }) =>
    await valeurRubriqueTemporaireService.createValeurRubriqueTemporaire({
      salarieId,
      rubriques,
    }),

  updateValeurRubriqueTemporaire: async ({ salarieId, rubriques }) =>
    await valeurRubriqueTemporaireService.updateBySalarieId(
      salarieId,
      rubriques
    ),

  deleteValeurRubriqueTemporaire: async ({ salarieId }) =>
    await valeurRubriqueTemporaireService.deleteBySalarieId(salarieId),

  valeurTemporaireExists: async ({ salarieId }) =>
    await valeurRubriqueTemporaireService.existsForSalarie(salarieId),
};

export default valeurRubriqueTemporaireResolvers;
