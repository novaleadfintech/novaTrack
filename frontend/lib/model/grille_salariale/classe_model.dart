import 'package:frontend/model/grille_salariale/echelon_indice_model.dart';
 
class ClasseModel {
  final String id;
  final String libelle;
  final List<EchelonIndiceModel>? echelons;

  ClasseModel({
    required this.id,
    required this.libelle,
    required this.echelons,
  });

  factory ClasseModel.fromJson(Map<String, dynamic> json) {
    return ClasseModel(
      id: json['_id'],
      libelle: json['libelle'],
      echelons: json['echelons'] != null
          ? List<EchelonIndiceModel>.from(
              json['echelons'].map((e) => EchelonIndiceModel.fromJson(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": "\"$id\"",
      "libelle": "\"$libelle\"",
      "echelons": echelons != null
          ? List<dynamic>.from(echelons!.map((e) => e.toJson()))
          : null,
    };
  }

  bool equalTo({required ClasseModel classe}) {
    return classe.id == id;
  }
}
