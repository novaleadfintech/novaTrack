class PosteModel {
  final String id;
  final String libelle;

  PosteModel({
    required this.id,
    required this.libelle,
  });

  factory PosteModel.fromJson(Map<String, dynamic> json) {
    return PosteModel(
      id: json['_id'],
      libelle: json['libelle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": "\"$id\"",
      "libelle": "\"$libelle\"",
    };
  }

  bool equalTo({required PosteModel poste}) {
    return poste.id == id;
  }
}
