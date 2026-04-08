import "package:frontend/model/bulletin_paie/rubrique_on_bulletin_model.dart";

class VariablePaieModel {
  final String salarieKey;
  final List<RubriqueOnBulletinModel> rubriques;
  final List<RubriqueOnBulletinModel>? primesExceptionnelles;

  VariablePaieModel({
    required this.salarieKey,
    required this.rubriques,
    this.primesExceptionnelles,
  });

  Map<String, dynamic> toJson() => {
        "salarieKey": salarieKey,
        "rubriques": rubriques.map((r) => r.toJson()).toList(),
        "primesExceptionnelles": primesExceptionnelles != null
            ? primesExceptionnelles!.map((r) => r.toJson()).toList()
            : [],
      };
}
