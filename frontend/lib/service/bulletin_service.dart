import 'dart:convert';
import 'package:frontend/model/bulletin_paie/validate_bulletin_model.dart';
import '../model/bulletin_paie/Etat_bulletin.dart';
import '../model/bulletin_paie/bulletin_model.dart';
import 'package:http/http.dart' as http;
import '../app/integration/popop_status.dart';
import '../global/config.dart';
import '../global/constant/request_management_value.dart';
import '../model/request_response.dart';
import 'request_header.dart';

class BulletinService {
  static Future<List<BulletinPaieModel>> getCurrentBulletins(
      {EtatBulletin? etat}) async {
    List<BulletinPaieModel> bulletins = [];
    var body = '''
              query CurrentBulletinsPaie {
    currentBulletinsPaie {
        _key
        etat
        debutPeriodePaie
        finPeriodePaie
        dateEdition
        salarie {
            _key
            dateEnregistrement
            periodPaie
            paieClause
            fullCount
            personnel {
                _key
                nom
                prenom
                email
                telephone
                adresse
                sexe
                poste {
                    _key
                    libelle
                }
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
                pays {
                    _key
                    name
                    code
                    tauxTVA
                    phoneNumber
                    initiauxPays
                }
                personnePrevenir {
                    nom
                    lien
                    telephone1
                    telephone2
                }
            }
            bulletinCategorie {
                _key
                bulletinCategorie
            }
        }
        validate {
            validateStatus
            date
            commentaire
            validater {
                _key
                login
                password
                canLogin
                _token
                dateEnregistrement
                personnel {
                    _key
                    nom
                    prenom
                    email
                    telephone
                    adresse
                    sexe
                    poste {
                        _key
                        libelle
                    }
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
        }
        rubriques {
            value
            rubrique {
                _key
                rubrique
                code
                type
                nature
                rubriqueRole
                rubriqueIdentity
                portee
                section {
                    _key
                    section
                }
                calcul {
                    operateur
                    elements {
                        type
                        valeur
                        rubrique {
                            _key
                            rubrique
                            code
                            type
                            nature
                            portee
                            rubriqueIdentity
                        }
                    }
                }
                sommeRubrique {
                    operateur
                    elements {
                        type
                        valeur
                        rubrique {
                            _key
                            rubrique
                            code
                            type
                            nature
                            portee
                            rubriqueIdentity
                        }
                    }
                }
                taux {
                    taux
                    base {
                        _key
                        rubrique
                        code
                        type
                        nature
                        portee
                        rubriqueIdentity
                    }
                }
                bareme {
                    reference {
                        _key
                        rubrique
                        code
                        type
                        nature
                        portee
                        rubriqueIdentity
                    }
                    tranches {
                        min
                        max
                        value {
                            type
                            valeur
                            taux {
                                taux
                                base {
                                    _key
                                    rubrique
                                    code
                                    type
                                    nature
                                    portee
                                    rubriqueIdentity
                                }
                            }
                        }
                    }
                }
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
      throw (RequestMessage.failgettingDataMessage);
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw (RequestMessage.failgettingDataMessage);
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['currentBulletinsPaie'];

      if (data != null) {
        for (var bulletin in data) {
          bulletins.add(BulletinPaieModel.fromJson(bulletin));
        }
      }
    } else {
      throw (jsonDecode(response.body)['errors'][0]['message']);
    }
    return bulletins;
  }

  static Future<List<BulletinPaieModel>> getCurrentValidateBulletins(
      {EtatBulletin? etat}) async {
    List<BulletinPaieModel> bulletins = [];
    var body = '''
              query CrrentValidateBulletin {
    currentValidateBulletin {
        _key
        etat
        debutPeriodePaie
        finPeriodePaie
        dateEdition
        salarie {
            _key
            dateEnregistrement
            periodPaie
            paieClause
            fullCount
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
                pays {
                    _key
                    name
                    code
                    tauxTVA
                    phoneNumber
                    initiauxPays
                }
                personnePrevenir {
                    nom
                    lien
                    telephone1
                    telephone2
                }
            }
            bulletinCategorie {
                _key
                bulletinCategorie
            }
        }
        validate {
            validateStatus
            date
            commentaire
            validater {
                _key
                login
                password
                canLogin
                _token
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
        }
        rubriques {
            value
            rubrique {
                _key
                rubrique
                code
                type
                nature
                rubriqueRole
                rubriqueIdentity
                portee
                section {
                    _key
                    section
                }
                calcul {
                    operateur
                    elements {
                        type
                        valeur
                        rubrique {
                            _key
                            rubrique
                            code
                            type
                            nature
                            portee
                            rubriqueIdentity
                        }
                    }
                }
                sommeRubrique {
                    operateur
                    elements {
                        type
                        valeur
                        rubrique {
                            _key
                            rubrique
                            code
                            type
                            nature
                            portee
                            rubriqueIdentity
                        }
                    }
                }
                taux {
                    taux
                    base {
                        _key
                        rubrique
                        code
                        type
                        nature
                        portee
                        rubriqueIdentity
                    }
                }
                bareme {
                    reference {
                        _key
                        rubrique
                        code
                        type
                        nature
                        portee
                        rubriqueIdentity
                    }
                    tranches {
                        min
                        max
                        value {
                            type
                            valeur
                            taux {
                                taux
                                base {
                                    _key
                                    rubrique
                                    code
                                    type
                                    nature
                                    portee
                                    rubriqueIdentity
                                }
                            }
                        }
                    }
                }
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
      throw (RequestMessage.failgettingDataMessage);
    }).timeout(
      const Duration(seconds: reqTimeout),
      onTimeout: () {
        throw (RequestMessage.failgettingDataMessage);
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['currentValidateBulletin'];

      if (data != null) {
        for (var bulletin in data) {
          bulletins.add(BulletinPaieModel.fromJson(bulletin));
        }
      }
    } else {
      throw (jsonDecode(response.body)['errors'][0]['message']);
    }
    return bulletins;
  }

static Future<RequestResponse> generateBulletinsForPeriod({
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    var body = '''
    mutation GenerateBulletinsForPeriod {
      generateBulletinsForPeriod(
        dateDebut: ${dateDebut.millisecondsSinceEpoch}, 
        dateFin: ${dateFin.millisecondsSinceEpoch}
      )
    }
  ''';

    try {
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
          throw RequestMessage.failgettingDataMessage;
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        // Vérifier s'il y a des erreurs GraphQL
        if (jsonData['errors'] != null) {
          return RequestResponse(
            message: jsonData['errors'][0]['message'],
            status: PopupStatus.serverError,
          );
        }

        var data = jsonData['data']['generateBulletinsForPeriod'];

        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            status: PopupStatus.serverError,
            message: data ?? RequestMessage.successwithbugMessage,
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
  static Future<List<BulletinPaieModel>> getArchiveBulletins(
      {EtatBulletin? etat}) async {
    List<BulletinPaieModel> bulletins = [];
    var body = '''
              query ArchiveBulletinsPaie {
    archiveBulletinsPaie {
        _key
        etat
         
        debutPeriodePaie
        finPeriodePaie
         dateEdition
        salarie {
            _key
            dateEnregistrement
            periodPaie
            paieClause
            fullCount
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
                pays {
                    _key
                    name
                    code
                    tauxTVA
                    phoneNumber
                    initiauxPays
                }
                personnePrevenir {
                    nom
                    lien
                    telephone1
                    telephone2
                }
            }
            bulletinCategorie {
                _key
                bulletinCategorie
            }
        }
        validate {
            validateStatus
            date
            commentaire
            validater {
                _key
                login
                password
                canLogin
                _token
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
        }
        rubriques {
            value
            rubrique {
                _key
                rubrique
                code
                type
                nature
                rubriqueRole
                rubriqueIdentity
                portee
                section {
                    _key
                    section
                }
                calcul {
                    operateur
                    elements {
                        type
                        valeur
                        rubrique {
                            _key
                            rubrique
                            code
                            type
                            nature
                            portee
                            rubriqueIdentity
                        }
                    }
                }
                sommeRubrique {
                    operateur
                    elements {
                        type
                        valeur
                        rubrique {
                            _key
                            rubrique
                            code
                            type
                            nature
                            portee
                            rubriqueIdentity
                        }
                    }
                }
                taux {
                    taux
                    base {
                        _key
                        rubrique
                        code
                        type
                        nature
                        portee
                        rubriqueIdentity
                    }
                }
                bareme {
                    reference {
                        _key
                        rubrique
                        code
                        type
                        nature
                        portee
                        rubriqueIdentity
                    }
                    tranches {
                        min
                        max
                        value {
                            type
                            valeur
                            taux {
                                taux
                                base {
                                    _key
                                    rubrique
                                    code
                                    type
                                    nature
                                    portee
                                    rubriqueIdentity
                                }
                            }
                        }
                    }
                }
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
        throw RequestMessage.failgettingDataMessage;
      },
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['archiveBulletinsPaie'];

      if (data != null) {
        for (var bulletin in data) {
          bulletins.add(BulletinPaieModel.fromJson(bulletin));
        }
      }
    } else {
      throw jsonDecode(response.body)['errors'][0]['message'];
    }
    return bulletins;
  }

  static Future<RequestResponse> validerBulletin({
    required String key,
    required ValidateBulletinModel validateBulletin,
    required DateTime? datePayement,
  }) async {
    var body = '''
   mutation ValiderBulletin {
    validerBulletin(
        key: "$key"
        datePayement: ${datePayement?.millisecondsSinceEpoch},
        validate: ${validateBulletin.toJson()}
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
          return RequestResponse.response(
            status: PopupStatus.serverError,
            message: RequestMessage.timeoutMessage,
          );
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['validerBulletin'];

        if (data == RequestMessage.success) {
          return RequestResponse(
            message: RequestMessage.successMessage,
            status: PopupStatus.success,
          );
        } else {
          return RequestResponse(
            status: PopupStatus.serverError,
            message: RequestMessage.successwithbugMessage,
          );
        }
      } else {
        return RequestResponse(
          message: jsonDecode(response.body)['errors'][0]['message'],
          status: PopupStatus.serverError,
        );
      }
    } catch (error) {
      throw error.toString();
    }
  }

  // static Future<BulletinModel> payer({
//     required String key,
//     required List<BanqueModel> banques,
//     required String moyenPayement,
//     required String userKey,
//   }) async {
//     BulletinModel? bulletin;
//     var body = '''
//                mutation ValiderBulletin {
//                   validerBulletin(key: "$key", ''';
//     body += 'banqueKey: [';
//     for (var banque in banques) {
//       body += '"${banque.key}"';
//     }
//     body += '],';
//     body += '''moyenPayement: "$moyenPayement", userKey: "$userKey") {
//                     _key
//                     etat
//                     moyenPayement
//                     datePayement
//                     dateEdition
//                     montant
//                     retenus {
//                         libelle
//                         montant
//                         taux
//                     }
//                     gains {
//                         libelle
//                         montant
//                         taux
//                     }
//                     banque {
//                         _key
//                         name
//                         codeGuichet
//                         codeBanque
//                         cleRIB
//                         logo
//                     }
//                     personnel {
//                         _key
//                         nom
//                         prenom
//                         email
//                         telephone
//                         adresse
//                         sexe
//                         poste{_key, libelle}
//                         pays {
//                             name
//                             code
//                         }
//                     }
//                 }
//               }

//             ''';
//     var response = await http.post(
//       Uri.parse(serverUrl),
//       body: json.encode({
//         'query': body,
//       }),
//       headers: getHeaders(),
//     ).catchError((onError) {
//       throw RequestMessage.failgettingDataMessage;
//     }).timeout(
//       const Duration(seconds: reqTimeout),
//       onTimeout: () {
//         throw RequestMessage.failgettingDataMessage;
//       },
//     );
//     if (response.statusCode == 200) {
//       var jsonData = jsonDecode(response.body);
//       var data = jsonData['data']['validerBulletin'];
//       if (data != null) {
//         bulletin = BulletinModel.fromJson(data);
//       }
//     } else {
//       throw jsonDecode(response.body)['errors'][0]['message'];
//     }
//     return bulletin!;
//   }

 
}
