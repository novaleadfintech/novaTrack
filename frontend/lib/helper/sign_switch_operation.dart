import '../model/bulletin_paie/tranche_model.dart';

String getOperateurSymbol(Operateur operateur) {
  switch (operateur) {
    case Operateur.addition:
      return "+";
    case Operateur.soustraction:
      return "-";
    case Operateur.multiplication:
      return "*";
    case Operateur.division:
      return "/";
    default:
      return "";
  }
}
