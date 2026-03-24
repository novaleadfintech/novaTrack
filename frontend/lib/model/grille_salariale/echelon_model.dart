class EchelonModel {
  final String key;
  final String libelle;

  EchelonModel({
    required this.key,
    required this.libelle,
  });

  factory EchelonModel.fromJson(Map<String, dynamic> json) {
    return EchelonModel(
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

  bool equalTo({required EchelonModel echelon}) {
    return echelon.key == key;
  }

  @override
  String toString() {
    return libelle;
  }
}
