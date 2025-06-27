// import 'frais_divers_model.dart';
// import '../service/service_model.dart';

// class LigneFactureModel {
//   final String id;
//   final String designation;
//   final int? quantite;
//   final int? dureeLivraison;
//   final double? prixSupplementaire;
//   final double? remise;
//   final ServiceModel? service;
//   final double montant;
//   final String? unit;
//   final List<FraisDiversModel>? fraisDivers;

//   LigneFactureModel({
//     required this.id,
//     required this.designation,
//     required this.montant,
//     this.quantite,
//     this.prixSupplementaire,
//     this.dureeLivraison,
//     this.remise,
//     this.service,
//     this.unit,
//     this.fraisDivers,
//   });

//   factory LigneFactureModel.fromJson(Map<String, dynamic> json) {
//     return LigneFactureModel(
//       id: json['_id'],
//       designation: json['designation'],
//       unit: json['unit'],
//       quantite: json['quantite'],
//       montant: (json['montant'] ?? 0.0).toDouble(),
//       dureeLivraison: json['dureeLivraison'],
//       remise: json['remise'] == null ? null : (json['remise']).toDouble(),
//       prixSupplementaire: json['prixSupplementaire'] != null ? (json['prixSupplementaire'] as num).toDouble() : null,
//       service: json['service'] != null
//           ? ServiceModel.fromJson(json['service'])
//           : null,
//       fraisDivers:
//           json.containsKey('fraisDivers') && json['fraisDivers'] is List
//               ? (json['fraisDivers'] as List)
//                   .map((frais) => FraisDiversModel.fromJson(frais))
//                   .toList()
//               : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'designation': designation,
//       'unit': unit,
//       'quantite': quantite,
//       'dureeLivraison': dureeLivraison,
//       'prixSupplementaire': prixSupplementaire,
//       'remise': remise,
//       'montant': montant,
//       'service': service?.toJson(),
//       'fraisDivers': fraisDivers?.map((frais) => frais.toJson()).toList(),
//     };
//   }
// }
