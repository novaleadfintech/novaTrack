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

enum BuyingManner {
  total("Paiement total"),
  partiel("Paiement partiel"),
  credit("À crédit");

  final String label;

  const BuyingManner(this.label);
}

String buyingMannerToString(BuyingManner modePayement) {
  return modePayement.toString().split('.').last;
}

BuyingManner buyingMannerFromString(String modePayement) {
  return BuyingManner.values.firstWhere(
    (e) => e.toString().split('.').last == modePayement,
  );
}

// Statut des dettes
enum DebtStatus {
  pending("En attente"),
  partial("Partiellement payé"),
  paid("Payé");

  final String label;
  const DebtStatus(this.label);
}

String debtStatusToString(DebtStatus debtStatus) {
  return debtStatus.toString().split('.').last;
}

DebtStatus debtStatusFromString(String debtStatus) {
  return DebtStatus.values.firstWhere(
    (e) => e.toString().split('.').last == debtStatus,
  );
}
