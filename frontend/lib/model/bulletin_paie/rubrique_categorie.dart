import 'categorie_paie.dart';
import 'rubrique_paie.dart';

class RubriquepaieCategorieModel {
  final paieCategorieModel bulletincategorie;
  final List<RubriqueOnBulletinModel> rubriques;

  RubriquepaieCategorieModel({
    required this.bulletincategorie,
    required this.rubriques,
  });

  factory RubriquepaieCategorieModel.fromJson(Map<String, dynamic> json) {
    return RubriquepaieCategorieModel(
      bulletincategorie: paieCategorieModel.fromJson(json['bulletincategorie']),
      rubriques: (json['rubriques'] as List)
          .map((e) => RubriqueOnBulletinModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bulletincategorie': bulletincategorie.toJson(),
      'rubriques': rubriques.map((e) => e.toJson()).toList(),
    };
  }
}


