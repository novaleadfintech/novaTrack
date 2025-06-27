import 'frais_divers_model.dart';
import '../service/service_model.dart';

class LigneProformaModel {
  final String id;
  final String designation;
  final int? quantite;
  final int? dureeLivraison;
  final double? prixSupplementaire;
  final double? remise;
  final ServiceModel? service;
  final double montant;
  final String? unit;
  final List<FraisDiversModel>? fraisDivers;

  LigneProformaModel({
    required this.id,
    required this.designation,
    required this.montant,
    this.quantite,
    this.prixSupplementaire,
    this.dureeLivraison,
    this.remise,
    this.service,
    this.unit,
    this.fraisDivers,
  });

  factory LigneProformaModel.fromJson(Map<String, dynamic> json) {
    return LigneProformaModel(
      id: json['_id'],
      designation: json['designation'],
      unit: json['unit'],
      quantite: json['quantite'],
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      dureeLivraison: json['dureeLivraison'],
      prixSupplementaire: json['prixSupplementaire'] == null
          ? 0
          : (json['prixSupplementaire'] as num?)?.toDouble(),
      remise: (json['remise'] as num?)?.toDouble() ?? 0.0,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      fraisDivers: (json['fraisDivers'] as List?)
              ?.map((frais) => FraisDiversModel.fromJson(frais))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'designation': designation,
      'unit': unit,
      'quantite': quantite,
      'dureeLivraison': dureeLivraison,
      'remise': remise,
      'montant': montant,
      'prixSupplementaire': prixSupplementaire,
      'service': service?.toJson(),
      'fraisDivers': fraisDivers?.map((frais) => frais.toJson()).toList(),
    };
  }
}
