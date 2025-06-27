import '../dto/facturation/frais_divers_dto.dart';
import '../model/facturation/frais_divers_model.dart';

List<FraisDiversModel> convertFraisDiversList(
    List<Map<String, dynamic>> fraisList) {
  try {
    return fraisList.map((frais) {
      if (frais["libelle"]?.text == null || frais["libelle"].text.isEmpty) {
        throw "Le libellé d'un des frais divers est vide ou invalide.";
      }
      if (frais["montant"]?.text == null ||
          double.tryParse(frais["montant"].text) == null) {
        throw "Le montant d'un des frais divers est  invalide.";
      }
      if (frais["tva"] == null) {
        throw "La TVA d'un des frais divers est manquante.";
      }

      return FraisDiversModel(
        libelle: frais["libelle"].text,
        montant: double.parse(frais["montant"].text),
        tva: frais["tva"],
      );
    }).toList();
  } catch (e) {
    rethrow;
  }
}

List<FraisDiversDto> convertFraisDiversDtoList(
    List<Map<String, dynamic>> fraisList) {
  try {
    return fraisList.map((frais) {
      if (frais["libelle"]?.text == null || frais["libelle"].text.isEmpty) {
        throw "Le libellé d'un des frais divers est vide ou invalide.";
      }
      if (frais["montant"]?.text == null ||
          double.tryParse(frais["montant"].text) == null) {
        throw "Le montant d'un des frais divers est  invalide.";
      }
      if (frais["tva"] == null) {
        throw "La TVA d'un des frais divers est manquante.";
      }
      return FraisDiversDto(
        libelle: frais["libelle"].text,
        montant: double.parse(frais["montant"].text),
        tva: frais["tva"],
      );
    }).toList();
  } catch (e) {
    rethrow;
  }
}
