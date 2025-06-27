enum StatusFacture {
  paid("Soldé"),
  tobepaid("À payer"),
  unpaid("Impayé"),
  blocked("Bloqué"),
  partialpaid("Partiellement payé");

  final String label;

  const StatusFacture(this.label);
}

enum StatusProforma {
  wait("En attente"),
  validated("Validé"),
  cancel("Annulé"),
  archived("Archivé");

  final String label;

  const StatusProforma(this.label);
}

String statusProformaToString(StatusProforma status) {
  return status.toString().split('.').last;
}

StatusProforma statusProformaFromString(String status) {
  return StatusProforma.values
      .firstWhere((e) => e.toString().split('.').last == status);
}

String statusFactureToString(StatusFacture status) {
  return status.toString().split('.').last;
}

StatusFacture statusFactureFromString(String status) {
  return StatusFacture.values
      .firstWhere((e) => e.toString().split('.').last == status);
}

enum TypeFacture {
  recurrent("Récurente"),
  punctual("Ponctuelle");

  final String label;
  const TypeFacture(this.label);
}

String typeFactureToString(TypeFacture type) {
  return type.toString().split('.').last;
}

TypeFacture typeFactureFromString(String type) {
  return TypeFacture.values
      .firstWhere((e) => e.toString().split('.').last == type);
}

enum EtatFacture {
  proformat("Proforma"),
  facture("Factures");

  final String label;
  const EtatFacture(this.label);
}

String etatFactureToString(EtatFacture etat) {
  return etat.toString().split('.').last;
}

EtatFacture etatFactureFromString(String etat) {
  return EtatFacture.values.firstWhere(
    (e) => e.toString().split('.').last == etat,
  );
}
