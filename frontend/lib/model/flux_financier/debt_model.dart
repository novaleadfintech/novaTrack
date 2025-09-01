import "../client/client_model.dart";
import '../habilitation/user_model.dart';
import './type_flux_financier.dart';

class DebtModel {
  final String id;
  final String? libelle;
  final String? referenceFacture;
  final ClientModel? client;
  final DebtStatus? status;
  final double montant;
  final DateTime? dateEnregistrement;
  final DateTime? dateOperation;
  final String? pieceJustificative;
  final UserModel? user;

  DebtModel({
    required this.id,
    this.libelle,
    required this.montant,
    required this.client,
    this.dateEnregistrement,
    this.pieceJustificative,
    this.referenceFacture,
    this.dateOperation,
    this.user,
    required this.status,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['_id'] as String,
      libelle: json['libelle'] as String?,
      status:
          json['status'] != null ? debtStatusFromString(json['status']) : null,
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      dateEnregistrement: json['dateEnregistrement'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateEnregistrement'])
          : null,
      dateOperation: json['dateOperation'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateOperation'])
          : null,
      pieceJustificative: json['pieceJustificative'],
      client:
          json['client'] != null ? ClientModel.fromJson(json['client']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'libelle': libelle,
      'montant': montant,
      'dateEnregistrement': dateEnregistrement?.millisecondsSinceEpoch,
      'dateOperation': dateOperation?.millisecondsSinceEpoch,
      'pieceJustificative': pieceJustificative,
      'referenceFacture': referenceFacture,
      'user': user?.toJson(),
      'client': client?.toJson(),
      'status': status != null ? debtStatusToString(status!) : null,
    };
  }
}
