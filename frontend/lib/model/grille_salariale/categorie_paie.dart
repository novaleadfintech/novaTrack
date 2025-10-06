import 'package:frontend/model/grille_salariale/classe_model.dart';

class CategoriePaieModelModel {
  final String id;
  final String libelle;
  final List<ClasseModel>? classes;

  CategoriePaieModelModel({
    required this.id,
    required this.libelle,
    required this.classes,
  });

  factory CategoriePaieModelModel.fromJson(Map<String, dynamic> json) {
    return CategoriePaieModelModel(
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

  bool equalTo({required CategoriePaieModelModel poste}) {
    return poste.id == id;
  }
}
