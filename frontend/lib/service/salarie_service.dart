import 'dart:convert';
import 'package:frontend/global/config.dart';
import 'package:frontend/model/entreprise/banque.dart';
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
        _id
        dateEnregistrement
        paieManner
        fullCount
        numeroCompte
        paiementPlace {
            _id
            name
        }
        moyenPaiement{
          _id
          libelle
          type
        }
        numeroMatricule
        personnel {
            _id
            nom
            prenom
            email
            telephone
            adresse
            sexe
            poste{_id, libelle}
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
                _id
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
        categoriePaie {
            _id
            categoriePaie
        }
        classe {
            _id
            libelle
        }
        echelon {
            _id
            libelle
        }
        grilleCategoriePaie {
            _id
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
        _id
        dateEnregistrement
        fullCount
        paieManner
        moyenPaiement{
          _id
          libelle
          type
        }
        numeroMatricule
        personnel {
            _id
            nom
            prenom
            email
            telephone
            adresse
            sexe
            poste{_id, libelle}
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
                _id
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
        categoriePaie {
            _id
            categoriePaie
        }
        periodPaie
        typePaie
        salaire
        classe {
            _id
            libelle
        }
        echelon {
            _id
            libelle
        }
        grilleCategoriePaie {
            _id
            libelle
        }
        RubriqueBulletin {
            _id
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
    required String personnelId,
    required String categoriePaieId,
    required int? periodPaie,
    required PaieManner paieManner,
    required ClasseModel classe,
    required String numeroMatricule,
    required MoyenPaiementModel moyenPaiement,
    required BanqueModel paiementPlace,
    required EchelonModel echelon,
    required GrilleCategoriePaieModel grilleCategoriePaie,
    required String? numeroCompte,
  }) async {
    var body = '''
      mutation CreateSalarie {
          createSalarie(
              personnelId: "$personnelId"
              categoriePaieId: "$categoriePaieId"
              periodPaie: $periodPaie
              paieManner: ${paieMannerToString(paieManner)}
              classeId: "${classe.id}"
              moyenPaiement: ${moyenPaiement.toJson()}
              numeroMatricule: "$numeroMatricule"
              paiementPlaceId: "${paiementPlace.id}"
              numeroCompte:${numeroCompte != null ? "\"$numeroCompte\"" : null}
              echelonId: "${echelon.id}"
              grilleCategoriePaieId: "${grilleCategoriePaie.id}"
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
    required String? personnelId,
    required String? categoriePaieId,
    required int? periodPaie,
    required MoyenPaiementModel? moyenPaiement,
    // required String? numeroMatricule,
    required PaieManner? paieManner,
  }) async {
    String body = '''
  mutation UpdateSalarie {
    updateSalarie(
      key: "$key",
      periodPaie: $periodPaie,
''';

    if (personnelId != null) {
      body += 'personnelId: "$personnelId",';
    }
    if (categoriePaieId != null) {
      body += 'categoriePaieId: "$categoriePaieId",';
    }

    if (paieManner != null) {
      body += "paieManner: ${paieMannerToString(paieManner)},";
    }
    if (moyenPaiement != null) {
      body += "moyenPaiement: ${moyenPaiement.toJson()},";
    }
    // if (numeroMatricule != null) {
    //   body += 'numeroMatricule: "$numeroMatricule",';
    // }

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
