import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/model/entreprise/type_canaux_paiement.dart';
import 'package:frontend/service/request_header.dart';
import '../global/constant/request_management_value.dart';
import '../model/entreprise/banque.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../model/pays_model.dart';
import '../model/request_response.dart';

class BanqueService {
  static Future<RequestResponse> createBanque({
    required String name,
    required PaysModel country,
    required String codeBanque,
    required String numCompte,
    required String codeBIC,
    required CanauxPaiement type,
    // required double somme,
    PlatformFile? file,
    required String codeGuichet,
    required String cleRIB,
  }) async {
    try {
      // soldeReel: $somme,

      String body = '''
        mutation CreateBanque(\$logo: Upload) {
            createBanque(
                name: "$name",
                codeGuichet:"$codeGuichet",
                codeBanque: "$codeBanque",
                cleRIB: "$cleRIB",
                type: ${canauxPaiementToString(type)}
                codeBIC: "$cleRIB",
                numCompte: "$numCompte",
                country: ${country.toJson()},''';
      body += 'logo: \$logo';
      body += '''
            )
        }
        ''';

      var multipartRequest = http.MultipartRequest('POST', Uri.parse(serverUrl))
        ..fields['operations'] = jsonEncode({
          "query": body,
          "variables": {
            "logo": null,
          }
        });

      multipartRequest.fields['map'] = jsonEncode({
        "logo": ["variables.logo"]
      });
       if (file != null && file.bytes != null) {
        multipartRequest.files.add(
          http.MultipartFile.fromBytes(
            'logo',
            file.bytes!,
            filename: file.name,
            contentType: MediaType(
              "application",
              "octet-stream",
            ),
          ),
        );
      }

      multipartRequest.headers.addAll({
        ...getHeaders(),
      });

      var streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          return RequestResponse.response(
            status: PopupStatus.customError,
            message: RequestMessage.timeoutMessage,
          );
        },
      );

      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createBanque'];
        if (data != null) {
          return RequestResponse(
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            status: PopupStatus.serverError,
          );
        }
      } else {
        return RequestResponse(
          message: jsonDecode(response.body)['errors'][0]['message'],
          status: PopupStatus.serverError,
        );
      }
    } catch (error) {
      return RequestResponse(
        status: PopupStatus.serverError,
        message: RequestMessage.onCatchErrorMessage,
      );
    }
  }

  static Future<RequestResponse> resetBanqueAmount({
    required String key,
    required double somme,
  }) async {
    var body = '''
      mutation ResetBanqueAmount {
        resetBanqueAmount(key: "$key", soldeReel: $somme)
      }
  ''';
    try {
      var response = await http
          .post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      )
          .timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          throw RequestMessage.timeoutMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['resetBanqueAmount'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: jsonDecode(response.body)['errors'][0]['message'],
            status: PopupStatus.serverError,
          );
        }
      } else {
        return RequestResponse(
          message: jsonDecode(response.body)['errors'][0]['message'],
          status: PopupStatus.serverError,
        );
      }
    } catch (error) {
      return RequestResponse(
        message: RequestMessage.onCatchErrorMessage,
        status: PopupStatus.serverError,
      );
    }
  }

  static Future<RequestResponse> updateBanque({
    required String key,
    required String? name,
    required String? codeBanque,
    required PaysModel? country,
    required PlatformFile? file,
    required CanauxPaiement? type,
    required String? numCompte,
    required String? codeBIC,
    required String? codeGuichet,
    required String? cleRIB,
  }) async {
    try {
      String body = '''
       mutation UpdateBanque (\$logo: Upload){
        updateBanque(
            key: "$key",
        ''';

      if (name != null) {
        body += ' name: "$name",';
      }

      if (codeBanque != null) {
        body += ' codeBanque: "$codeBanque",';
      }

      if (type != null) {
        body += 'type: ${canauxPaiementToString(type)},';
      }
      if (country != null) {
        body += 'country: ${country.toJson()},';
      }
      if (codeGuichet != null) {
        body += 'codeGuichet: "$codeGuichet",';
      }
      if (codeBIC != null) {
        body += 'codeBIC: "$codeBIC",';
      }
      if (numCompte != null) {
        body += 'numCompte: "$numCompte",';
      }
      if (cleRIB != null) {
        body += 'cleRIB: "$cleRIB",';
      }

      body += 'logo: \$logo';

      body += '''
            )
        }
        ''';

      // Détection des cas
      bool isFileModified = file != null && file.bytes != null;
      bool isFileUnchanged = file != null && file.bytes == null;

// Définir les variables à envoyer
      final variables = {"logo": isFileUnchanged ? "__unchanged__" : null};

      var multipartRequest = http.MultipartRequest('POST', Uri.parse(serverUrl))
        ..fields['operations'] = jsonEncode({
          "query": body,
          "variables": variables,
        });

      if (isFileModified) {
        multipartRequest.fields['map'] = json.encode({
          "0": ["variables.logo"]
        });

        multipartRequest.files.add(
          http.MultipartFile.fromBytes(
            '0',
            file.bytes!,
            filename: file.name,
            contentType: MediaType("application", "octet-stream"),
          ),
        );
      } else {
        multipartRequest.fields['map'] = json.encode({});
      }

// Ajouter les headers
      multipartRequest.headers.addAll({
        ...getHeaders(),
      });

      var streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          return RequestResponse.response(
            status: PopupStatus.customError,
            message: RequestMessage.timeoutMessage,
          );
        },
      );

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['updateBanque'];
        if (data != null) {
          return RequestResponse(
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            status: PopupStatus.serverError,
          );
        }
      } else {
        return RequestResponse(
          message: jsonDecode(response.body)['errors'][0]['message'],
          status: PopupStatus.serverError,
        );
      }
    } catch (error) {
      return RequestResponse(
        status: PopupStatus.serverError,
        message: "Une erreur s'est produite : $error",
      );
    }
  }

  static Future<List<BanqueModel>> getAllBanques(
      {int? perPage, int? skip}) async {
    List<BanqueModel> banques = [];
    var body = '''
               query Banques {
                  banques (perPage: $perPage, skip: $skip){
                      _id
                      name
                      codeGuichet
                      codeBanque
                      cleRIB
                      codeBIC
                      numCompte
                      type
                      logo
                      country {
                        _id
                        name
                        code
                      }
                      soldeReel
                      soldeTheorique
                      }
              }
            ''';
    var response = await http
        .post(
      Uri.parse(serverUrl),
      body: json.encode({
        'query': body,
      }),
      headers: getHeaders(),
    )
        .timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.timeoutMessage;
      },
    );
    try {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['banques'];
        if (data != null) {
          for (var banque in data) {
            banques.add(BanqueModel.fromJson(banque));
          }
        } else {
          throw RequestMessage.successwithbugMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
      return banques;
    } catch (e) {
      throw e.toString();
    }
  }
}
