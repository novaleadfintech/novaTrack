import '../pays_model.dart';
import 'service_prix_model.dart';
import 'enum_service.dart';

class ServiceModel {
  final String id;
  final String libelle;
  final double? prix;
  final List<ServiceTarifModel?> tarif;
  final ServiceType? type;
  final EtatService? etat;
  final NatureService? nature;
  final String? description;
  final PaysModel country;
  final int? fullCount;

  ServiceModel({
    required this.id,
    required this.libelle,
    required this.tarif,
    required this.country,
    required this.type,
    required this.prix,
    required this.nature,
    this.etat,
    this.description,
    this.fullCount,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'],
      libelle: json['libelle'],
country: PaysModel.fromJson(json["country"]),
      prix: json['prix']==null?null:(json['prix'] as num).toDouble(),
      tarif: json['tarif'] == null
          ? []
          : (json['tarif'] as List)
          .map((tarif) => ServiceTarifModel.fromJson(tarif))
          .toList(),
      type: json['type'] != null ? serviceTypeFromString(json['type']) : null,
      etat: json['etat'] != null ? etatServiceFromString(json['etat']) : null,
      nature: json['nature'] != null
          ? natureServiceFromString(json['nature'])
          : null,
      description: json['description'],
      fullCount: json['fullCount']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'libelle': libelle,
      'tarif': tarif.map((t) => t?.toJson()).toList(),
      'prix': prix,
      'type': serviceTypeToString(type!),
      'etat': etatServiceToString(etat!),
      'nature': natureServiceToString(nature!),
      'description': description,
      'fullCount': fullCount,
    };
  }
}
