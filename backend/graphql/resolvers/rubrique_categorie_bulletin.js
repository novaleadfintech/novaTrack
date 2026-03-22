import RubriqueBulletin from "../../models/bulletin_paie/rubrique_categorie_bulletin.js";

const rubriqueBulletinModel = new RubriqueBulletin();

const rubriqueBulletinResolvers = {
  rubriqueBulletinByCategorieBulletin: async ({ categorieBulletinId }) =>
    await rubriqueBulletinModel.getRubriqueBulletinByCategorieBulletin({
      categorieBulletinId: categorieBulletinId,
    }),

  variablePaieAndPrimeExceptionnelles: async ({
    categorieBulletinId,
    salarieId,
  }) =>
    await rubriqueBulletinModel.getvariablePaieAndPrimeExceptionnelles({
      categoriePaieId: categorieBulletinId,
      salarieId: salarieId,
    }),

  rubriqueBulletinByCategorieBulletinForConfiguration: async ({
    categorieBulletinId,
  }) =>
    await rubriqueBulletinModel.getRubriqueBulletinByCategorieBulletinForConfiguration(
      { categorieBulletinId: categorieBulletinId },
    ),

  createCategorieBulletinRubrique: async ({
    rubriqueId,
    categorieBulletinId,
    value,
  }) =>
    await rubriqueBulletinModel.createCategorieBulletinRubrique({
      rubriqueId: rubriqueId,
      categorieBulletinId: categorieBulletinId,
      value: value,
    }),

  updateCategorieBulletinRubrique: async ({
    rubriqueId,
    categorieBulletinId,
    value,
  }) =>
    await rubriqueBulletinModel.updateCategorieBulletinRubrique({
      rubriqueId: rubriqueId,
      categorieBulletinId: categorieBulletinId,
      value: value,
    }),

  deleteCategorieBulletinRubrique: async ({
    rubriqueId,
    categorieBulletinId,
  }) =>
    await rubriqueBulletinModel.deleteCategorieBulletinRubrique({
      rubriqueId: rubriqueId,
      categorieBulletinId: categorieBulletinId,
    }),
};

export default rubriqueBulletinResolvers;
