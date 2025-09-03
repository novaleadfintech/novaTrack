import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../global/constant/request_management_value.dart';
import '../model/client/client_model.dart';
import '../model/entreprise/banque.dart';
import '../model/flux_financier/debt_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../model/moyen_paiement_model.dart';
import '../model/request_response.dart';
import 'request_header.dart';

class DebtService {
  static Future<RequestResponse> createDebt({
    required String libelle,
    required ClientModel client,
    required double montant,
    DateTime? dateOperation,
    required String? referenceFacture,
    required String userId,
    PlatformFile? file,
  }) async {
    try {
      String body = '''
        mutation CreateDebt(\$pieceJustificative: Upload) {
            createDebt(
                libelle: "$libelle",
                montant: $montant,
                userId: "$userId",        
                clientId: "${client.id}",        
        ''';

      if (dateOperation != null) {
        body += 'dateOperation: ${dateOperation.millisecondsSinceEpoch},';
      }
      if (referenceFacture != null && referenceFacture.isNotEmpty) {
        body += 'referenceFacture: "$referenceFacture",';
      }
      body += 'pieceJustificative: \$pieceJustificative';
      body += '''
            )
        }
        ''';

      // Création de la requête multipart
      var multipartRequest = http.MultipartRequest('POST', Uri.parse(serverUrl))
        ..fields['operations'] = jsonEncode({
          "query": body,
          "variables": {
            "pieceJustificative": null,
          }
        });

      multipartRequest.fields['map'] = jsonEncode({
        "pieceJustificative": ["variables.pieceJustificative"]
      });

      if (file != null) {
        multipartRequest.files.add(
          http.MultipartFile.fromBytes(
            'pieceJustificative',
            file.bytes!,
            filename: file.name,
            contentType: MediaType("application", "octet-stream"),
          ),
        );
      }

      multipartRequest.headers.addAll({...getHeaders()});

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
        var data = jsonData['data']['createDebt'];
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

  static Future<RequestResponse> updateDebt({
    required String key,
    String? libelle,
    required double? montant,
    required DateTime? dateOperation,
    required MoyenPaiementModel? moyenPayement,
    required String? referenceTransaction,
    required BanqueModel? banque,
    required ClientModel? client,
    required PlatformFile? file,
  }) async {
    try {
      String body = '''
       mutation UpdateDebt (\$pieceJustificative: Upload){
        updateDebt(
            key: "$key",
        ''';
      if (dateOperation != null) {
        body += 'dateOperation: ${dateOperation.millisecondsSinceEpoch},';
      }
      if (libelle != null) {
        body += 'libelle: "$libelle",';
      }
      if (referenceTransaction != null) {
        body += 'referenceTransaction: "$referenceTransaction",';
      }
      if (montant != null) {
        body += 'montant: $montant,';
      }
      if (moyenPayement != null) {
        body += 'moyenPayement: ${moyenPayement.toJson()},';
      }
      if (banque != null) {
        body += 'bankId: "${banque.id}"';
      }
      if (client != null) {
        body += 'clientId: "${client.id}"';
      }
      body += 'pieceJustificative: \$pieceJustificative';

      body += '''
            )
        }
        ''';
      bool isFileModified = file != null && file.bytes != null;
      bool isFileUnchanged = file != null && file.bytes == null;

      final variables = {
        "pieceJustificative": isFileUnchanged ? "__unchanged__" : null
      };
      // Création de la requête multipart
      http.MultipartRequest multipartRequest = http.MultipartRequest(
          'POST', Uri.parse(serverUrl))
        ..fields['operations'] =
            jsonEncode(<String, Object>{"query": body, "variables": variables});

      multipartRequest.fields['map'] = jsonEncode(<String, List<String>>{
        "pieceJustificative": ["variables.pieceJustificative"]
      });

      if (isFileModified) {
        multipartRequest.files.add(
          http.MultipartFile.fromBytes(
            'pieceJustificative',
            file.bytes!,
            filename: file.name,
            contentType: MediaType("application", "octet-stream"),
          ),
        );
      } else {
        multipartRequest.fields['map'] = json.encode({});
      }

      multipartRequest.headers.addAll({...getHeaders()});

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
        var data = jsonData['data']['updateDebt'];
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

  static Future<RequestResponse> deleteDebt({
    required String key,
  }) async {
    try {
      String body = '''
       mutation DeleteDebt {
          deleteDebt(key: "$key")
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
        onTimeout: () {
          return RequestResponse.response(
            message: RequestMessage.timeoutMessage,
            status: PopupStatus.customError,
          );
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var deleteDebt = jsonData['data']['deleteDebt'];
        if ((deleteDebt == RequestMessage.success)) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
            status: PopupStatus.serverError,
          );
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<List<DebtModel>> getDebts() async {
    var body = '''
               query Debts {
                  debts {
                      _id
                      libelle
                      montant
                      referenceFacture
                      status
                      dateOperation
                      dateEnregistrement
                      pieceJustificative
                      client {
                          _id
                          ... on ClientMoral {
                              _id
                              raisonSociale
                          }
                          ... on ClientPhysique {
                              _id
                              nom
                              prenom
                          }
                      }
                      user {
                          _id
                          personnel {
                              _id
                              nom
                              prenom
                              email
                              telephone
                          }
                      }
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
        .catchError((onError) {
      throw RequestMessage.failgettingDataMessage;
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw RequestMessage.timeoutMessage;
      },
    );
    List<DebtModel> debts = [];
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['debts'];
      print(data);
      if (data != null) {
        for (var debt in data) {
          debts.add(DebtModel.fromJson(debt));
        }
      } else {
        throw RequestMessage.failgettingDataMessage;
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return debts;
  }
}
