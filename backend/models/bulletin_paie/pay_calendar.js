import { aql } from "arangojs";
import db from "../../db/database_connection.js";
import { isValidValue } from "../../utils/util.js";

const payCalendarCollection = db.collection("payCalendars");
class PayCalendar {
  constructor() {
    this.initializeCollections();
  }

  async initializeCollections() {
    if (!(await payCalendarCollection.exists())) {
      payCalendarCollection.create();
    }
  }

  getAllPayCalendar = async ({ skip, perPage }) => {
    let limit = aql``;
    if (perPage != undefined && skip != undefined) {
      limit = aql`LIMIT ${skip}, ${perPage}`;
    }
    try {
      const query = await db.query(
        aql`
          FOR payCalendar IN ${payCalendarCollection}
          SORT payCalendar.timeStamp DESC
        ${limit}
          RETURN payCalendar
        `
      );

      if (query.hasNext) {
        return await query.all();
      } else {
        return [];
      }
    } catch (err) {
      console.error(err);
      throw new Error("Erreur lors de la récupération");
    }
  };

  getPayCalendar = async ({ key }) => {
    try {
      return await payCalendarCollection.document(key);
    } catch (err) {
      console.error(err);

      throw new Error("Le calendrier que vous recherchez n'existe pas! ");
    }
  };

  createPayCalendar = async ({ libelle, dateDebut, dateFin }) => {
    isValidValue({ value: [libelle, dateDebut, dateFin] });

    const newPayCalendar = {
      libelle: libelle,
      dateDebut: dateDebut,
      dateFin: dateFin,
      timeStamp: Date.now(),
    };
    try {
      await payCalendarCollection.save(newPayCalendar);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de l'enregistrement de la période de paie"
      );
    }
  };

  updatePayCalendar = async ({ key, libelle }) => {
    const updateField = {};
    if (libelle != undefined) {
      updateField.libelle = libelle;
    }

    isValidValue({ value: updateField });
    try {
      await payCalendarCollection.update(key, updateField);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(
        "Une erreur s'est produite lors de la mise à jour du payCalendar"
      );
    }
  };

  deletePayCalendar = async ({ key }) => {
    try {
      // Suppression de la payCalendar
      await payCalendarCollection.remove(key);
      return "OK";
    } catch (err) {
      console.error(err);

      throw new Error(
        err.message ||
          "Une erreur s'est produite lors de la suppression du calendrier de paie"
      );
    }
  };

  isExistPayCalendar = async ({ key }) => {
    const exist = await payCalendarCollection.documentExists(key);
    if (!exist) {
      throw new Error("Calendrier de paie est inexistante!");
    }
  };
}

export default PayCalendar;
