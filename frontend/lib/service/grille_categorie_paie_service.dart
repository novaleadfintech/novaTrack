import 'dart:convert';
import 'package:frontend/model/grille_salariale/classe_model.dart';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/grille_salariale/categorie_paie.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;
import 'request_header.dart';

class GrilleCategoriePaieService {
  static Future<List<GrilleCategoriePaieModel>>
      getGrilleCategoriePaies() async {
    var body = '''
      query CategoriesPaieGrille {
    categoriesPaieGrille {
        _id
        libelle
        classes {
            _id
            libelle
            echelonIndiciciaires {
                indice
                echelon {
                    _id
                    libelle
                }
            }
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
        .catchError((onError) {
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.failgettingDataMessage;
      },
    );

    List<GrilleCategoriePaieModel> grilleCategoriePaies = [];

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['categoriesPaieGrille'];
      if (data != null) {
        for (var grilleCategoriePaie in data) {
          grilleCategoriePaies
              .add(GrilleCategoriePaieModel.fromJson(grilleCategoriePaie));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return grilleCategoriePaies;
  }

  static Future<RequestResponse> createGrilleCategoriePaie({
    required String libelle,
    required List<ClasseModel> classes,
  }) async {
    var body = '''
    mutation CreateCategoriePaieGrille {
    createCategoriePaieGrille(libelle: "$libelle", classes: ${classes.map((e) => e.toJson()).toList().toString().replaceAll("'", "")}
    , )
}
    ''';
    print(body);
    try {
      var response = await http
          .post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      )
          .timeout(const Duration(seconds: reqTimeout), onTimeout: () {
        throw RequestMessage.timeoutMessage;
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createGrilleCategoriePaie'];
        if (data == RequestMessage.success) {
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
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<RequestResponse> updateGrilleCategoriePaie({
    required String key,
    required String grilleCategoriePaie,
  }) async {
    var body = '''
     mutation UpdateGrilleCategoriePaie {
    updateGrilleCategoriePaie(key: "$key", grilleCategoriePaie: "$grilleCategoriePaie")
}

    ''';

    try {
      var response = await http
          .post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      )
          .timeout(const Duration(seconds: reqTimeout), onTimeout: () {
        throw RequestMessage.timeoutMessage;
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['updateGrilleCategoriePaie'];
        if (data == RequestMessage.success) {
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
    } catch (error) {
      throw RequestMessage.onCatchErrorMessage;
    }
  }

  static Future<RequestResponse> deleteGrilleCategoriePaie({
    required String key,
  }) async {
    var body = '''
     mutation DeleteGrilleCategoriePaie {
    deleteGrilleCategoriePaie(key: "$key")
}

    ''';

    try {
      var response = await http
          .post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      )
          .timeout(const Duration(seconds: reqTimeout), onTimeout: () {
        throw RequestMessage.timeoutMessage;
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['deleteGrilleCategoriePaie'];
        if (data == RequestMessage.success) {
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
    } catch (error) {
      throw RequestMessage.onCatchErrorMessage;
    }
  }
}
