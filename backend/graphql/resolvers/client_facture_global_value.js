import ClientFactureGlobaLValueModel from "../../models/facturation/client_facture_global_value_model.js";

const clientFactureGlobalValueModel = new ClientFactureGlobaLValueModel();

const clientFactureGlobalValueResolvers = {
  clientFactureGlobalValues: async () =>
    await clientFactureGlobalValueModel.clientFactureGlobalValues(),

  configClientFactureGlobaLValue: async ({ clientId, nbreJrMaxPenalty }) =>
    await clientFactureGlobalValueModel.configClientFactureGlobaLValue({
      clientId: clientId,
      nbreJrMaxPenalty: nbreJrMaxPenalty,
    }),
};

export default clientFactureGlobalValueResolvers;
