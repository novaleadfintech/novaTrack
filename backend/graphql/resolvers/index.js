import clientResolvers from "./client.js";
import personnelResolvers from "./personnel.js";
import serviceResolvers from "./service.js";
import userResolvers from "./user.js";
import roleResolvers from "./role.js";
import permissionResolvers from "./permission.js";
import fluxFinancierResolvers from "./flux_financier.js";
import factureResolvers from "./facture.js";
import categorieResolvers from "./categorie.js";
import ligneFactureResolvers from "./ligneFacture.js";
import ligneProformaResolvers from "./ligneProforma.js";
import entrepriseResolvers from "./entreprise.js";
import creanceResolvers from "./creance.js";
import proformaResolvers from "./proforma.js";
import banqueResolvers from "./banque.js";
import decouverteResolvers from "./decouverte.js";
import bulletinPaieResolvers from "./bulletin.js";
import libelleFluxResolvers from "./libelle_flux.js";
import countryResolvers from "./country.js";
import rubriqueBulletinResolvers from "./rubrique_bulletin.js";
import sectionBulletinResolvers from "./section_bulletin.js";
import categoriePaieResolvers from "./categoriePaie.js";
import moyenPaiementResolvers from "./moyen_paiement.js";
import salaireResolvers from "./salaire.js";
import rubriqueCategorieRubrique from "./rubrique_categorie.js";
import clientFactureGlobalValueResolvers from "./client_facture_global_value.js";

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
  ...ligneFactureResolvers,
  ...ligneProformaResolvers,
  ...entrepriseResolvers,
  ...creanceResolvers,
  ...proformaResolvers,
  ...banqueResolvers,
  ...decouverteResolvers,
  ...bulletinPaieResolvers,
  ...libelleFluxResolvers,
  ...countryResolvers,
  ...rubriqueBulletinResolvers,
  ...sectionBulletinResolvers,
  ...categoriePaieResolvers,
  ...salaireResolvers,
  ...moyenPaiementResolvers,
  ...rubriqueCategorieRubrique,
  ...clientFactureGlobalValueResolvers,
};

export default graphQlResolvers;
