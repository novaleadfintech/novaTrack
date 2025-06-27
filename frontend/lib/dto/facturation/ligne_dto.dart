import '../../model/service/service_model.dart';
import 'frais_divers_dto.dart';

class LigneDto {
  final String designation;
  final int quantite;
  final int? dureeLivraison;
  final double? prixSupplementaire;
  final String unit;
  final String serviceId;
  final ServiceModel? service;
  final List<FraisDiversDto>? fraisDivers;

  LigneDto({
    required this.designation,
    required this.quantite,
    this.prixSupplementaire,
    this.dureeLivraison,
    required this.serviceId,
    required this.unit,
    this.service,
    this.fraisDivers,
  });

  factory LigneDto.fromJson(Map<String, dynamic> json) {
    return LigneDto(
      designation: json['designation'],
      unit: json['unit'],
      quantite: json['quantite'],
      prixSupplementaire: json['prixSupplementaire'] == null
          ? 0
          : (json['prixSupplementaire'] as num?)?.toDouble(),
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      serviceId: json['serviceId'],
      fraisDivers: (json['fraisDivers'] as List?)
              ?.map((frais) => FraisDiversDto.fromJson(frais))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'designation': "\"$designation\"",
      'unit': "\"$unit\"",
      'quantite': quantite,
      'dureeLivraison': dureeLivraison,
      'prixSupplementaire': prixSupplementaire,
      'serviceId': "\"$serviceId\"",
      'fraisDivers': fraisDivers?.map((frais) => frais.toJson()).toList(),
    };
  }
}
