import 'package:frontend/model/flux_financier/type_flux_financier.dart';

class LibelleFluxModel {
  final dynamic key;
  final String libelle;
  final FluxFinancierType type;

  LibelleFluxModel({
    required this.key,
    required this.libelle,
    required this.type,
  });

  factory LibelleFluxModel.fromJson(Map<String, dynamic> json) {
    return LibelleFluxModel(
      key: json["_key"],
      libelle: json["libelle"],
      type: fluxFinancierTypeFromString(
        json["type"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_key": key,
      "libelle": libelle,
      "type": fluxFinancierTypeToString(type),
    };
  }
}
