enum EtatService {
  archived("Inactif"),
  unarchived("Actif");

  final String label;
  const EtatService(this.label);
}
enum NatureService {
  unique("Unique"),
  multiple("Multiple");

  final String label;
  const NatureService(this.label);
}

enum ServiceType {
  produit("Produit"),
  punctual("Ponctuel"),
  recurrent("Récurrent");

  final String label;
  const ServiceType(this.label);
}

String etatServiceToString(EtatService etat) {
  return etat.toString().split('.').last;
}

EtatService etatServiceFromString(String etat) {
  return EtatService.values
      .firstWhere((e) => e.toString().split('.').last == etat);
}
String natureServiceToString(NatureService etat) {
  return etat.toString().split('.').last;
}

NatureService natureServiceFromString(String etat) {
  return NatureService.values
      .firstWhere((e) => e.toString().split('.').last == etat);
}

String serviceTypeToString(ServiceType type) {
  return type.toString().split('.').last;
}

ServiceType serviceTypeFromString(String type) {
  return ServiceType.values
      .firstWhere((e) => e.toString().split('.').last == type);
}
