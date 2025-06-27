import '../pays_model.dart';
import 'type_canaux_paiement.dart';

class BanqueModel {
  final String id;
  final String name;
  final String codeBanque;
  final double soldeReel;
  final double soldeTheorique;
  final PaysModel? country;
  final String? logo;
  final String codeBIC;
  final CanauxPaiement? type;
  final String codeGuichet;
  final String numCompte;
  final String cleRIB;

  BanqueModel({
    required this.id,
    required this.name,
    required this.codeBanque,
    this.country,
    this.type,
    required this.soldeReel,
    required this.soldeTheorique,
    required this.codeBIC,
    this.logo,
    required this.cleRIB,
    required this.numCompte,
    required this.codeGuichet,
  });

  factory BanqueModel.fromJson(Map<String, dynamic> json) {
    return BanqueModel(
      id: json['_id'],
      name: json['name'],
      codeBanque: json['codeBanque'],
      country:
          json['country'] == null ? null : PaysModel.fromJson(json["country"]),
      logo: json['logo'],
      type: json["type"] == null
          ? null
          : canauxPaiementFromString(json["type"]),
      soldeReel:
          json['soldeReel'] == null ? 0 : (json['soldeReel'] as num).toDouble(),
      soldeTheorique: json['soldeTheorique'] == null
          ? 0
          : (json['soldeTheorique'] as num).toDouble(),
      codeBIC: json['codeBIC'] ?? "",
      numCompte: json['numCompte'] ?? "",
      codeGuichet: json['codeGuichet'],
      cleRIB: json['cleRIB'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'codeBanque': codeBanque,
      'soldeTheorique': soldeTheorique.toDouble(),
      'soldeReel': soldeReel.toDouble(),
      'logo': logo,
      'type':
          type == null ? null : canauxPaiementToString(type!),
      'country': country,
      'codeBIC': codeBIC,
      'numCompte': numCompte,
      'cleRIB': cleRIB,
      'codeGuichet': codeGuichet,
    };
  }

  bool equalTo({required BanqueModel bank}) {
    return bank.id == id;
  }
}
