import { db, aql } from "../../config/database.js";

const collection = db.collection("variablePaie");

class valeurRubriqueTemporaire {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await salarieCollection.exists())) {
      salarieCollection.create();
    }
  }

  async getAll() {
    const cursor = await db.query(aql`
      FOR v IN ${collection}
      SORT v._key DESC
      RETURN v
    `);
    return await cursor.all();
  }

  /**
   * 🔍 Récupérer les valeurs rubriques d’un salarié
   */
  async getBySalarieId(salarieId) {
    const cursor = await db.query(aql`
      FOR v IN ${collection}
        FILTER v.salarieId == ${salarieId}
        RETURN v
    `);
    const result = await cursor.next();
    return result || null;
  }

  /**
   * ⚙️ Vérifie si un enregistrement temporaire existe déjà
   */
  async existsForSalarie(salarieId) {
    const cursor = await db.query(aql`
      RETURN LENGTH(
        FOR v IN ${collection}
          FILTER v.salarieId == ${salarieId}
          RETURN 1
      ) > 0
    `);
    const [exists] = await cursor.all();
    return exists === true;
  }

  /**
   * ➕ Créer une valeur rubrique temporaire
   */
  async create({ salarieId, rubriques }) {
    // Vérifie si déjà existant pour éviter doublon
    const exists = await this.existsForSalarie(salarieId);
    if (exists) {
      throw new Error(
        `Une valeur temporaire existe déjà pour le salarié ${salarieId}`
      );
    }

    const doc = {
      salarieId,
      rubriques,
      createdAt: Date.now(),
    };

    const meta = await collection.save(doc);
    return { ...doc, _id: meta._id, _key: meta._key };
  }

  async updateBySalarieId(salarieId, rubriques) {
    const cursor = await db.query(aql`
      FOR v IN ${collection}
        FILTER v.salarieId == ${salarieId}
        UPDATE v WITH { rubriques: ${rubriques}, updatedAt: DATE_NOW() } IN ${collection}
        RETURN NEW
    `);
    const result = await cursor.next();
    if (!result) {
      throw new Error(
        `Aucune valeur temporaire trouvée pour le salarié ${salarieId}`
      );
    }
    return result;
  }

  async deleteBySalarieId(salarieId) {
    const cursor = await db.query(aql`
      FOR v IN ${collection}
        FILTER v.salarieId == ${salarieId}
        REMOVE v IN ${collection}
        RETURN OLD
    `);
    const result = await cursor.next();
    return result || null;
  }
}

export default valeurRubriqueTemporaire;
