import { buildSchema } from "graphql";
import serviceSchema from "./service_schema.js";
import personnelSchema from "./personnel_schema.js";
import userSchema from "./user_schema.js";
import roleSchema from "./role_schema.js";
import permissionSchema from "./permission_schema.js";
import paysSchema from "./country_schema.js";
import clientSchema from "./client_schema.js";
import commonEnumType from "./common_type.js";
import comment from "./comment_schema.js";
import fluxFinancierShema from "./flux_financier_schema.js";
import factureSchema from "./facture_schema.js";
import categorieSchema from "./categorie_schema.js";
import ligneFactureSchema from "./ligne_facture_schema.js";
import ligneProformaSchema from "./ligne_proforma_schema.js";
import fraisDiversSchema from "./frais_divers_schema.js";
import creanceSchema from "./creance_schema.js";
import entrepriseSchema from "./entreprise_schema.js";
import proformaSchema from "./proforma_schema.js";
import banqueSchema from "./banque_schema.js";
import decouverteSchema from "./decouvert_schema.js";
import bulletinPaieSchema from "./bulletin_schema.js";
import libelleFluxSchema from "./libelle_flux.js";
import facturesAcompteSchema from "./facture_accompte.js";
import reductionSchema from "./reduction_schema.js";
import moduleSchema from "./module_schema.js";
import rubriqueSchema from "./rubrique_bulletin_schema.js";
import sectionSchema from "./section_bulletin_schema.js";
import trancheSchema from "./param_tranche_bulletin_schema.js";
import categoriePaieSchema from "./categorie_paie_schema.js";
import salaireSchema from "./salarie_schema.js";
import moyenPaiementSchema from "./moyen_paiement_schema.js";
import rubriqueCategorieSchema from "./rubrique_categorie_schema.js";
import clientFactureGlobalValueSchema from "./client_facture_global_value_schema.js";
import posteSchema from "./poste_schema.js";
import debtSchema from "./debt_schema.js";  
import classeSchema from "./classe_schema.js";
import echelonSchema from "./echelon_schema.js";
import grilleSalarialeSchema from "./grille_salariale_schema.js";
import payCalendarSchema from "./pay_calender_schema.js";

const types = [];
const queries = [];
const mutations = [];

const schemas = [
  serviceSchema,
  personnelSchema,
  userSchema,
  roleSchema,
  permissionSchema,
  paysSchema,
  clientSchema,
  commonEnumType,
  comment,
  fluxFinancierShema,
  factureSchema,
  categorieSchema,
  ligneFactureSchema,
  ligneProformaSchema,
  fraisDiversSchema,
  creanceSchema,
  entrepriseSchema,
  proformaSchema,
  banqueSchema,
  decouverteSchema,
  bulletinPaieSchema,
  reductionSchema,
  facturesAcompteSchema,
  libelleFluxSchema,
  moduleSchema,
  rubriqueSchema,
  sectionSchema,
  trancheSchema,
  categoriePaieSchema,
  salaireSchema,
  moyenPaiementSchema,
  rubriqueCategorieSchema,
  clientFactureGlobalValueSchema,
  posteSchema,
  debtSchema,
  classeSchema,
  echelonSchema,
  grilleSalarialeSchema,
  payCalendarSchema,
];

schemas.forEach((schema) => {
  types.push(schema.typeDef);
  queries.push(schema.query);
  mutations.push(schema.mutation);
});

const typeDefs = `
  ${types.join("\n")}

  type Query {
    ${queries.join("\n")}
  }

  type Mutation {
    ${mutations.join("\n")}
  }
`;

const graphQlSchema = buildSchema(typeDefs);

export default graphQlSchema;
