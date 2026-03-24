
import 'package:frontend/model/client/client_model.dart';
import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import '../habilitation/user_model.dart';
import './type_flux_financier.dart';
import 'validate_flux_model.dart';

class FluxFinancierModel {
  final String key;
  final String? libelle;
  final String? reference;
  final String? referenceTransaction;
  final FluxFinancierType? type;
  final ClientModel? client;
  final String? partiePrenante;
  final FluxFinancierStatus? status;
  final double montant;
  final bool? isFromSystem;
  final MoyenPaiementModel? moyenPayement;
  final DateTime? dateEnregistrement;
  final DateTime? dateOperation;
  final String? pieceJustificative;
  final List<ValidateFluxModel>? validated;
  final UserModel? user;
  final String? factureKey;
  final BanqueModel? bank;

  FluxFinancierModel({
    required this.key,
    this.libelle,
    this.type,
    required this.montant,
    required this.client,
    this.moyenPayement,
    this.dateEnregistrement,
    this.pieceJustificative,
    this.referenceTransaction,
    this.dateOperation,
    this.bank,
    this.partiePrenante,
    this.isFromSystem = false,
    this.user,
    this.reference,
    this.factureKey,
    required this.validated,
    required this.status,
  });

  factory FluxFinancierModel.fromJson(Map<String, dynamic> json) {
    return FluxFinancierModel(
      key: json['_key'] as String,
      reference: json['reference'] as String?,
      libelle: json['libelle'] as String?,
      type: json['type'] != null
          ? fluxFinancierTypeFromString(json['type'])
          : null,
      isFromSystem: json['isFromSystem'] ?? false,
      status: json['status'] != null
          ? fluxFinancierStatusFromString(json['status'])
          : FluxFinancierStatus.wait,
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      moyenPayement: json['moyenPayement'] != null
          ? MoyenPaiementModel.fromJson(json["moyenPayement"])
          : null,
      dateEnregistrement: json['dateEnregistrement'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateEnregistrement'])
          : null,
      dateOperation: json['dateOperation'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateOperation'])
          : null,
      pieceJustificative: json['pieceJustificative'],
      bank: json['bank'] != null ? BanqueModel.fromJson(json['bank']) : null,
      client:
          json['client'] != null ? ClientModel.fromJson(json['client']) : null,
      partiePrenante: json['partiePrenante'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      factureKey: json['factureKey'],
      referenceTransaction: json['referenceTransaction'] ?? "",
      validated: json['validate'] != null
          ? (json['validate'] as List<dynamic>)
              .map((valide) => ValidateFluxModel.fromJson(valide))
              .toList()
          : null,    
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_key': key,
      'libelle': libelle,
      'reference': reference,
      'type': type != null ? fluxFinancierTypeToString(type!) : null,
      'montant': montant,
      'moyenPayement': moyenPayement?.toJson(),
      'dateEnregistrement': dateEnregistrement?.millisecondsSinceEpoch,
      'dateOperation': dateOperation?.millisecondsSinceEpoch,
      'pieceJustificative': pieceJustificative,
      'partiePrenante': partiePrenante,
      'referenceTransaction': referenceTransaction,
      'lieuOperation': bank?.toJson,
      'user': user?.toJson(),
      'client': client?.toJson(),
      'factureKey': factureKey,
      'validated': validated?.map((valide) => valide.toJson()).toList(),  
      'status': status != null ? fluxFinancierStatusToString(status!) : null,
      'isFromSystem': isFromSystem,
    };
  }

  bool isInput() => type == FluxFinancierType.input;
}
