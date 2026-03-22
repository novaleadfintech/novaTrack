import 'package:frontend/model/bulletin_paie/tranche_model.dart';

class CategorieBulletinModel {
  final dynamic id;
  final String categorieBulletin;
  final PaieClause paieClause;

  CategorieBulletinModel({
    required this.id,
    required this.categorieBulletin,
    required this.paieClause,
  });

  factory CategorieBulletinModel.fromJson(Map<String, dynamic> json) {
    return CategorieBulletinModel(
      id: json["_id"],
      categorieBulletin: json["categorieBulletin"] ?? "",
      paieClause: PaieClause.paieClauseFromJson(json["paieClause"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "categorieBulletin": categorieBulletin,
      "paieClause": PaieClause.paieClauseToString(paieClause),
    };
  }

  bool equalTo({required CategorieBulletinModel categorieBulletin}) {
    return categorieBulletin.id == id;
  }
}
