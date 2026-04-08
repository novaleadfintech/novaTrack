enum TypeRubrique {
  gain("Gain"),
  retenue("Retenue");

  final String label;
  const TypeRubrique(this.label);
}

String typeRubriqueToString(TypeRubrique type) {
  return type.toString().split(".").last;
}

TypeRubrique typeRubriqueFromJson(String type) {
  return TypeRubrique.values
      .firstWhere((e) => e.toString().split(".").last == type);
}
enum PorteeRubrique {
  individuel("Individuel"),
  commun("Catégorie de paie"),
  defaultIndividuel("Individuel avec une valeur par défaut");

  final String label;
  const PorteeRubrique(this.label);

  static String porteeRubriqueToString(PorteeRubrique portee) {
    return portee.toString().split(".").last;
  }

  static PorteeRubrique porteeRubriqueFromJson(String portee) {
    return PorteeRubrique.values
        .firstWhere((e) => e.toString().split(".").last == portee);
  }
}


