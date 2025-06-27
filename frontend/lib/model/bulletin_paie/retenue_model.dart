// class RubriqueModel {
//   final String libelle;
//   final double montant;
//   final double taux;
//   final bool? isAvance;
//   RubriqueModel({
//     required this.libelle,
//     required this.montant,
//     required this.taux,
//  this.isAvance,
//   });

//   factory RubriqueModel.fromJson(Map<String, dynamic> json) {
//     return RubriqueModel(
//       libelle: json['libelle'],
//       montant: (json['montant'] as num).toDouble(),
//       taux: (json['taux'] as num).toDouble(),
//       isAvance: json['isAvance'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'libelle': libelle,
//       'montant': montant,
//       'taux': taux,
//       'isAvance': isAvance,
//     };
//   }
// }
