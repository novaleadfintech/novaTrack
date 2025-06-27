import { aql } from "arangojs";
import db from "../db/database_connection.js";
import { isValidValue } from "../utils/util.js";

const countryCollection = db.collection("countries");

class CountryModel {
  constructor() {}

  async getAllCountries({ perPage, skip }) {
    let limit = aql``;
    if (skip !== undefined && perPage !== undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }

    const query = await db.query(
      aql`
        FOR country IN ${countryCollection}
        SORT country.name ASC
        ${limit}
        RETURN country
      `,
      { fullCount: true }
    );

    if (query.hasNext) {
      const countries = await query.all();
      return countries.map((country) => ({
        fullCount: query.extra.stats.fullCount,
        ...country,
      }));
    } else {
      return [];
    }
  }

  // Récupérer un pays par clé
  async getCountry({ key }) {
    try {
      return await countryCollection.document(key);
    } catch {
      throw new Error(`Pays inexistant`);
    }
  }

  // Créer un pays
  async createCountry({ name, code, phoneNumber, tauxTVA, initiauxPays }) {
    isValidValue({ value: [name, code, phoneNumber, tauxTVA, initiauxPays] });
    const query = await db.query(
      aql`
        FOR country IN ${countryCollection}
        FILTER country.code == ${code}
        RETURN country
      `
    );
    if (query.hasNext) {
      throw new Error("Le pays existe déjà? veuillez le modifier");
    }
    const country = {
      name: name,
      code: code,
      phoneNumber: phoneNumber,
      initiauxPays: initiauxPays,
      tauxTVA: tauxTVA || null,
      timeStamp: Date.now(),
    };

    try {
      await countryCollection.save(country);
      return "OK";
    } catch {
      throw new Error("Une erreur s'est produite lors de l'enregistrement");
    }
  }

  async updateCountry({ key, name, code, phoneNumber, tauxTVA, initiauxPays }) {
    let updateField = {};

    if (name !== undefined) updateField.name = name;
    if (code !== undefined) updateField.code = code;
    if (initiauxPays !== undefined) updateField.initiauxPays = initiauxPays;
    if (phoneNumber !== undefined) updateField.phoneNumber = phoneNumber;
    if (tauxTVA !== undefined) updateField.tauxTVA = tauxTVA;

    isValidValue({ value: updateField });

    try {
      await countryCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      throw new Error(
        "Une erreur s'est produite lors de la mise à jour > " + err
      );
    }
  }

  // Supprimer un pays
  async deleteCountry({ key }) {
    try {
      await countryCollection.remove(key);
      return "OK";
    } catch {
      throw new Error("Une erreur s'est produite lors de la suppression");
    }
  }
}

export default CountryModel;
