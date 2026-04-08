import "categorie_paie.dart";
import "rubrique_on_bulletin_model.dart";

class RubriquepaieCategorieModel {
  final PaieCategorieModel bulletincategorie;
  final List<RubriqueOnBulletinModel> rubriques;

  RubriquepaieCategorieModel({
    required this.bulletincategorie,
    required this.rubriques,
  });

  factory RubriquepaieCategorieModel.fromJson(Map<String, dynamic> json) {
    return RubriquepaieCategorieModel(
      bulletincategorie: PaieCategorieModel.fromJson(json["bulletincategorie"]),
      rubriques: (json["rubriques"] as List)
          .map((e) => RubriqueOnBulletinModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "bulletincategorie": bulletincategorie.toJson(),
      "rubriques": rubriques.map((e) => e.toJson()).toList(),
    };
  }
}


