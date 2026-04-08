import { aql, CollectionType } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import RubriqueBulletin from "./rubrique_bulletin.js";
import BulletinCategorie from "./categorie_bulletin.js";
import ValeurRubriqueTemporaire from "./valeur_rubrique_temporaire.js";
const bulletinCategorieRubriqueCollection = db.collection(
  "bulletinCategorieRubriques",
);
import { PorteeRubrique } from "./bulletin.js";
const rubriqueBulletin = new RubriqueBulletin();
const bulletinCategorieModel = new BulletinCategorie();
const valeurRubriqueTemporaireModel = new ValeurRubriqueTemporaire();

class BulletinCategorieRubrique {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await bulletinCategorieRubriqueCollection.exists())) {
      await bulletinCategorieRubriqueCollection.create();
    }
  }

  getRubriqueBulletinByBulletinCategorie = async ({ bulletinCategorieKey }) => {
    try {
      // Récupérer la config avec le tableau de rubriques complètes
      const cursor = await db.query(aql`
        FOR config IN ${bulletinCategorieRubriqueCollection}
          FILTER config.bulletinCategorieKey == ${bulletinCategorieKey}
          FILTER config.rubriques != null
          LIMIT 1
          RETURN config
      `);

      if (!cursor.hasNext) {
        return [];
      }

      const config = await cursor.next();
      const storedRubriques = config.rubriques || [];

      // Transformer en format attendu (RubriqueOnBulletin)
      const result = storedRubriques.map((rubrique) => ({
        rubrique: rubrique,
        value: rubrique.value ?? null,
      }));

      // Trier les résultats par timeStamp croissant
      result.sort((a, b) => {
        const tA = a.rubrique?.timeStamp ?? 0;
        const tB = b.rubrique?.timeStamp ?? 0;
        return tA - tB;
      });

      return result;
    } catch (e) {
      console.error(e);
      throw new Error("Erreur lors de la récupération des données");
    }
  };

  //selection des valeurs
  getvariablePaieAndPrimeExceptionnelles = async ({
    bulletinCategorieKey,
    salarieKey,
  }) => {
    try {
      const cursor = await db.query(aql`
        FOR variablePaie IN ${bulletinCategorieRubriqueCollection}
          FILTER variablePaie.bulletinCategorieKey == ${bulletinCategorieKey}
          RETURN variablePaie
      `);
      const rubriqueConfiforCategorie = await cursor.all();

      const existingVariable =
        await valeurRubriqueTemporaireModel.getBySalarieKey({
          salarieKey: salarieKey,
        });
      // existingVariable is a document with shape { salarieKey, rubriques: [{ rubriqueKey, value }], primesExceptionnelles: [...] }
      const rubriquesVariables = existingVariable?.rubriques || [];
      const primesVariables = existingVariable?.primesExceptionnelles || [];
      // A REMPLACER PAR LA LISTE DE IDENTITE DEFINI DANS BULLETIN
      const excludedIdentities = [
        "anciennete",
        "avanceSurSalaire",
        "primeExceptionnelle",
        "nombrePersonneCharge",
        "salaireBase",
        "netPayer",
      ];

      const rubriqueEntries = [];
      for (const bulletinCategorieRubrique of rubriqueConfiforCategorie) {
        const rubrique = await rubriqueBulletin.getRubriqueBulletin({
          key: bulletinCategorieRubrique.rubriqueKey,
        });

        // Garder uniquement les rubriques de nature constante et valeur nulle, et exclure certaines identités
        if (
          rubrique.portee == PorteeRubrique.individuel &&
          //  !(
          //    rubrique?.nature == NatureRubrique.constant &&
          //    rubrique?.value != null
          //  ) ||
          excludedIdentities.includes(rubrique?.rubriqueIdentity)
        ) {
          continue;
        }

        // Chercher une valeur personnalisée (si déjà définie)
        const variableForRubrique = rubriquesVariables.find(
          (v) =>
            v.rubriqueKey === rubrique.key ||
            v.rubriqueKey === bulletinCategorieRubrique.rubriqueKey,
        );

        const entry = {
          value:
            variableForRubrique?.value !== undefined
              ? variableForRubrique.value
              : (rubrique.value ?? null),
          rubrique: { ...rubrique },
        };

        rubriqueEntries.push(entry);
      }

      // trier par timeStamp
      rubriqueEntries.sort((a, b) => {
        const tA = a.rubrique?.timeStamp ?? 0;
        const tB = b.rubrique?.timeStamp ?? 0;
        return tA - tB;
      });

      // Construire les primes exceptionnelles : combiner celles définies dans la configuration et celles stockées pour le salarié
      const primesFromExistingPromises = (primesVariables || []).map(
        async (pe) => {
          const rubrique = await rubriqueBulletin.getRubriqueBulletin({
            key: pe.rubriqueKey,
          });
          return { value: pe.value, rubrique };
        },
      );
      const primesFromExisting = await Promise.all(primesFromExistingPromises);

      // retourner sous la forme attendue par le frontend : liste de ValeurRubriqueTemporaire

      return {
        ...existingVariable,
        salarieKey: salarieKey,
        paieVariables: rubriqueEntries,
        primesExceptionnelles: primesFromExisting,
      };
    } catch (e) {
      console.error(e);
      throw new Error(
        "Erreur lors de la récupération des rubriques de type constante à valeur nulle",
      );
    }
  };

  getRubriqueBulletinByBulletinCategorieForConfiguration = async ({
    bulletinCategorieKey,
  }) => {
    try {
      // Récupérer la config avec le tableau de rubriques complètes
      const cursor = await db.query(aql`
        FOR config IN ${bulletinCategorieRubriqueCollection}
          FILTER config.bulletinCategorieKey == ${bulletinCategorieKey}
          FILTER config.rubriques != null
          LIMIT 1
          RETURN config
      `);

      let storedRubriques = [];
      if (cursor.hasNext) {
        const config = await cursor.next();
        storedRubriques = config.rubriques || [];
      }

      // Récupérer toutes les rubriques disponibles
      const allRubriques = await rubriqueBulletin.getAllRubriqueBulletin();

      const result = allRubriques.map((rubrique) => {
        // Chercher si cette rubrique existe dans la config stockée (par code ou _key)
        const storedRubrique = storedRubriques.find(
          (stored) =>
            stored._key === rubrique._key || stored.code === rubrique.code,
        );

        return {
          rubriqueOnBulletin: {
            // Utiliser la rubrique stockée (avec formules modifiées) si elle existe, sinon la rubrique originale
            rubrique: storedRubrique || rubrique,
            value: storedRubrique?.value ?? null,
          },
          isChecked: !!storedRubrique,
        };
      });

      // Trier par timeStamp croissant
      result.sort((a, b) => {
        const tA = a.rubriqueOnBulletin.rubrique?.timeStamp ?? 0;
        const tB = b.rubriqueOnBulletin.rubrique?.timeStamp ?? 0;
        return tA - tB;
      });
      return result;
    } catch (e) {
      console.error(e);
      throw new Error("Erreur lors de la récupération des données");
    }
  };

  createBulletinCategorieRubrique = async ({
    rubriqueKey,
    bulletinCategorieKey,
    value,
  }) => {
    isValidValue({ value: [rubriqueKey, bulletinCategorieKey] });
    try {
      await rubriqueBulletin.isExistRubriqueBulletin({ key: rubriqueKey });
      await bulletinCategorieModel.isExistBulletinCategorie({
        key: bulletinCategorieKey,
      });

      if (
        !!!(await this.getBulletinCategorieRubriqueByLink({
          bulletinCategorieKey: bulletinCategorieKey,
          rubriqueKey: rubriqueKey,
        }))
      ) {
        const newRubriqueCategrie = {
          rubriqueKey: rubriqueKey,
          bulletinCategorieKey: bulletinCategorieKey,
          value: value,
        };
        await bulletinCategorieRubriqueCollection.save(newRubriqueCategrie);
      }
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error("Erreur lors de l'enrégistrement");
    }
  };

  getBulletinCategorieRubriqueByLink = async ({
    rubriqueKey,
    bulletinCategorieKey,
  }) => {
    const query = await db.query(aql`
      FOR bulletinCategorieRubrique IN ${bulletinCategorieRubriqueCollection}
        FILTER bulletinCategorieRubrique.rubriqueKey == ${rubriqueKey} AND bulletinCategorieRubrique.bulletinCategorieKey == ${bulletinCategorieKey}
        LIMIT 1
        RETURN bulletinCategorieRubrique
    `);

    if (query.hasNext) {
      return await query.next();
    }
  };

  updateBulletinCategorieRubrique = async ({
    rubriqueKey,
    bulletinCategorieKey,
    value,
  }) => {
    try {
      const data = await this.getBulletinCategorieRubriqueByLink({
        bulletinCategorieKey: bulletinCategorieKey,
        rubriqueKey: rubriqueKey,
      });
      if (data) {
        await bulletinCategorieRubriqueCollection.update(data._key, {
          value: value,
        });
      }
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error("Erreur lors de la modification des données");
    }
  };

  deleteBulletinCategorieRubrique = async ({
    rubriqueKey,
    bulletinCategorieKey,
  }) => {
    try {
      const data = await this.getBulletinCategorieRubriqueByLink({
        bulletinCategorieKey: bulletinCategorieKey,
        rubriqueKey: rubriqueKey,
      });
      if (!!data) {
        await bulletinCategorieRubriqueCollection.remove(data._key);
      }
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error("Erreur lors de la suppression");
    }
  };

  // // Nouvelle méthode : récupérer la config avec rubriques complètes
  // getRubriqueCategorieConfig = async ({ bulletinCategorieKey }) => {
  //   try {
  //     const cursor = await db.query(aql`
  //       FOR config IN ${bulletinCategorieRubriqueCollection}
  //         FILTER config.bulletinCategorieKey == ${bulletinCategorieKey}
  //         FILTER config.rubriques != null
  //         LIMIT 1
  //         RETURN config
  //     `);

  //     if (cursor.hasNext) {
  //       const config = await cursor.next();
  //       return {
  //         _key: config._key,
  //         bulletinCategorieKey: config.bulletinCategorieKey,
  //         rubriques: config.rubriques || [],
  //       };
  //     }
  //     return null;
  //   } catch (e) {
  //     console.error(e);
  //     throw new Error("Erreur lors de la récupération de la configuration");
  //   }
  // };

  // Nouvelle méthode : sauvegarder/remplacer la config avec rubriques complètes
  saveRubriqueCategorieConfig = async ({
    bulletinCategorieKey,
    rubriquesConfiged,
  }) => {
    try {
      await bulletinCategorieModel.isExistBulletinCategorie({
        key: bulletinCategorieKey,
      });

      // const parsedRubriques = JSON.parse(rubriques);

      // Chercher si une config existe déjà pour cette catégorie
      const cursor = await db.query(aql`
        FOR config IN ${bulletinCategorieRubriqueCollection}
          FILTER config.bulletinCategorieKey == ${bulletinCategorieKey}
          FILTER config.rubriques != null
          LIMIT 1
          RETURN config
      `);

      if (cursor.hasNext) {
        // Mettre à jour le document existant
        const existingConfig = await cursor.next();
        await bulletinCategorieRubriqueCollection.update(existingConfig._key, {
          rubriquesConfiged: parsedRubriques,
        });
      } else {
        // Créer un nouveau document
        const newConfig = {
          bulletinCategorieKey: bulletinCategorieKey,
          rubriquesConfiged: rubriquesConfiged,
        };
        await bulletinCategorieRubriqueCollection.save(newConfig);
      }

      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error("Erreur lors de la sauvegarde de la configuration");
    }
  };
}

export default BulletinCategorieRubrique;
