import 'package:frontend/model/bulletin_paie/rubrique_paie.dart';

class ValeurRubriqueTemporaire {
  final int? id;
  final int salarieId;
  final List<RubriqueOnBulletinModel> rubriques;

  ValeurRubriqueTemporaire({
    this.id,
    required this.salarieId,
    required this.rubriques,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'salarieId': salarieId,
      };

  factory ValeurRubriqueTemporaire.fromJson(Map<String, dynamic> json) {
    return ValeurRubriqueTemporaire(
      id: json['id'],
      salarieId: json['salarieId'],
      rubriques: (json['rubriques'] as List<dynamic>)
          .map((e) => RubriqueOnBulletinModel.fromJson(e))
          .toList(),
    );
  }
}
