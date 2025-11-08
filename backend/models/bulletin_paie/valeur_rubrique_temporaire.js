import { aql } from "arangojs";
import db from "../../db/database_connection.js";

const variablePaieCollection = db.collection("variablePaies");

class valeurRubriqueTemporaire {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await variablePaieCollection.exists())) {
      variablePaieCollection.create();
    }
  }

  async getAll() {
    const cursor = await db.query(aql`
      FOR v IN ${variablePaieCollection}
      SORT v._key DESC
      RETURN v
    `);
    return await cursor.all();
  }

  /**
   * 🔍 Récupérer les valeurs rubriques d’un salarié
   */
  async getBySalarieId({ salarieId }) {
    const cursor = await db.query(aql`
      FOR v IN ${variablePaieCollection}
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
        FOR v IN ${variablePaieCollection}
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
  async createVariablesPaies({ salarieId, rubriques, primesExceptionnelles }) {
    // Vérifie si déjà existant pour éviter doublon
    const exists = await this.existsForSalarie(salarieId);
    let existVariablePaie;
    const doc = {
      salarieId,
      rubriques,
      primesExceptionnelles,
      createdAt: Date.now(),
    };
    if (exists) {
      existVariablePaie = await this.getBySalarieId({ salarieId: salarieId });
      if (existVariablePaie) {
        await variablePaieCollection.update(existVariablePaie._id, doc);
        return "OK";
      }
    }
    await variablePaieCollection.save(doc);
    return "OK";
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
