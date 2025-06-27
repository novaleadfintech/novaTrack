import 'categorie_paie.dart';
import 'rubrique_paie.dart';

class RubriqueCategoriePaieModel {
  final CategoriePaieModel categorie;
  final List<RubriqueOnBulletinModel> rubriques;

  RubriqueCategoriePaieModel({
    required this.categorie,
    required this.rubriques,
  });

  factory RubriqueCategoriePaieModel.fromJson(Map<String, dynamic> json) {
    return RubriqueCategoriePaieModel(
      categorie: CategoriePaieModel.fromJson(json['categorie']),
      rubriques: (json['rubriques'] as List)
          .map((e) => RubriqueOnBulletinModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categorie': categorie.toJson(),
      'rubriques': rubriques.map((e) => e.toJson()).toList(),
    };
  }
}


