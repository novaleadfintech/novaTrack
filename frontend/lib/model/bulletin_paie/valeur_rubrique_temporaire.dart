import "package:frontend/model/bulletin_paie/rubrique_on_bulletin_model.dart";

class ValeurRubriqueTemporaire {
  final String? key;
  final String salarieKey;
  final List<RubriqueOnBulletinModel> rubriques;
  final List<RubriqueOnBulletinModel>? primesExceptionnelles;


  ValeurRubriqueTemporaire({
    this.key,
    required this.salarieKey,
    required this.rubriques,
    required this.primesExceptionnelles,
  });

  Map<String, dynamic> toJson() => {
        "key": key,
        "salarieKey": salarieKey,
        "rubriques": rubriques.map((r) => r.toJson()).toList(),
        "primesExceptionnelles":
            primesExceptionnelles?.map((r) => r.toJson()).toList(),
      };

  factory ValeurRubriqueTemporaire.fromJson(Map<String, dynamic> json) {
    return ValeurRubriqueTemporaire(
      key: json["_key"],
      salarieKey: json["salarieKey"],
      rubriques: (json["rubriques"] as List<dynamic>)
          .map((e) => RubriqueOnBulletinModel.fromJson(e))
          .toList(),
      primesExceptionnelles: json["primesExceptionnelles"] != null
          ? (json["primesExceptionnelles"] as List<dynamic>)
              .map((e) => RubriqueOnBulletinModel.fromJson(e))
              .toList()
          : null,
    );
  }
}
