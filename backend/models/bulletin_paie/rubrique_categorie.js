import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import RubriqueBulletin from "./rubrique_bulletin.js";
import CategoriePaie from "./categorie_paie.js";
 import ValeurRubriqueTemporaire from "./valeur_rubrique_temporaire.js";
 const rubriqueCategorieCollection = db.collection("categoriePaieRubriques");
 import { PorteeRubrique } from "./bulletin.js";

 const rubriqueBulletin = new RubriqueBulletin();
 const categoriePaieModel = new CategoriePaie();
 const valeurRubriqueTemporaireModel = new ValeurRubriqueTemporaire();

 class RubriqueCategorie {
   constructor() {
     this.initializeCollections();
   }

   async initializeCollections() {
     if (!(await rubriqueCategorieCollection.exists())) {
       rubriqueCategorieCollection.create({
         type: CollectionType.EDGE_COLLECTION,
       });
     }
   }

   getRubriqueBulletinByCategoriePaie = async ({ categoriePaieId }) => {
     try {
       const rubriqueCategorieEdges =
         await rubriqueCategorieCollection.edges(categoriePaieId);
       const rubriqueConfiforCategorie = rubriqueCategorieEdges.edges;

       // Attendre la récupération des rubriques
       const result = await Promise.all(
         rubriqueConfiforCategorie.map(async (rubriqueCategorie) => {
           const rubrique = await rubriqueBulletin.getRubriqueBulletin({
             key: rubriqueCategorie._from,
           });

           return {
             ...rubriqueCategorie,
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
     categoriePaieId,
     salarieId,
   }) => {
     try {
       const rubriqueCategorieEdges =
         await rubriqueCategorieCollection.edges(categoriePaieId);

       const rubriqueConfiforCategorie = rubriqueCategorieEdges.edges;

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
       for (const rubriqueCategorie of rubriqueConfiforCategorie) {
         const rubrique = await rubriqueBulletin.getRubriqueBulletin({
           key: rubriqueCategorie._from,
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
             v.rubriqueId === rubriqueCategorie._from,
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
         rubriques: rubriqueEntries,
         primesExceptionnelles: primesFromExisting,
       };
     } catch (e) {
       console.error(e);
       throw new Error(
         "Erreur lors de la récupération des rubriques de type constante à valeur nulle",
       );
     }
   };

   getRubriqueBulletinByCategoriePaieForConfiguration = async ({
     categoriePaieId,
   }) => {
     try {
       const rubriqueCategorieEdges =
         await rubriqueCategorieCollection.edges(categoriePaieId);

       const rubriqueConfiforCategorie = rubriqueCategorieEdges.edges;
       const allRubriques = await rubriqueBulletin.getAllRubriqueBulletin();

       const result = allRubriques.map((rubrique) => {
         const config = rubriqueConfiforCategorie.find(
           (conf) => conf._from === rubrique._id,
         );
         return {
           rubriqueCategorie: {
             rubrique,
             value: config ? config.value : null,
           },
           isChecked: !!config,
         };
       });

       // Trier par timeStamp croissant
       result.sort((a, b) => {
         const tA = a.rubriqueCategorie.rubrique?.timeStamp ?? 0;
         const tB = b.rubriqueCategorie.rubrique?.timeStamp ?? 0;
         return tA - tB;
       });
       return result;
     } catch (e) {
       console.error(e);
       throw new Error("Erreur lors de la récupération des données");
     }
   };

   createRubriqueCategorie = async ({ rubriqueId, categorieId, value }) => {
     isValidValue({ value: [rubriqueId, categorieId] });
     try {
       await rubriqueBulletin.isExistRubriqueBulletin({ key: rubriqueId });
       await categoriePaieModel.isExistCategoriePaie({ key: categorieId });

       if (
         !!!(await this.getRubriqueCategorieByLink({
           categorieId: categorieId,
           rubriqueId: rubriqueId,
         }))
       ) {
         const newRubriqueCategrie = {
           _from: rubriqueId,
           _to: categorieId,
           value: value,
         };
         await rubriqueCategorieCollection.save(newRubriqueCategrie);
       }
       return "OK";
     } catch (e) {
       console.error(e);
       throw new Error("Erreur lors de l'enrégistrement");
     }
   };

   getRubriqueCategorieByLink = async ({ rubriqueId, categorieId }) => {
     const query = await db.query(aql`
      FOR doc IN ${rubriqueCategorieCollection}
        FILTER doc._from == ${rubriqueId} AND doc._to == ${categorieId}
        LIMIT 1
        RETURN doc
    `);

     if (query.hasNext) {
       return await query.next();
     }
   };

   updateRubriqueCategorie = async ({ rubriqueId, categorieId, value }) => {
     try {
       const data = await this.getRubriqueCategorieByLink({
         categorieId: categorieId,
         rubriqueId: rubriqueId,
       });
       if (data) {
         await rubriqueCategorieCollection.update(data._id, { value: value });
       }
       return "OK";
     } catch (e) {
       console.error(e);
       throw new Error("Erreur lors de la modification des données");
     }
   };

   deleteRubriqueCategorie = async ({ rubriqueId, categorieId }) => {
     try {
       const data = await this.getRubriqueCategorieByLink({
         categorieId: categorieId,
         rubriqueId: rubriqueId,
       });
       if (!!data) {
         await rubriqueCategorieCollection.remove(data._id);
       }
       return "OK";
     } catch (e) {
       console.error(e);
       throw new Error("Erreur lors de la suppression");
     }
   };
 }

export default RubriqueCategorie;
