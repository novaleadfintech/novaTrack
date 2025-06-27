enum ModuleAlias {
  facturation("FACTURATION"),
  client("CLIENT"),
  service("SERVICE"),
  personnel("PERSONNEL"),
  payement("PAYEMENT"),
  fluxFinancier("FLUX_FINANCIER"),
  creance("CREANCE"),
  config("CONFIG"),
  banque("BANQUE"),
  utilisateur("UTILISATEUR"),
  habilitation("HABILITATION"),
  bulletin("BULLETIN");

  final String label;
  const ModuleAlias(this.label);
}
