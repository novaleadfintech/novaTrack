import 'dart:convert';
import 'package:frontend/model/grille_salariale/echelon_indice_model.dart';

import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/grille_salariale/classe_model.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;
import 'request_header.dart';

class ClasseService {
  static Future<List<ClasseModel>> getClasses() async {
    var body = '''
      query Classes {
        classes {
          _id
          libelle
          echelonIndiciaires {
            echelon {
              _id
              libelle
            }
            indice
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

    List<ClasseModel> classes = [];

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['classes'];
      if (data != null) {
        for (var classe in data) {
          classes.add(classe.fromJson(classe));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return classes;
  }

  static Future<RequestResponse> createClasse({
    required String libelle,
    required List<EchelonIndiceModel> echelonIndiciaires,
  }) async {
    var body = '''
    mutation CreateClasse {
    createClasse(libellle: "$libelle", echelonIndiciaires: ${jsonEncode(echelonIndiciaires)}, )
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
        var data = jsonData['data']['createClasse'];
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

  static Future<RequestResponse> updateClasse({
    required String key,
    required String classe,
  }) async {
    var body = '''
     mutation UpdateClasse {
    updateClasse(key: "$key", classe: "$classe")
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
        var data = jsonData['data']['updateClasse'];
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

  static Future<RequestResponse> deleteClasse({
    required String key,
  }) async {
    var body = '''
     mutation DeleteClasse {
    deleteClasse(key: "$key")
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
        var data = jsonData['data']['deleteClasse'];
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
