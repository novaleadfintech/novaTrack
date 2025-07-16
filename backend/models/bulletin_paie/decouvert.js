import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";
import Salarie from "../bulletin_paie/salarie.js";
import Banque from "../banque.js";
import FluxFinancier, {
  FluxFinancierType,
  FluxFinancierStatus,
} from "../flux_financier/flux_financier.js";
import BulletinPaie from "../bulletin_paie/bulletin.js";

const decouverteCollection = db.collection("decouvertes");
const FluxFinancierModel = new FluxFinancier();
const BanqueModel = new Banque();
const SalaireModel = new Salarie();
const bulletinModel = new BulletinPaie();
const locateBanqueFolder = "banque";

const DecouverteStatus = {
  paid: "paid",
  partialpaid: "partialpaid",
  unpaid: "unpaid",
};

class Decouverte {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await decouverteCollection.exists())) {
      decouverteCollection.create();
    }
  }
  getAllDecouvertes = async ({ perPage, skip }) => {
    let limit = aql``;
    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    const query = await db.query(
      aql`FOR decouverte IN ${decouverteCollection} SORT decouverte.dateEnregistrement                                     DESC ${limit} RETURN decouverte`,
      { fullCount: true }
    );
    if (query.hasNext) {
      const decouvertes = await query.all();
      return Promise.all(
        decouvertes.map(async (decouverte) => {
          return {
            ...decouverte,
            // salarie: await SalaireModel.getSalarie({
            //   key: decouverte.salarieId,
            // }),
          };
        })
      );
    } else {
      return [];
    }
  };

  getDecouverte = async ({ key }) => {
    try {
      const decouverte = await decouverteCollection.document(key);
      return {
        ...decouverte,
        // salarie: await SalaireModel.getSalarie({
        //   key: decouverte.salarieId,
        // }),
      };
    } catch (e) {
      throw new Error(`Ce decouvert est introuvable`);
    }
  };

  createDecouverte = async ({
    justification,
    montant,
    dureeReversement,
    salarieId,
    moyenPayement,
    banqueId,
    referenceTransaction,
    userId,
  }) => {
    isValidValue({
      value: [
        justification,
        montant,
        dureeReversement,
        referenceTransaction,
        moyenPayement,
        banqueId,
        userId,
      ],
    });

    const salarie = await SalaireModel.getSalarie({ key: salarieId });
    // const bulletin =
    await bulletinModel.verifyMontantDecouvertPossible({
      id: salarieId,
      montantDemande: montant,
    });
    // creer un flux financier si confirmé
    const banque = await BanqueModel.getBanque({ key: banqueId });
    const { logo, ...otherdata } = banque;
    if (logo != null) {
      otherdata.logo = logo.replace(
        process.env.FILE_PREFIX + `${locateBanqueFolder}/`,
        ""
      );
    }

    const decouvert = {
      justification,
      salarie: salarie,
      montant: montant,
      dureeReversement,
      referenceTransaction: referenceTransaction,
      dateEnregistrement: Date.now(),
      montantRestant: montant,
      status: DecouverteStatus.unpaid,
      moyenPayement,
      banque: otherdata,
    };

    try {
      const decouvertResult = await decouverteCollection.save(decouvert, {
        returnNew: true,
      });
      // creer un flux financier
      await FluxFinancierModel.createFluxFinancier({
        libelle: `Avance sur salaire de ${salarie.personnel.nom} ${salarie.personnel.prenom}`,
        type: FluxFinancierType.output,
        montant: montant,
        moyenPayement: moyenPayement,
        bankId: banqueId,
        isFromSystem: true,
        userId: userId,
        referenceTransaction: referenceTransaction,
        decouvertId: decouvertResult.new._id,
      });
    } catch (e) {
      throw new Error("Une erreur s'est produite lors de la création");
    }

    return "OK";
  };

  updateDecouverte = async ({
    key,
    justification,
    montant,
    dureeReversement,
    salarieId,
    referenceTransaction,
    banqueId,
    moyenPayement,
    montantRestant,
  }) => {
    const updateField = {};
    const fluxUpateField = {};

    if (justification !== undefined) {
      updateField.justification = justification;
    }

    if (moyenPayement !== undefined) {
      updateField.moyenPayement = moyenPayement;
      fluxUpateField.moyenPayement = moyenPayement;
    }

    if (montant !== undefined) {
      updateField.montant = montant;
      fluxUpateField.montant = montant;
    }
    if (referenceTransaction !== undefined) {
      updateField.referenceTransaction = referenceTransaction;
      fluxUpateField.referenceTransaction = referenceTransaction;
    }

    if (dureeReversement !== undefined) {
      await bulletinModel.verifyMontantDecouvertPossible({
        id: salarieId,
        montantDemande: montant,
      });
      updateField.dureeReversement = dureeReversement;
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
      fluxUpateField.bankId = banqueId;
    }

    isValidValue({ value: updateField });

    if (montantRestant !== undefined) {
      updateField.montantRestant = montantRestant;
    }

    if (salarieId !== undefined) {
      const salarie = await SalaireModel.getSalarie({ key: salarieId });
      updateField.salarie = salarie;
    }

    try {
      if (Object.keys(updateField).length === 0) {
        throw new Error("Aucun champ à mettre à jour");
      }
      const decouvertfluxFinancier =
        await FluxFinancierModel.getFluxFiancierbyDecouvert({
          decouvertId: key,
        });
      if (decouvertfluxFinancier) {
        if (
          decouvertfluxFinancier.validate?.validateStatus ==
          FluxFinancierStatus.valid
        ) {
          throw new Error(
            "Vous ne pouvez plus modifier cette avance sur salaire"
          );
        } else {
          await decouverteCollection.update(key, updateField);
          await FluxFinancierModel.updateFluxFinancier({
            key: decouvertfluxFinancier._id,
            ...fluxUpateField,
          });
        }
      }
      return "OK";
    } catch (e) {
      throw new Error("Une erreur s'est produite lors de la mise à jour." + e);
    }
  };

  async getAncienneDecouvertebyId({ salaireId }) {
    const query = await db.query(
      aql`FOR decouverte IN decouvertes 
          FILTER decouverte.salaireId == ${salaireId} AND decouverte.montantRestant > 0 
          SORT decouverte.dateEnregistrement ASC 
          LIMIT 1 
          RETURN decouverte`
    );
    return query.hasNext ? await query.next() : null;
  }
}
export default Decouverte;
