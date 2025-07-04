// permissions.js
import { shield, rule, and, or } from "graphql-shield";
import PermissionAlias from "./permisson_alias.js";
import Permission from "../../models/habilitation/permission.js";

const PermissionModel = new Permission();
export const hasPermission = (permissionAlias) =>
  rule({ cache: "contextual" })(async (parent, args, ctx) => {
    if (!ctx?.user) {
      return new Error("Vous devez être connecté pour effectuer cette action.");
    }

    const roles = ctx.user?.roles || [];

    // Récupère toutes les permissions de tous les rôles
    const allPermissions = [];

    for (const userRole of roles) {
      console.log("userRole", userRole);
      const permissions = await PermissionModel.getAllPermissionsByRoleForUser({
        roleId: userRole.role._id,
      });
      const aliases = permissions.map((p) => p.alias);
      allPermissions.push(...aliases);
    }

    if (!allPermissions.includes(permissionAlias)) {
      return new Error(
        `Accès refusé : vous n'avez pas la permission requise pour effectuer cette action`
      );
    }

    return true;
  });

const isAuthenticated = rule()(async (parent, args, context, info) => {
  if (!context.user) return false;
  return true;
});

const isSelf = rule({ cache: "contextual" })(
  async (parent, args, context, info) => {
    const currentUserId = context?.user?._id;

    const targetUserId = args?.userId || args?.id || args?.key;

    if (!currentUserId) {
      return new Error("Vous devez être connecté pour effectuer cette action.");
    }

    if (currentUserId !== targetUserId) {
      return new Error(
        "Accès refusé : vous ne pouvez voir que vos propres données."
      );
    }

    return true;
  }
);

const permissions = shield(
  {
    // Queries
    Query: {
      // protection pour les requete de service
      services: hasPermission(PermissionAlias.readService),
      service: hasPermission(PermissionAlias.readService),
      // protection pour les requete de libelle financier
      libelleFlux: hasPermission(PermissionAlias.readLibelleFluxFinancier),
      // protection pour les requete des utilisateurs
      users: hasPermission(PermissionAlias.readUser),
      user: or(hasPermission(PermissionAlias.readUser), isSelf),
      // protection pour les requete de banque
      banques: hasPermission(PermissionAlias.readBanque),
      banque: hasPermission(PermissionAlias.readBanque),
      // protection pour les requete de catégorie
      categories: isAuthenticated,
      categorie: isAuthenticated,
      //protection pour les requete de client
      clients: hasPermission(PermissionAlias.readClient),
      client: hasPermission(PermissionAlias.readClient),
      //protection pour les requete de pays
      allCountries: hasPermission(PermissionAlias.readPays),

      country: hasPermission(PermissionAlias.readPays),
      //protection pour les requete de flux financier
      unpaidCreances: hasPermission(PermissionAlias.readCreance),
      creancesTobePay: hasPermission(PermissionAlias.readCreance),
      getDailyClaim: isAuthenticated,
      //protection pour les requete de l'entreprise
      entreprise: or(
        hasPermission(PermissionAlias.manageEntreprise),
        hasPermission(PermissionAlias.readEntreprise)
      ),
      //protection pour les requete de facture
      paidFactures: hasPermission(PermissionAlias.readFacture),
      unpaidFacture: hasPermission(PermissionAlias.readFacture),
      newRecurrentFacture: hasPermission(PermissionAlias.readFacture),
      facture: hasPermission(PermissionAlias.readFacture),
      factureByClient: hasPermission(PermissionAlias.readFacture),
      recurrentFactureByClient: hasPermission(PermissionAlias.readFacture),
      ligneFactureByFacture: hasPermission(PermissionAlias.readFacture),
      payementFacture: or(
        hasPermission(PermissionAlias.readFacture),
        hasPermission(PermissionAlias.createFluxFinancier)
      ),
      //protection pour les fluxfinancier
      fluxFinanciers: hasPermission(PermissionAlias.readFluxFinancier),
      archiveFluxFinanciers: hasPermission(PermissionAlias.readFluxFinancier),
      fluxFinancier: hasPermission(PermissionAlias.readFluxFinancier),
      unValidatedFluxFinanciers: or(
        hasPermission(PermissionAlias.readFluxFinancier),
        hasPermission(PermissionAlias.validFluxFinancier)
      ),
      fluxFinanciersByBank: hasPermission(
        PermissionAlias.exportBanqueTransaction
      ),
      fluxFiancierbyFacture: hasPermission(PermissionAlias.readFluxFinancier),
      yearBilan: isAuthenticated,
      bilan: hasPermission(PermissionAlias.readFinalSituation),
      yearBilan: hasPermission(PermissionAlias.readFinalSituation),
      libelleFlux: hasPermission(PermissionAlias.readLibelleFluxFinancier),
      //protection pour les proformas
      ligneProformaByProforma: hasPermission(PermissionAlias.readProforma),
      proformas: hasPermission(PermissionAlias.readProforma),
      archivedProformas: hasPermission(PermissionAlias.readProforma),
      // proforma: hasPermission(PermissionAlias.readProforma),
      proformaByClient: hasPermission(PermissionAlias.readProforma),

      //Protection pour les permission
      permissions: hasPermission(PermissionAlias.assignPermissionRole),
      permission: hasPermission(PermissionAlias.assignPermissionRole),
      permissionByRole: hasPermission(PermissionAlias.assignPermissionRole),
      //Protection pour le personnel
      personnels: hasPermission(PermissionAlias.readPersonnel),
      personnel: hasPermission(PermissionAlias.readPersonnel),
      //Protection pour roles
      roles: hasPermission(PermissionAlias.assignPermissionRole),
      role: hasPermission(PermissionAlias.assignPermissionRole),
      // bulletins
      currentBulletinsPaie: hasPermission(PermissionAlias.readBulletin),
      archiveBulletinsPaie: hasPermission(PermissionAlias.readBulletin),
      bulletinPaie: hasPermission(PermissionAlias.readBulletin),
      // Categorie de paie
      categoriesPaie: hasPermission(PermissionAlias.readCategoriePaie),
      categoriePaie: hasPermission(PermissionAlias.readCategoriePaie),
      // Categorie de paie
      categories: hasPermission(PermissionAlias.readCategorieClient),
      categorie: hasPermission(PermissionAlias.readCategorieClient),
      // Moyen de paiement
      moyensPaiement: hasPermission(PermissionAlias.readMoyenPaiement),
      moyenPaiement: hasPermission(PermissionAlias.readMoyenPaiement),
      // Section de buletin
      sectionsBulletin: hasPermission(PermissionAlias.readBulletinSection),
      sectionBulletin: hasPermission(PermissionAlias.readBulletinSection),
      // rubrique de buletin
      rubriqueBulletin: hasPermission(PermissionAlias.readBulletinRubrique),
      rubriquesBulletin: hasPermission(PermissionAlias.readBulletinRubrique),

      // salarié
      salaries: hasPermission(PermissionAlias.readSalarie),
      salarie: hasPermission(PermissionAlias.readSalarie),

      // Avance sur salaire
      decouvertes: hasPermission(PermissionAlias.readAvance),
      decouverte: hasPermission(PermissionAlias.readAvance),
    },

    // Mutations
    Mutation: {
      createLibelleFlux: hasPermission(
        PermissionAlias.createLibelleFluxFinancier
      ),
      updateLibelleFlux: hasPermission(
        PermissionAlias.updateLibelleFluxFinancier
      ),
      deleteLibelleFlux: hasPermission(
        PermissionAlias.deleteLibelleFluxFinancier
      ),
      createService: hasPermission(PermissionAlias.createService),
      updateService: hasPermission(PermissionAlias.updateService),
      archivedService: hasPermission(PermissionAlias.archiveService),
      unarchivedService: hasPermission(PermissionAlias.archiveService),

      //Mutation de user
      attribuerRolePersonnel: hasPermission(
        PermissionAlias.assignRolePersonnel
      ),
      handleRoleEditing: hasPermission(PermissionAlias.handleRoleEditing),
      attribuerRoleUser: hasPermission(PermissionAlias.assignRolePersonnel),
      retirerRoleUser: hasPermission(PermissionAlias.assignRolePersonnel),
      updateLoginData: isSelf,
      resetLoginParameter: hasPermission(PermissionAlias.resetLoginPassword),
      access: hasPermission(PermissionAlias.autoriseAccess),
      seConnecter: true,
      seDeconnecter: isSelf,
      // Mutation de banque
      createBanque: hasPermission(PermissionAlias.createBanque),
      updateBanque: hasPermission(PermissionAlias.updateBanque),
      //Mutation de catégorie
      createCategorie: isAuthenticated,
      updateCategorie: isAuthenticated,
      // deleteCategorie: isAuthenticated,
      //Mutation de client
      createClientMoral: hasPermission(PermissionAlias.createClient),
      createClientPhysique: hasPermission(PermissionAlias.createClient),
      updateClientMoral: hasPermission(PermissionAlias.updateClient),
      updateClientPhysique: hasPermission(PermissionAlias.updateClient),
      archivedClient: hasPermission(PermissionAlias.archiveClient),
      unarchivedClient: hasPermission(PermissionAlias.archiveClient),
      // Mutation de pays
      createCountry: hasPermission(PermissionAlias.createPays),
      updateCountry: hasPermission(PermissionAlias.updatePays),
      //deleteCountry: hasPermission(PermissionAlias.updatePays),
      // Mutation de l'entreprise
      createEntreprise: hasPermission(PermissionAlias.manageEntreprise),
      updateEntreprise: hasPermission(PermissionAlias.manageEntreprise),
      //Mutation de facture
      createFacture: hasPermission(PermissionAlias.createFacture),
      updateFacture: hasPermission(PermissionAlias.updateFacture),
      updateLigneFacture: hasPermission(PermissionAlias.updateFacture),
      deleteLigneFacture: hasPermission(PermissionAlias.updateFacture),
      // deleteAllByFacture: hasPermission(PermissionAlias.updateFacture),
      updateFactureAccompte: or(
        hasPermission(PermissionAlias.updateFactureAfterSend),
        hasPermission(PermissionAlias.exonorerFacturePenalty)
      ),
      deleteFacture: hasPermission(PermissionAlias.deleteFacture),
      stopperService: hasPermission(PermissionAlias.stopperService),
      ajouterLigneFacture: hasPermission(PermissionAlias.updateFacture),
      //Mutation de flux financier
      ajouterPayement: hasPermission(PermissionAlias.createFluxFinancier),
      createFluxFinancier: hasPermission(PermissionAlias.createFluxFinancier),
      updateFluxFinancier: hasPermission(PermissionAlias.createFluxFinancier),
      deleteFluxFinancier: hasPermission(PermissionAlias.createFluxFinancier),
      validFluxFinancier: hasPermission(PermissionAlias.validFluxFinancier),
      // Mutation de libelle financier
      createLibelleFlux: hasPermission(
        PermissionAlias.createLibelleFluxFinancier
      ),
      updateLibelleFlux: hasPermission(
        PermissionAlias.updateLibelleFluxFinancier
      ),
      deleteLibelleFlux: hasPermission(
        PermissionAlias.deleteLibelleFluxFinancier
      ),
      // Mutation de proforma
      updateLigneProforma: hasPermission(PermissionAlias.updateProforma),
      deleteLigneProforma: hasPermission(PermissionAlias.updateProforma),
      deleteLigneProforma: hasPermission(PermissionAlias.updateProforma),
      updateProforma: hasPermission(PermissionAlias.updateProforma),
      ajouterLigneProforma: hasPermission(PermissionAlias.updateProforma),
      createProforma: hasPermission(PermissionAlias.createProforma),
      validerProforma: hasPermission(PermissionAlias.validProforma),
      deleteProforma: hasPermission(PermissionAlias.deleteProforma),
      // deleteAllByProforma: hasPermission(PermissionAlias.updateProforma)
      //Mutation pour les permissions
      createPermission: hasPermission(PermissionAlias.assignPermissionRole),
      updatePermission: hasPermission(PermissionAlias.assignPermissionRole),
      deletePermission: hasPermission(PermissionAlias.assignPermissionRole),
      //Mutation pour le personnel
      createPersonnel: hasPermission(PermissionAlias.createPersonnel),
      updatePersonnel: hasPermission(PermissionAlias.updatePersonnel),
      archivedPersonnel: hasPermission(PermissionAlias.archivePersonnel),
      unarchivedPersonnel: hasPermission(PermissionAlias.archivePersonnel),
      //Mutation pour roles
      createRole: hasPermission(PermissionAlias.createRole),
      deleteRole: hasPermission(PermissionAlias.createRole),
      updateRole: hasPermission(PermissionAlias.createRole),
      retirerPermissionRole: hasPermission(
        PermissionAlias.assignPermissionRole
      ),
      attribuerPermissionRole: hasPermission(
        PermissionAlias.assignPermissionRole
      ),
      roleByUser: or(
        hasPermission(PermissionAlias.assignRolePersonnel),
        hasPermission(PermissionAlias.assignPermissionRole)
      ),

      // Mutation de bulletin
      createBulletinPaie: hasPermission(PermissionAlias.createBulletin),
      updateBulletinPaie: hasPermission(PermissionAlias.updateBulletin),
      validerBulletin: hasPermission(PermissionAlias.validBulletin),
      // Mutation de categorie de paie
      createCategoriePaie: hasPermission(PermissionAlias.createCategoriePaie),
      updateCategoriePaie: hasPermission(PermissionAlias.updateCategoriePaie),
      deleteCategoriePaie: hasPermission(PermissionAlias.deleteCategoriePaie),
      // Mutation de categorie de client
      createCategorie: hasPermission(PermissionAlias.createCategorieClient),
      updateCategorie: hasPermission(PermissionAlias.updateCategorieClient),
      deleteCateforie: hasPermission(PermissionAlias.deleteCategorieClient),
      // Mutation de categorie de client
      createMoyenPaiement: hasPermission(PermissionAlias.createMoyenPaiement),
      updateMoyenPaiement: hasPermission(PermissionAlias.updateMoyenPaiement),
      deleteMoyenPaiement: hasPermission(PermissionAlias.deleteMoyenPaiement),
      // Mutation de section de bulletin
      createSectionBulletin: hasPermission(
        PermissionAlias.createBulletinSection
      ),
      updateSectionBulletin: hasPermission(
        PermissionAlias.updateBulletinSection
      ),
      deleteSectionBulletin: hasPermission(
        PermissionAlias.deleteBulletinSection
      ),
      //Rubrique
      createRubriqueBulletin: hasPermission(
        PermissionAlias.createBulletinRubrique
      ),
      updateRubriqueBulletin: hasPermission(
        PermissionAlias.updateBulletinRubrique
      ),
      // salarie
      createSalarie: hasPermission(PermissionAlias.createSalarie),
      updateSalarie: hasPermission(PermissionAlias.updateSalarie),
      // Avance sur salaire
      createDecouverte: hasPermission(PermissionAlias.createAvance),
      updateDecouverte: hasPermission(PermissionAlias.updateAvance),
    },
  },
  {
    debug: true,
    allowExternalErrors: true,
  }
);

export default permissions;
