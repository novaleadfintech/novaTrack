import 'package:frontend/model/grille_salariale/echelon_indice_model.dart';
 
class ClasseModel {
  final String id;
  final String libelle;
  final List<EchelonIndiceModel>? echelonIndiciciaires;

  ClasseModel({
    required this.id,
    required this.libelle,
    required this.echelonIndiciciaires,
  });

  factory ClasseModel.fromJson(Map<String, dynamic> json) {
    return ClasseModel(
      id: json['_id'],
      libelle: json['libelle'],
      echelonIndiciciaires: json['echelonIndiciciaires'] != null
          ? List<EchelonIndiceModel>.from(
              json['echelonIndiciciaires']
              .map((e) => EchelonIndiceModel.fromJson(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": "\"$id\"",
      "libelle": "\"$libelle\"",
      "echelonIndiciciaires": echelonIndiciciaires != null
          ? List<dynamic>.from(echelonIndiciciaires!.map((e) => e.toJson()))
          : null,
    };
  }

  bool equalTo({required ClasseModel classe}) {
    return classe.id == id;
  }
}
