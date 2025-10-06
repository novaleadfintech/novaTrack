import 'package:frontend/model/grille_salariale/echelon_model.dart';

class EchelonIndiceModel {
  final EchelonModel echelon;
  int? indice;

  EchelonIndiceModel({
    required this.echelon,
    required this.indice,
  });

  factory EchelonIndiceModel.fromJson(Map<String, dynamic> json) {
    return EchelonIndiceModel(
      echelon: EchelonModel.fromJson(json["echelon"]),
      indice: json["indice"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "echelon": echelon.toJson(),
      "indice": "\"$indice\"",
    };
  }

  void setIndice(int newIndice) {
    indice = newIndice;
  }
}
