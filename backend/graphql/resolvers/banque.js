import Banque from "../../models/banque.js";

const banqueModel = new Banque();

const banqueResolvers = {
  banques: async ({ skip, perPage }) =>
    await banqueModel.getAllBanques({
      perPage: perPage,
      skip: skip,
    }),

  banque: async ({ key }) => await banqueModel.getBanque({ key: key }),

  createBanque: async ({
    name,
    codeBanque,
    codeBIC,
    numCompte,
    country,
    type,
    logo,
    codeGuichet,
    cleRIB,
  }) =>
    await banqueModel.createBanque({
      cleRIB: cleRIB,
      codeGuichet: codeGuichet,
      codeBanque: codeBanque,
      name: name,
      type: type,
      codeBIC: codeBIC,
      numCompte: numCompte,
      // soldeReel: soldeReel,
      country: country,
      logo: logo,
    }),

  updateBanque: async ({
    key,
    name,
    codeBIC,
    numCompte,
    codeBanque,
    country,
    type,
    logo,
    codeGuichet,
    cleRIB,
  }) =>
    await banqueModel.updateBanque({
      key: key,
      name: name,
      cleRIB: cleRIB,
      codeBanque: codeBanque,
      codeBIC: codeBIC,
      type: type,
      numCompte: numCompte,
      codeGuichet: codeGuichet,
      logo: logo,
      country: country,
    }),

  // resetBanqueAmount: async ({ key, soldeReel }) =>
  //   await banqueModel.resetBanqueAmount({ key: key, soldeReel: soldeReel, }),

  deleteBanque: async ({ key }) => await banqueModel.deleteBanque({ key: key }),
};

export default banqueResolvers;
