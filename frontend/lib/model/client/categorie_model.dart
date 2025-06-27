class CategorieModel {
  final String id;
  final String libelle;
  static dynamic categorieErr;

  CategorieModel({
    required this.id,
    required this.libelle,
  });

  factory CategorieModel.fromJson(Map<String, dynamic> json) {
    return CategorieModel(
      id: json["_id"],
      libelle: json["libelle"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "libelle": libelle,
    };
  }
}
