import RubriqueBulletin from "../../models/bulletin_paie/rubrique_bulletin.js";

const rubriqueBulletinModel = new RubriqueBulletin();

const rubriqueBulletinResolvers = {
  rubriquesBulletin: async ({ perPage, skip }) =>
    await rubriqueBulletinModel.getAllRubriqueBulletin({
      skip: skip,
      perPage: perPage,
    }),

  rubriqueBulletin: async ({ key }) =>
    rubriqueBulletinModel.getRubriqueBulletin({ key: key }),

  createRubriqueBulletin: async ({
    rubrique,
    code,
    type,
    sectionId,
    portee,
    calcul,
    rubriqueRole,
    rubriqueIdentity,
    taux,
    sommeRubrique,
    nature,
    bareme,
  }) =>
    await rubriqueBulletinModel.createRubriqueBulletin({
      rubrique: rubrique,
      code: code,
      type: type,
      nature: nature,
      portee: portee,
      sectionId: sectionId,
      calcul: calcul,
      rubriqueRole: rubriqueRole,
      rubriqueIdentity: rubriqueIdentity,
      taux: taux,
      bareme: bareme,
      sommeRubrique: sommeRubrique,
    }),

  updateRubriqueBulletin: async ({
    key,
    rubrique,
    // code,
    type,
    sectionId,
    calcul,
    rubriqueIdentity,
    rubriqueRole,
    portee,
    taux,
    sommeRubrique,
    nature,
    bareme,
  }) =>
    await rubriqueBulletinModel.updateRubriqueBulletin({
      key: key,
      rubrique: rubrique,
      // code: code,
      calcul: calcul,
      nature: nature,
      taux: taux,
      portee: portee,
      rubriqueRole: rubriqueRole,
      rubriqueIdentity: rubriqueIdentity,
      bareme: bareme,
      sommeRubrique: sommeRubrique,
      type: type,
      sectionId: sectionId,
    }),

  // deleteBulletinRubrique: async ({ key }) =>
  //   await rubriqueBulletinModel.deleteRubriqueBulletin({ key: key }),
};

export default rubriqueBulletinResolvers;
