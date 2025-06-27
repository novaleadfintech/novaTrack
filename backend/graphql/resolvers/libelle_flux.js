import LibelleFlux from "../../models/flux_financier/libelle_flux.js";

const libelleFluxModel = new LibelleFlux();

const libelleFluxResolvers = {
  libelleFlux: async ({ perPage, skip, type }) =>
    libelleFluxModel.getLibelleFlux({
      skip: skip,
      perPage: perPage,
      type: type,
    }),

  //libelleFlux: async ({ key }) => libelleFluxModel.getLibelleFlux({ key: key }),

  createLibelleFlux: async ({ libelle, type }) =>
    libelleFluxModel.createLibelleFlux({
      libelle: libelle,
      type: type,
    }),

  updateLibelleFlux: async ({ key, libelle }) =>
    libelleFluxModel.updateLibelleFlux({
      key: key,
      libelle: libelle,
    }),

  deleteLibelleFlux: async ({ key }) =>
    libelleFluxModel.deleteLibelle({ key: key }),
};

export default libelleFluxResolvers;
