import 'dart:convert';
import 'package:frontend/global/config.dart';
import 'package:frontend/model/bulletin_paie/operateur_model.dart';
 import 'package:frontend/model/grille_salariale/classe_model.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import 'package:http/http.dart' as http;

import '../app/integration/popop_status.dart';
import '../global/constant/request_management_value.dart';
import '../model/bulletin_paie/salarie_model.dart';
import '../model/bulletin_paie/tranche_model.dart';
import '../model/grille_salariale/categorie_paie.dart';
import '../model/grille_salariale/echelon_model.dart';
import '../model/request_response.dart';
import 'request_header.dart';

class SalarieService {
  static Future<List<SalarieModel>> getSalaries({
    int? perPage,
    int? skip,
  }) async {
    var body = '''
     query Salaries {
    salaries {
        _key
        dateEnregistrement
        paieClause
        fullCount
        numeroCompte
       operateur{_key, libelle}
        moyenPaiement{
          _key
          libelle
          type
        }
        numeroMatricule
        personnel {
            _key
            nom
            prenom
            email
            telephone
            adresse
            sexe
            poste{_key, libelle}
            situationMatrimoniale
            commentaire
            etat
            dateEnregistrement
            dateNaissance
            dateDebut
            dateFin
            nombreEnfant
            nombrePersonneCharge
            dureeEssai
            typePersonnel
            typeContrat
            fullCount
            pays {
                _key
                name
                code
                tauxTVA
                phoneNumber
                initiauxPays
            }
            personnePrevenir {
                nom
                lien
                telephone1
                telephone2
            }
        }
        bulletinCategorie {
            _key
            bulletinCategorie
            paieClause
        }
        classe {
            _key
            libelle
        }
        echelon {
            _key
            libelle
        }
        grillepaieCategorie {
            _key
            libelle
        }
        periodPaie
        
    }
}

    ''';

    var response = await http
        .post(
          Uri.parse(serverUrl),
          body: json.encode({'query': body}),
          headers: getHeaders(),
        )
        .timeout(
          const Duration(seconds: reqTimeout),
          onTimeout: () => throw RequestMessage.timeoutMessage,
        );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
       var data = jsonData['data']['salaries'];

      if (data != null) {
        return (data as List)
            .map((json) => SalarieModel.fromJson(json))
            .toList();
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<SalarieModel> getSalarie({required String key}) async {
    var body = '''
      query Salarie {
    salarie {
        _key
        dateEnregistrement
        fullCount
        paieClause
        operateur{_key, libelle}
        moyenPaiement{
          _key
          libelle
          type
        }
        numeroMatricule
        personnel {
            _key
            nom
            prenom
            email
            telephone
            adresse
            sexe
            poste{_key, libelle}
            situationMatrimoniale
            commentaire
            etat
            dateEnregistrement
            dateNaissance
            dateDebut
            dateFin
            nombreEnfant
            nombrePersonneCharge
            dureeEssai
            typePersonnel
            typeContrat
            fullCount
            pays {
                _key
                name
                code
                tauxTVA
                phoneNumber
                initiauxPays
            }
            personnePrevenir {
                nom
                lien
                telephone1
                telephone2
            }
        }
        bulletinCategorie {
            _key
            bulletinCategorie
            paieClause
        }
        periodPaie
        typePaie
        salaire
        classe {
            _key
            libelle
        }
        echelon {
            _key
            libelle
        }
        grillepaieCategorie {
            _key
            libelle
        }
        RubriqueBulletin {
            _key
            rubrique
            code
            type
            nature
        }
    }
}
    ''';

    var response = await http
        .post(
          Uri.parse(serverUrl),
          body: json.encode({'query': body}),
          headers: getHeaders(),
        )
        .timeout(
          const Duration(seconds: reqTimeout),
          onTimeout: () => throw RequestMessage.timeoutMessage,
        );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['salarie'];
      return SalarieModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<RequestResponse> createSalarie({
    required String personnelKey,
    required String bulletinCategorieKey,
    required int? periodPaie,
    required PaieClause paieClause,
    required ClasseModel classe,
    required String numeroMatricule,
    required MoyenPaiementModel moyenPaiement,
    required OperateurModel operateur,
    required EchelonModel echelon,
    required GrillepaieCategorieModel grillepaieCategorie,
    required String? numeroCompte,
  }) async {
    var body = '''
      mutation CreateSalarie {
          createSalarie(
              personnelKey: "$personnelKey"
              bulletinCategorieKey: "$bulletinCategorieKey"
              periodPaie: $periodPaie
              paieClause: ${PaieClause.paieClauseToString(paieClause)}
              classeKey: "${classe.key}"
              moyenPaiement: ${moyenPaiement.toJson()}
              numeroMatricule: "$numeroMatricule"
              operateur: ${operateur.toJson()}
              numeroCompte:${numeroCompte != null ? "\"$numeroCompte\"" : null}
              echelonKey: "${echelon.key}"
              grillepaieCategorieKey: "${grillepaieCategorie.key}"
          )
      }
    ''';
    var response = await http
        .post(
          Uri.parse(serverUrl),
          body: json.encode({'query': body}),
          headers: getHeaders(),
        )
        .timeout(
          const Duration(seconds: reqTimeout),
          onTimeout: () => throw RequestMessage.timeoutMessage,
        );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var result = jsonData['data']['createSalarie'];
      if (result == RequestMessage.success) {
        return RequestResponse(
          message: RequestMessage.successMessage,
          status: PopupStatus.success,
        );
      } else {
        throw RequestMessage.serverErrorMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<RequestResponse> updateSalarie({
    required String key,
    required String? personnelKey,
    required String? bulletinCategorieKey,
    required int? periodPaie,
    required MoyenPaiementModel? moyenPaiement,
    // required String? numeroMatricule,
    required PaieClause? paieClause,
    String? numeroMatricule,
    required OperateurModel? operateur,
    String? numeroCompte,
    GrillepaieCategorieModel? grillepaieCategorie,
    required classe,
    EchelonModel? echelon,
  }) async {
    String body = '''
  mutation UpdateSalarie {
    updateSalarie(
      key: "$key",
      periodPaie: $periodPaie,
''';

    if (personnelKey != null) {
      body += 'personnelKey: "$personnelKey",';
    }
    if (bulletinCategorieKey != null) {
      body += 'bulletinCategorieKey: "$bulletinCategorieKey",';
    }

    if (paieClause != null) {
      body += "paieClause: ${PaieClause.paieClauseToString(paieClause)},";
    }
    if (moyenPaiement != null) {
      body += "moyenPaiement: ${moyenPaiement.toJson()},";
    }

    // Champs additionnels pour la mise à jour
    if (numeroMatricule != null) {
      body += 'numeroMatricule: "$numeroMatricule",';
    }
    // operateur est requis — on l'ajoute toujours
    if (operateur != null) {
      body += 'operateur: ${operateur.toJson()},';
    }
    if (numeroCompte != null) {
      body += 'numeroCompte: "$numeroCompte",';
    }
    if (grillepaieCategorie != null) {
      body += 'grillepaieCategorieKey: "${grillepaieCategorie.key}",';
    }
    if (classe != null) {
      body += 'classeKey: "${classe.key}",';
    }
    if (echelon != null) {
      body += 'echelonKey: "${echelon.key}",';
    }

    body += '''
    )
  }
''';

    var response = await http
        .post(
          Uri.parse(serverUrl),
          body: json.encode({'query': body}),
          headers: getHeaders(),
        )
        .timeout(
          const Duration(seconds: reqTimeout),
          onTimeout: () => throw RequestMessage.timeoutMessage,
        );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var result = jsonData['data']['updateSalarie'];
      if (result == RequestMessage.success) {
        return RequestResponse(
          message: RequestMessage.successMessage,
          status: PopupStatus.success,
        );
      } else {
        throw RequestMessage.serverErrorMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }

  static Future<RequestResponse> deleteSalarie({required String key}) async {
    var body = '''
      mutation DeleteSalarie {
        deleteSalarie(key: "$key")
      }
    ''';

    var response = await http
        .post(
          Uri.parse(serverUrl),
          body: json.encode({'query': body}),
          headers: getHeaders(),
        )
        .timeout(
          const Duration(seconds: reqTimeout),
          onTimeout: () => throw RequestMessage.timeoutMessage,
        );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var result = jsonData['data']['deleteSalarie'];
      if (result == RequestMessage.success) {
        return RequestResponse(
          message: RequestMessage.successMessage,
          status: PopupStatus.success,
        );
      } else {
        throw RequestMessage.serverErrorMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
  }
}
