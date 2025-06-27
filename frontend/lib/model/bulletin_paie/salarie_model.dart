import '../personnel/personnel_model.dart';
import 'categorie_paie.dart';
import 'tranche_model.dart';

class SalarieModel {
  final String id;
  final PersonnelModel personnel;
  final CategoriePaieModel categoriePaie;
  final double dateEnregistrement;
  final int? periodPaie;
  final PaieManner? paieManner;

  final int? fullCount;

  SalarieModel({
    required this.id,
    required this.personnel,
    required this.categoriePaie,
    required this.dateEnregistrement,
    required this.periodPaie,
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
      'paieManner': paieMannerToString(paieManner!),
      'fullCount': fullCount,
    };
  }
}
