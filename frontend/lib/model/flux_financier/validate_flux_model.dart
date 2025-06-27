import 'package:frontend/model/flux_financier/type_flux_financier.dart';
import 'package:frontend/model/habilitation/user_model.dart';
class ValidateFluxModel {
  final FluxFinancierStatus validateStatus;
  final DateTime date;
  final UserModel validater;
  final String commentaire;

  ValidateFluxModel({
    required this.validateStatus,
    required this.date,
    required this.validater,
    required this.commentaire,
  });

  factory ValidateFluxModel.fromJson(Map<String, dynamic> json) {
    return ValidateFluxModel(
      validateStatus: fluxFinancierStatusFromString(json["validateStatus"]),
      date: DateTime.fromMillisecondsSinceEpoch(json["date"]),
      validater: UserModel.fromJson(json["validater"]),
      commentaire: json["commentaire"],
              
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "validateStatus": fluxFinancierStatusToString(validateStatus),
      "date": date.millisecondsSinceEpoch,
      "validater": validater.toJson(),
      "commentaire": commentaire,
    };
  }
}
