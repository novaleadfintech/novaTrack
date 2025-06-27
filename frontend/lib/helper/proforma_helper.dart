import '../model/facturation/proforma_model.dart';
import 'facture_proforma_helper.dart';


double calculerMontantHT({
  required ProformaModel proforma,
}) {
  double montantDeservice =
      calculerSimpleMontantTotal(lignes: proforma.ligneProformas!);

  double frais = calculerMontantTotalFraisDivers(
    lignes: proforma.ligneProformas!,
    tauxTVA: proforma.client!.pays!.tauxTVA!,
  );
  return montantDeservice + frais;
}
