class OperateurModel {
  final String key;
  final String libelle;

  OperateurModel({
    required this.key,
    required this.libelle,
  });

  factory OperateurModel.fromJson(Map<String, dynamic> json) {
    return OperateurModel(
      key: json['_key'],
      libelle: json['libelle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_key": "\"$key\"",
      "libelle": "\"$libelle\"",
    };
  }

  bool equalTo({required OperateurModel poste}) {
    return poste.key == key;
  }
}
