import 'dart:convert';
import '../model/facturation/frais_divers_model.dart';
import 'package:http/http.dart' as http;
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/request_response.dart';
import 'request_header.dart';

class LigneProformaService {
  static Future<RequestResponse> createLigneProforma({
    required String proformaId,
    required String serviceId,
    required String designation,
    required int? dureeLivraison,
    required String unit,
    double? prixSupplementaire,
    List<FraisDiversModel>? fraisDivers,
    int? quantite,
    double? remise,
  }) async {
    // Initialisation de la requête
    String body = '''
  mutation AjouterLigneProforma {
    ajouterLigneProforma(
      proformaId: "$proformaId",
      serviceId: "$serviceId",
      unit: "$unit",
      designation: "$designation",
  ''';
  
    if (dureeLivraison != null) {
      body += 'dureeLivraison: $dureeLivraison,';
    }
    // Si les frais divers sont définis, on les ajoute à la requête
    if (fraisDivers != null && fraisDivers.isNotEmpty) {
      body += 'fraisDivers: [';

      // Conversion de chaque fraisDivers en JSON
      for (var frais in fraisDivers) {
        body +=
            '{libelle:"${frais.libelle}", montant: ${frais.montant}, tva: ${frais.tva}}';
      }

      body += '],';
    }
    if (quantite != null) {
      body += 'quantite: $quantite,';
    }
    if (prixSupplementaire != null) {
      body += 'prixSupplementaire: $prixSupplementaire,';
    }

    if (remise != null) {
      body += 'remise: $remise,';
    }

    body += '''
    )
  }
  ''';

    try {
      var response = await http.post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      ).timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          throw RequestMessage.timeoutMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['ajouterLigneProforma'];
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

  static Future<RequestResponse> retirerLigneProforma({
    required String ligneProformaId,
  }) async {
    // Initialisation de la requête
    String body = '''
      mutation DeleteLigneProforma {
        deleteLigneProforma(key:"$ligneProformaId")
      }
  ''';

    try {
      var response = await http.post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      ).timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          throw RequestMessage.timeoutMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['deleteLigneProforma'];
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

  static Future<RequestResponse> updateLigneProforma({
    required String ligneProformaId,
    String? serviceId,
    String? designation,
    int? dureeLivraison,
    double? prixSupplementaire,
    String? unit,
    List<FraisDiversModel>? fraisDivers,
    int? quantite,
    double? remise,
  }) async {
    String body = '''
  mutation UpdateLigneProforma {
    updateLigneProforma(
      key: "$ligneProformaId",
  ''';

    if (fraisDivers != null && fraisDivers.isNotEmpty) {
      body += 'fraisDivers: [';

      for (var frais in fraisDivers) {
        body +=
            '{libelle: "${frais.libelle}", montant: ${frais.montant}, tva: ${frais.tva}}';
      }

      body += '],';
    }
    if (quantite != null && quantite != 0) {
      body += 'quantite: $quantite,';
    }

    if (prixSupplementaire != null) {
      body += 'prixSupplementaire: $prixSupplementaire,';
    }

    if (unit != null) {
      body += 'unit: "$unit"';
    }
    if (designation != null) {
      body += 'designation: "$designation",';
    }
    if (serviceId != null) {
      body += 'serviceId: "$serviceId",';
    }
    if (dureeLivraison != null && dureeLivraison != 0) {
      body += 'dureeLivraison: $dureeLivraison,';
    }
    if (remise != null) {
      body += 'remise: $remise,';
    }

    body += '''
    )
  }
  ''';

    try {
      var response = await http.post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      ).timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          throw RequestMessage.timeoutMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['updateLigneProforma'];
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
