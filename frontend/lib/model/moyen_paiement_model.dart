import 'entreprise/type_canaux_paiement.dart';

class MoyenPaiementModel {
  final dynamic key;
  final String libelle;
  final CanauxPaiement? type;

  MoyenPaiementModel({
    required this.key,
    required this.libelle,
    this.type,

  });

  factory MoyenPaiementModel.fromJson(Map<String, dynamic> json) {
    return MoyenPaiementModel(
      key: json["_key"],
      type:
          json["type"] == null ? null : canauxPaiementFromString(json["type"]),
      libelle: json["libelle"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_key": "\"$key\"",
      "libelle": "\"$libelle\"",
      'type': type == null ? null : canauxPaiementToString(type!),
    };
  }

  bool equalTo({required MoyenPaiementModel libelle}) {
    return libelle.key == key;
  }
}
