import 'dart:convert';
import 'package:frontend/model/grille_salariale/classe_model.dart';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/grille_salariale/categorie_paie.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;
import 'request_header.dart';

class GrillepaieCategorieService {
  static Future<List<GrillepaieCategorieModel>>
      getGrillepaieCategories() async {
    var body = '''
      query CategoriesPaieGrille {
    categoriesPaieGrille {
        _key
        libelle
        classes {
            _key
            libelle
            echelonIndiciciaires {
                indice
                echelon {
                    _key
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

    List<GrillepaieCategorieModel> grillepaieCategories = [];

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['categoriesPaieGrille'];
      if (data != null) {
        for (var grillepaieCategorie in data) {
          grillepaieCategories
              .add(GrillepaieCategorieModel.fromJson(grillepaieCategorie));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return grillepaieCategories;
  }

  static Future<RequestResponse> createGrillepaieCategorie({
    required String libelle,
    required List<ClasseModel> classes,
  }) async {
    var body = '''
    mutation CreatepaieCategorieGrille {
    createpaieCategorieGrille(libelle: "$libelle", classes: ${classes.map((e) => e.toJson()).toList().toString().replaceAll("'", "")}
    , )
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
        var data = jsonData['data']['createGrillepaieCategorie'];
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

  static Future<RequestResponse> updateGrillepaieCategorie({
    required String key,
    required String grillepaieCategorie,
  }) async {
    var body = '''
     mutation UpdateGrillepaieCategorie {
    updateGrillepaieCategorie(key: "$key", grillepaieCategorie: "$grillepaieCategorie")
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
        var data = jsonData['data']['updateGrillepaieCategorie'];
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

  static Future<RequestResponse> deleteGrillepaieCategorie({
    required String key,
  }) async {
    var body = '''
     mutation DeleteGrillepaieCategorie {
    deleteGrillepaieCategorie(key: "$key")
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
        var data = jsonData['data']['deleteGrillepaieCategorie'];
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
