import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidEmail, isValidValue } from "../../utils/util.js";

const personnelCollection = db.collection("personnels");
const bulletinCollection = db.collection("bulletins");
import Pays from "../country.js";

const paysModel = new Pays();

const EtatPersonnel = {
  archived: "archived",
  unarchived: "unarchived",
};

class Personnel {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await personnelCollection.exists())) {
      personnelCollection.create();
    }
    if (!(await bulletinCollection.exists())) {
      bulletinCollection.create();
    }
  }

  //recuperer tous les personnels
  getAllPersonnel = async ({ skip, perPage, etat }) => {
    let limit = aql``;
    let filtre = aql``;
    if (skip !== undefined && perPage != undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    if (etat !== undefined) {
      filtre = aql`FILTER personnel.etat == ${etat}`;
    }
    const query = await db.query(
      aql`FOR personnel IN ${personnelCollection} ${filtre} 
      LET sortKey1 = personnel.nom != null ? personnel.nom : ""
      LET sortKey2 = personnel.prenom != null ? personnel.prenom : ""
      SORT sortKey1 ASC, sortKey2 ASC
      ${limit} RETURN personnel`,
      { fullCount: true }
    );
    if (query.hasNext) {
      const personnels = await query.all();
      return personnels.map((personnel) => {
        return {
          fullCount: query.extra.stats.fullCount,
          ...personnel,
        };
      });
    } else {
      return [];
    }
  };

  //récuperer un personnel
  getPersonnel = async ({ key }) => {
    try {
      const personnel = await personnelCollection.document(key);
      return personnel;
    } catch (e) {
      console.error(e);
      throw new Error(`Ce personnel est inexistant`);
    }
  };

  //création de personnel
  createPersonnel = async ({
    nom,
    prenom,
    email,
    telephone,
    adresse,
    pays,
    sexe,
    etat = EtatPersonnel.unarchived,
    poste,
    situationMatrimoniale,
    commentaire,
    dateNaissance,
    dateDebut,
    dateFin,
    nombreEnfant,
    nombrePersonneCharge,
    typePersonnel,
    typeContrat,
    personnePrevenir,
    dureeEssai = 0,
  }) => {
    // Validation des champs requis
    isValidValue({
      value: [
        nom,
        prenom,
        email,
        telephone,
        etat,
        sexe,
        poste,
        situationMatrimoniale,
        pays,
        dateNaissance,
        dateDebut,
        typePersonnel,
        personnePrevenir,
      ],
    });

    isValidEmail({ email: email });

    if (adresse !== undefined) {
      isValidValue({ value: adresse });
    }
    if (typeContrat !== undefined) {
      isValidValue({ value: typeContrat });
    }
    if (commentaire !== undefined) {
      isValidValue({ value: commentaire });
    }

    try {
      const existingPersonnel = await db.query(aql`
        FOR personnel IN ${personnelCollection}
        FILTER personnel.email == ${email}
        LIMIT 1
        RETURN personnel
      `);

      if (existingPersonnel.hasNext) {
        throw new Error(`Un personnel avec l'email ${email} existe déjà.`);
      }
      const completPays = await paysModel.getCountry({ key: pays });
      const personnel = {
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        adresse: adresse,
        sexe: sexe,
        etat: etat,
        pays: completPays,
        poste: poste,
        situationMatrimoniale: situationMatrimoniale,
        commentaire: commentaire,
        dateEnregistrement: Date.now(),
        dateNaissance: dateNaissance,
        dateDebut: dateDebut,
        dateFin: dateFin,
        dureeEssai: dureeEssai,
        nombreEnfant: nombreEnfant,
        nombrePersonneCharge: nombrePersonneCharge,
        typePersonnel: typePersonnel,
        typeContrat: typeContrat,
        personnePrevenir: personnePrevenir,
      };

      await personnelCollection.save(personnel);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(`Une erreur s'est produite lors de l'enregistrement `);
    }
  };

  //Mettre à jour les donnée des personnels
  updatePersonnel = async ({
    key,
    nom,
    prenom,
    email,
    telephone,
    adresse,
    sexe,
    pays,
    poste,
    situationMatrimoniale,
    commentaire,
    dateNaissance,
    dateDebut,
    dateFin,
    dureeEssai,
    nombreEnfant,
    nombrePersonneCharge,
    typePersonnel,
    typeContrat,
    personnePrevenir,
  }) => {
    let updateField = {};

    if (nom !== undefined) {
      updateField.nom = nom;
    }

    if (prenom !== undefined) {
      updateField.prenom = prenom;
    }

    if (dateNaissance !== undefined) {
      updateField.dateNaissance = dateNaissance;
    }

    if (dateDebut !== undefined) {
      updateField.dateDebut = dateDebut;
    }

    if (typePersonnel !== undefined) {
      updateField.typePersonnel = typePersonnel;
    }
    if (typeContrat !== undefined) {
      updateField.typeContrat = typeContrat;
    }
    if (personnePrevenir !== undefined) {
      updateField.personnePrevenir = personnePrevenir;
    }

    if (email !== undefined) {
      isValidEmail({ email: email });
      const existingPersonnel = await db.query(aql`
        FOR personnel IN ${personnelCollection}
        FILTER personnel.email == ${email}
        LIMIT 1
        RETURN personnel
      `);

      if (existingPersonnel.hasNext) {
        throw new Error(`Un personnel avec l'email ${email} existe déjà.`);
      }
      updateField.email = email;
    }

    if (telephone !== undefined) {
      updateField.telephone = telephone;
    }
    if (pays !== undefined) {
      const completPays = await paysModel.getCountry({ key: pays });
      updateField.pays = completPays;
    }
    if (sexe !== undefined) {
      updateField.sexe = sexe;
    }

    if (poste !== undefined) {
      updateField.poste = poste;
    }
    if (situationMatrimoniale !== undefined) {
      updateField.situationMatrimoniale = situationMatrimoniale;
    }
    isValidValue({ value: updateField });
    if (dureeEssai !== undefined) {
      updateField.dureeEssai = dureeEssai;
    }
    updateField.dateFin = dateFin;
    if (commentaire !== undefined) {
      try {
        isValidValue({ value: commentaire });
        updateField.commentaire = commentaire;
      } catch {
        updateField.commentaire = null;
      }
    }

    if (adresse !== undefined) {
      try {
        isValidValue({ value: adresse });
        updateField.adresse = adresse;
      } catch {
        updateField.adresse = null;
      }
    }

    if (nombreEnfant !== undefined) {
      updateField.nombreEnfant = nombreEnfant;
    }
    if (nombrePersonneCharge !== undefined) {
      updateField.nombrePersonneCharge = nombrePersonneCharge;
    }

    try {
      await personnelCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error("Une erreur s'est produite lors de la mise à jour");
    }
  };

  archivedPersonnel = async ({ key }) => {
    const trx = await db.beginTransaction({
      write: [personnelCollection, bulletinCollection],
    });

    try {
      const updateField = { etat: EtatPersonnel.archived };
      await trx.step(() => personnelCollection.update(key, updateField));
      await trx.step(() =>
        db.query(aql`
          FOR bulletin IN ${bulletinCollection}
          FILTER bulletin.personnelId == ${key}
          UPDATE bulletin WITH { regenerate: false } IN ${bulletinCollection}
        `)
      );
      await trx.commit();
      return "OK";
    } catch (err) {
      console.error(err);

      await trx.abort();
      throw new Error(
        `Une erreur s'est produite lors de l'archivage du personnel et de la mise à jour des bulletins`
      );
    }
  };

  unarchivedPersonnel = async ({ key }) => {
    const trx = await db.beginTransaction({
      write: [personnelCollection, bulletinCollection],
    });

    try {
      const updateField = { etat: EtatPersonnel.unarchived };
      await trx.step(() => personnelCollection.update(key, updateField));

      await trx.step(() =>
        db.query(aql`
          FOR bulletin IN ${bulletinCollection}
          FILTER bulletin.personnelId == ${key}
          UPDATE bulletin WITH { regenerate: true } IN ${bulletinCollection}
        `)
      );
      await trx.commit();
      return "OK";
    } catch (err) {
      console.error(err);

      await trx.abort();
      throw new Error(
        `Une erreur s'est produite lors du désarchivage du personnel et de la mise à jour des bulletins`
      );
    }
  };

  isExistPersonnel = async ({ key }) => {
    const exist = await personnelCollection.documentExists(key);
    if (!exist) {
      throw new Error("Ce personnel n'existe pas!");
    }
  };
}
export default Personnel;
export { EtatPersonnel };
