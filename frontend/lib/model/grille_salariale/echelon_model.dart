class EchelonModel {
  final String id;
  final String libelle;

  EchelonModel({
    required this.id,
    required this.libelle,
  });

  factory EchelonModel.fromJson(Map<String, dynamic> json) {
    return EchelonModel(
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

  bool equalTo({required EchelonModel echelon}) {
    return echelon.id == id;
  }

  @override
  String toString() {
    return libelle;
  }
}
