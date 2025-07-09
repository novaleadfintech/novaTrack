import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const sectionBulletinCollection = db.collection("sectionBulletins");
const rubriqueBulletinCollection = db.collection("rubriqueBulletins");
class SectionBulletin {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await sectionBulletinCollection.exists())) {
      sectionBulletinCollection.create();
    }
    if (!(await rubriqueBulletinCollection.exists())) {
      rubriqueBulletinCollection.create();
    }
  }

  getAllSectionBulletin = async ({ skip, perPage }) => {
    let limit = aql``;
    if (perPage != undefined && skip != undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    try {
      const query = await db.query(
        aql`
          FOR sectionBulletin IN ${sectionBulletinCollection}
          SORT sectionBulletin.timeStamp DESC
        ${limit}
          RETURN sectionBulletin
        `
      );

      if (query.hasNext) {
        return await query.all();
      } else {
        return [];
      }
    } catch (err) {
      throw new Error("Erreur lors de la récupération" + err);
    }
  };

  getSectionBulletin = async ({ key }) => {
    try {
      return await sectionBulletinCollection.document(key);
    } catch (err) {
      throw new Error(
        "La section bulletin que vous recherchez n'existe pas! " + err
      );
    }
  };

  createSectionBulletin = async ({ section }) => {
    isValidValue({ value: [section] });

    const newSectionBulletin = {
      section: section,
      timeStamp: Date.now(),
    };
    try {
      await sectionBulletinCollection.save(newSectionBulletin);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de l'enregistrement du section"
      );
    }
  };

  updateSectionBulletin = async ({ key, section }) => {
    const updateField = {};
    if (section != undefined) {
      updateField.section = section;
    }

    isValidValue({ value: updateField });
    try {
      await sectionBulletinCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la mise à jour du section"
      );
    }
  };

  deleteSectionBulletin = async ({ key }) => {
    try {
      // Vérifie si une rubrique utilise encore cette section
      const cursor = await db.query(
        `
      FOR rubrique IN ${rubriqueBulletinCollection}
        FILTER rubrique.sectionId == ${key}
        LIMIT 1
        RETURN rubrique
    `
      );

      const rubriqueExistante = await cursor.next();

      if (rubriqueExistante) {
        throw new Error(
          "Impossible de supprimer : cette section est encore utilisée par une rubrique."
        );
      }

      // Suppression de la section
      await sectionBulletinCollection.remove(key);
      return "OK";
    } catch (err) {
      throw new Error(
        err.message ||
          "Une erreur s'est produite lors de la suppression de la section"
      );
    }
  };

  isExistSectionBulletin = async ({ key }) => {
    const exist = await sectionBulletinCollection.documentExists(key);
    if (!exist) {
      throw new Error("Cette section est inexistante!");
    }
  };
}

export default SectionBulletin;
