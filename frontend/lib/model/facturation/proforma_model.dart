import 'package:frontend/model/facturation/ligne_model.dart';
import 'package:frontend/model/facturation/reduction_model.dart';

import 'enum_facture.dart';
import '../client/client_model.dart';

class ProformaModel {
  final String id;
  final String reference;
  final DateTime? dateEtablissementProforma;
  final ReductionModel? reduction;
  final bool? tva;
  final double? tauxTVA;
  final ClientModel? client;
  final DateTime? dateEnregistrement;
  final List<LigneModel>? ligneProformas;
  final StatusProforma? status;
  final int? garantyTime;
  final DateTime? dateEnvoie;
  final double? montant;

  ProformaModel({
    required this.id,
    required this.reference,
    this.dateEtablissementProforma,
    this.reduction,
    this.tva,
    this.client,
    this.dateEnregistrement,
    this.ligneProformas,
    this.status,
    this.tauxTVA,
    this.garantyTime,
    this.dateEnvoie,
    this.montant,
  });

  factory ProformaModel.fromJson(Map<String, dynamic> json) {
    return ProformaModel(
      id: json['_id'] ?? '',
      reference: json['reference'] ?? '',
      dateEtablissementProforma: json['dateEtablissementProforma'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['dateEtablissementProforma'])
          : null,
      reduction: json['reduction'] != null
          ? ReductionModel.fromJson(json["reduction"])
          : null,
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      tauxTVA: (json['tauxTVA'] as num?)?.toDouble() ?? 0.0,
      tva: json['tva'] ?? false,
      client:
          json['client'] != null ? ClientModel.fromJson(json['client']) : null,
      dateEnregistrement: json['dateEnregistrement'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateEnregistrement'])
          : null,
      status: json["status"] != null
          ? statusProformaFromString(json["status"])
          : null,
      ligneProformas: (json['ligneProformas'] as List?)
              ?.map((ligneProforma) => LigneModel.fromJson(ligneProforma))
              .toList() ??
          [],
      garantyTime: (json['garantyTime'] as num?)?.toInt() ?? 0,
      dateEnvoie: json['dateEnvoie'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateEnvoie'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reference': reference,
      'dateEtablissementProforma':
          dateEtablissementProforma?.millisecondsSinceEpoch,
      'reduction': reduction?.toJson(),
      'tva': tva,
      'client': client?.toJson(),
      'dateEnregistrement': dateEnregistrement?.millisecondsSinceEpoch,
      'ligneProformas': ligneProformas
          ?.map((ligneProforma) => ligneProforma.toJson())
          .toList(),
      'montant': montant,
      'status': statusProformaToString(status!),
      'garantyTime': garantyTime,
      'dateEnvoie': dateEnvoie?.millisecondsSinceEpoch,
    };
  }
}
