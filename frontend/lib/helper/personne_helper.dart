import '../model/personnel/enum_personnel.dart';

List<TypeContrat> getContratsFor({required TypePersonnel type}) {
  switch (type) {
    case TypePersonnel.stagiaire:
      return [TypeContrat.conventionDeStage];
    case TypePersonnel.consultant:
      return [TypeContrat.prestationDeService, TypeContrat.consultantFreelance];
    case TypePersonnel.employe:
      return [
        TypeContrat.cdi,
        TypeContrat.cdd,
        TypeContrat.alternance,
        TypeContrat.apprentissage
      ];
    case TypePersonnel.interim:
      return [TypeContrat.missionInterim, TypeContrat.cdd];
    case TypePersonnel.freelance:
      return [TypeContrat.contratFreelance, TypeContrat.prestationDeService];
  }
}
