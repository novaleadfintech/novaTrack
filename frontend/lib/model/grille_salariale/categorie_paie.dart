import 'package:frontend/model/grille_salariale/classe_model.dart';

class GrillepaieCategorieModel {
  final String key;
  final String libelle;
  final List<ClasseModel>? classes;

  GrillepaieCategorieModel({
    required this.key,
    required this.libelle,
    required this.classes,
  });

  factory GrillepaieCategorieModel.fromJson(Map<String, dynamic> json) {
    return GrillepaieCategorieModel(
      key: json['_key'],
      libelle: json['libelle'],
      classes: json['classes'] != null
          ? List<ClasseModel>.from(
              json['classes'].map((e) => ClasseModel.fromJson(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_key": "\"$key\"",
      "libelle": "\"$libelle\"",
      "classes": classes != null
          ? List<dynamic>.from(classes!.map((e) => e.toJson()))
          : null,
    };
  }

  bool equalTo({required GrillepaieCategorieModel grillepaieCategorie}) {
    return grillepaieCategorie.key == key;
  }
}
