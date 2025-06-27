import SectionBulletin from "../../models/bulletin_paie/section_bulletin.js";

const sectionBulletinModel = new SectionBulletin();

const sectionBulletinResolvers = {
  sectionsBulletin: async ({ perPage, skip }) =>
    await sectionBulletinModel.getAllSectionBulletin({
      skip: skip,
      perPage: perPage,
    }),

  sectionBulletin: async ({ key }) =>
    await sectionBulletinModel.getSectionBulletin({ key: key }),

  createSectionBulletin: async ({ section }) =>
    await sectionBulletinModel.createSectionBulletin({
      section: section,
    }),

  updateSectionBulletin: async ({ key, section }) =>
    await sectionBulletinModel.updateSectionBulletin({
      key: key,
      section: section,
    }),

  deleteSectionBulletin: async ({ key }) =>
    await sectionBulletinModel.deleteLibelle({ key: key }),
};

export default sectionBulletinResolvers;
