import '''
package:frontend/model/bulletin_paie/rubrique.dart''';

class RubriqueOnBulletinModel {
  final RubriqueBulletin rubrique;
  double? value;

  RubriqueOnBulletinModel({
    required this.rubrique,
    this.value,
  });

  factory RubriqueOnBulletinModel.fromJson(Map<String, dynamic> json) {
    
    return RubriqueOnBulletinModel(
      rubrique: RubriqueBulletin.fromJson(json['rubrique']),
      value: json['value'] == null ? null : (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rubriqueId': "\"${rubrique.id}\"",
      'value': value,
    };
  }
}

class RubriquePaieConfig {
  final RubriqueOnBulletinModel rubriquePaie;
  bool isChecked;

  RubriquePaieConfig({
    required this.rubriquePaie,
    required this.isChecked,
  });

  factory RubriquePaieConfig.fromJson(Map<String, dynamic> json) {
    return RubriquePaieConfig(
      rubriquePaie: RubriqueOnBulletinModel.fromJson(json['rubriqueCategorie']),
      isChecked: json['isChecked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rubriqueCategorie': rubriquePaie.toJson(),
      'isCheck': isChecked,
    };
  }
}
