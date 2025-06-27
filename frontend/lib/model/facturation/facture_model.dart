import 'package:frontend/model/commentaire_model.dart';
import 'package:frontend/model/facturation/ligne_model.dart';
import 'package:frontend/model/facturation/reduction_model.dart';
import '../entreprise/banque.dart';
import 'enum_facture.dart';
import '../client/client_model.dart';
import 'facture_acompte.dart';
import '../flux_financier/flux_financier_model.dart';

class FactureModel {
  final String id;
  final String reference;
  final DateTime? dateEtablissementFacture;
  final TypeFacture? type;
  final ReductionModel? reduction;
  final bool? tva;
  final ClientModel? client;
  final List<FactureAcompteModel> facturesAcompte;
  final DateTime? dateEnregistrement;
  final List<FluxFinancierModel>? payements;
  final List<LigneModel>? ligneFactures;
  final bool? regenerate;
  final bool? blocked;
  final bool? isDeletable;
  final String? secreteKey;
  final StatusFacture? status;
  final int? generatePeriod;
  final int? delaisPayment;
  final List<CommentModel?> commentaires;
  final DateTime? dateDebutFacturation;
  final double? montant;
  final double? tauxTVA;
  final List<BanqueModel>? banques;
  final bool? isConvertFromProforma;
  static dynamic factureErr;

  FactureModel({
    required this.id,
    required this.reference,
    required this.facturesAcompte,
    this.dateEtablissementFacture,
    this.type,
    this.reduction,
    this.tva,
    required this.commentaires,
    this.client,
    this.tauxTVA,
    this.dateEnregistrement,
    this.payements,
    this.delaisPayment,
    this.ligneFactures,
    this.regenerate,
    this.blocked,
    this.isDeletable,
    this.secreteKey,
    this.status,
    this.generatePeriod,
    this.dateDebutFacturation,
    this.montant,
    this.banques,
    this.isConvertFromProforma,
  });

  factory FactureModel.fromJson(Map<String, dynamic> json) {
   
    return FactureModel(
      id: json['_id'],
      reference: json['reference'],
      dateEtablissementFacture: json['dateEtablissementFacture'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['dateEtablissementFacture'])
          : null,
      type: json['type'] != null ? typeFactureFromString(json['type']) : null,
      reduction: json['reduction'] != null
          ? ReductionModel.fromJson(json["reduction"])
          : null,
      tauxTVA: (json['tauxTVA'] as num?)?.toDouble() ?? 0.0,
      montant:
          json['montant'] != null ? (json['montant'] as num).toDouble() : null,
      tva: json['tva'] ?? false,
      client:
          json['client'] != null ? ClientModel.fromJson(json['client']) : null,
      dateEnregistrement: json['dateEnregistrement'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateEnregistrement'])
          : null,
      payements: json['payements'] != null
          ? (json['payements'] as List)
              .map((payement) => FluxFinancierModel.fromJson(payement))
              .toList()
          : null,
      ligneFactures: json['ligneFactures'] != null
          ? (json['ligneFactures'] as List)
              .map((ligneFacture) => LigneModel.fromJson(ligneFacture))
              .toList()
          : null,
      facturesAcompte: (json['facturesAcompte'] as List)
          .map((factureAcompte) => FactureAcompteModel.fromJson(factureAcompte))
          .toList(),
      banques: json['banques'] != null
          ? (json['banques'] as List)
              .map((banque) => BanqueModel.fromJson(banque))
              .toList()
          : null,
      regenerate: json['regenerate'] ?? false,
      blocked: json['blocked'] ?? false,
      isDeletable: json['isDeletable'],
      secreteKey: json['secreteKey'] ?? '',
      status: json['status'] != null
          ? statusFactureFromString(json['status'])
          : null,
      generatePeriod: json['generatePeriod']?.toInt(),
      delaisPayment: json['delaisPayment']?.toInt(),
      isConvertFromProforma: json["isConvertFromProforma"] ?? false,
      dateDebutFacturation: json['dateDebutFacturation'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateDebutFacturation'])
          : null,
      commentaires: json['commentaires'] != null
          ? (json['commentaires'] as List)
              .map((commentaire) => CommentModel.fromJson(commentaire))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reference': reference,
      'dateEtablissementFacture':
          dateEtablissementFacture?.millisecondsSinceEpoch,
      'type': typeFactureToString(type!),
      'reduction': reduction?.toJson(),
      'tva': tva,
      'client': client?.toJson(),
      'dateEnregistrement': dateEnregistrement!.millisecondsSinceEpoch,
      'payements': payements?.map((payement) => payement.toJson()).toList(),
      'ligneFactures':
          ligneFactures?.map((ligneFacture) => ligneFacture.toJson()).toList(),
      'facturesAcompte': facturesAcompte
          .map((facturesAcompte) => facturesAcompte.toJson())
          .toList(),
      'banques': banques?.map((banque) => banque.toJson()).toList(),
      'regenerate': regenerate,
      'isDeletable': isDeletable,
      'montant': montant,
      'secreteKey': secreteKey,
      'status': statusFactureToString(status!),
      'generatePeriod': generatePeriod,
      'delaisPayment': delaisPayment,
      'dateDebutFacturation': dateDebutFacturation?.millisecondsSinceEpoch,
      'isConvertFromProforma': isConvertFromProforma,
    };
  }
}
