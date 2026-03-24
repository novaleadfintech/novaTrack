import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import Banque, { locateBanqueFolder } from "../banque.js";
import FluxFinancier, {
   FluxFinancierType,
} from "../flux_financier/flux_financier.js";
import Salarie from "./salarie.js";
import RubriqueBulletin from "./rubrique_bulletin.js";
import User from "../habilitation/user.js";
import ValeurRubriqueTemporaire from "./valeur_rubrique_temporaire.js";
import RubriqueCategorieConf from "./rubrique_categorie_bulletin.js";
import Entreprise from "../entreprise.js";

const FluxFinancierModel = new FluxFinancier();
const RubriqueCategorieConfModel = new RubriqueCategorieConf();
const SalarieModel = new Salarie();
const BanqueModel = new Banque();
const EntrepriseModel = new Entreprise();
const ValeurRubriqueTemporaireModel = new ValeurRubriqueTemporaire();
const RubriqueBulletinModel = new RubriqueBulletin();
const bulletinCollection = db.collection("bulletins");
const decouverteCollection = db.collection("decouvertes");
const userModel = new User();

const EtatBulletin = {
  wait: "wait",
  reject: "reject",
  returne: "returne",
  valid: "valid",
};
const DecouverteStatus = {
  paid: "paid",
  unpaid: "unpaid",
  partialpaid: "partialpaid",
};

const RubriqueIdentity = {
  anciennete: "anciennete",
  nombrePersonneCharge: "nombrePersonneCharge",
  netPayer: "netPayer",
  salaireBase: "salaireBase",
  avanceSurSalaire: "avanceSurSalaire",
};

const BaseType = {
  rubrique: "rubrique",
  valeur: "valeur",
};

const Operateur = {
  addition: "addition",
  soustraction: "soustraction",
  multiplication: "multiplication",
  division: "division",
};

const TypeRubrique = {
  gain: "gain",
  retenue: "retenue",
};

const PorteeRubrique = {
  individuel: "individuel",
  commun: "commun",
};

const TrancheValueType = {
  valeur: "valeur",
  taux: "taux",
};
const NatureRubrique = {
  constant: "constant",
  taux: "taux",
  calcul: "calcul",
  sommeRubrique: "sommeRubrique",
  bareme: "bareme",
};

class BulletinPaie {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await bulletinCollection.exists())) {
      await bulletinCollection.create();
    }
    if (!(await decouverteCollection.exists())) {
      await decouverteCollection.create();
    }
  }
  async getAllCurrentBulletins({ perPage, skip, etat }) {
    let limit = aql``;
    let filter = aql``;
    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    if (etat != undefined) {
      filter = aql`FILTER bulletin.etat == ${etat}`;
    } else {
      filter = aql`FILTER bulletin.etat == ${EtatBulletin.wait} OR bulletin.etat == ${EtatBulletin.returne}`;
    }
    const query = await db.query(
      aql`FOR bulletin IN ${bulletinCollection} SORT bulletin.timeStamp DESC ${filter} ${limit} RETURN bulletin`,
      { fullCount: true },
    );
    if (query.hasNext) {
      const bulletins = await query.all();
      return Promise.all(
        bulletins.map(async (bulletin) => {
          const rubriquesPromises = bulletin.rubriques.map(async (rubrique) => {
            const rubriqueBulletin =
              await RubriqueBulletinModel.getRubriqueBulletin({
                key: rubrique.rubriqueId,
              });
            return {
              ...rubrique,
              rubrique: rubriqueBulletin,
            };
          });
          const rubriquesResolues = await Promise.all(rubriquesPromises);
          let validate;
          if (bulletin.validate != null) {
            validate = bulletin.validate ?? [];
            await Promise.all(
              validate.map(async (valid) => {
                valid.validater = await userModel.getUser({
                  key: valid.validater,
                });
              }),
            );
          }
          return {
            ...bulletin,
            validate: validate,
            rubriques: rubriquesResolues,
          };
        }),
      );
    } else {
      return [];
    }
  }
  async getAllCurrentValidateBulletins({ perPage, skip }) {
    let limit = aql``;

    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const today = Date.now();

    const query = await db.query(
      aql`
      LET today = ${today}
  
      FOR bulletin IN ${bulletinCollection}
        FILTER bulletin.etat == ${EtatBulletin.valid}
        SORT bulletin.timeStamp DESC
        ${limit}
        RETURN bulletin
      `,
      { fullCount: true },
    );
    if (query.hasNext) {
      const bulletins = await query.all();

      return Promise.all(
        bulletins.map(async (bulletin) => {
          const rubriquesPromises = bulletin.rubriques.map(async (rubrique) => {
            const rubriqueBulletin =
              await RubriqueBulletinModel.getRubriqueBulletin({
                key: rubrique.rubriqueId,
              });
            return {
              ...rubrique,
              rubrique: rubriqueBulletin,
            };
          });

          const rubriquesResolues = await Promise.all(rubriquesPromises);

          let validate;
          if (bulletin.validate != null) {
            validate = bulletin.validate ?? [];
            await Promise.all(
              validate.map(async (valid) => {
                valid.validater = await userModel.getUser({
                  key: valid.validater,
                });
              }),
            );
          }

          return {
            ...bulletin,
            validate: validate,
            rubriques: rubriquesResolues,
          };
        }),
      );
    } else {
      return [];
    }
  }

  async getReadySalaries({ dateDebut, dateFin }) {
    const salaires = await SalarieModel.getAllActiveSalarieByPeriod({
      dateDebut: dateDebut,
      dateFin: dateFin,
    });

    const readySalaries = [];

    for (const salarie of salaires) {
      if (
        (await this.verifySingleFutureBulletin({
          dateDebut: dateDebut,
          dateFin: dateFin,
          salarieKey: salarie._key,
        })) == true
      ) {
        readySalaries.push(salarie);
      }
    }
    return readySalaries;
  }

  async generateBulletinsForPeriod({ dateDebut, dateFin }) {
    const readySalaries = await this.getReadySalaries({
      dateDebut,
      dateFin,
    });

    if (readySalaries.length == 0) {
      throw new Error("Toutes les bulletins on été générés pour cette période");
    }

    const results = [];

    for (const salarie of readySalaries) {
      try {
        // 2. Récupérer les rubriques de base (avec valeurs collectives) configurer pour une catégorie
        const rubriquesBase =
          await RubriqueCategorieConfModel.getRubriqueBulletinBypaieCategorie({
            paieCategorieKey: salarie.paieCategorie._key,
          });

        // console.log(rubriquesBase);
        // 3. Récupérer les valeurs temporaires saisies
        const valeursTemp = await ValeurRubriqueTemporaireModel.getBySalarieKey(
          {
            salarieKey: salarie._key,
          },
        );

        // 4. Fusionner : remplacer les null par les valeurs saisies
        const rubriques = rubriquesBase.map((rubrique) => {
          // Chercher si une valeur temporaire existe pour cette rubrique
          const valeurTemp = valeursTemp?.rubriques?.find(
            (r) => r.rubriqueKey === rubrique.rubrique._key,
          );
          return {
            rubriqueKey: rubrique.rubrique._key,
            value: valeurTemp?.value ?? rubrique.value ?? 0,
          };
        });
        // Fusionner les deux tableaux
        rubriques.push(...(valeursTemp?.primesExceptionnelles || []));
        // console.log(salarie);
        // 5. Créer le bulletin
        await this.createBulletin({
          debutPeriodePaie: dateDebut,
          finPeriodePaie: dateFin,
          dateEdition: Date.now(),
          salarieKey: salarie._key,

          rubriques: rubriques,
        });
      } catch (error) {
        console.error(error);
        throw new Error(error);
      }
    }
    return "OK";
  }

  async verifySingleFutureBulletin({ dateDebut, dateFin, salarieKey }) {
    try {
      // Vérifie s'il existe déjà un bulletin pour ce salarié dans la période donnée
      const query = await db.query(aql`
      FOR b IN ${bulletinCollection} 
        FILTER b.salarie._key == ${salarieKey} 
        AND NOT (
          b.finPeriodePaie < ${dateDebut} 
          OR b.debutPeriodePaie > ${dateFin}
        )
        LIMIT 1 
        RETURN b 
    `);

      const bulletinExiste = query.hasNext;

      if (bulletinExiste) {
        console.log("Bulletin existe déjà pour cette période");
      } else {
        console.log("Aucun bulletin, création possible");
      }

      // Retourne true si AUCUN bulletin n'existe (peut créer)
      // Retourne false si un bulletin existe (ne peut PAS créer)
      return !bulletinExiste;
    } catch (error) {
      console.error("Erreur lors de la vérification du duplicata :", error);
      throw new Error("Erreur interne lors de la vérification du bulletin.");
    }
  }

  async getAllArchiveBulletins({ perPage, skip, etat }) {
    let limit = aql``;
    let filter = aql``;
    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    if (etat != undefined) {
      filter = aql`FILTER bulletin.etat == ${etat}`;
    } else {
      filter = aql`FILTER bulletin.etat == ${EtatBulletin.valid} OR bulletin.etat == ${EtatBulletin.reject}`;
    }
    const query = await db.query(
      aql`FOR bulletin IN ${bulletinCollection} SORT bulletin.timeStamp DESC ${filter} ${limit} RETURN bulletin`,
      { fullCount: true },
    );
    if (query.hasNext) {
      const bulletins = await query.all();
      return Promise.all(
        bulletins.map(async (bulletin) => {
          const rubriquesPromises = bulletin.rubriques.map(async (rubrique) => {
            const rubriqueBulletin =
              await RubriqueBulletinModel.getRubriqueBulletin({
                key: rubrique.rubriqueKey,
              });
            return {
              ...rubrique,
              rubrique: rubriqueBulletin,
            };
          });
          const rubriquesResolues = await Promise.all(rubriquesPromises);
          let validate;
          if (bulletin.validate != null) {
            validate = bulletin.validate ?? [];
            await Promise.all(
              validate.map(async (valid) => {
                valid.validater = await userModel.getUser({
                  key: valid.validater,
                });
              }),
            );
          }
          return {
            ...bulletin,
            rubriques: rubriquesResolues,
            validate: validate,
          };
        }),
      );
    } else {
      return [];
    }
  }

  async getBulletin({ id }) {
    try {
      const bulletin = await bulletinCollection.document({ _key: id });
      const rubriquesPromises = bulletin.rubriques.map(async (rubrique) => {
        const rubriqueBulletin =
          await RubriqueBulletinModel.getRubriqueBulletin({
            key: rubrique.rubriqueKey,
          });
        return {
          ...rubrique,
          rubrique: rubriqueBulletin,
        };
      });
      const rubriquesResolues = await Promise.all(rubriquesPromises);
      let validate;
      if (bulletin.validate != null) {
        validate = bulletin.validate ?? [];
        await Promise.all(
          validate.map(async (valid) => {
            valid.validater = await userModel.getUser({
              key: valid.validater,
            });
          }),
        );
      }
      return {
        ...bulletin,
        validate: validate,
        rubriques: rubriquesResolues,
      };
    } catch (err) {
      console.error(err);
      throw new Error(`Ce bulletin est introuvable`);
    }
  }

  async getPreviousBulletin({ salarieKey }) {
    try {
      const query = await db.query(
        aql`FOR bulletin IN ${bulletinCollection} FILTER bulletin.salarie._key == ${salarieKey} SORT bulletin.dateEdition DESC
        LIMIT 1
        RETURN bulletin`,
      );
      if (query.hasNext) {
        const bulletin = await query.next();
        const rubriquesPromises = bulletin.rubriques.map(async (rubrique) => {
          const rubriqueBulletin =
            await RubriqueBulletinModel.getRubriqueBulletin({
              key: rubrique.rubriqueKey,
            });
          return {
            ...rubrique,
            rubrique: rubriqueBulletin,
          };
        });
        const rubriquesResolues = await Promise.all(rubriquesPromises);
        let validate;
        if (bulletin.validate != null) {
          validate = bulletin.validate ?? [];
          await Promise.all(
            validate.map(async (valid) => {
              valid.validater = await userModel.getUser({
                key: valid.validater,
              });
            }),
          );
        }
        return {
          ...bulletin,
          validate: validate,
          rubriques: rubriquesResolues,
        };
      }
    } catch (err) {
      console.error(err);
      throw new Error(`Ce bulletin est introuvable`);
    }
  }

  async verifyMontantDecouvertPossible({ id, montantDemande }) {
    try {
      const cursor = await db.query(aql`
      FOR bulletin IN ${bulletinCollection}
      FILTER bulletin.salarie._key == ${id}
      AND bulletin.etat ==${EtatBulletin.valid}
      SORT bulletin.timeStamp DESC
      LIMIT 1
      RETURN bulletin
    `);

      const bulletin = await cursor.next();
      if (!bulletin) {
        throw new Error(
          "Vous n'êtes pas éligible à une avance sur salaire. Vous n'avez jamais été payé auparavant.",
        );
      }

      const rubriquesPromises = bulletin.rubriques.map(async (rubrique) => {
        const rubriqueBulletin =
          await RubriqueBulletinModel.getRubriqueBulletin({
            key: rubrique.rubriqueKey,
          });
        return {
          ...rubrique,
          rubrique: rubriqueBulletin,
        };
      });

      const rubriquesResolues = await Promise.all(rubriquesPromises);

      // 🔍 Trouver la rubrique "net à payer"
      const rubriqueNetAPayer = rubriquesResolues.find(
        (r) => r.rubrique?.rubriqueIdentity === RubriqueIdentity.netPayer,
      );
      let valeurNet;
      if (!rubriqueNetAPayer) {
        valeurNet = 0;
      } else {
        valeurNet = rubriqueNetAPayer.value;
        if (isNaN(valeurNet)) {
          valeurNet = 0;
        }
      }

      const moitie = valeurNet / 2;
      if (montantDemande > moitie) {
        throw new Error(
          `Nous trouvons que vous seriez incapable de remborser la somme demandée? Le maximun de somme que vous pouvez demander s'éléve à ${moitie}`,
        );
      }

      let validate = bulletin.validate ?? [];
      await Promise.all(
        validate.map(async (valid) => {
          valid.validater = await userModel.getUser({
            key: valid.validater,
          });
        }),
      );

      return {
        ...bulletin,
        rubriques: rubriquesResolues,
        validate,
      };
    } catch (err) {
      console.error(err);

      throw new Error(
        err.message || "Erreur lors de la récupération du bulletin.",
      );
    }
  }

  async createBulletin({
    debutPeriodePaie,
    finPeriodePaie,
    dateEdition,
    salarieKey,
    rubriques,
  }) {
    isValidValue({
      value: [debutPeriodePaie, finPeriodePaie, dateEdition, salarieKey],
    });

    isValidValue({ value: rubriques });

    // Vérification de chevauchement d'une période de paie
    const existingBulletin = await db.query(aql`
    FOR bulletin IN ${bulletinCollection}
    FILTER bulletin.salarie._key == ${salarieKey}
    AND NOT (bulletin.finPeriodePaie < ${debutPeriodePaie}
    AND (bulletin.etat == ${EtatBulletin.wait} OR bulletin.etat == ${EtatBulletin.returne} OR bulletin.etat == ${EtatBulletin.valid} )
    OR bulletin.debutPeriodePaie > ${finPeriodePaie})
    LIMIT 1
    RETURN bulletin
  `);

    if (existingBulletin.hasNext) {
      throw new Error(
        `Un bulletin existe déjà pour ce salarié dans cette période.`,
      );
    }

    const salarie = await SalarieModel.getSalarie({ key: salarieKey });
    // Étape 1 : Récupérer les découverts impayés ou partiellement payés
    const decouvertesQuery = await db.query(aql`
    FOR decouvert IN ${decouverteCollection}
      FILTER decouvert.salarie._key == ${salarieKey}
      AND (decouvert.status != ${DecouverteStatus.paid})
      RETURN decouvert
  `);

    const decouvertes = await decouvertesQuery.all();

    // Étape 2 : Calculer la somme totale à déduire pour avance sur salaire
    let totalAvance = 0;

    for (const dec of decouvertes) {
      if (dec.dureeReversement > 0) {
        const quotien = dec.montant / dec.dureeReversement;
        totalAvance += Math.min(quotien, dec.montantRestant);
      }
    }

    // Étape 3 : Charger les données complètes des rubriques
    for (let i = 0; i < rubriques.length; i++) {
      // console.log(rubriques[i]);
      const rubriqueData = await RubriqueBulletinModel.getRubriqueBulletin({
        key: rubriques[i].rubriqueKey,
      });
      rubriques[i].rubrique = rubriqueData;
    }

    // Étape 4 : Ajouter ou mettre à jour la rubrique "avanceSurSalaire"
    const indexRubriqueAvance = rubriques.findIndex(
      (r) => r.rubrique?.rubriqueIdentity === RubriqueIdentity.avanceSurSalaire,
    );

    if (indexRubriqueAvance !== -1) {
      rubriques[indexRubriqueAvance].value = totalAvance;
    }

    // Étape 4' : Ajouter ou mettre à jour la rubrique "avanceSurSalaire"
    const indexRubriqueSalaireBace = rubriques.findIndex((r) => {
      return r.rubrique?.rubriqueIdentity === RubriqueIdentity.salaireBase;
    });

    if (indexRubriqueSalaireBace !== -1) {
      rubriques[indexRubriqueSalaireBace].value = await this.calculateSalaire({
        salarie: salarie,
      });
    }

    // Étape 4' : Ajouter ou mettre à jour la rubrique "ancienneté"
    const indexRubriqueAnciennete = rubriques.findIndex(
      (r) => r.rubrique?.rubriqueIdentity === RubriqueIdentity.anciennete,
    );

    if (indexRubriqueAnciennete !== -1) {
      rubriques[indexRubriqueAnciennete].value =
        salarie.personnel.dateFin ??
        Date.now -
          (salarie.personnel.dateDebut + salarie.personnel.periodeEssai ?? 0);
    }
    // Étape 4' : Ajouter ou mettre à jour la rubrique "ancienneté"
    const indexRubriqueNbrePerssonneEnCharge = rubriques.findIndex(
      (r) =>
        r.rubrique?.rubriqueIdentity === RubriqueIdentity.nombrePersonneCharge,
    );

    if (indexRubriqueNbrePerssonneEnCharge !== -1) {
      rubriques[indexRubriqueNbrePerssonneEnCharge].value =
        salarie.personnel.nombrePersonneCharge ?? 0;
    }

    console.log("Début du calcul des rubriques...");
    const rubriquesCalculees =
      this.calculateRubriquesWithDependencies(rubriques);
    console.log("Calcul des rubriques terminé");

    const bulletin = {
      salarie: salarie,
      dateEdition: dateEdition,
      etat: EtatBulletin.wait,
      debutPeriodePaie: debutPeriodePaie,
      finPeriodePaie: finPeriodePaie,
      rubriques: rubriquesCalculees,
      timeStamp: Date.now(),
    };

    const session = await db.beginTransaction({
      write: [bulletinCollection, decouverteCollection],
    });

    try {
      await session.step(async () => {
        await bulletinCollection.save(bulletin);
      });

      await session.commit();

      console.log(`Bulletin créé avec succès pour le salarié ${salarieKey}`);
      return "OK";
    } catch (error) {
      console.error("Erreur lors de la création du bulletin:", error);
      await session.abort();
      throw new Error(
        `Erreur lors de la création du bulletin: ${error.message}`,
      );
    }
  }

  async calculateSalaire({ salarie }) {
    try {
      // 1. Vérifier si le salarié a une grille salariale, classe et échelon
      if (!salarie.grillepaieCategorie || !salarie.classe || !salarie.echelon) {
        console.warn("Grille salariale, classe ou échelon ne sont pas défini");
        return 0;
      }

      // 2. Récupérer la valeur indiciaire de l'entreprise
      const indice = await EntrepriseModel.getValeurIndiciaire();

      if (!indice) {
        throw new Error("Valeur indiciaire non trouvée");
      }

      // 3. Récupérer les informations de la grille salariale
      const grilleSalariale = salarie.grillepaieCategorie;
      const classeKey = salarie.classe._key;
      const echelonKey = salarie.echelon._key;

      // 4. Vérifier que la grille a des classes
      if (!grilleSalariale.classes || grilleSalariale.classes.length === 0) {
        console.warn("Aucune classe dans la grille salariale - salaire = 0");
        return 0;
      }

      // 5. Trouver la classe correspondante dans la grille
      const classeCorrespondante = grilleSalariale.classes.find(
        (c) => c._key === classeKey,
      );

      if (!classeCorrespondante) {
        console.warn(
          `Classe non trouvée dans la grille salariale - salaire = 0`,
        );
        return 0;
      }

      // 6. Vérifier que la classe a des échelons indiciaires
      if (
        !classeCorrespondante.echelonIndiciciaires ||
        classeCorrespondante.echelonIndiciciaires.length === 0
      ) {
        console.warn(
          "Aucun échelon indiciaire dans cette classe - salaire = 0",
        );
        return 0;
      }

      // 7. Trouver l'échelon indiciaire correspondant
      const echelonIndiciaire = classeCorrespondante.echelonIndiciciaires.find(
        (ei) => ei.echelon._key === echelonKey,
      );

      if (!echelonIndiciaire) {
        console.warn(`Échelon indiciaire non trouvé`);
        return 0;
      }

      // 8. Récupérer l'indice de l'échelon
      const indiceEchelon = echelonIndiciaire.indice;

      if (indiceEchelon == null) {
        console.warn("Indice non défini pour cet échelon");
        return 0;
      }
      const salaire = indiceEchelon * indice;
      return salaire;
    } catch (error) {
      console.error("Erreur lors du calcul du salaire:", error);
      return 0;
    }
  }

  /**
   * Calcule le montant d'une rubrique selon sa nature
   * @param {Object} params
   * @param {Object} params.rubriqueOnBulletin - La rubrique à calculer
   * @param {Array} params.toutesLesRubriquesSurBulletin - Toutes les rubriques du bulletin
   * @returns {number} Le montant calculé
   */
  calculerMontantRubrique({
    rubriqueOnBulletin,
    toutesLesRubriquesSurBulletin,
  }) {
    const rubrique = rubriqueOnBulletin.rubrique;

    switch (rubrique.nature) {
      case NatureRubrique.constant:
        return rubriqueOnBulletin.value ?? 0;

      case NatureRubrique.taux: {
        const taux = rubrique.taux.taux;

        const baseRubrique = toutesLesRubriquesSurBulletin.find(
          (el) => el.rubrique.code === rubrique.taux.base.code,
        ) || { rubrique: rubrique.taux.base, value: 0 };

        const base = baseRubrique.value ?? 0;
        return (taux * base) / 100;
      }

      case NatureRubrique.calcul: {
        const op = rubrique.calcul.operateur;
        const rubriquesCible = rubrique.calcul.elements;

        const valeurs = rubriquesCible.map((element) => {
          if (element.type === BaseType.rubrique) {
            const r = toutesLesRubriquesSurBulletin.find(
              (toElement) => toElement.rubrique.code === element.rubrique.code,
            ) || { rubrique: element.rubrique, value: 0 };
            return r.value;
          } else if (element.type === BaseType.valeur) {
            return element.valeur;
          }
          return 0;
        });

        if (valeurs.length === 0) return 0;

        let result = valeurs[0];

        switch (op) {
          case Operateur.addition:
            result += valeurs[1];
            break;
          case Operateur.soustraction:
            result -= valeurs[1];
            break;
          case Operateur.multiplication:
            result *= valeurs[1];
            break;
          case Operateur.division:
            result /= valeurs[1] === 0 ? 1 : valeurs[1];
            break;
        }

        return result;
      }

      case NatureRubrique.sommeRubrique: {
        const rubriquesCible = rubrique.sommeRubrique.elements;

        const valeurs = rubriquesCible.map((element) => {
          if (element.type === BaseType.rubrique) {
            const match = toutesLesRubriquesSurBulletin.find(
              (toElement) => toElement.rubrique.code === element.rubrique.code,
            ) || { rubrique: element.rubrique, value: 0 };
            return match.value;
          } else if (element.type === BaseType.valeur) {
            return element.valeur ?? 0;
          }
          return 0;
        });

        if (valeurs.length === 0) return 0;

        const result = valeurs.reduce((a, b) => a + (b ?? 0), 0);
        return result;
      }

      case NatureRubrique.bareme: {
        const bareme = rubriqueOnBulletin.rubrique.bareme;

        const reference = toutesLesRubriquesSurBulletin.find(
          (el) => el.rubrique.code === bareme.reference.code,
        ) || {
          rubrique: {
            id: "id",
            rubrique: "rubrique",
            code: "code",
            type: TypeRubrique.gain,
            nature: NatureRubrique.constant,
            portee: null,
          },
          value: 0,
        };

        const referenceValue =
          rubriqueOnBulletin.rubrique.rubriqueIdentity ===
          RubriqueIdentity.anciennete
            ? this.calculerAncienneteEnAnnees(reference.value)
            : reference.value;

        const tranche = bareme.tranches.find((tr) => {
          return (
            referenceValue >= tr.min &&
            (tr.max === null || referenceValue <= tr.max)
          );
        }) || {
          min: 0,
          max: 0,
          value: {
            type: TrancheValueType.valeur,
            valeur: 0,
          },
        };

        if (tranche.value.type === TrancheValueType.valeur) {
          return tranche.value.valeur;
        } else if (tranche.value.type === TrancheValueType.taux) {
          const taux = tranche.value.taux.taux;

          const baseRubrique = toutesLesRubriquesSurBulletin.find(
            (el) => el.rubrique.code === tranche.value.taux.base.code,
          ) || { rubrique: rubrique.taux.base, value: 0 };

          const base = baseRubrique.value ?? 0;
          return (taux * base) / 100;
        }

        return 0;
      }

      default:
        return 0;
    }
  }

  calculerAncienneteEnAnnees(ancienneteEnMs) {
    const msParAnnee = 365.25 * 24 * 60 * 60 * 1000;
    return ancienneteEnMs / msParAnnee;
  }
  /**
   * Trouve les dépendances directes d'une rubrique
   * @param {Object} rubrique - La rubrique à analyser
   * @param {Array} allRubriques - Toutes les rubriques
   * @returns {Set<string>} Ensemble des codes de rubriques dépendantes
   */
  findDependencies(rubrique, allRubriques) {
    const dependencies = new Set();

    switch (rubrique.rubrique.nature) {
      case NatureRubrique.taux:
        if (rubrique.rubrique.taux?.base) {
          dependencies.add(rubrique.rubrique.taux.base.code);
        }
        break;

      case NatureRubrique.calcul:
        for (const element of rubrique.rubrique.calcul?.elements || []) {
          if (element.type === BaseType.rubrique) {
            dependencies.add(element.rubrique.code);
          }
        }
        break;

      case NatureRubrique.sommeRubrique:
        for (const element of rubrique.rubrique.sommeRubrique?.elements || []) {
          if (element.type === BaseType.rubrique) {
            dependencies.add(element.rubrique.code);
          }
        }
        break;

      case NatureRubrique.bareme:
        if (rubrique.rubrique.bareme?.reference) {
          dependencies.add(rubrique.rubrique.bareme.reference.code);
        }
        break;

      case NatureRubrique.constant:
        // Pas de dépendances
        break;
    }

    return dependencies;
  }

  /**
   * Tri topologique pour résoudre l'ordre de calcul
   * @param {Map<string, Set<string>>} dependencyMap - Graphe des dépendances
   * @param {Array} rubriques - Liste des rubriques
   * @returns {Array} Rubriques triées dans l'ordre de calcul
   */
  topologicalSort(dependencyMap, rubriques) {
    const visited = new Set();
    const result = [];

    function dfs(rubrique) {
      const code = rubrique.rubrique.code;

      if (visited.has(code)) return;

      // Traiter d'abord les dépendances
      const dependencies = dependencyMap[code] || new Set();

      for (const dependency of dependencies) {
        const depRubrique = rubriques.find(
          (r) => r.rubrique.code === dependency,
        );

        if (!depRubrique) {
          throw new Error(`Dépendance manquante: ${dependency}`);
        }

        if (!visited.has(dependency)) {
          dfs(depRubrique);
        }
      }

      // Marquer comme visité et ajouter au résultat
      visited.add(code);
      result.push(rubrique);
    }

    // Traiter chaque rubrique non visitée
    for (const rubrique of rubriques) {
      if (!visited.has(rubrique.rubrique.code)) {
        dfs(rubrique);
      }
    }

    return result;
  }
  /**
   * Calcule toutes les rubriques dans le bon ordre de dépendances
   * @param {Array} rubriques - Liste des rubriques à calculer
   * @returns {Array} Rubriques avec valeurs calculées
   */
  calculateRubriquesWithDependencies(rubriques) {
    // Créer le graphe des dépendances
    const dependencyMap = new Map();

    for (const rubrique of rubriques) {
      dependencyMap.set(
        rubrique.rubrique.code,
        this.findDependencies(rubrique, rubriques),
      );
    }

    // Tri topologique pour obtenir l'ordre de calcul
    const orderedRubriques = this.topologicalSort(dependencyMap, rubriques);

    // Calculer les valeurs dans l'ordre
    for (const rubrique of orderedRubriques) {
      rubrique.value = this.calculerMontantRubrique({
        rubriqueOnBulletin: rubrique,
        toutesLesRubriquesSurBulletin: rubriques,
      });
    }
    return rubriques;
  }

  async updateBulletin({
    key,
    banqueKey,
    moyenPayement,
    salarieKey,
    rubriques,
    debutPeriodePaie,
    referencePaie,
    finPeriodePaie,
    dateEdition,
  }) {
    const updateField = {};

    if (moyenPayement !== undefined) {
      updateField.moyenPayement = moyenPayement;
    }

    if (dateEdition !== undefined) {
      updateField.dateEdition = dateEdition;
    }

    if (debutPeriodePaie !== undefined) {
      updateField.debutPeriodePaie = debutPeriodePaie;
    }

    if (rubriques !== undefined) {
      updateField.rubriques = rubriques;
    }

    if (referencePaie !== undefined) {
      updateField.referencePaie = referencePaie;
    }

    if (finPeriodePaie !== undefined) {
      updateField.finPeriodePaie = finPeriodePaie;
    }
    if (banqueKey !== undefined) {
      const banque = await BanqueModel.getBanque({ key: banqueKey });
      const { logo, ...otherdata } = banque;
      if (logo != null) {
        otherdata.logo = logo.replace(
          process.env.FILE_PREFIX + `${locateBanqueFolder}/`,
          "",
        );
      }
      updateField.banque = otherdata;
    }

    if (salarieKey !== undefined) {
      await SalarieModel.isExistSalarie({ key: salarieKey });
      const existingBulletin = await db.query(aql`
      FOR bulletin IN ${bulletinCollection}
      FILTER bulletin.salarieKey == ${salarieKey} 
      AND (bulletin.etat == ${EtatBulletin.wait} OR bulletin.etat == ${EtatBulletin.returne})
      AND bulletin._key == ${key}
      AND bulletin.debutPeriodePaie >= ${debutPeriodePaie}
      AND bulletin.finPeriodePaie <= ${finPeriodePaie}
      LIMIT 1
      RETURN bulletin
    `);

      if (existingBulletin.hasNext) {
        throw new Error(`Un bulletin existe déjà pour ce salarié.`);
      }
      updateField.salarieKey = salarieKey;
    }

    try {
      await bulletinCollection.update(key, updateField);
      return "OK";
    } catch (e) {
      console.error(e);
      throw new Error(`Une erreur s'est produite lors de la mise à jour`);
    }
  }

  // async duplicateBulletinsMonthly() {
  //   const bulletins = await this.getBulletinsToRegenerate();

  //   if (bulletins.length > 0) {
  //     const session = await db.beginTransaction({
  //       write: [bulletinCollection],
  //     });
  //     try {
  //       for (const bulletin of bulletins) {
  //         const { retenus, gains, salarieKey, _key } = bulletin;
  //         const filteredRetenus = retenus.filter((retenu) => !retenu.isAvance);
  //         await session.step(async () => {
  //           await this.createBulletin({
  //             gains: gains,
  //             salarieKey: salarieKey,
  //             retenus: filteredRetenus,
  //           });
  //         });
  //         await session.step(async () => {
  //           await bulletinCollection.update(_key, { regenerate: false });
  //         });
  //       }
  //       await session.commit();
  //     } catch (error) {
  // console.error(error);

  //       await session.abort();
  //       throw new Error(
  //         `Erreur lors de la duplication des bulletins`
  //       );
  //     }
  //   }
  // }

  // async getBulletinsToRegenerate() {
  //   const today = Date.now();
  //   const monthDaysInMillis = 60 * 1000; //28 * 24 * 60 * 60 * 1000;
  //   let bulletins = [];
  //   try {
  //     const query = await db.query(
  //       aql`FOR b IN ${bulletinCollection}
  //       FILTER b.regenerate == true
  //       AND b.etat == ${EtatBulletin.archived}
  //         AND ${today} - b.dateEdition > ${monthDaysInMillis}
  //       RETURN b`
  //     );
  //     if (query.hasNext) {
  //       bulletins = await query.all();
  //     }
  //     return bulletins;
  //   } catch (err) {

  //     throw err;
  //   }
  // }

  async validateBulletin({ key, validate, datePayement }) {
    const session = await db.beginTransaction({
      write: ["bulletins", "fluxFinanciers", "decouvertes"],
    });

    try {
      isValidValue({ value: { key, validate } });

      const bulletin = await this.getBulletin({ id: key });

      if (
        bulletin.etat != EtatBulletin.wait &&
        bulletin.etat != EtatBulletin.returne
      ) {
        // Abandonner la transaction avant de lancer l'erreur
        await session.abort();
        throw new Error("Ce bulletin a déjà été validé");
      }

      const netayerRubrique = bulletin.rubriques.find(
        (r) => r.rubrique?.rubriqueIdentity == RubriqueIdentity.netPayer,
      );
      const montant = netayerRubrique?.value ?? 0;

      const decouvertesQuery = await db.query(aql`
      FOR decouvert IN ${decouverteCollection}
        FILTER decouvert.salarie._key == ${bulletin.salarie._key}
        AND (decouvert.status == ${DecouverteStatus.unpaid} OR decouvert.status == ${DecouverteStatus.partialpaid})
        SORT decouvert.timeStamp ASC
        RETURN decouvert
    `);
      const decouvertes = await decouvertesQuery.all();

      // Remboursements de découvertes

      // Paiement du salaire
      if (validate.validateStatus === EtatBulletin.valid) {
        if (montant == 0) {
          throw new Error(
            `Ce bulletin de ${bulletin.salarie.personnel.nom} ${bulletin.salarie.personnel.prenom} n'a pas de net à payer ou son net à payer n'a pas de valeur`,
          );
        }

        // for (const dec of decouvertes) {
        //   const quotien = dec.montant / dec.dureeReversement;
        //   const montantRembourse = Math.min(quotien, dec.montantRestant);

        //   if (montantRembourse > 0) {
        //     // Flux de remboursement
        //     await FluxFinancierModel.createFluxFinancier({
        //       libelle: `Remboursement de l'avance sur salaire de ${bulletin.salarie.personnel.nom} ${bulletin.salarie.personnel.prenom}`,
        //       montant: montantRembourse,
        //       moyenPayement: bulletin.moyenPayement,
        //       type: FluxFinancierType.input,
        //       bankKey: bulletin.banque._key,
        //       isFromSystem: true,
        //       userKey: validate.validater,
        //       referenceTransaction: `${bulletin.referencePaie}-1`,
        //     });

        //     // Mise à jour du découvert
        //     const nouveauRestant = dec.montantRestant - montantRembourse;
        //     let nouveauStatut = DecouverteStatus.partialpaid;
        //     if (nouveauRestant <= 0.0001) {
        //       nouveauStatut = DecouverteStatus.paid;
        //     }

        //     await decouverteCollection.update(dec._key, {
        //       montantRestant: nouveauRestant,
        //       status: nouveauStatut,
        //     });
        //   }
        // }
        // await FluxFinancierModel.createFluxFinancier({
        //   libelle: `Paiement du salaire de ${bulletin.salarie.personnel.nom} ${bulletin.salarie.personnel.prenom}`,
        //   montant: montant,
        //   moyenPayement: bulletin.moyenPayement,
        //   type: FluxFinancierType.output,
        //   bankKey: bulletin.banque._key,
        //   userKey: validate.validater,
        //   isFromSystem: true,
        //   referenceTransaction: `${bulletin.referencePaie}`,
        //   bulletinKey: bulletin._key,
        // });
      }
      // Mise à jour du bulletin
      let newValidate = Array.isArray(bulletin.validate)
        ? bulletin.validate.map((valid) => ({
            ...valid,
            validater: valid.validater,
          }))
        : [];

      newValidate.push(validate);

      await bulletinCollection.update(key, {
        datePayement: datePayement,
        validate: newValidate,
        etat: validate.validateStatus,
      });

      await session.commit();
      return "OK";
    } catch (error) {
      console.error(error);

      await session.abort();

      throw new Error(error);
    }
  }

  async deleteBulletin({ id }) {
    // Logique pour supprimer un bulletin de paie
  }
}

export default BulletinPaie;
export { NatureRubrique, PorteeRubrique };
