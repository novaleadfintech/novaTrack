import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/pays_model.dart';
import '../model/entreprise/entreprise.dart';
import 'package:http/http.dart' as http;

import '../model/request_response.dart';
import 'request_header.dart';

class EntrepriseService {
  static Future<StrictEntreprise> getEntrepriseInformation() async {
    const String query = '''
    query Entreprise {
    entreprise {
        _id
        logo
        adresse
        email
        raisonSociale
        ville
        telephone
        tamponSignature
        nomDG
        pays {
            _id
            name
            code
        }
    }
}
  ''';

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        body: jsonEncode({'query': query}),
headers: getHeaders(),
      ).timeout(const Duration(seconds: reqTimeout));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final data = jsonData['data']['entreprise'];
        if (data != null) {
          try {
            return StrictEntreprise.fromJson(data);
          } catch (err) {
             

            throw "Certaines données de l'entreprise ne sont pas à jour. Veuillez contacter l'administrateur";
          }
        } else {
          throw "Les données de l'entreprise ne sont pas à jour. Veuillez contacter l'administrateur";
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<Entreprise> getEntrepriseInformationForUpdate() async {
    const String query = '''
    query Entreprise {
    entreprise {
        _id
        logo
        adresse
        email
        ville
        raisonSociale
        telephone
        tamponSignature
        nomDG
        pays {
            _id
            name
            initiauxPays
            code
            phoneNumber
            tauxTVA
        }
    }
}
  ''';

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        body: jsonEncode({'query': query}),
   headers: getHeaders(),
      ).timeout(const Duration(seconds: reqTimeout));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final data = jsonData['data']['entreprise'];
        if (data != null) {
          return Entreprise.fromJson(data);
        } else {
          return Entreprise(
            id: null,
            raisonSociale: null,
            logo: null,
            ville: null,
            adresse: null,
            email: null,
            telephone: null,
            tamponSignature: null,
            nomDG: null,
            pays: null,
          );
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<RequestResponse> updateEntreprise({
    String? key,
    String? nomDG,
    String? ville,
    String? email,
    int? telephone,
    String? raisonSociale,
    PaysModel? pays,
    String? adresse,
    PlatformFile? logo,
    PlatformFile? tamponSignature,
  }) async {
    try {
      String body = '''
    mutation UpdateEntreprise (\$logo: Upload, \$tamponSignature: Upload){
      updateEntreprise(
    ''';
      if (key != null) {
        body += 'key: "$key",';
      }
      if (nomDG != null) {
        body += 'nomDG: "$nomDG",';
      }
      if (email != null) {
        body += 'email: "$email",';
      }
      if (telephone != null) {
        body += 'telephone: $telephone,';
      }
      if (adresse != null) {
        body += 'adresse: "$adresse",';
      }
      if (ville != null) {
        body += 'ville: "$ville",';
      }
      if (raisonSociale != null) {
        body += 'raisonSociale: "$raisonSociale",';
      }
      if (pays != null) {
        body += 'pays: "${pays.id!}",';
      }

      body += 'logo: \$logo,';
      body += 'tamponSignature: \$tamponSignature';

      body += '''
      )
    }
    ''';

      http.MultipartRequest multipartRequest =
          http.MultipartRequest('POST', Uri.parse(serverUrl))
            ..fields['operations'] = jsonEncode({
              "query": body,
              "variables": {
                "logo": null,
                "tamponSignature": null,
              }
            });

      multipartRequest.fields['map'] = jsonEncode({
        "logo": ["variables.logo"],
        "tamponSignature": ["variables.tamponSignature"]
      });

      if (logo != null) {
        multipartRequest.files.add(
          http.MultipartFile.fromBytes(
            'logo',
            logo.bytes!,
            filename: logo.name,
            contentType: MediaType("application", "octet-stream"),
          ),
        );
      }

      // Ajouter le fichier tamponSignature si présent
      if (tamponSignature != null) {
        multipartRequest.files.add(
          http.MultipartFile.fromBytes(
            'tamponSignature',
            tamponSignature.bytes!,
            filename: tamponSignature.name,
            contentType: MediaType("application", "octet-stream"),
          ),
        );
      }

      multipartRequest.headers.addAll({
       ...getHeaders()
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
        var data = jsonData['data']['updateEntreprise'];
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
        message: error.toString(),
        status: PopupStatus.serverError,
      );
    }
  }
}
