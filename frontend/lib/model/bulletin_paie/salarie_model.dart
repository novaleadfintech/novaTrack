import 'package:frontend/model/bulletin_paie/bulletin_categorie.dart';
import 'package:frontend/model/bulletin_paie/operateur_model.dart';
import 'package:frontend/model/grille_salariale/categorie_paie.dart';
import 'package:frontend/model/grille_salariale/classe_model.dart';
import 'package:frontend/model/grille_salariale/echelon_model.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import '../personnel/personnel_model.dart';
 import 'tranche_model.dart';

class SalarieModel {
  final String key;
  final PersonnelModel personnel;
  final BulletinCategorieModel bulletinCategorie;
  final double dateEnregistrement;
  final int? periodPaie;
  final String? numeroMatricule;
  final EchelonModel? echelon;
  final MoyenPaiementModel? moyenPaiement;
  final String? numeroCompte;
  final OperateurModel? operateur;
  final ClasseModel? classe;
  final GrillepaieCategorieModel? grillepaieCategorie;
  // final PaieManner? paieManner;
  final PaieClause? paieClause;

  final int? fullCount;

  SalarieModel({
    required this.key,
    required this.personnel,
    required this.bulletinCategorie,
    required this.dateEnregistrement,
    required this.periodPaie,
    this.echelon,
    this.classe,
    this.numeroCompte,
    this.operateur,
    this.moyenPaiement,
    this.grillepaieCategorie,
    this.numeroMatricule,
    // this.paieManner = PaieManner.finMois,
    this.paieClause,
    this.fullCount,
  });

  factory SalarieModel.fromJson(Map<String, dynamic> json) {
    return SalarieModel(
      key: json['_key'] ?? "",
      personnel: PersonnelModel.fromJson(json['personnel']),
      bulletinCategorie:
          BulletinCategorieModel.fromJson(json['bulletinCategorie']),
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
      grillepaieCategorie: json['grillepaieCategorie'] != null
          ? GrillepaieCategorieModel.fromJson(json['grillepaieCategorie'])
          : null,
      fullCount: json['fullCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_key': key,
      'personnel': personnel.toJson(),
      'bulletinCategorie': bulletinCategorie.toJson(),
      'dateEnregistrement': dateEnregistrement,
      'periodPaie': periodPaie,
      'echelon': echelon?.toJson(),
      'numeroMatricule': numeroMatricule,
      'classe': classe?.toJson(),
      'grillepaieCategorie': grillepaieCategorie?.toJson(),
      // 'paieManner': paieMannerToString(paieManner!),
      'paieClause': PaieClause.paieClauseToString(paieClause!),
      'fullCount': fullCount,
    };
  }
}
