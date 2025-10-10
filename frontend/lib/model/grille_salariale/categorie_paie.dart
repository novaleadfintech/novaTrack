import 'package:frontend/model/grille_salariale/classe_model.dart';

class GrilleCategoriePaieModel {
  final String id;
  final String libelle;
  final List<ClasseModel>? classes;

  GrilleCategoriePaieModel({
    required this.id,
    required this.libelle,
    required this.classes,
  });

  factory GrilleCategoriePaieModel.fromJson(Map<String, dynamic> json) {
    return GrilleCategoriePaieModel(
      id: json['_id'],
      libelle: json['libelle'],
      classes: json['classes'] != null
          ? List<ClasseModel>.from(
              json['classes'].map((e) => ClasseModel.fromJson(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": "\"$id\"",
      "libelle": "\"$libelle\"",
      "classes": classes != null
          ? List<dynamic>.from(classes!.map((e) => e.toJson()))
          : null,
    };
  }

  bool equalTo({required GrilleCategoriePaieModel grilleCategoriePaie}) {
    return grilleCategoriePaie.id == id;
  }
}
