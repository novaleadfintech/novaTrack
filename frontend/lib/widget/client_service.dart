// import 'package:flutter/material.dart';
// import '../app/integration/popop_status.dart';
// import '../app/integration/request_frot_behavior.dart';
// import '../app/pages/utils/client_util.dart';
// import '../app/responsitvity/responsivity.dart';
// import '../helper/date_helper.dart';
// import '../model/client/client_model.dart';
// import '../model/facturation/facture_model.dart';
// import '../model/facturation/ligne_facture_model.dart';
// import '../model/request_response.dart';
// import '../service/facture_service.dart';
// import '../style/app_style.dart';
// import 'app_action_button.dart';
// import 'confirmation_dialog_box.dart';
// import 'table_body_middle.dart';
// import 'table_header.dart';
// import 'package:gap/gap.dart';
// import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

// class ClientService extends StatefulWidget {
//   final ClientModel client;

//   const ClientService({
//     super.key,
//     required this.client,
//   });

//   @override
//   State<ClientService> createState() => _ClientServiceState();
// }

// class _ClientServiceState extends State<ClientService> {
//   late SimpleFontelicoProgressDialog _dialog;
//   late List<FactureModel> factures;
//   bool isLoading = true;
//   bool hasError = false;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _dialog = SimpleFontelicoProgressDialog(context: context);
//     fetchServices();
//   }

//   // Méthode pour récupérer les services
//   Future<void> fetchServices() async {
//     try {
//       setState(() {
//         isLoading = true;
//         hasError = false;
//         errorMessage = null;
//       });

//       factures = await FactureService.getRecurrentFactureByClient(
//         clientId: widget.client.id,
//       );
//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         hasError = true;
//         errorMessage =
//             "Une erreur s'est produite lors de la récupération des données : $e";
//       });
//     }
//   }

//   void arrestService({required FactureModel facture}) async {
//     bool? confirmed = await handleOperationButtonPress(context,
//         content:
//             "Voulez vous vraiment arreter la regénération de cette facture?");
//     if (confirmed) {
//       _dialog.show(message: "Arrêt en cours");
//       RequestResponse result = await FactureService.stoppregeneration(
//           secreteKey: facture.secreteKey!);
//       _dialog.hide();
//       if (result.status == PopupStatus.success) {
//         MutationRequestContextualBehavior.showPopup(
//             status: result.status,
//             customMessage: "Regeneration arrêté avec succès!");
//         await fetchServices();
//       } else {
//         MutationRequestContextualBehavior.showPopup(
//           status: result.status,
//           customMessage: result.message,
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = Responsive.isMobile(context);
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFDADCE0),
//         ),
//         color: Theme.of(context).colorScheme.surface,
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Text(
//                 "Service",
//                 style: TextStyle(
//                   fontFamily: "Inter",
//                   fontWeight: FontWeight.w600,
//                   fontSize: 18,
//                   color: Theme.of(context).colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const Gap(4),
//           if (isLoading)
//             const Center(child: CircularProgressIndicator())
//           else if (hasError)
//             Center(
//               child: Text(
//                 errorMessage ?? "Erreur",
//                 style: const TextStyle(color: Colors.red),
//               ),
//             )
//           else if (factures.isEmpty)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Text(
//                   "Aucun service",
//                 ),
//               ),
//             )
//           else
//             SingleChildScrollView(
//               child: Table(
//                 columnWidths: const {
//                   2: IntrinsicColumnWidth(),
//                 },
//                 children: [
//                   tableHeader(
//                       tablesTitles: isMobile
//                           ? clientServiceTableColumnSmall
//                           : clientServiceTableColumn,
//                       context),
//                   // Parcours des factures et des lignes de service
//                   ...factures.expand((facture) {
//                     List<LigneFactureModel> ligneFacture =
//                         facture.ligneFactures!;
//                     return ligneFacture.map((ligne) {
//                       return isMobile
//                           ? TableRow(
//                               decoration: tableDecoration(context),
//                               children: [
//                                 TabledetailBodyMiddle(
//                                   valeur: facture.reference,
//                                 ),
//                                 AppActionButton(
//                                   onPressed: () {
//                                     arrestService(facture: facture);
//                                   },
//                                   child: const Text("Arrêter"),
//                                 ),
//                               ],
//                             )
//                           : TableRow(
//                               decoration: tableDecoration(context),
//                               children: [
//                                 TableBodyMiddle(
//                                   valeur: facture.reference,
//                                 ),
//                                 TableBodyMiddle(
//                                   valeur: getStringDate(
//                                       time: facture.dateEnregistrement!),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Center(
//                                     child: AppActionButton(
//                                       onPressed: () {
//                                         arrestService(facture: facture);
//                                       },
//                                       child: const Text("Arrêter"),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                     }).toList();
//                   }),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
