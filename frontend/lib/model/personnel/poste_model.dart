class PosteModel {
  final String key;
  final String libelle;

  PosteModel({
    required this.key,
    required this.libelle,
  });

  factory PosteModel.fromJson(Map<String, dynamic> json) {
    return PosteModel(
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

  bool equalTo({required PosteModel poste}) {
    return poste.key == key;
  }
}
