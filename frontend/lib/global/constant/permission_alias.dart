enum PermissionAlias {
  createFacture("CREATE_FACTURE"),
  updateFacture("EDIT_FACTURE"),
  deleteFacture("DELETE_FACTURE"),
  readFacture("READ_FACTURE"),
  canSetFactureGlobalValues("CAN_SET_FACTURE_GLOBAL_VALUES"),
  createProforma("CREATE_PROFORMA"),
  stopFactureGeneration("STOP_FACTURE_REGENERATION"),
  exonorerFacturePenalty("EXONORATE_FACTURE_PENALTY"),
  updateProforma("EDIT_PROFORMA"),
  deleteProforma("DELETE_PROFORMA"),
  cancelProformat("CANCEL_PROFORMA"),
  updateFactureAfterSend("EDIT_FACTURE_AFTER_SEND"),
  readProforma("READ_PROFORMA"),
  validProforma("VALID_PROFORMA"),
  validFluxFinancier("VALID_FLUX_FINANCIER"),
  readFinalSituation("READ_FINANCIAL_SITUATION"),
  createClient("CREATE_CLIENT"),
  updateClient("EDIT_CLIENT"),
  archiveClient("ARCHIVER_CLIENT"),
  readClient("READ_CLIENT"),
  createService("CREATE_SERVICE"),
  updateService("EDIT_SERVICE"),
  archiveService("ARCHIVER_SERVICE"),
  readService("READ_SERVICE"),
  createPersonnel("CREATE_PERSONNEL"),
  updatePersonnel("EDIT_PERSONNEL"),
  archivePersonnel("ARCHIVER_PERSONNEL"),
  readPersonnel("READ_PERSONNEL"),
  createFluxFinancier("CREATE_FLUX_FINANCIER"),
  deleteFluxFinancier("DELETE_FLUX_FINANCIER"),
  updateFluxFinancier("EDIT_FLUX_FINANCIER"),
  readFluxFinancier("READ_FLUX_FINANCIER"),
  readLibelleFluxFinancier("READ_LIBELLE_FINANCIER"),
  readCreance("READ_CREANCE"),
  createLibelleFluxFinancier("CREATE_LIBELLE_FINANCIER"),
  updateLibelleFluxFinancier("EDIT_LIBELLE_FINANCIER"),
  deleteLibelleFluxFinancier("DELETE_LIBELLE_FINANCIER"),
  createBanque("CREATE_BANQUE"),
  updateBanque("EDIT_BANQUE"),
  readBanque("READ_BANQUE"),
  exportBanqueTransaction("EXPORT_BANQUE_TRANSACTION"),
  //banque
  createPays("CREATE_PAYS"),
  updatePays("EDIT_PAYS"),
  readPays("READ_PAYS"),
  //user
  resetLoginPassword("RESET_LOGIN_PASSWORD"),
  autoriseAccess("AUTORISE_ACCESS"),
  assignRolePersonnel("ASSIGN_ROLE_PERSONNEL"),
  assignPermissionRole("ASSIGN_PERMISSION_ROLE"),
  handelRoleAutorization("HANDLE_ROLE_EDITING"),
  readUser("READ_USER"),
  createRole("CREATE_PROFIL"),
  updateRole("EDIT_PROFIL"),
  readRole("READ_PROFIL"),
  manageEntreprise("MANAGE_ENTREPRISE_DATA"),
  readEntreprise("READ_ENTREPRISE_DATA"),

  // Bulletin
  readBulletin("READ_BULLETIN"),
  createBulletin("CREATE_BULLETIN"),
  updateBulletin("EDIT_BULLETIN"),
  deleteBulletin("DELETE_BULLETIN"),
  validBulletin("VALID_BULLETIN"),

// Salarié
  createSalarie("CREATE_SALARIE"),
  updateSalarie("EDIT_SALARIE"),
  readSalarie("READ_SALARIE"),

// Avance
  createAvance("CREATE_AVANCE"),
  updateAvance("EDIT_AVANCE"),
  readAvance("READ_AVANCE"),

// Catégorie Paie
  createCategoriePaie("CREATE_CATEGORIE_PAIE"),
  updateCategoriePaie("EDIT_CATEGORIE_PAIE"),
  readCategoriePaie("READ_CATEGORIE_PAIE"),
  deleteCategoriePaie("DELETE_CATEGORIE_PAIE"),

// Moyen de Paiement
  createMoyenPaiement("CREATE_MOYEN_PAIEMENT"),
  updateMoyenPaiement("EDIT_MOYEN_PAIEMENT"),
  readMoyenPaiement("READ_MOYEN_PAIEMENT"),
  deleteMoyenPaiement("DELETE_MOYEN_PAIEMENT"),

// Catégorie Client
  createCategorieClient("CREATE_CATEGORIE_CLIENT"),
  updateCategorieClient("EDIT_CATEGORIE_CLIENT"),
  readCategorieClient("READ_CATEGORIE_CLIENT"),
  deleteCategorieClient("DELETE_CATEGORIE_CLIENT"),

// Section Bulletin
  createBulletinSection("CREATE_BULLETIN_SECTION"),
  updateBulletinSection("EDIT_BULLETIN_SECTION"),
  readBulletinSection("READ_BULLETIN_SECTION"),
  deleteBulletinSection("DELETE_BULLETIN_SECTION"),

// Rubrique Bulletin
  createBulletinRubrique("CREATE_BULLETIN_RUBRIQUE"),
  updateBulletinRubrique("EDIT_BULLETIN_RUBRIQUE"),
readBulletinRubrique("READ_BULLETIN_RUBRIQUE"),
  createPoste("CREATE_POSTE"),
  updatePoste("EDIT_POSTE"),
  readPoste("READ_POSTE"),

// Assignation
  assignRubriqueCategoriePaie("ASSIGN_RUBRIQUE_TO_CATEGORIE");
//Poste
  final String label;
  const PermissionAlias(this.label);
}
