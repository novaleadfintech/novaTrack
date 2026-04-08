import RubriqueBulletin from "../../models/bulletin_paie/rubrique_categorie_bulletin.js";

const rubriqueBulletinModel = new RubriqueBulletin();

const rubriqueBulletinResolvers = {
  rubriqueBulletinByBulletinCategorie: async ({ bulletinCategorieKey }) =>
    await rubriqueBulletinModel.getRubriqueBulletinByBulletinCategorie({
      bulletinCategorieKey: bulletinCategorieKey,
    }),

  variablePaieAndPrimeExceptionnelles: async ({
    bulletinCategorieKey,
    salarieKey,
  }) =>
    await rubriqueBulletinModel.getvariablePaieAndPrimeExceptionnelles({
      paieCategorieKey: bulletinCategorieKey,
      salarieKey: salarieKey,
    }),

  rubriqueBulletinByBulletinCategorieForConfiguration: async ({
    bulletinCategorieKey,
  }) =>
    await rubriqueBulletinModel.getRubriqueBulletinByBulletinCategorieForConfiguration(
      { bulletinCategorieKey: bulletinCategorieKey },
    ),

  // getRubriqueCategorieConfig: async ({ bulletinCategorieKey }) =>
  //   await rubriqueBulletinModel.getRubriqueCategorieConfig({
  //     bulletinCategorieKey: bulletinCategorieKey,
  //   }),

  // createBulletinCategorieRubrique: async ({
  //   rubriqueKey,
  //   bulletinCategorieKey,
  //   value,
  // }) =>
  //   await rubriqueBulletinModel.createBulletinCategorieRubrique({
  //     rubriqueKey: rubriqueKey,
  //     bulletinCategorieKey: bulletinCategorieKey,
  //     value: value,
  //   }),

  // updateBulletinCategorieRubrique: async ({
  //   rubriqueKey,
  //   bulletinCategorieKey,
  //   value,
  // }) =>
  //   await rubriqueBulletinModel.updateBulletinCategorieRubrique({
  //     rubriqueKey: rubriqueKey,
  //     bulletinCategorieKey: bulletinCategorieKey,
  //     value: value,
  //   }),

  // deleteBulletinCategorieRubrique: async ({
  //   rubriqueKey,
  //   bulletinCategorieKey,
  // }) =>
  //   await rubriqueBulletinModel.deleteBulletinCategorieRubrique({
  //     rubriqueKey: rubriqueKey,
  //     bulletinCategorieKey: bulletinCategorieKey,
  //   }),

  saveRubriqueCategorieConfig: async ({
    bulletinCategorieKey,
    rubriquesConfiged,
  }) =>
    await rubriqueBulletinModel.saveRubriqueCategorieConfig({
      bulletinCategorieKey: bulletinCategorieKey,
      rubriqueConfiged: rubriquesConfiged,
    }),
};

export default rubriqueBulletinResolvers;
