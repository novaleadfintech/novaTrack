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
      const cursor = await db.query(aql`
        FOR rubriqueBulletion IN ${bulletinCategorieRubriqueCollection}
          FILTER rubriqueBulletion.bulletinCategorieKey == ${bulletinCategorieKey}
          RETURN rubriqueBulletion
      `);
      const rubriqueConfiforCategorie = await cursor.all();
      console.log(rubriqueConfiforCategorie);
      // Attendre la récupération des rubriques
      const result = await Promise.all(
        rubriqueConfiforCategorie.map(async (bulletinCategorieRubrique) => {
          const rubrique = await rubriqueBulletin.getRubriqueBulletin({
            key: bulletinCategorieRubrique.rubriqueKey,
          });

          return {
            ...bulletinCategorieRubrique,
            rubrique: rubrique,
          };
        }),
      );

      // Trier les résultats par timeStamp croissant
      result.sort((a, b) => {
        const tA = a.rubrique?.timeStamp ?? 0;
        const tB = b.rubrique?.timeStamp ?? 0;
        return tA - tB;
      });
      return result;
    } catch (e) {
      console.log(e);
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
      const cursor = await db.query(aql`
        FOR rubriqueBulletin IN ${bulletinCategorieRubriqueCollection}
          FILTER rubriqueBulletin.bulletinCategorieKey == ${bulletinCategorieKey}
          RETURN rubriqueBulletin
      `);
      const rubriqueConfigforCategorie = await cursor.all();
      const allRubriques = await rubriqueBulletin.getAllRubriqueBulletin();

      const result = allRubriques.map((rubrique) => {
        const config = rubriqueConfigforCategorie.find(
          (conf) => conf.rubriqueKey === rubrique._key,
        );
        return {
          rubriqueOnBulletin: {
            rubrique,
            value: config ? config.value : null,
          },
          isChecked: !!config,
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
    isValkeyValue({ value: [rubriqueKey, bulletinCategorieKey] });
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
}

export default BulletinCategorieRubrique;
