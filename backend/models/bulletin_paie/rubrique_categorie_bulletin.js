import { aql, CollectionType } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import RubriqueBulletin from "./rubrique_bulletin.js";
import CategorieBulletin from "./categorie_bulletin.js";
import ValeurRubriqueTemporaire from "./valeur_rubrique_temporaire.js";
const categorieBulletinRubriqueCollection = db.collection(
  "categorieBulletinRubriques",
);
import { PorteeRubrique } from "./bulletin.js";
const rubriqueBulletin = new RubriqueBulletin();
const categorieBulletinModel = new CategorieBulletin();
const valeurRubriqueTemporaireModel = new ValeurRubriqueTemporaire();

class CategorieBulletinRubrique {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await categorieBulletinRubriqueCollection.exists())) {
      await categorieBulletinRubriqueCollection.create({
        type: CollectionType.EDGE_COLLECTION,
      });
    }
  }

  getRubriqueBulletinByCategorieBulletin = async ({ categorieBulletinId }) => {
    try {
      const categorieBulletinRubriqueEdges =
        await categorieBulletinRubriqueCollection.edges(categorieBulletinId);
      const rubriqueConfiforCategorie = categorieBulletinRubriqueEdges.edges;
      console.log(rubriqueConfiforCategorie);
      // Attendre la récupération des rubriques
      const result = await Promise.all(
        rubriqueConfiforCategorie.map(async (categorieBulletinRubrique) => {
          const rubrique = await rubriqueBulletin.getRubriqueBulletin({
            key: categorieBulletinRubrique._from,
          });

          return {
            ...categorieBulletinRubrique,
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
    categorieBulletinId,
    salarieId,
  }) => {
    try {
      const categorieBulletinRubriqueEdges =
        await categorieBulletinRubriqueCollection.edges(categorieBulletinId);

      const rubriqueConfiforCategorie = categorieBulletinRubriqueEdges.edges;

      const existingVariable =
        await valeurRubriqueTemporaireModel.getBySalarieId({
          salarieId: salarieId,
        });
      // existingVariable is a document with shape { salarieId, rubriques: [{ rubriqueId, value }], primesExceptionnelles: [...] }
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
      for (const categorieBulletinRubrique of rubriqueConfiforCategorie) {
        const rubrique = await rubriqueBulletin.getRubriqueBulletin({
          key: categorieBulletinRubrique._from,
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
            v.rubriqueId === rubrique._id ||
            v.rubriqueId === categorieBulletinRubrique._from,
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
            key: pe.rubriqueId,
          });
          return { value: pe.value, rubrique };
        },
      );
      const primesFromExisting = await Promise.all(primesFromExistingPromises);

      // retourner sous la forme attendue par le frontend : liste de ValeurRubriqueTemporaire

      return {
        ...existingVariable,
        salarieId: salarieId,
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

  getRubriqueBulletinByCategorieBulletinForConfiguration = async ({
    categorieBulletinId,
  }) => {
    try {
      const categorieBulletinRubriqueEdges =
        await categorieBulletinRubriqueCollection.edges(categorieBulletinId);

      const rubriqueConfigforCategorie = categorieBulletinRubriqueEdges.edges;
      const allRubriques = await rubriqueBulletin.getAllRubriqueBulletin();

      const result = allRubriques.map((rubrique) => {
        const config = rubriqueConfigforCategorie.find(
          (conf) => conf._from === rubrique._id,
        );
        return {
          rubriqueOnBulletin: {
            rubrique,
            value: config ? config.value : null,
          },
          isChecked: !!config,
        };
      });
      console.log(result);
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

  createCategorieBulletinRubrique = async ({
    rubriqueId,
    categorieBulletinId,
    value,
  }) => {
    isValidValue({ value: [rubriqueId, categorieBulletinId] });
    try {
      await rubriqueBulletin.isExistRubriqueBulletin({ key: rubriqueId });
      await categorieBulletinModel.isExistCategorieBulletin({
        key: categorieBulletinId,
      });

      if (
        !!!(await this.getCategorieBulletinRubriqueByLink({
          categorieId: categorieBulletinId,
          rubriqueId: rubriqueId,
        }))
      ) {
        const newRubriqueCategrie = {
          _from: rubriqueId,
          _to: categorieBulletinId,
          value: value,
        };
        await categorieBulletinRubriqueCollection.save(newRubriqueCategrie);
      }
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error("Erreur lors de l'enrégistrement");
    }
  };

  getCategorieBulletinRubriqueByLink = async ({
    rubriqueId,
    categorieBulletinId,
  }) => {
    const query = await db.query(aql`
      FOR doc IN ${categorieBulletinRubriqueCollection}
        FILTER doc._from == ${rubriqueId} AND doc._to == ${categorieBulletinId}
        LIMIT 1
        RETURN doc
    `);

    if (query.hasNext) {
      return await query.next();
    }
  };

  updateCategorieBulletinRubrique = async ({
    rubriqueId,
    categorieBulletinId,
    value,
  }) => {
    try {
      const data = await this.getCategorieBulletinRubriqueByLink({
        categorieId: categorieBulletinId,
        rubriqueId: rubriqueId,
      });
      if (data) {
        await categorieBulletinRubriqueCollection.update(data._id, {
          value: value,
        });
      }
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error("Erreur lors de la modification des données");
    }
  };

  deleteCategorieBulletinRubrique = async ({
    rubriqueId,
    categorieBulletinId,
  }) => {
    try {
      const data = await this.getCategorieBulletinRubriqueByLink({
        categorieBulletinId: categorieBulletinId,
        rubriqueId: rubriqueId,
      });
      if (!!data) {
        await categorieBulletinRubriqueCollection.remove(data._id);
      }
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error("Erreur lors de la suppression");
    }
  };
}

export default CategorieBulletinRubrique;
