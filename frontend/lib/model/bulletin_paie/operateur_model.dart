class OperateurModel {
  final String id;
  final String libelle;

  OperateurModel({
    required this.id,
    required this.libelle,
  });

  factory OperateurModel.fromJson(Map<String, dynamic> json) {
    return OperateurModel(
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

  bool equalTo({required OperateurModel poste}) {
    return poste.id == id;
  }
}
