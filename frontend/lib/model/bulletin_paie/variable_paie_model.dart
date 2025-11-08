import 'package:frontend/model/bulletin_paie/rubrique_paie.dart';

class VariablePaieModel {
  final String salarieId;
  final List<RubriqueOnBulletinModel> rubriques;
  final List<RubriqueOnBulletinModel>? primesExceptionnelles;

  VariablePaieModel({
    required this.salarieId,
    required this.rubriques,
    this.primesExceptionnelles,
  });

  Map<String, dynamic> toJson() => {
        'salarieId': salarieId,
        'rubriques': rubriques.map((r) => r.toJson()).toList(),
        'primesExceptionnelles': primesExceptionnelles != null
            ? primesExceptionnelles!.map((r) => r.toJson()).toList()
            : [],
      };
}
