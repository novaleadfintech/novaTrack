import CountryModel from "../../models/country.js";

const countryModel = new CountryModel();
const countryResolvers = {
  allCountries: async ({ skip, perPage }) =>
    await countryModel.getAllCountries({
      perPage: perPage,
      skip: skip,
    }),

  country: async ({ key }) => await countryModel.getCountry({ key: key }),

  createCountry: async ({ name, code, phoneNumber, tauxTVA, initiauxPays }) =>
    await countryModel.createCountry({
      name: name,
      code: code,
      tauxTVA: tauxTVA,
      initiauxPays: initiauxPays,
      phoneNumber: phoneNumber,
    }),

  updateCountry: async ({
    key,
    name,
    code,
    phoneNumber,
    tauxTVA,
    initiauxPays,
  }) =>
    await countryModel.updateCountry({
      key: key,
      name: name,
      code: code,
      initiauxPays: initiauxPays,
      tauxTVA: tauxTVA,
      phoneNumber: phoneNumber,
    }),
};

export default countryResolvers;
