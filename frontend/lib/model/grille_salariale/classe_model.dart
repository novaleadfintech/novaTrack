import 'package:frontend/model/grille_salariale/echelon_indice_model.dart';
 
class ClasseModel {
  final String id;
  final String libelle;
  final List<EchelonIndiceModel>? echelonIndiciaires;

  ClasseModel({
    required this.id,
    required this.libelle,
    required this.echelonIndiciaires,
  });

  factory ClasseModel.fromJson(Map<String, dynamic> json) {
    return ClasseModel(
      id: json['_id'],
      libelle: json['libelle'],
      echelonIndiciaires: json['echelonIndiciaires'] != null
          ? List<EchelonIndiceModel>.from(
              json['echelonIndiciaires']
              .map((e) => EchelonIndiceModel.fromJson(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": "\"$id\"",
      "libelle": "\"$libelle\"",
      "echelonIndiciaires": echelonIndiciaires != null
          ? List<dynamic>.from(echelonIndiciaires!.map((e) => e.toJson()))
          : null,
    };
  }

  bool equalTo({required ClasseModel classe}) {
    return classe.id == id;
  }
}
