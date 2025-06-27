enum NatureRubrique {
  constant("Constant"),
  taux("Taux"),
  calcul("Calculé"),
  sommeRubrique('Somme de rubriques'),
  bareme("Barême");

  final String label;
  const NatureRubrique(this.label);
}

String natureRubriqueToString(NatureRubrique nature) {
  return nature.toString().split('.').last;
}

NatureRubrique natureRubriqueFromJson(String nature) {
  return NatureRubrique.values
      .firstWhere((e) => e.toString().split('.').last == nature);
}
