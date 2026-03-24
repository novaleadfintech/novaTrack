//  static Future<BulletinPaieModel?> getPreviousBulletins(
//       {required String salarieKey}) async {
//     var body = '''
//               query PreviousBulletinsPaie {
//     previousBulletinsPaie(salarieKey: "$salarieKey") {
//         _key
//         etat
//         moyenPayement{
//           _key
//           libelle
//         }
//         datePayement
//         debutPeriodePaie
//         finPeriodePaie
//         referencePaie
//         dateEdition
//         banque {
//             _key
//             name
//             codeGuichet
//             codeBanque
//             cleRIB
//             codeBIC
//             numCompte
//             logo
//             soldeTheorique
//             soldeReel
//             country {
//                 _key
//                 name
//                 code
//             }
//         }
//         salarie {
//             _key
//             dateEnregistrement
//             periodPaie
//             paieManner
//             fullCount
//             personnel {
//                 _key
//                 nom
//                 prenom
//                 email
//                 telephone
//                 adresse
//                 sexe
//                 poste{_key, libelle}
//                 situationMatrimoniale
//                 commentaire
//                 etat
//                 dateEnregistrement
//                 dateNaissance
//                 dateDebut
//                 dateFin
//                 nombreEnfant
//                 nombrePersonneCharge
//                 dureeEssai
//                 typePersonnel
//                 typeContrat
//                 fullCount
//                 pays {
//                     _key
//                     name
//                     code
//                     tauxTVA
//                     phoneNumber
//                     initiauxPays
//                 }
//                 personnePrevenir {
//                     nom
//                     lien
//                     telephone1
//                     telephone2
//                 }
//             }
//             paieCategorie {
//                 _key
//                 paieCategorie
//             }
//         }
//         validate {
//             validateStatus
//             date
//             commentaire
//             validater {
//                 _key
//                 login
//                 password
//                 canLogin
//                 _token
//                 dateEnregistrement
//                 personnel {
//                     _key
//                     nom
//                     prenom
//                     email
//                     telephone
//                     adresse
//                     sexe
//                     poste{_key, libelle}
//                     situationMatrimoniale
//                     commentaire
//                     etat
//                     dateEnregistrement
//                     dateNaissance
//                     dateDebut
//                     dateFin
//                     nombreEnfant
//                     nombrePersonneCharge
//                     dureeEssai
//                     typePersonnel
//                     typeContrat
//                     fullCount
//                 }
//             }
//         }
//         rubriques {
//             value
//             rubrique {
//                 _key
//                 rubrique
//                 code
//                 type
//                 nature
//                 rubriqueRole
//                 rubriqueIdentity
//                 portee
//                 section {
//                     _key
//                     section
//                 }
//                 calcul {
//                     operateur
//                     elements {
//                         type
//                         valeur
//                         rubrique {
//                             _key
//                             rubrique
//                             code
//                             type
//                             nature
//                             portee
//                             rubriqueIdentity
//                         }
//                     }
//                 }
//                 sommeRubrique {
//                     operateur
//                     elements {
//                         type
//                         valeur
//                         rubrique {
//                             _key
//                             rubrique
//                             code
//                             type
//                             nature
//                             portee
//                             rubriqueIdentity
//                         }
//                     }
//                 }
//                 taux {
//                     taux
//                     base {
//                         _key
//                         rubrique
//                         code
//                         type
//                         nature
//                         portee
//                         rubriqueIdentity
//                     }
//                 }
//                 bareme {
//                     reference {
//                         _key
//                         rubrique
//                         code
//                         type
//                         nature
//                         portee
//                         rubriqueIdentity
//                     }
//                     tranches {
//                         min
//                         max
//                         value {
//                             type
//                             valeur
//                             taux {
//                                 taux
//                                 base {
//                                     _key
//                                     rubrique
//                                     code
//                                     type
//                                     nature
//                                     portee
//                                     rubriqueIdentity
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }
//             ''';

//     var response = await http
//         .post(
//       Uri.parse(serverUrl),
//       body: json.encode({
//         'query': body,
//       }),
//       headers: getHeaders(),
//     )
//         .catchError((onError) {
//       throw (RequestMessage.failgettingDataMessage);
//     }).timeout(
//       const Duration(seconds: reqTimeout),
//       onTimeout: () {
//         throw (RequestMessage.failgettingDataMessage);
//       },
//     );
//     if (response.statusCode == 200) {
//       var jsonData = jsonDecode(response.body);
//       var data = jsonData['data']['previousBulletinsPaie'];

//       if (data != null) {
//         return BulletinPaieModel.fromJson(data);
//       }
//     } else {
//       throw (jsonDecode(response.body)['errors'][0]['message']);
//     }
//     return null;
//   }


//  static Future<RequestResponse> createBulletin({
//     required SalarieModel salarie,
//     required DateTime dateEdition,
//     required DateTime debutPeriodePaie,
//     required DateTime finPeriodePaie,
//     required MoyenPaiementModel moyenPayement,
//     required String referencePaie,
//     required BanqueModel banque,
//     required List<RubriqueOnBulletinModel> bulletinRubriques,
//   }) async {
//     final rubriquesStr = bulletinRubriques.map((r) {
//       return r.toJson();
//     }).join(',');
//     var body = '''
//     mutation CreateBulletinPaie {
//     createBulletinPaie(
//         dateEdition: ${dateEdition.millisecondsSinceEpoch},
//         banqueKey: "${banque.key}",
//         salarieKey: "${salarie.key}",
//         rubriques: [$rubriquesStr],
//         referencePaie:"$referencePaie"
//         moyenPayement:${moyenPayement.toJson()},
//         debutPeriodePaie: ${debutPeriodePaie.millisecondsSinceEpoch},
//         finPeriodePaie: ${finPeriodePaie.millisecondsSinceEpoch},
//     )
// }
//     ''';
//     try {
//       var response = await http
//           .post(
//         Uri.parse(serverUrl),
//         body: json.encode({'query': body}),
//         headers: getHeaders(),
//       )
//           .timeout(
//         const Duration(seconds: reqTimeout),
//         onTimeout: () {
//           return RequestResponse.response(
//             status: PopupStatus.serverError,
//             message: RequestMessage.timeoutMessage,
//           );
//         },
//       );

//       if (response.statusCode == 200) {
//         var jsonData = jsonDecode(response.body);
//         var data = jsonData['data']['createBulletinPaie'];

//         if (data == RequestMessage.success) {
//           return RequestResponse(
//             message: RequestMessage.successMessage,
//             status: PopupStatus.success,
//           );
//         } else {
//           return RequestResponse(
//             status: PopupStatus.serverError,
//             message: RequestMessage.successwithbugMessage,
//           );
//         }
//       } else {
//         return RequestResponse(
//           message: jsonDecode(response.body)['errors'][0]['message'],
//           status: PopupStatus.serverError,
//         );
//       }
//     } catch (error) {
//       throw error.toString();
//     }
//   }


//  static Future<RequestResponse> updateBulletin({
//     required String key,
//     required MoyenPaiementModel moyenPayement,
//     required String referencePaie,
//     required BanqueModel banque,
//     required List<RubriqueOnBulletinModel> bulletinRubriques,
//   }) async {
//     final rubriquesStr = bulletinRubriques.map((r) {
//       return r.toJson();
//     }).join(',');
//     var body = '''
//       mutation UpdateBulletinPaie {
//           updateBulletinPaie(
//               key: "$key",
//               banqueKey: "${banque.key}",
//               rubriques: [$rubriquesStr],
//               referencePaie: "$referencePaie",
//               moyenPayement: ${moyenPayement.toJson()},
//           )
//       }
//     ''';
//     try {
//       var response = await http
//           .post(
//         Uri.parse(serverUrl),
//         body: json.encode({'query': body}),
//         headers: getHeaders(),
//       )
//           .timeout(
//         const Duration(seconds: reqTimeout),
//         onTimeout: () {
//           return RequestResponse.response(
//             status: PopupStatus.serverError,
//             message: RequestMessage.timeoutMessage,
//           );
//         },
//       );

//       if (response.statusCode == 200) {
//         var jsonData = jsonDecode(response.body);
//         var data = jsonData['data']['updateBulletinPaie'];

//         if (data == RequestMessage.success) {
//           return RequestResponse(
//             message: RequestMessage.successMessage,
//             status: PopupStatus.success,
//           );
//         } else {
//           return RequestResponse(
//             status: PopupStatus.serverError,
//             message: RequestMessage.successwithbugMessage,
//           );
//         }
//       } else {
//         return RequestResponse(
//           message: jsonDecode(response.body)['errors'][0]['message'],
//           status: PopupStatus.serverError,
//         );
//       }
//     } catch (error) {
//       throw error.toString();
//     }
//   }

