
enum TypeContrat {
  cdi("CDI"),
  cdd("CDD"),
  alternance("Contrat d'alternance"),
  apprentissage("Contrat d'apprentissage"),
  missionInterim("Mission intérim"),
  conventionDeStage("Convention de stage"),
  prestationDeService("Prestation de service"),
  consultantFreelance("Consultant freelance"),
  contratFreelance("Contrat freelance");

  final String label;
  const TypeContrat(this.label);
}


enum TypePersonnel {
  stagiaire("Stagiaire"),
  consultant("Consultant"),
  employe("Employé"),
  interim("Intérimaire"),
  freelance("Freelance");

  final String label;
  const TypePersonnel(this.label);
}


String typePersonnelToString(TypePersonnel typePersonnel) {
  return typePersonnel.toString().split('.').last;
}

TypePersonnel typePersonnelFromString(String typePersonnel) {
  return TypePersonnel.values
      .firstWhere((e) => e.toString().split('.').last == typePersonnel);
}

String typeContratlToString(TypeContrat typeContrat) {
  return typeContrat.toString().split('.').last;
}

TypeContrat typeContratFromString(String typeContrat) {
  return TypeContrat.values
      .firstWhere((e) => e.toString().split('.').last == typeContrat);
}


enum EtatPersonnel {
  archived("Inactif"),
  unarchived("Actif");

  final String label;
  const EtatPersonnel(this.label);
}

String etatPersonnelToString(EtatPersonnel etat) {
  return etat.toString().split('.').last;
}

EtatPersonnel etatPersonnelFromString(String etat) {
  return EtatPersonnel.values
      .firstWhere((e) => e.toString().split('.').last == etat);
}
