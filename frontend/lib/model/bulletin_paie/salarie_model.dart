import 'package:frontend/model/grille_salariale/categorie_paie.dart';
import 'package:frontend/model/grille_salariale/classe_model.dart';
import 'package:frontend/model/grille_salariale/echelon_model.dart';

import '../personnel/personnel_model.dart';
import 'categorie_paie.dart';
import 'tranche_model.dart';

class SalarieModel {
  final String id;
  final PersonnelModel personnel;
  final CategoriePaieModel categoriePaie;
  final double dateEnregistrement;
  final int? periodPaie;
  final EchelonModel? echelon;
  final ClasseModel? classe;
  final GrilleCategoriePaieModel? grilleCategoriePaie;
  final PaieManner? paieManner;

  final int? fullCount;

  SalarieModel({
    required this.id,
    required this.personnel,
    required this.categoriePaie,
    required this.dateEnregistrement,
    required this.periodPaie,
    this.echelon,
    this.classe,
    this.grilleCategoriePaie,
    this.paieManner = PaieManner.finMois,
    this.fullCount,
  });

  factory SalarieModel.fromJson(Map<String, dynamic> json) {
    return SalarieModel(
      id: json['_id'] ?? "",
      personnel: PersonnelModel.fromJson(json['personnel']),
      categoriePaie: CategoriePaieModel.fromJson(json['categoriePaie']),
      dateEnregistrement: json['dateEnregistrement']?.toDouble() ?? 0.0,
      periodPaie: json['periodPaie']?.toInt(),
      paieManner: paieMannerFromJson(json['paieManner']),
      echelon: json['echelon'] != null
          ? EchelonModel.fromJson(json['echelon'])
          : null,
      classe:
          json['classe'] != null ? ClasseModel.fromJson(json['classe']) : null,
      grilleCategoriePaie: json['grilleCategoriePaie'] != null
          ? GrilleCategoriePaieModel.fromJson(json['grilleCategoriePaie'])
          : null,
      fullCount: json['fullCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'personnel': personnel.toJson(),
      'categoriePaie': categoriePaie.toJson(),
      'dateEnregistrement': dateEnregistrement,
      'periodPaie': periodPaie,
      'echelon': echelon?.toJson(),
      'classe': classe?.toJson(),
      'grilleCategoriePaie': grilleCategoriePaie?.toJson(),
      'paieManner': paieMannerToString(paieManner!),
      'fullCount': fullCount,
    };
  }
}
