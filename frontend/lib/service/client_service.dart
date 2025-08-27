import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/model/client/responsable_model.dart';
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/client/client_model.dart';
import '../model/client/enum_client.dart';
import '../model/pays_model.dart';
import '../model/common_type.dart';
import '../model/request_response.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'request_header.dart';

class ClientService {
  static Future<List<ClientModel>> getUnarchivedAllPartenaire() async {
    var body = '''
      query Clients {
          clients(etat: unarchived) {
          _id
          email
          telephone
          nature
          adresse
          pays{
            _id
            name
            code
            initiauxPays
            tauxTVA
            phoneNumber
          }
          etat
          dateEnregistrement
          fullCount
          ... on ClientMoral {
              _id
              raisonSociale
              email
              logo
              telephone
              pays{
                _id
                name
                code
                tauxTVA
                phoneNumber
              }
              adresse
              etat
              responsable {
                prenom
                nom
                email
                telephone
                civilite
                sexe
                poste
            }
              dateEnregistrement
              fullCount
              categorie {
                  _id
                  libelle
              }
          }
          ... on ClientPhysique {
              _id
              nom
              prenom
              sexe
              pays{
              _id
              name
              code
              initiauxPays
              tauxTVA
              phoneNumber
              }
              email
              telephone
              adresse
              etat
              dateEnregistrement
              fullCount
          }
      }
      }
    ''';

    List<ClientModel> clients = [];
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
          throw RequestMessage.failgettingDataMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['clients'];
        if (data != null) {
          for (var client in data) {
            clients.add(ClientModel.fromJson(client));
          }
        } else {
          throw RequestMessage.successwithbugMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
    return clients;
  }

  static Future<List<ClientModel>> getUnarchivedClientsAndProspects() async {
    var body = '''
      query Clients {
          unarchivedClientsAndProspects {
          _id
          email
          telephone
          nature
          adresse
          pays{
            _id
            name
            code
            initiauxPays
            tauxTVA
            phoneNumber
          }
          etat
          dateEnregistrement
          fullCount
          ... on ClientMoral {
              _id
              raisonSociale
              email
              logo
              telephone
              pays{
                _id
                name
                code
                tauxTVA
                phoneNumber
              }
              adresse
              etat
              responsable {
                prenom
                nom
                email
                telephone
                civilite
                sexe
                poste
            }
              dateEnregistrement
              fullCount
              categorie {
                  _id
                  libelle
              }
          }
          ... on ClientPhysique {
              _id
              nom
              prenom
              sexe
              pays{
              _id
              name
              code
              initiauxPays
              tauxTVA
              phoneNumber
              }
              email
              telephone
              adresse
              etat
              dateEnregistrement
              fullCount
          }
      }
      }
    ''';

    List<ClientModel> clients = [];
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
          throw RequestMessage.failgettingDataMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['unarchivedClientsAndProspects'];
        if (data != null) {
          for (var client in data) {
            clients.add(ClientModel.fromJson(client));
          }
        } else {
          throw RequestMessage.successwithbugMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw RequestMessage.failgettingDataMessage;
    }
    return clients;
  }

  static Future<List<ClientModel>> getUnarchivedClients() async {
    var body = '''
      query Clients {
          clients(etat: unarchived, nature: ${natureClientToString(NatureClient.client)}) {
          _id
          email
          telephone
          nature
          adresse
          pays{
            _id
            name
            code
            initiauxPays
            tauxTVA
            phoneNumber
          }
          etat
          dateEnregistrement
          fullCount
          ... on ClientMoral {
              _id
              raisonSociale
              email
              logo
              telephone
              pays{
                _id
                name
                code
                initiauxPays
                tauxTVA
                phoneNumber
              }
              adresse
              etat
              responsable {
                prenom
                nom
                email
                telephone
                civilite
                sexe
                poste
            }
              dateEnregistrement
              fullCount
              categorie {
                  _id
                  libelle
              }
          }
          ... on ClientPhysique {
              _id
              nom
              prenom
              sexe
              pays{
              _id
              name
              initiauxPays
              code
              tauxTVA
              phoneNumber
              }
              email
              telephone
              adresse
              etat
              dateEnregistrement
              fullCount
          }
      }
      }
    ''';

    List<ClientModel> clients = [];
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
          throw RequestMessage.failgettingDataMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['clients'];

        if (data != null) {
          for (var client in data) {
            clients.add(ClientModel.fromJson(client));
          }
          return clients;
        } else {
          throw RequestMessage.successwithbugMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<List<ClientModel>> getUnarchivedFournisseur() async {
    var body = '''
      query Clients {
          clients(etat: unarchived, nature: ${natureClientToString(NatureClient.fournisseur)}) {
          _id
          email
          telephone
          nature
          adresse
          pays{
            _id
            name
            code
            initiauxPays
            tauxTVA
            phoneNumber
          }
          etat
          dateEnregistrement
          fullCount
          ... on ClientMoral {
              _id
              raisonSociale
              email
              logo
              telephone
              pays{
                _id
                name
                code
                initiauxPays
                tauxTVA
                phoneNumber
              }
              adresse
              etat
              responsable {
                prenom
                nom
                email
                telephone
                civilite
                sexe
                poste
            }
              dateEnregistrement
              fullCount
              categorie {
                  _id
                  libelle
              }
          }
          ... on ClientPhysique {
              _id
              nom
              prenom
              sexe
              pays{
              _id
              name
              initiauxPays
              code
              tauxTVA
              phoneNumber
              }
              email
              telephone
              adresse
              etat
              dateEnregistrement
              fullCount
          }
      }
      }
    ''';

    List<ClientModel> clients = [];
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
          throw RequestMessage.failgettingDataMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['clients'];

        if (data != null) {
          for (var client in data) {
            clients.add(ClientModel.fromJson(client));
          }
          return clients;
        } else {
          throw RequestMessage.successwithbugMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw RequestMessage.failgettingDataMessage;
    }
  }

  // Méthode pour obtenir les clients archivés
  static Future<List<ClientModel>> getArchivedClientsAndProspect() async {
    var body = '''
     query Clients {
          clients(etat: archived) {
          _id
          email
          telephone
          nature
          adresse
          pays{
            _id
            name
            code
            initiauxPays
            tauxTVA
            phoneNumber
          }
          etat
          dateEnregistrement
          fullCount
          ... on ClientMoral {
              _id
              raisonSociale
              email
              telephone
              logo
              pays{
              _id
              name
              code
              initiauxPays
              tauxTVA
              phoneNumber
              }
              adresse
              etat
              responsable {
                prenom
                nom
                email
                telephone
                civilite
                sexe
                poste
            }
              dateEnregistrement
              fullCount
              categorie {
                  _id
                  libelle
              }
          }
          ... on ClientPhysique {
              _id
              nom
              prenom
              sexe
              pays{
              _id
              name
              code
              tauxTVA
              initiauxPays
              phoneNumber
              }
              email
              telephone
              adresse
              etat
              dateEnregistrement
              fullCount
          }
      }
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
          throw RequestMessage.failgettingDataMessage;
        },
      );
      List<ClientModel> clients = [];

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['clients'];

        if (data != null) {
          for (var client in data) {
            clients.add(ClientModel.fromJson(client));
          }
          return clients;
        } else {
          throw RequestMessage.failgettingDataMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      rethrow;
    }
  }

  static Future<ClientModel> getClient({required String key}) async {
    var body = '''
      query Client {
          client(key: "$key") {
              _id
              email
              telephone
              adresse
              nature
              etat
              dateEnregistrement
              fullCount
              pays {
                  _id
          name
          code
          initiauxPays
          tauxTVA
          phoneNumber
              }
              ... on ClientMoral {
                  _id
                  raisonSociale
                  logo
                  email
                  telephone
                  adresse
                  etat
                  responsable {
                _id
                prenom
                nom
                email
                telephone
                civilite
                sexe
                poste
            }
                  dateEnregistrement
                  fullCount
                  pays {
                      _id
          name
          code
          initiauxPays
          tauxTVA
          phoneNumber
                  }
                  categorie {
                      _id
                      libelle
                  }
              }
              ... on ClientPhysique {
                  _id
                  nom
                  prenom
                  sexe
                  email
                  telephone
                  adresse
                  etat
                  dateEnregistrement
                  fullCount
                  pays {
                     _id
          name
          code
          initiauxPays
          tauxTVA
          phoneNumber
                  }
              }
          }
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
          throw RequestMessage.failgettingDataMessage;
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['client'];
        if (data != null) {
          return ClientModel.fromJson(data);
        } else {
          throw RequestMessage.successwithbugMessage;
        }
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      rethrow;
    }
  }

  static Future<RequestResponse> createMoralClient({
    required String raisonSociale,
    required ResponsableModel? responsable,
    required String categorieId,
    required NatureClient nature,
    PlatformFile? file,
    required String? email,
    required int? telephone,
    required String? adresse,
    required PaysModel pays,
  }) async {
    try {
      String body = '''
      mutation CreateClientMoral(\$logo: Upload) {
        createClientMoral(
          raisonSociale: "$raisonSociale",
          nature: ${natureClientToString(nature)},
          categorieId: "$categorieId",
          pays: {_id: "${pays.id}", name: "${pays.name}", code: ${pays.code}, phoneNumber: ${pays.phoneNumber}, tauxTVA: ${pays.tauxTVA}, initiauxPays: ${pays.initiauxPays.toList()}},
          logo: \$logo,''';
      if (responsable != null) {
        body +=
            'responsable: {prenom: "${responsable.prenom}", nom: "${responsable.nom}", sexe: ${sexeToString(responsable.sexe!)}, civilite: ${civiliteToString(responsable.civilite!)}, email: "${responsable.email}", telephone: ${responsable.telephone}, poste: "${responsable.poste}"},';
      }
      if (email != null && email.isNotEmpty) {
        body += 'email: "$email",';
      }
      if (adresse != null && adresse.isNotEmpty) {
        body += 'adresse: "$adresse",';
      }
      if (telephone != null) {
        body += 'telephone: $telephone,';
      }
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
        })
        ..fields['map'] = jsonEncode({
          "logo": ["variables.logo"]
        })
        ..headers.addAll({
          ...getHeaders(),
        });

      if (file != null) {
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

      var streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          return RequestResponse.response(
            status: PopupStatus.customError,
            message: "Requête expirée",
          );
        },
      );

      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createClientMoral'];
        if (data != null) {
          return RequestResponse(
            status: PopupStatus.success,
            message: "Client créé avec succès",
          );
        } else {
          return RequestResponse(
            message: "Erreur lors de la création du client",
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
        message: "Erreur lors de la requête : $error",
        status: PopupStatus.serverError,
      );
    }
  }

  static Future<RequestResponse> createPhysiqueClient({
    required String nom,
    required String prenom,
    required Sexe sexe,
    required NatureClient nature,
    required String? email,
    required int? telephone,
    required String? adresse,
    required PaysModel pays,
  }) async {
    var body = '''
      mutation CreateClientPhysique {
        createClientPhysique(
            nom: "$nom"
            prenom: "$prenom"
            sexe: ${sexeToString(sexe)}
           nature: ${natureClientToString(nature)},
           pays: {_id: "${pays.id}", name: "${pays.name}", code: ${pays.code}, phoneNumber: ${pays.phoneNumber}, tauxTVA: ${pays.tauxTVA}, initiauxPays: ${pays.initiauxPays.toList()}},
             ''';
    if (email != null && email.isNotEmpty) {
      body += 'email: "$email",';
    }
    if (adresse != null && adresse.isNotEmpty) {
      body += 'adresse: "$adresse",';
    }
    if (telephone != null) {
      body += 'telephone: $telephone,';
    }
    body += '''
        )
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
          return RequestResponse.response(status: PopupStatus.customError);
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['createClientPhysique'];
        if (data != null) {
          return RequestResponse(
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
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

  static Future<RequestResponse> updateClientMoral({
    String? id,
    String? raisonSociale,
    ResponsableModel? responsable,
    String? categorieId,
    PlatformFile? file,
    NatureClient? nature,
    String? email,
    int? telephone,
    String? adresse,
    PaysModel? pays,
  }) async {
    try {
      String body = '''
    mutation UpdateClientMoral(\$logo: Upload) {
      updateClientMoral(
        key: "$id",
    ''';

      if (raisonSociale != null && raisonSociale.isNotEmpty) {
        body += 'raisonSociale: "$raisonSociale",';
      }
      if (responsable != null) {
        body +=
            'responsable: {prenom: "${responsable.prenom}", nom: "${responsable.nom}", sexe: ${sexeToString(responsable.sexe!)}, civilite: ${civiliteToString(responsable.civilite!)}, email: "${responsable.email}", telephone: ${responsable.telephone}, poste: "${responsable.poste}"},';
      }
      if (categorieId != null) {
        body += 'categorieId: "$categorieId",';
      }
      if (email != null) {
        body += 'email: "$email",';
      }
      if (nature != null) {
        body += 'nature: ${natureClientToString(nature)},';
      }
      if (adresse != null) {
        body += 'adresse: "$adresse",';
      }
      if (pays != null) {
        body +=
            'pays: {_id: "${pays.id}", name: "${pays.name}", code: ${pays.code}, phoneNumber: ${pays.phoneNumber}, tauxTVA: ${pays.tauxTVA}, initiauxPays: ${pays.initiauxPays.toList()}},';
      }
      if (telephone != null) {
        body += 'telephone: $telephone,';
      }

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
            contentType: MediaType("application", "octet-stream"),
          ),
        );
      }

      // multipartRequest.headers.addAll({
      //   "Authorization": "",
      // });
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
        var data = jsonData['data']['updateClientMoral'];
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
        message: "Une erreur s'est produite : ${error.toString()}",
      );
    }
  }

  static Future<RequestResponse> updatePhysiqueClient({
    required String clientId,
    String? nom,
    String? prenom,
    Sexe? sexe,
    String? email,
    NatureClient? nature,
    int? telephone,
    String? adresse,
    PaysModel? pays,
  }) async {
    var body = '''
      mutation UpdateClientPhysique {
        updateClientPhysique(
          key: "$clientId",
    ''';

    if (nom != null) {
      body += 'nom: "$nom",';
    }
    if (prenom != null) {
      body += 'prenom: "$prenom",';
    }
    if (sexe != null) {
      body += 'sexe: ${sexeToString(sexe)},';
    }

    if (email != null) {
      body += 'email: "$email",';
    }
    if (adresse != null) {
      body += 'adresse: "$adresse",';
    }
    if (pays != null) {
      body +=
          'pays: {_id: "${pays.id}", name: "${pays.name}", code: ${pays.code}, phoneNumber: ${pays.phoneNumber},initiauxPays: ${pays.initiauxPays.toList()}, tauxTVA: ${pays.tauxTVA}},';
    }
    if (telephone != null) {
      body += 'telephone: $telephone,';
    }

    if (nature != null) {
      body += 'nature: ${natureClientToString(nature)},';
    }

    body += '''
      ) }
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
          return RequestResponse.response(
            message: RequestMessage.timeoutMessage,
            status: PopupStatus.information,
          );
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['updateClientPhysique'];
        if (data != null) {
          return RequestResponse(
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
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
        status: PopupStatus.customError,
      );
    }
  }

  static Future<RequestResponse> archiveClient({
    required String clientId,
  }) async {
    var body = '''
      mutation ArchivedClient {
        archivedClient(key: "$clientId")
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
          return RequestResponse.response(
            message: RequestMessage.timeoutMessage,
            status: PopupStatus.information,
          );
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['archivedClient'];
        if (data != null) {
          return RequestResponse(
            message: "Client archivé avec succès",
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
            status: PopupStatus.customError,
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
        status: PopupStatus.customError,
      );
    }
  }

  static Future<RequestResponse> unarchiveClient({
    required String clientId,
  }) async {
    var body = '''
      mutation UnarchivedClient {
        unarchivedClient(key: "$clientId")
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
          return RequestResponse.response(
            message: RequestMessage.timeoutMessage,
            status: PopupStatus.information,
          );
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['unarchivedClient'];
        if (data != null) {
          return RequestResponse(
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
            status: PopupStatus.customError,
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
        status: PopupStatus.customError,
      );
    }
  }
}
