import 'package:frontend/model/bulletin_paie/etat_bulletin.dart';
import 'package:frontend/model/habilitation/user_model.dart';

class ValidateBulletinModel {
  final EtatBulletin validateStatus;
  final DateTime date;
  final UserModel validater;
  final String commentaire;

  ValidateBulletinModel({
    required this.validateStatus,
    required this.date,
    required this.validater,
    required this.commentaire,
  });

  factory ValidateBulletinModel.fromJson(Map<String, dynamic> json) {
    return ValidateBulletinModel(
      validateStatus: etatBulletinFromJson(json["validateStatus"]),
      date: DateTime.fromMillisecondsSinceEpoch(json["date"]),
      validater: UserModel.fromJson(json["validater"]),
      commentaire: "${json["commentaire"]}",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "validateStatus": etatBulletinToString(validateStatus),
      "date": date.millisecondsSinceEpoch,
      "validater": "\"${validater.id}\"",
      "commentaire": "\"$commentaire\"",
    };
  }
}
