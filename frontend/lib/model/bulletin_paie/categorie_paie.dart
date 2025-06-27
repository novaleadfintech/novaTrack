class CategoriePaieModel {
  final dynamic id;
  final String categoriePaie;

  CategoriePaieModel({
    required this.id,
    required this.categoriePaie,
  });

  factory CategoriePaieModel.fromJson(Map<String, dynamic> json) {
    return CategoriePaieModel(
      id: json["_id"],
      categoriePaie: json["categoriePaie"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "categoriepaie": categoriePaie,
    };
  }

  bool equalTo({required CategoriePaieModel categoriePaie}) {
    return categoriePaie.id == id;
  }
}
