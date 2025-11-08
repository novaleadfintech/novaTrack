import 'package:frontend/model/bulletin_paie/rubrique_paie.dart';

class ValeurRubriqueTemporaire {
  final String? id;
  final String salarieId;
  final List<RubriqueOnBulletinModel> rubriques;
  final List<RubriqueOnBulletinModel>? primesExceptionnelles;


  ValeurRubriqueTemporaire({
    this.id,
    required this.salarieId,
    required this.rubriques,
    required this.primesExceptionnelles,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'salarieId': salarieId,
        'rubriques': rubriques.map((r) => r.toJson()).toList(),
        'primesExceptionnelles':
            primesExceptionnelles?.map((r) => r.toJson()).toList(),
      };

  factory ValeurRubriqueTemporaire.fromJson(Map<String, dynamic> json) {
    return ValeurRubriqueTemporaire(
      id: json['_id'],
      salarieId: json['salarieId'],
      rubriques: (json['rubriques'] as List<dynamic>)
          .map((e) => RubriqueOnBulletinModel.fromJson(e))
          .toList(),
      primesExceptionnelles: json['primesExceptionnelles'] != null
          ? (json['primesExceptionnelles'] as List<dynamic>)
              .map((e) => RubriqueOnBulletinModel.fromJson(e))
              .toList()
          : null,
    );
  }
}
