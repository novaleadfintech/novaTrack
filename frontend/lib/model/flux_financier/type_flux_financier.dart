enum FluxFinancierType {
  input("Entrée"),
  output("Sortie");

  final String label;
  const FluxFinancierType(this.label);
}

String fluxFinancierTypeToString(FluxFinancierType type) {
  return type.toString().split('.').last;
}

FluxFinancierType fluxFinancierTypeFromString(String type) {
  return FluxFinancierType.values.firstWhere(
    (e) => e.toString().split('.').last == type,
  );
}

enum FluxFinancierStatus {
  wait("En attente"),
  valid("Validé"),
  returne("Renvoyé"),
  reject("Rejeté");
  
  final String label;
  const FluxFinancierStatus(this.label);
}

String fluxFinancierStatusToString(FluxFinancierStatus status) {
  return status.toString().split('.').last;
}

FluxFinancierStatus fluxFinancierStatusFromString(String status) {
  return FluxFinancierStatus.values.firstWhere(
    (e) => e.toString().split('.').last == status,
  );
}
