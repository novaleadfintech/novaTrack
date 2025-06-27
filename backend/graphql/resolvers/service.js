import Service from "../../models/facturation/service.js";

const serviceModel = new Service();
const serviceResolvers = {
  services: async ({ skip, perPage, etat }) =>
    await serviceModel.getAllServices({
      perPage: perPage,
      skip: skip,
      etat: etat,
    }),

  service: async ({ key }) => await serviceModel.getService({ key: key }),

  //creer un nouveau service
  createService: async ({
    libelle,
    tarif,
    etat = "unarchived",
    type,
    prix,
    nature,
    description,
    country,
  }) =>
    await serviceModel.createService({
      description: description,
      libelle: libelle,
      tarif: tarif,
      prix: prix,
      nature: nature,
      type: type,
      etat: etat,
      country: country,
    }),

  updateService: async ({
    key,
    libelle,
    tarif,
    nature,
    prix,
    type,
    description,
    country,
  }) =>
    await serviceModel.updateService({
      key: key,
      description: description,
      libelle: libelle,
      tarif: tarif,
      prix: prix,
      nature: nature,
      type: type,
      country: country,
    }),

  archivedService: async ({ key }) =>
    await serviceModel.archivedService({ key: key }),

  unarchivedService: async ({ key }) =>
    await serviceModel.unarchivedService({ key: key }),
};

export default serviceResolvers;
