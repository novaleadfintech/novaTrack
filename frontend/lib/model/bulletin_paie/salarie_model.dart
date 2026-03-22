import 'package:frontend/model/bulletin_paie/categorie_bulletin.dart';
import 'package:frontend/model/bulletin_paie/operateur_model.dart';
import 'package:frontend/model/grille_salariale/categorie_paie.dart';
import 'package:frontend/model/grille_salariale/classe_model.dart';
import 'package:frontend/model/grille_salariale/echelon_model.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import '../personnel/personnel_model.dart';
 import 'tranche_model.dart';

class SalarieModel {
  final String id;
  final PersonnelModel personnel;
  final CategorieBulletinModel categorieBulletin;
  final double dateEnregistrement;
  final int? periodPaie;
  final String? numeroMatricule;
  final EchelonModel? echelon;
  final MoyenPaiementModel? moyenPaiement;
  final String? numeroCompte;
  final OperateurModel? operateur;
  final ClasseModel? classe;
  final GrilleCategoriePaieModel? grilleCategoriePaie;
  // final PaieManner? paieManner;
  final PaieClause? paieClause;

  final int? fullCount;

  SalarieModel({
    required this.id,
    required this.personnel,
    required this.categorieBulletin,
    required this.dateEnregistrement,
    required this.periodPaie,
    this.echelon,
    this.classe,
    this.numeroCompte,
    this.operateur,
    this.moyenPaiement,
    this.grilleCategoriePaie,
    this.numeroMatricule,
    // this.paieManner = PaieManner.finMois,
    this.paieClause,
    this.fullCount,
  });

  factory SalarieModel.fromJson(Map<String, dynamic> json) {
    return SalarieModel(
      id: json['_id'] ?? "",
      personnel: PersonnelModel.fromJson(json['personnel']),
      categorieBulletin: CategorieBulletinModel.fromJson(json['categorieBulletin']),
      dateEnregistrement: json['dateEnregistrement']?.toDouble() ?? 0.0,
      periodPaie: json['periodPaie']?.toInt(),
      // paieManner: paieMannerFromJson(json['paieManner']),
      paieClause: PaieClause.paieClauseFromJson(json['paieClause']),
      echelon: json['echelon'] != null
          ? EchelonModel.fromJson(json['echelon'])
          : null,
      numeroMatricule: json['numeroMatricule'],
      numeroCompte: json['numeroCompte'],
      moyenPaiement: json["moyenPaiement"] == null
          ? null
          : MoyenPaiementModel.fromJson(json["moyenPaiement"]),
      operateur: json['operateur'] != null
          ? OperateurModel.fromJson(json['operateur'])
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
      'categorieBulletin': categorieBulletin.toJson(),
      'dateEnregistrement': dateEnregistrement,
      'periodPaie': periodPaie,
      'echelon': echelon?.toJson(),
      'numeroMatricule': numeroMatricule,
      'classe': classe?.toJson(),
      'grilleCategoriePaie': grilleCategoriePaie?.toJson(),
      // 'paieManner': paieMannerToString(paieManner!),
      'paieClause': PaieClause.paieClauseToString(paieClause!),
      'fullCount': fullCount,
    };
  }
}
