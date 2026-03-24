import 'package:frontend/model/bulletin_paie/tranche_model.dart';

class BulletinCategorieModel {
  final dynamic key;
  final String bulletinCategorie;
  final PaieClause paieClause;

  BulletinCategorieModel({
    required this.key,
    required this.bulletinCategorie,
    required this.paieClause,
  });

  factory BulletinCategorieModel.fromJson(Map<String, dynamic> json) {
    return BulletinCategorieModel(
      key: json["_key"],
      bulletinCategorie: json["bulletinCategorie"] ?? "",
      paieClause: PaieClause.paieClauseFromJson(json["paieClause"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_key": key,
      "bulletinCategorie": bulletinCategorie,
      "paieClause": PaieClause.paieClauseToString(paieClause),
    };
  }

  bool equalTo({required BulletinCategorieModel bulletinCategorie}) {
    return bulletinCategorie.key == key;
  }
}
