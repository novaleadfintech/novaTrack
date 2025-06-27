import '../model/pays_model.dart';

checkPhoneNumber({required String phoneNumber, required PaysModel pays}) {
  List<int> initiaux = pays.initiauxPays;
  if (initiaux.isEmpty) {
    return "Aucun initial téléphonique n'est configuré pour ce pays.";
  }
  bool isValid =
      initiaux.any((init) => phoneNumber.startsWith(init.toString()));
  bool isNumInValid = phoneNumber.length != pays.phoneNumber!;

  if (!isValid) {
    return "Ce numéro de téléphone n'est pas valide! Voici les initiaux valide : ${initiaux.join(", ")}";
  }
  if (isNumInValid) {
    return "Le téléphone n'est pas du bon format. Il doit comporter ${pays.phoneNumber!} caractères.";
  }

  return null;
}
