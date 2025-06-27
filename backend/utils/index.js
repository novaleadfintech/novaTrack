import clientResolvers from "./client.js";
import personnelResolvers from "./personnel.js";
import serviceResolvers from "./service.js";
import userResolvers from "./user.js";
import roleResolvers from "./role.js";
import permissionResolvers from "./permission.js";
import fluxFinancierResolvers from "./flux_financier.js";
import factureResolvers from "./facture.js";
import categorieResolvers from "./categorie.js";
import ligneServiceResolvers from "./ligneService.js";

const graphQlResolvers = {
  ...serviceResolvers,
  ...personnelResolvers,
  ...userResolvers,
  ...roleResolvers,
  ...clientResolvers,
  ...personnelResolvers,
  ...permissionResolvers,
  ...fluxFinancierResolvers,
  ...factureResolvers,
  ...categorieResolvers,
  ...ligneServiceResolvers
};

export default graphQlResolvers;
