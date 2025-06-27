import 'oldpenalty_model.dart';
import 'penalty_model.dart';

class FactureAcompteModel {
  final int pourcentage;
  final int rang;
  final DateTime? datePayementEcheante;
  final DateTime dateEnvoieFacture;
  final bool? isPaid;
  final bool canPenalty;
  final bool? isSent;
  final PenaltyModel? penalty;
  final List<OldPenaltyModel>? oldPenalties;

  FactureAcompteModel({
    required this.pourcentage,
    required this.rang,
    this.datePayementEcheante,
    this.isPaid,
    required this.canPenalty,
    this.isSent,
    required this.dateEnvoieFacture,
    this.oldPenalties,
    this.penalty,
  });

  factory FactureAcompteModel.fromJson(Map<String, dynamic> json) {
    return FactureAcompteModel(
      pourcentage: (json["pourcentage"] as num).toInt(),
      isPaid: json["isPaid"] ?? false,
      isSent: json["isSent"] ?? false,
      canPenalty: json["canPenalty"] ?? true,
      rang: (json["rang"] as num).toInt(),
      datePayementEcheante: json["datePayementEcheante"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["datePayementEcheante"])
          : null,
      dateEnvoieFacture: json["dateEnvoieFacture"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["dateEnvoieFacture"])
          : DateTime.now().add(Duration(days: 6)),
      oldPenalties: json['oldPenalties'] != null
          ? (json['oldPenalties'] as List)
              .map((oldPenalty) => OldPenaltyModel.fromJson(oldPenalty))
              .toList()
          : null,
      penalty: json['penalty'] != null
          ? PenaltyModel.fromJson(json['penalty'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "pourcentage": pourcentage,
      "rang": rang,
      "isPaid": isPaid,
      "isSent": isSent,
      "canPenalty": canPenalty,
      "datePayementEcheante": datePayementEcheante?.millisecondsSinceEpoch,
      'oldPenalties': oldPenalties,
      'dateEnvoieFacture': dateEnvoieFacture.millisecondsSinceEpoch,
    };
  }
}
