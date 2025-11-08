import RubriqueBulletin from "../../models/bulletin_paie/rubrique_categorie.js";

const rubriqueBulletinModel = new RubriqueBulletin();

const rubriqueBulletinResolvers = {
  rubriqueBulletinByCategoriePaie: async ({ categoriePaieId }) =>
    await rubriqueBulletinModel.getRubriqueBulletinByCategoriePaie({
      categoriePaieId: categoriePaieId,
    }),

  variablePaieAndPrimeExceptionnelles: async ({ categoriePaieId, salarieId }) =>
    await rubriqueBulletinModel.getvariablePaieAndPrimeExceptionnelles({
      categoriePaieId: categoriePaieId,
      salarieId: salarieId,
    }),

  rubriqueBulletinByCategoriePaieForConfiguration: async ({
    categoriePaieId,
  }) =>
    await rubriqueBulletinModel.getRubriqueBulletinByCategoriePaieForConfiguration(
      { categoriePaieId: categoriePaieId }
    ),

  createRubriqueCategorie: async ({ rubriqueId, categorieId, value }) =>
    await rubriqueBulletinModel.createRubriqueCategorie({
      rubriqueId: rubriqueId,
      categorieId: categorieId,
      value: value,
    }),

  updateRubriqueCategorie: async ({ rubriqueId, categorieId, value }) =>
    await rubriqueBulletinModel.updateRubriqueCategorie({
      rubriqueId: rubriqueId,
      categorieId: categorieId,
      value: value,
    }),

  deleteRubriqueCategorie: async ({ rubriqueId, categorieId }) =>
    await rubriqueBulletinModel.deleteRubriqueCategorie({
      rubriqueId: rubriqueId,
      categorieId: categorieId,
    }),
};

export default rubriqueBulletinResolvers;
