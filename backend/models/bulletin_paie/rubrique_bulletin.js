import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import SectionBulletin from "./section_bulletin.js";

const rubriqueBulletinCollection = db.collection("rubriqueBulletins");
const rubriqueCategorieCollection = db.collection("categoriePaieRubriques");

const sectionBulletinModel = new SectionBulletin();
const NatureRubrique = {
  constant: "constant",
  taux: "taux",
  calcul: "calcul",
  sommeRubrique: "sommeRubrique",
  bareme: "bareme",
};
const RubriqueRole = {
  rubrique: "rubrique",
  variable: "variable",
};

const BaseType = {
  valeur: "valeur",
  rubrique: "rubrique",
};

class RubriqueBulletin {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await rubriqueBulletinCollection.exists())) {
      rubriqueBulletinCollection.create();
    }
    if (!(await rubriqueCategorieCollection.exists())) {
      rubriqueCategorieCollection.create({
        type: CollectionType.EDGE_COLLECTION,
      });
    }
  }

  getAllRubriqueBulletin = async ({ skip, perPage } = {}) => {
    let limit = aql``;
    if (perPage != undefined && skip != undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    try {
      const query = await db.query(
        aql`
          FOR rubriqueBulletin IN ${rubriqueBulletinCollection}
          SORT rubriqueBulletin.timeStamp ASC
        ${limit}
          RETURN rubriqueBulletin
        `
      );

      if (query.hasNext) {
        const rubriques = await query.all();

        return Promise.all(
          rubriques.map(async (rubrique) => {
            if (rubrique.taux) {
              rubrique.taux.base = await this.getRubriqueBulletinByCode({
                code: rubrique.taux.base,
              });
            }

            if (rubrique.calcul) {
              for (const element of rubrique.calcul.elements) {
                if (element.type == BaseType.rubrique) {
                  element.rubrique = await this.getRubriqueBulletinByCode({
                    code: element.rubrique,
                  });
                }
              }
            }
            if (rubrique.sommeRubrique) {
              for (const element of rubrique.sommeRubrique.elements) {
                element.rubrique = await this.getRubriqueBulletinByCode({
                  code: element.rubrique,
                });
              }
            }
            if (rubrique.bareme) {
              rubrique.bareme.reference = await this.getRubriqueBulletinByCode({
                code: rubrique.bareme.reference,
              });
              for (const element of rubrique.bareme.tranches) {
                if (element.value.taux) {
                  element.value.taux.base =
                    await this.getRubriqueBulletinByCode({
                      code: element.value.taux.base,
                    });
                }
              }
            }

            return {
              ...rubrique,
              section: rubrique.sectionId
                ? await sectionBulletinModel.getSectionBulletin({
                    key: rubrique.sectionId,
                  })
                : null,
            };
          })
        );
      } else {
        return [];
      }
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la récupération");
    }
  };
  getPrimeExceptionnel = async ({ skip, perPage } = {}) => {
    let limit = aql``;
    if (perPage != undefined && skip != undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    try {
      const query = await db.query(
        aql`
          FOR rubriqueBulletin IN ${rubriqueBulletinCollection}
          FILTER 
          SORT rubriqueBulletin.timeStamp ASC
        ${limit}
          RETURN rubriqueBulletin
        `
      );

      if (query.hasNext) {
        const rubriques = await query.all();

        return Promise.all(
          rubriques.map(async (rubrique) => {
            if (rubrique.taux) {
              rubrique.taux.base = await this.getRubriqueBulletinByCode({
                code: rubrique.taux.base,
              });
            }

            if (rubrique.calcul) {
              for (const element of rubrique.calcul.elements) {
                if (element.type == BaseType.rubrique) {
                  element.rubrique = await this.getRubriqueBulletinByCode({
                    code: element.rubrique,
                  });
                }
              }
            }
            if (rubrique.sommeRubrique) {
              for (const element of rubrique.sommeRubrique.elements) {
                element.rubrique = await this.getRubriqueBulletinByCode({
                  code: element.rubrique,
                });
              }
            }
            if (rubrique.bareme) {
              rubrique.bareme.reference = await this.getRubriqueBulletinByCode({
                code: rubrique.bareme.reference,
              });
              for (const element of rubrique.bareme.tranches) {
                if (element.value.taux) {
                  element.value.taux.base =
                    await this.getRubriqueBulletinByCode({
                      code: element.value.taux.base,
                    });
                }
              }
            }

            return {
              ...rubrique,
              section: rubrique.sectionId
                ? await sectionBulletinModel.getSectionBulletin({
                    key: rubrique.sectionId,
                  })
                : null,
            };
          })
        );
      } else {
        return [];
      }
    } catch (err) {
      console.error(err);

      throw new Error("Erreur lors de la récupération");
    }
  };

  getRubriqueBulletin = async ({ key }) => {
    try {
      const rubrique = await rubriqueBulletinCollection.document(key);
      if (rubrique.taux) {
        rubrique.taux.base = await this.getRubriqueBulletinByCode({
          code: rubrique.taux.base,
        });
      }

      if (rubrique.calcul) {
        for (const element of rubrique.calcul.elements) {
          if (element.type == BaseType.rubrique) {
            element.rubrique = await this.getRubriqueBulletinByCode({
              code: element.rubrique,
            });
          }
        }
      }
      if (rubrique.sommeRubrique) {
        for (const element of rubrique.sommeRubrique.elements) {
          element.rubrique = await this.getRubriqueBulletinByCode({
            code: element.rubrique,
          });
        }
      }
      if (rubrique.bareme) {
        rubrique.bareme.reference = await this.getRubriqueBulletinByCode({
          code: rubrique.bareme.reference,
        });
        for (const element of rubrique.bareme.tranches) {
          if (element.value.taux) {
            element.value.taux.base = await this.getRubriqueBulletinByCode({
              code: element.value.taux.base,
            });
          }
        }
      }
      return {
        ...rubrique,
        section: rubrique.sectionId
          ? await sectionBulletinModel.getSectionBulletin({
              key: rubrique.sectionId,
            })
          : null,
      };
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de la récupération du rubrique"
      );
    }
  };

  getRubriqueBulletinByCode = async ({ code }) => {
    try {
      const query = await db.query(
        aql`FOR rubrique IN ${rubriqueBulletinCollection} FILTER rubrique.code == ${code} SORT rubrique.timeStamp ASC RETURN rubrique`
      );
      if (query.hasNext) {
        const rubrique = await query.next();
        return {
          ...rubrique,
          section: rubrique.sectionId
            ? await sectionBulletinModel.getSectionBulletin({
                key: rubrique.sectionId,
              })
            : null,
        };
      }
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de la récupération du rubrique"
      );
    }
  };

  createRubriqueBulletin = async ({
    rubrique,
    code,
    type,
    sectionId,
    calcul,
    rubriqueIdentity,
    taux,
    portee,
    sommeRubrique,
    nature,
    rubriqueRole,
    bareme,
  }) => {
    isValidValue({
      value: [rubrique, code, nature],
    });

    if (rubriqueRole != RubriqueRole.variable) {
      isValidValue({ value: type });
    }

    if (nature == NatureRubrique.taux) {
      isValidValue({ value: taux });
    } else {
      taux = null;
    }
    if (nature == NatureRubrique.constant) {
      isValidValue({
        value: [rubriqueRole, portee],
      });
    } else {
      portee = null;
      rubriqueRole = null;
    }
    if (nature == NatureRubrique.calcul) {
      isValidValue({ value: calcul });
    } else {
      calcul = null;
    }
    if (nature == NatureRubrique.bareme) {
      isValidValue({ value: bareme });
    } else {
      bareme = null;
    }
    if (nature == NatureRubrique.sommeRubrique) {
      isValidValue({ value: sommeRubrique });
    } else {
      sommeRubrique = null;
    }
    if (sectionId) {
      isValidValue({ value: sectionId });
      await sectionBulletinModel.isExistSectionBulletin({ key: sectionId });
    }
    const newRubriqueBulletin = {
      rubrique: rubrique,
      code: code,
      type: type,
      nature: nature,
      sectionId: sectionId,
      taux: taux,
      rubriqueRole: rubriqueRole,
      portee: portee,
      calcul: calcul,
      sommeRubrique: sommeRubrique,
      bareme: bareme,
      rubriqueIdentity: rubriqueIdentity,
      timeStamp: Date.now(),
    };
    try {
      await rubriqueBulletinCollection.save(newRubriqueBulletin);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de l'enregistrement du rubrique"
      );
    }
  };

  updateRubriqueBulletin = async ({
    key,
    rubrique,
    // code,
    type,
    sectionId,
    rubriqueRole,
    calcul,
    taux,
    portee,
    rubriqueIdentity,
    sommeRubrique,
    nature,
    bareme,
  }) => {
    const updateField = {};
    if (rubrique != undefined) {
      updateField.rubrique = rubrique;
    }
    // if (code != undefined) {
    //   updateField.code = code;
    // }
    if (type != undefined) {
      updateField.type = type;
    }
    if (sectionId != undefined) {
      await sectionBulletinModel.isExistSectionBulletin({ key: sectionId });
    }
    updateField.sectionId = sectionId;

    if (rubriqueIdentity !== undefined) {
      updateField.rubriqueIdentity = rubriqueIdentity;
    }
    if (nature != undefined) {
      updateField.nature = nature;
      if (nature == NatureRubrique.constant) {
        isValidValue({ value: [rubriqueRole, portee] });
        if (rubriqueRole == RubriqueRole.variable) {
          type = null;
        }
      } else {
        portee = null;
        rubriqueRole = null;
      }
      updateField.rubriqueRole = rubriqueRole;
      updateField.type = type;
      updateField.portee = portee;
      if (nature == NatureRubrique.taux) {
        isValidValue({ value: taux });
      } else {
        taux = null;
      }
      updateField.taux = taux;

      if (nature == NatureRubrique.calcul) {
        isValidValue({ value: calcul });
      } else {
        calcul = null;
      }
      updateField.calcul = calcul;

      if (nature == NatureRubrique.sommeRubrique) {
        isValidValue({ value: sommeRubrique });
      } else {
        sommeRubrique = null;
      }
      updateField.sommeRubrique = sommeRubrique;

      if (nature == NatureRubrique.bareme) {
        isValidValue({ value: bareme });
      } else {
        bareme = null;
      }
      updateField.bareme = bareme;
    } else if (
      rubriques_composantes != undefined ||
      base != undefined ||
      bareme != undefined ||
      typeFormule != undefined ||
      taux != undefined
    ) {
      throw new Error("Vous devez spécifier le nature de la rubrique!");
    }

    try {
      await rubriqueBulletinCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de la mise à jour du rubrique"
      );
    }
  };

  deleteRubriqueBulletin = async ({ key }) => {
    try {
      await rubriqueBulletinCollection.remove(key);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de la suppression du rubrique"
      );
    }
  };

  isExistRubriqueBulletin = async ({ key }) => {
    const exist = await rubriqueBulletinCollection.documentExists(key);
    if (!exist) {
      throw new Error("Cette rubrique est inexistante!");
    }
  };
}

export default RubriqueBulletin;
