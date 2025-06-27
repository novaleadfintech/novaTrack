enum TypeClient {
  moral("Moral"),
  physique("Physique");

  final String label;
  const TypeClient(this.label);
}

enum EtatClient {
  archived("Inactif"),
  unarchived("Actif");

  final String label;
  const EtatClient(this.label);
}

enum NatureClient {
  prospect("Prospect"),
  client("Client"),
  fournisseur("Fournisseur");

  final String label;
  const NatureClient(this.label);
}


String etatClientToString(EtatClient etat) {
  return etat.toString().split('.').last;
}

EtatClient etatClientFromString(String etat) {
  return EtatClient.values
      .firstWhere((e) => e.toString().split('.').last == etat);
}

String natureClientToString(NatureClient nature) {
  return nature.toString().split('.').last;
}

NatureClient natureClientFromString(String nature) {
  return NatureClient.values
      .firstWhere((e) => e.toString().split('.').last == nature);
}


String typeClientToString(TypeClient type) {
  return type.toString().split('.').last;
}

TypeClient typeClientFromString(String type) {
  return TypeClient.values
      .firstWhere((e) => e.toString().split('.').last == type);
}
