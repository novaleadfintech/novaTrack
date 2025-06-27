import 'package:frontend/model/bulletin_paie/salarie_model.dart';

import '../entreprise/banque.dart';
import '../moyen_paiement_model.dart';
import 'etat_bulletin.dart';

class DecouverteModel {
  final String id;
  final String justification;
  final double montant;
  final DateTime dateEnregistrement;
  final double montantRestant;
  final int dureeReversement;
  final String? referenceTransaction;
  final DecouverteStatus status; // ou une enum si tu préfères
  final MoyenPaiementModel moyenPayement;
  final BanqueModel banque;
  final SalarieModel salarie;

  DecouverteModel({
    required this.id,
    required this.justification,
    required this.montant,
    required this.dateEnregistrement,
    required this.montantRestant,
    required this.dureeReversement,
    this.referenceTransaction,
    required this.status,
    required this.moyenPayement,
    required this.banque,
    required this.salarie,
  });

  factory DecouverteModel.fromJson(Map<String, dynamic> json) {
    return DecouverteModel(
      id: json["_id"],
      justification: json['justification'],
      montant: (json["montant"] as num).toDouble(),
      dateEnregistrement: DateTime.fromMillisecondsSinceEpoch(
        json["dateEnregistrement"] is int
            ? json["dateEnregistrement"]
            : int.parse(json["dateEnregistrement"]),
        isUtc: true,
      ),
      referenceTransaction: json["referenceTransaction"],
      montantRestant: (json["montantRestant"] as num).toDouble(),
      dureeReversement: json["dureeReversement"],
      status: decourverteStatusFromJson(json["status"]),
      moyenPayement: MoyenPaiementModel.fromJson(json["moyenPayement"]),
      banque: BanqueModel.fromJson(json["banque"]),
      salarie: SalarieModel.fromJson(json["salarie"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "justification": justification,
      "montant": montant,
      "dateEnregistrement": dateEnregistrement.millisecondsSinceEpoch,
      "montantRestant": montantRestant,
      "referenceTransaction": referenceTransaction,
      "dureeReversement": dureeReversement,
      "status": decourverteStatusToJson(status),
      'moyenPayement': moyenPayement.toJson(),
      "banque": banque.toJson(),
      "salarie": salarie.toJson(),
    };
  }
}
