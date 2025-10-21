import PayCalendar from "../../models/bulletin_paie/pay_calendar.js";
const payCalendar = new PayCalendar();

const payCalendarResolvers = {
  payCalendars: async ({ perPage, skip }) =>
    await payCalendar.getAllPayCalendar({
      skip: skip,
      perPage: perPage,
    }),

  payCalendar: async ({ key }) =>
    await payCalendar.getPayCalendar({ key: key }),

  createPayCalendar: async ({ libelle, dateDebut, dateFin }) =>
    await payCalendar.createPayCalendar({
      libelle: libelle,
      dateDebut: dateDebut,
      dateFin: dateFin,
    }),

  updatePayCalendar: async ({ key, libelle, dateDebut, dateFin }) =>
    await payCalendar.updatePayCalendar({
      key: key,
      libelle: libelle,
      dateDebut: dateDebut,
      dateFin: dateFin,
    }),

  deletePayCalendar: async ({ key }) =>
    await payCalendar.deletePayCalendar({ key: key }),
};

export default payCalendarResolvers;
