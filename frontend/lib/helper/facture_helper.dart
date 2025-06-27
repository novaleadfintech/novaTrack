import '../model/facturation/facture_model.dart';
import 'facture_proforma_helper.dart';

double calculerMontantHT({
  required FactureModel facture,
}) {
  double montantDeservice =
      calculerSimpleMontantTotal(lignes: facture.ligneFactures!);
  double penalite = facture.facturesAcompte.fold(
        0.0,
        (sum, acompte) =>
            sum! +
            (acompte.oldPenalties?.fold(0.0, (s, p) => s! + p.montant) ?? 0.0),
      ) ??
      0.0;
  double frais = calculerMontantTotalFraisDivers(
    lignes: facture.ligneFactures!,
    tauxTVA: facture.client!.pays!.tauxTVA!,
  );
  return montantDeservice + penalite + frais;
}
