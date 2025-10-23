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

const FluxFinancierModel = new FluxFinancier();
const SalarieModel = new Salarie();
const BanqueModel = new Banque();
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
  avanceSurSalaire: "avanceSurSalaire",
};

class BulletinPaie {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await bulletinCollection.exists())) {
      bulletinCollection.create();
    }
    if (!(await decouverteCollection.exists())) {
      decouverteCollection.create();
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
      { fullCount: true }
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
              })
            );
          }
          return {
            ...bulletin,
            validate: validate,
            rubriques: rubriquesResolues,
          };
        })
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
        SORT bulletin.timeStamp DESC
        ${limit}
        RETURN bulletin
      `,
      { fullCount: true }
    );
    if (query.hasNext) {
      const bulletins = await query.all();
      //         FILTER bulletin.etat == ${EtatBulletin.valid} AND bulletin.dateDebut <= ${today} AND bulletin.dateFin >= ${today}

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
              })
            );
          }

          return {
            ...bulletin,
            validate: validate,
            rubriques: rubriquesResolues,
          };
        })
      );
    } else {
      return [];
    }
  }

  async getReadyBulletins({ dateDebut, dateFin }) {
    const salaires = await SalarieModel.getAllActiveSalarieByPeriod({
      dateDebut: dateDebut,
      dateFin: dateFin,
    });
    const readySalaries = [];
     for (const salarie of salaires) { 
      if (
        await this.verifySingleFutureBulletin({
          dateDebut: dateDebut,
          dateFin: dateFin,
          salarieId: salarie._id,
        })
      ) {
        readySalaries.push(salarie);
      }
    }
    return readySalaries;
  }

  async verifySingleFutureBulletin({ dateDebut, dateFin, salarieId }) {
    try {
      // Vérifie s’il existe déjà un bulletin pour ce salarié dans la période donnée
      const query = await db.query(aql`
      FOR b IN ${bulletinCollection}
        FILTER b.salarieId == ${salarieId}
        AND (
          (b.dateDebut <= ${dateFin} AND b.dateFin >= ${dateDebut})
        )
        LIMIT 1
        RETURN b
    `);
       return !query.hasNext;
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
      { fullCount: true }
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
              })
            );
          }
          return {
            ...bulletin,
            rubriques: rubriquesResolues,
            validate: validate,
          };
        })
      );
    } else {
      return [];
    }
  }

  async getBulletin({ id }) {
    try {
      const bulletin = await bulletinCollection.document({ _id: id });
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
          })
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

  async getPreviousBulletin({ salarieId }) {
    try {
      const query = await db.query(
        aql`FOR bulletin IN ${bulletinCollection} FILTER bulletin.salarie._id == ${salarieId} SORT bulletin.dateEdition DESC
        LIMIT 1
        RETURN bulletin`
      );
      console.log(query);
      if (query.hasNext) {
        const bulletin = await query.next();
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
            })
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
      FILTER bulletin.salarie._id == ${id}
      AND bulletin.etat ==${EtatBulletin.valid}
      SORT bulletin.timeStamp DESC
      LIMIT 1
      RETURN bulletin
    `);

      const bulletin = await cursor.next();
      if (!bulletin) {
        throw new Error(
          "Vous n'êtes pas éligible à une avance sur salaire. Vous n'avez jamais été payé auparavant."
        );
      }

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

      // 🔍 Trouver la rubrique "net à payer"
      const rubriqueNetAPayer = rubriquesResolues.find(
        (r) => r.rubrique?.rubriqueIdentity === RubriqueIdentity.netPayer
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
          `Nous trouvons que vous seriez incapable de remborser la somme demandée? Le maximun de somme que vous pouvez demander s'éléve à ${moitie}`
        );
      }

      let validate = bulletin.validate ?? [];
      await Promise.all(
        validate.map(async (valid) => {
          valid.validater = await userModel.getUser({
            key: valid.validater,
          });
        })
      );

      return {
        ...bulletin,
        rubriques: rubriquesResolues,
        validate,
      };
    } catch (err) {
      console.error(err);

      throw new Error(
        err.message || "Erreur lors de la récupération du bulletin."
      );
    }
  }

  async createBulletin({
    moyenPayement,
    debutPeriodePaie,
    finPeriodePaie,
    referencePaie,
    dateEdition,
    banqueId,
    salarieId,
    rubriques,
  }) {
    isValidValue({
      value: [
        banqueId,
        moyenPayement,
        debutPeriodePaie,
        finPeriodePaie,
        referencePaie,
        dateEdition,
        salarieId,
      ],
    });

    isValidValue({ value: rubriques });

    // Vérification de chevauchement d’une période de paie
    const existingBulletin = await db.query(aql`
    FOR bulletin IN ${bulletinCollection}
    FILTER bulletin.salarie._id == ${salarieId}
    AND NOT (bulletin.finPeriodePaie < ${debutPeriodePaie}
    AND (bulletin.etat == ${EtatBulletin.wait} OR bulletin.etat == ${EtatBulletin.returne} OR bulletin.etat == ${EtatBulletin.valid} )
    OR bulletin.debutPeriodePaie > ${finPeriodePaie})
    LIMIT 1
    RETURN bulletin
`);

    if (existingBulletin.hasNext) {
      throw new Error(
        `Un bulletin existe déjà pour ce salarié dans cette période.`
      );
    }

    // Vérification de l’unicité de la référence de paie (si fournie)
    if (referencePaie != null) {
      const existingReferenceBulletin = await db.query(aql`
    FOR bulletin IN ${bulletinCollection}
    FILTER bulletin.referencePaie == ${referencePaie}
    LIMIT 1
    RETURN bulletin
  `);

      if (existingReferenceBulletin.hasNext) {
        throw new Error(
          `Un bulletin existe déjà avec cette référence de paie.`
        );
      }
    }

    const salarie = await SalarieModel.getSalarie({ key: salarieId });
    const banque = await BanqueModel.getBanque({ key: banqueId });
    const { logo, ...otherdata } = banque;
    if (logo != null) {
      otherdata.logo = logo.replace(
        process.env.FILE_PREFIX + `${locateBanqueFolder}/`,
        ""
      );
    }

    // Étape 1 : Récupérer les découverts impayés ou partiellement payés
    const decouvertesQuery = await db.query(aql`
  FOR decouvert IN ${decouverteCollection}
    FILTER decouvert.salarie._id == ${salarieId}
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

    // Étape 3 : Ajouter ou mettre à jour la rubrique "avanceSurSalaire"

    for (let i = 0; i < rubriques.length; i++) {
      const rubriqueData = await RubriqueBulletinModel.getRubriqueBulletin({
        key: rubriques[i].rubriqueId,
      });
      rubriques[i].rubrique = rubriqueData;
    }
    const indexRubriqueAvance = rubriques.findIndex(
      (r) => r.rubrique?.rubriqueIdentity === RubriqueIdentity.avanceSurSalaire
    );
    if (indexRubriqueAvance !== -1) {
      rubriques[indexRubriqueAvance].value = totalAvance;
    }
    // else {
    //   rubriques.push({
    //     rubrique: {
    //       constant: {
    //         identity: "avanceSurSalaire",
    //       },
    //     },
    //     valeur: totalAvance,
    //   });
    // }

    const bulletin = {
      salarie: salarie,
      dateEdition: dateEdition,
      etat: EtatBulletin.wait,
      banque: otherdata,
      debutPeriodePaie: debutPeriodePaie,
      finPeriodePaie: finPeriodePaie,
      referencePaie: referencePaie,
      moyenPayement: moyenPayement,
      rubriques: rubriques,
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
      return "OK";
    } catch (error) {
      console.error(error);

      await session.abort();
      throw new Error(`Erreur lors de la création du bulletin`);
    }
  }

  async updateBulletin({
    key,
    banqueId,
    moyenPayement,
    salarieId,
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
    if (banqueId !== undefined) {
      const banque = await BanqueModel.getBanque({ key: banqueId });
      const { logo, ...otherdata } = banque;
      if (logo != null) {
        otherdata.logo = logo.replace(
          process.env.FILE_PREFIX + `${locateBanqueFolder}/`,
          ""
        );
      }
      updateField.banque = otherdata;
    }

    if (salarieId !== undefined) {
      await SalarieModel.isExistSalarie({ key: salarieId });
      const existingBulletin = await db.query(aql`
      FOR bulletin IN ${bulletinCollection}
      FILTER bulletin.salarieId == ${salarieId} 
      AND (bulletin.etat == ${EtatBulletin.wait} OR bulletin.etat == ${EtatBulletin.returne})
      AND bulletin._id == ${key}
      AND bulletin.debutPeriodePaie >= ${debutPeriodePaie}
      AND bulletin.finPeriodePaie <= ${finPeriodePaie}
      LIMIT 1
      RETURN bulletin
    `);

      if (existingBulletin.hasNext) {
        throw new Error(`Un bulletin existe déjà pour ce salarié.`);
      }
      updateField.salarieId = salarieId;
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
  //         const { retenus, gains, salarieId, _key } = bulletin;
  //         const filteredRetenus = retenus.filter((retenu) => !retenu.isAvance);
  //         await session.step(async () => {
  //           await this.createBulletin({
  //             gains: gains,
  //             salarieId: salarieId,
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
        (r) => r.rubrique?.rubriqueIdentity == RubriqueIdentity.netPayer
      );
      const montant = netayerRubrique?.value ?? 0;

      const decouvertesQuery = await db.query(aql`
      FOR decouvert IN ${decouverteCollection}
        FILTER decouvert.salarie._id == ${bulletin.salarie._id}
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
            `Ce bulletin de ${bulletin.salarie.personnel.nom} ${bulletin.salarie.personnel.prenom} n'a pas de net à payer`
          );
        }

        for (const dec of decouvertes) {
          const quotien = dec.montant / dec.dureeReversement;
          const montantRembourse = Math.min(quotien, dec.montantRestant);

          if (montantRembourse > 0) {
            // Flux de remboursement
            await FluxFinancierModel.createFluxFinancier({
              libelle: `Remboursement de l'avance sur salaire de ${bulletin.salarie.personnel.nom} ${bulletin.salarie.personnel.prenom}`,
              montant: montantRembourse,
              moyenPayement: bulletin.moyenPayement,
              type: FluxFinancierType.input,
              bankId: bulletin.banque._id,
              isFromSystem: true,
              userId: validate.validater,
              referenceTransaction: `${bulletin.referencePaie}-1`,
            });

            // Mise à jour du découvert
            const nouveauRestant = dec.montantRestant - montantRembourse;
            let nouveauStatut = DecouverteStatus.partialpaid;
            if (nouveauRestant <= 0.0001) {
              nouveauStatut = DecouverteStatus.paid;
            }

            await decouverteCollection.update(dec._key, {
              montantRestant: nouveauRestant,
              status: nouveauStatut,
            });
          }
        }
        await FluxFinancierModel.createFluxFinancier({
          libelle: `Paiement du salaire de ${bulletin.salarie.personnel.nom} ${bulletin.salarie.personnel.prenom}`,
          montant: montant,
          moyenPayement: bulletin.moyenPayement,
          type: FluxFinancierType.output,
          bankId: bulletin.banque._id,
          userId: validate.validater,
          isFromSystem: true,
          referenceTransaction: `${bulletin.referencePaie}`,
          bulletinId: bulletin._id,
        });
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

      // Re-lancer l'erreur spécifique de validation
      if (error.message === "Ce bulletin a déjà été validé") {
        throw error.message;
      }

      throw new Error(
        "Une erreur s'est produite lors de la validation du bulletin"
      );
    }
  }

  async deleteBulletin({ id }) {
    // Logique pour supprimer un bulletin de paie
  }
}

export default BulletinPaie;
