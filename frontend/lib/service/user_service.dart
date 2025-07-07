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
    required String personnelId,
    required String roleId,
    required String createBy,
  }) async {
    var body = '''
    mutation AttribuerRolePersonnel {
        attribuerRolePersonnel(personnelId: "$personnelId", roleId:"$roleId", createBy: "$createBy")    }
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
            _id
            login
            password
            roles {
            _id
            roleAuthorization
            authorizeTime
            role {
                _id
                libelle
                permissions {
                    _id
                    libelle
                    alias
                    isChecked
                    module {
                        _id
                        name
                        alias
                    }
                }
            }
            authorizer {
                _id
                login
                password
                canLogin
                _token
                isTheFirstConnection
                dateEnregistrement
            }
            createBy {
                _id
                login
                password
                canLogin
                _token
                isTheFirstConnection
                dateEnregistrement
                personnel {
                    _id
                    nom
                    prenom
                    email
                    telephone
                    adresse
                    sexe
                    poste
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
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
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
        _id
        login
        password
        canLogin
        _token
        dateEnregistrement
        roles {
            _id
            roleAuthorization
            authorizeTime
            role {
                _id
                libelle
                permissions {
                    _id
                    libelle
                    alias
                    isChecked
                    module {
                        _id
                        name
                        alias
                    }
                }
            }
            authorizer {
                _id
                login
                password
                canLogin
                _token
                isTheFirstConnection
                dateEnregistrement
            }
            createBy {
                _id
                login
                password
                canLogin
                _token
                isTheFirstConnection
                dateEnregistrement
                personnel {
                    _id
                    nom
                    prenom
                    email
                    telephone
                    adresse
                    sexe
                    poste
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
            _id
            nom
            prenom
            email
            telephone
            adresse
            sexe
            poste
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
        _id
         login
        password
        canLogin
        _token
          dateEnregistrement
        roles {
            _id
            roleAuthorization
            authorizeTime
            role {
                _id
                libelle
            }
            authorizer {
                _id
                 personnel {
                    _id
                    nom
                    prenom
                     telephone
                    adresse
                    poste
                }
              }
            createBy {
                _id
                personnel {
                _id
                nom
                prenom
                sexe
                 telephone
                adresse
                 poste
              }
            }
            timeStamp
        }
        isTheFirstConnection
        personnel {
            _id
            nom
            prenom
            email
            etat
            sexe
            telephone
            adresse
            poste
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
    required String userId,
  }) async {
    var body = '''
    mutation seDeconnecter {
        seDeconnecter(key: "$userId")
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
    required String userRoleId,
    required String authorizer,
    required RoleAuthorization roleAuthorization,
  }) async {
    var body = '''
    mutation HandleRoleEditing {
        handleRoleEditing(authorizer: "$authorizer", userRoleId: "$userRoleId", roleAuthorization: ${RoleAuthorization.roleAuthorizationToString(roleAuthorization)})
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
    required String userId,
    required bool canLogin,
  }) async {
    var body = '''
    mutation Access {
    access(key: "$userId", canLogin: $canLogin)
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
    required String userId,
  }) async {
    var body = '''
    mutation ResetLoginParameter {
    resetLoginParameter(key: "$userId")
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
    required String userId,
    String? login,
    required String ancienMotdepasse,
    required String password,
  }) async {
    var body = '''
    mutation UpdateLoginData {
    updateLoginData(key:"$userId",''';

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
        message: RequestMessage.onCatchErrorMessage,
        status: PopupStatus.customError,
      );
    }
  }
}
