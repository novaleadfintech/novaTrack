import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import 'request_header.dart';

class PayementService {
  static Future<RequestResponse> ajouterPayement({
    required String factureId,
    required double montant,
    required DateTime? dateOperation,
    required MoyenPaiementModel moyenPayement,
    required String referenceTransaction,
    required String userId,
    required String clientId,
    required BanqueModel bank,
    required PlatformFile? file,
  }) async {
    try {
      String body = '''
      mutation AjouterPayement(\$pieceJustificative: Upload) {
          ajouterPayement(
              key: "$factureId",
              montant: $montant,
              moyenPayement: ${moyenPayement.toJson()},
              referenceTransaction: "$referenceTransaction",
              userId: "$userId",
              clientId: "$clientId",
              
      ''';

      body += 'bankId: "${bank.id}"';
      

      if (dateOperation != null) {
        body += 'dateOperation: ${dateOperation.millisecondsSinceEpoch},';
      }

      body += 'pieceJustificative: \$pieceJustificative';

      body += '''
          )
      }
      ''';

      var multipartRequest = http.MultipartRequest('POST', Uri.parse(serverUrl))
        ..fields['operations'] = jsonEncode({
          "query": body,
          "variables": {
            "pieceJustificative": file != null ? null : null,
          }
        });

      multipartRequest.fields['map'] = jsonEncode({
        "preuve": ["variables.pieceJustificative"]
      });

      if (file != null && file.bytes != null) {
        multipartRequest.files.add(
          http.MultipartFile.fromBytes(
            'preuve',
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
        var data = jsonData['data']['ajouterPayement'];
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
        status: PopupStatus.customError,
        message: "Une erreur s'est produite : $error",
      );
    }
  }
}
