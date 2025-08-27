
import 'package:frontend/model/client/client_model.dart';
import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import '../habilitation/user_model.dart';
import './type_flux_financier.dart';
import 'tranche_payement_credit.dart';
import 'validate_flux_model.dart';

class FluxFinancierModel {
  final String id;
  final String? libelle;
  final String? reference;
  final String? referenceTransaction;
  final FluxFinancierType? type;
  final ClientModel? client;
  final FluxFinancierStatus? status;
  final double montant;
  final bool? isFromSystem;
  final MoyenPaiementModel? moyenPayement;
  final DateTime? dateEnregistrement;
  final DateTime? dateOperation;
  final String? pieceJustificative;
  final List<ValidateFluxModel>? validated;
  final UserModel? user;
  final String? factureId;
  final BanqueModel? bank;
  final BuyingManner? buyingManner;
  // final DebtStatus? debtStatus;
  final double? montantPaye;
  final List<TranchePayementModel?>? tranchePayement;

  FluxFinancierModel({
    required this.id,
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
    this.isFromSystem = false,
    this.user,
    this.reference,
    this.factureId,
    required this.validated,
    required this.status,
    this.buyingManner,
    // this.debtStatus,
    this.montantPaye,
    this.tranchePayement,
  });

  factory FluxFinancierModel.fromJson(Map<String, dynamic> json) {
    return FluxFinancierModel(
      id: json['_id'] as String,
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
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      factureId: json['factureId'],
      referenceTransaction: json['referenceTransaction'] ?? "",
      validated: json['validate'] != null
          ? (json['validate'] as List<dynamic>)
              .map((valide) => ValidateFluxModel.fromJson(valide))
              .toList()
          : null,
      buyingManner: json['buyingManner'] != null
          ? buyingMannerFromString(json['buyingManner'])
          : null,
      // debtStatus: json['debtStatus'] != null
      //     ? debtStatusFromString(json['debtStatus'])
      //     : null,
      montantPaye: (json['montantPaye'] as num?)?.toDouble() ?? 0.0,
      tranchePayement: json['tranchePayement'] != null
          ? (json['tranchePayement'] as List<dynamic>)
              .map((tranche) => TranchePayementModel.fromJson(tranche))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'libelle': libelle,
      'reference': reference,
      'type': type != null ? fluxFinancierTypeToString(type!) : null,
      'montant': montant,
      'moyenPayement': moyenPayement?.toJson(),
      'dateEnregistrement': dateEnregistrement?.millisecondsSinceEpoch,
      'dateOperation': dateOperation?.millisecondsSinceEpoch,
      'pieceJustificative': pieceJustificative,
      'referenceTransaction': referenceTransaction,
      'lieuOperation': bank?.toJson,
      'user': user?.toJson(),
      'client': client?.toJson(),
      'factureId': factureId,
      'validated': validated?.map((valide) => valide.toJson()).toList(),  
      'status': status != null ? fluxFinancierStatusToString(status!) : null,
      'isFromSystem': isFromSystem,
      'buyingManner':
          buyingManner != null ? buyingMannerToString(buyingManner!) : null,
      // 'debtStatus': debtStatus != null ? debtStatusToString(debtStatus!) : null
      'montantPaye': montantPaye,
      'tranchePayement': tranchePayement?.map((tranche) => tranche?.toJson()).toList(),
    };
  }

  bool isInput() => type == FluxFinancierType.input;
}
