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
      'rubriqueKey': "\"${rubrique.key}\"",
      'value': value,
    };
  }
}

class RubriquePaieConfig {
  final RubriqueOnBulletinModel rubriqueOnBulletin;
  bool isChecked;

  RubriquePaieConfig({
    required this.rubriqueOnBulletin,
    required this.isChecked,
  });

  factory RubriquePaieConfig.fromJson(Map<String, dynamic> json) {
    return RubriquePaieConfig(
      rubriqueOnBulletin:
          RubriqueOnBulletinModel.fromJson(json['rubriqueOnBulletin']),
      isChecked: json['isChecked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rubriqueOnBulletin': rubriqueOnBulletin.toJson(),
      'isChecked': isChecked,
    };
  }
}
