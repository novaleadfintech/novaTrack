enum CanauxPaiement {
  caisse('Caisse'),
  operateurMobile('Opérateur mobile'),
  banque("Banque");
  // bitCoins('Bitcoins');

  final String label;
  const CanauxPaiement(this.label);
}

String canauxPaiementToString(CanauxPaiement canauxPaiement) {
  return canauxPaiement.toString().split('.').last;
}

CanauxPaiement canauxPaiementFromString(String canauxPaiement) {
  return CanauxPaiement.values
      .firstWhere((e) => e.toString().split('.').last == canauxPaiement);
}
