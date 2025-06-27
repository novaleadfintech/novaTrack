import 'entreprise/type_canaux_paiement.dart';

class MoyenPaiementModel {
  final dynamic id;
  final String libelle;
  final CanauxPaiement? type;

  MoyenPaiementModel({
    required this.id,
    required this.libelle,
    this.type,

  });

  factory MoyenPaiementModel.fromJson(Map<String, dynamic> json) {
    return MoyenPaiementModel(
      id: json["_id"],
      type:
          json["type"] == null ? null : canauxPaiementFromString(json["type"]),
      libelle: json["libelle"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": "\"$id\"",
      "libelle": "\"$libelle\"",
      'type': type == null ? null : canauxPaiementToString(type!),
    };
  }

  bool equalTo({required MoyenPaiementModel libelle}) {
    return libelle.id == id;
  }
}
