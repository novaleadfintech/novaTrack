import { aql } from "arangojs";
import db from "../../db/database_connection.js";

const variablePaieCollection = db.collection("variablePaies");

class valeurRubriqueTemporaire {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await variablePaieCollection.exists())) {
      await variablePaieCollection.create();
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

  async getBySalarieKey({ salarieKey }) {
    const cursor = await db.query(aql`
      FOR v IN ${variablePaieCollection}
        FILTER v.salarieKey == ${salarieKey}
        RETURN v
    `);
    const result = await cursor.next();
    return result || null;
  }

  async existsForSalarie(salarieKey) {
    const cursor = await db.query(aql`
      RETURN LENGTH(
        FOR v IN ${variablePaieCollection}
          FILTER v.salarieKey == ${salarieKey}
          RETURN 1
      ) > 0
    `);
    const [exists] = await cursor.all();
    return exists === true;
  }

  /**
   * ➕ Créer une valeur rubrique temporaire
   */
  async createVariablesPaies({ salarieKey, rubriques, primesExceptionnelles }) {
    // Vérifie si déjà existant pour éviter doublon
    const exists = await this.existsForSalarie(salarieKey);
    let existVariablePaie;
    const doc = {
      salarieKey,
      rubriques,
      primesExceptionnelles,
      createdAt: Date.now(),
    };
    if (exists) {
      existVariablePaie = await this.getBySalarieKey({ salarieKey: salarieKey });
      if (existVariablePaie) {
        await variablePaieCollection.update(existVariablePaie._key, doc);
        return "OK";
      }
    }
    await variablePaieCollection.save(doc);
    return "OK";
  }

  async updateBySalarieKey(salarieKey, rubriques) {
    const cursor = await db.query(aql`
      FOR v IN ${collection}
        FILTER v.salarieKey == ${salarieKey}
        UPDATE v WITH { rubriques: ${rubriques}, updatedAt: DATE_NOW() } IN ${collection}
        RETURN NEW
    `);
    const result = await cursor.next();
    if (!result) {
      throw new Error(
        `Aucune valeur temporaire trouvée pour le salarié ${salarieKey}`,
      );
    }
    return result;
  }

  async deleteBySalarieKey(salarieKey) {
    const cursor = await db.query(aql`
      FOR v IN ${collection}
        FILTER v.salarieKey == ${salarieKey}
        REMOVE v IN ${collection}
        RETURN OLD
    `);
    const result = await cursor.next();
    return result || null;
  }
}

export default valeurRubriqueTemporaire;
