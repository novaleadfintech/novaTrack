import ClientFactureGlobaLValueModel from "../../models/facturation/client_facture_global_value_model.js";

const clientFactureGlobalValueModel = new ClientFactureGlobaLValueModel();

const clientFactureGlobalValueResolvers = {
  clientFactureGlobalValues: async () =>
    await clientFactureGlobalValueModel.clientFactureGlobalValues(),

  configClientFactureGlobaLValue: async ({ clientKey, nbreJrMaxPenalty }) =>
    await clientFactureGlobalValueModel.configClientFactureGlobaLValue({
      clientKey: clientKey,
      nbreJrMaxPenalty: nbreJrMaxPenalty,
    }),
};

export default clientFactureGlobalValueResolvers;
