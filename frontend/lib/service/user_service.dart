import 'dart:convert';
import '../model/habilitation/role_enum.dart';
import '../model/habilitation/user_model.dart';
import 'package:http/http.dart' as http;
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/request_response.dart';
import 'request_header.dart';

class UserService {
  static Future<RequestResponse> assignRoleToPersonnel({
    required String personnelKey,
    required String roleKey,
    required String createBy,
  }) async {
    var body = '''
    mutation AttribuerRolePersonnel {
        attribuerRolePersonnel(personnelKey: "$personnelKey", roleKey:"$roleKey", createBy: "$createBy")    }
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
        var data = jsonData['data']['attribuerRolePersonnel'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
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

  static Future<UserModel> seConnecter({
    required String login,
    required String password,
  }) async {
    var body = '''
   mutation SeConnecter {
        seConnecter(login: "$login", password: "$password") {
            _key
            login
            password
            roles {
            _key
            roleAuthorization
            authorizeTime
            role {
                _key
                libelle
                permissions {
                    _key
                    libelle
                    alias
                    isChecked
                    module {
                        _key
                        name
                        alias
                    }
                }
            }
            authorizer {
                _key
                login
                password
                canLogin
                _token
                isTheFirstConnection
                dateEnregistrement
            }
            createBy {
                _key
                login
                password
                canLogin
                _token
                isTheFirstConnection
                dateEnregistrement
                personnel {
                    _key
                    nom
                    prenom
                    email
                    telephone
                    adresse
                    sexe
                    poste{_key, libelle}
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
                }
            }
            timeStamp
        }
            isTheFirstConnection
            canLogin
            _token
            dateEnregistrement
        }
    }
  ''';
    try {
      var response = await http.post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "",
        },
      ).timeout(
        const Duration(seconds: reqTimeout),
        onTimeout: () {
          throw RequestMessage.timeoutMessage;
        },
      ).catchError((error) {
        throw error;
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print(jsonData);
        var data = jsonData['data']['seConnecter'];
        return UserModel.fromJson(data);
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<UserModel> getUser({
    required String key,
  }) async {
    var body = '''
     query User {
    user(key: "$key") {
        _key
        login
        password
        canLogin
        _token
        dateEnregistrement
        roles {
            _key
            roleAuthorization
            authorizeTime
            role {
                _key
                libelle
                permissions {
                    _key
                    libelle
                    alias
                    isChecked
                    module {
                        _key
                        name
                        alias
                    }
                }
            }
            authorizer {
                _key
                login
                password
                canLogin
                _token
                isTheFirstConnection
                dateEnregistrement
            }
            createBy {
                _key
                login
                password
                canLogin
                _token
                isTheFirstConnection
                dateEnregistrement
                personnel {
                    _key
                    nom
                    prenom
                    email
                    telephone
                    adresse
                    sexe
                    poste{_key, libelle}
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
                }
            }
            timeStamp
        }
        personnel {
            _key
            nom
            prenom
            email
            telephone
            adresse
            sexe
            poste{_key, libelle}
            situationMatrimoniale
            commentaire
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
          throw RequestMessage.timeoutMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['user'];

        return UserModel.fromJson(data);
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<List<UserModel>> getUsers() async {
    var body = '''
     query Users {
         users {
        _key
         login
        password
        canLogin
        _token
          dateEnregistrement
        roles {
            _key
            roleAuthorization
            authorizeTime
            role {
                _key
                libelle
            }
            authorizer {
                _key
                 personnel {
                    _key
                    nom
                    prenom
                     telephone
                    adresse
                    poste{_key, libelle}
                }
              }
            createBy {
                _key
                personnel {
                _key
                nom
                prenom
                sexe
                 telephone
                adresse
                 poste{_key, libelle}
              }
            }
            timeStamp
        }
        isTheFirstConnection
        personnel {
            _key
            nom
            prenom
            email
            etat
            sexe
            telephone
            adresse
            poste{_key, libelle}
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
          throw RequestMessage.timeoutMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print(jsonData);
        var data = jsonData['data']['users'];
        List<UserModel> users = [];
        if (data != null) {
          for (var user in data) {
            users.add(UserModel.fromJson(user));
          }
        }
        return users;
      } else {
        throw jsonDecode(response.body)['errors'][0]['message'];
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<RequestResponse> seDeconnecter({
    required String userKey,
  }) async {
    var body = '''
    mutation seDeconnecter {
        seDeconnecter(key: "$userKey")
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
        var data = jsonData['data']['seDeconnecter'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
            status: PopupStatus.information,
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

  static Future<RequestResponse> handleRoleEditing({
    required String userRoleKey,
    required String authorizer,
    required RoleAuthorization roleAuthorization,
  }) async {
    var body = '''
    mutation HandleRoleEditing {
        handleRoleEditing(authorizer: "$authorizer", userRoleKey: "$userRoleKey", roleAuthorization: ${RoleAuthorization.roleAuthorizationToString(roleAuthorization)})
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
        var data = jsonData['data']['handleRoleEditing'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
            status: PopupStatus.information,
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

  static Future<RequestResponse> access({
    required String userKey,
    required bool canLogin,
  }) async {
    var body = '''
    mutation Access {
    access(key: "$userKey", canLogin: $canLogin)
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
        var data = jsonData['data']['access'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
            status: PopupStatus.information,
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

  static Future<RequestResponse> resetLoginParameter({
    required String userKey,
  }) async {
    var body = '''
    mutation ResetLoginParameter {
    resetLoginParameter(key: "$userKey")
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
        var data = jsonData['data']['resetLoginParameter'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            message: RequestMessage.successwithbugMessage,
            status: PopupStatus.information,
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

  static Future<dynamic> updateLoginData({
    required String userKey,
    String? login,
    required String ancienMotdepasse,
    required String password,
  }) async {
    var body = '''
    mutation UpdateLoginData {
    updateLoginData(key:"$userKey",''';

    if (login != null) body += 'login: "$login",';
    body += 'password: "$password"';
    body += 'oldPassword: "$ancienMotdepasse"';
    body += ''')
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
        var data = jsonData['data']['updateLoginData'];
        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
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
        message: error.toString(),
        status: PopupStatus.customError,
      );
    }
  }
}
