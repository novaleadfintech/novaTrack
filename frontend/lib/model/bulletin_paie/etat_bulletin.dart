enum EtatBulletin {
wait("En attente"),
  valid("Validé"),
  reject("Rejeté"),
  returne("Renvoyé");

  final String label;
  const EtatBulletin(this.label);
}

String etatBulletinToString(EtatBulletin etat) {
  return etat.toString().split('.').last;
}

EtatBulletin etatBulletinFromJson(String etat) {
  return EtatBulletin.values
      .firstWhere((e) => e.toString().split('.').last == etat);
}
enum DecouverteStatus {
  paid("Soldé"),
  unpaid("À payer"),
  partialpaid("Partiellement payé");

  final String label;
  const DecouverteStatus(this.label);
}

String decourverteStatusToJson(DecouverteStatus status) {
  return status.toString().split('.').last;
}

DecouverteStatus decourverteStatusFromJson(String status) {
  return DecouverteStatus.values
      .firstWhere((e) => e.toString().split('.').last == status);
}
