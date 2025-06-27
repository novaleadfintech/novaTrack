import '../model/facturation/frais_divers_model.dart';
import '../model/facturation/ligne_model.dart';
import '../model/facturation/reduction_model.dart';
import '../model/flux_financier/flux_financier_model.dart';

double calculerMontantPaye({required List<FluxFinancierModel> payements}) {
  return payements.fold(0, (total, payement) => total + payement.montant);
}

double calculerSimpleMontantTotal({
  required List<LigneModel> lignes,
}) {
  double sommeApresRemise = 0;
  for (var ligneFacture in lignes) {
    sommeApresRemise += ligneFacture.montant;
  }
  return sommeApresRemise;
}

double calculerMontantTotalFraisDivers({
  required List<LigneModel> lignes,
  required double tauxTVA,
}) {
  double total = 0;

  for (var ligneFacture in lignes) {
    if (ligneFacture.fraisDivers!.isNotEmpty) {
      for (var frais in ligneFacture.fraisDivers!) {
        if (frais.tva == true) {
          total += frais.montant * (1 + tauxTVA / 100);
        } else {
          total += frais.montant;
        }
      }
    }
  }
  return total;
}

double calculMontantFraisDivers({
  required FraisDiversModel frais,
  required double tauxTVA,
}) {
  return frais.montant +
      (frais.tva != true ? 0 : frais.montant * tauxTVA / 100);
}

double calculerTva({
  required List<LigneModel> lignes,
  required ReductionModel reduction,
  required bool tva,
  required double tauxTVA,
}) {
  var montant = calculerSimpleMontantTotal(lignes: lignes) -
      calculerReduction(lignes: lignes, reduction: reduction);
  return tva ? montant * (tauxTVA / 100) : 0;
}

double calculerReduction({
  required List<LigneModel> lignes,
  required ReductionModel reduction,
}) {
  return reduction.unite != null
      ? calculerSimpleMontantTotal(lignes: lignes) * reduction.valeur / 100
      : reduction.valeur;
}
