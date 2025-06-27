import 'package:frontend/model/flux_financier/type_flux_financier.dart';

class LibelleFluxModel {
  final dynamic id;
  final String libelle;
  final FluxFinancierType type;

  LibelleFluxModel({
    required this.id,
    required this.libelle,
    required this.type,
  });

  factory LibelleFluxModel.fromJson(Map<String, dynamic> json) {
    return LibelleFluxModel(
      id: json["_id"],
      libelle: json["libelle"],
      type: fluxFinancierTypeFromString(
        json["type"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "libelle": libelle,
      "type": fluxFinancierTypeToString(type),
    };
  }
}
