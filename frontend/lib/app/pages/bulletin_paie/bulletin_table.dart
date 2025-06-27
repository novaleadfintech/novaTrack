// import 'package:flutter/material.dart';
// import 'package:frontend/app/pages/detail_pop.dart';
// import 'package:frontend/app/pages/utils/bulletin_util.dart';
// import 'package:frontend/helper/amout_formatter.dart';
// import 'package:frontend/helper/date_helper.dart';
// import 'package:frontend/model/bulletin_paie/bulletin_model.dart';
// import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
// import '../../../global/constant/constant.dart';
// import '../../../model/request_response.dart';
// import '../../../style/app_style.dart';
// import '../../../widget/table_body_last.dart';
// import '../../../widget/table_body_middle.dart';
// import '../../../widget/table_header.dart';
// import '../../integration/popop_status.dart';
// import '../../integration/request_frot_behavior.dart';
// import '../../responsitvity/responsivity.dart';
// import '../../pdf/bulletin_generate/bulletin.dart';
// import 'archive/detail_bulletin.dart';

// class BulletinTable extends StatefulWidget {
//   final List<BulletinModel> paginatedBulletinData;
//   final VoidCallback refresh;

//   const BulletinTable({
//     super.key,
//     required this.paginatedBulletinData,
//     required this.refresh,
//   });

//   @override
//   State<BulletinTable> createState() => _BulletinTableState();
// }

// class _BulletinTableState extends State<BulletinTable> {
//   late SimpleFontelicoProgressDialog _dialog;

//   onShowDetail({required BulletinModel bulletin}) {
//     showDetailDialog(
//       context,
//       content: DetailBulletinPage(
//         bulletin: bulletin,
//       ),
//       title: "Détail de bulletin",
//     );
//   }

//   downloadcurrentBulletin({
//     required BulletinModel currentBulletin,
//   }) async {
//     _dialog.show(
//       message: "",
//       type: SimpleFontelicoProgressDialogType.phoenix,
//       backgroundColor: Colors.transparent,
//     );
//     try {
//       RequestResponse? result =
//           await BulletinPdfGenerator.generateAndDownloadPdf(
//         bulletin: currentBulletin,
//       );

//       _dialog.hide();
//       if (result!.status == PopupStatus.success) {
//         MutationRequestContextualBehavior.showPopup(
//           status: result.status,
//           customMessage:
//               "Bulletin de ${currentBulletin.personnel.nom} ${currentBulletin.personnel.prenom} téléchargé avec succès.",
//         );
//       } else {
//         MutationRequestContextualBehavior.showPopup(
//           status: result.status,
//           customMessage: result.message,
//         );
//         return;
//       }
//     } catch (e) {
//       MutationRequestContextualBehavior.showPopup(
//         status: PopupStatus.customError,
//         customMessage: "Erreur lors du téléchargement",
//       );
//       return;
//     }
//   }

//   @override
//   void initState() {
//     _dialog = SimpleFontelicoProgressDialog(context: context);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Table(
//           columnWidths: {
//             4: const FixedColumnWidth(33),
//             2: Responsive.isMobile(context)
//                 ? const FixedColumnWidth(33)
//                 : const FlexColumnWidth(),
//           },
//           children: [
//             Responsive.isMobile(context)
//                 ? tableHeader(
//                     tablesTitles: bulletinTableTitlesSmall,
//                     context,
//                   )
//                 : tableHeader(
//                     tablesTitles: bulletinTableTitles,
//                     context,
//                   ),
//           ],
//         ),
//         Expanded(
//           child: SingleChildScrollView(
//             child: Table(
//               columnWidths: {
//                 4: const FixedColumnWidth(33),
//                 2: Responsive.isMobile(context)
//                     ? const FixedColumnWidth(33)
//                     : const FlexColumnWidth(),
//                 3: Responsive.isMobile(context)
//                     ? const FixedColumnWidth(33)
//                     : const FlexColumnWidth(),
//               },
//               children: [
//                 ...widget.paginatedBulletinData.map(
//                   (bulletin) => Responsive.isMobile(context)
//                       ? TableRow(
//                           decoration: tableDecoration(context),
//                           children: [
//                             TableBodyMiddle(
//                               valeur:
//                                   '${bulletin.personnel.nom} ${bulletin.personnel.prenom}',
//                             ),
//                             TableBodyMiddle(
//                               valeur: getShortStringDate(
//                                 time: bulletin.dateEdition,
//                               ),
//                             ),
//                             TableBodyLast(
//                               items: [
//                                 (
//                                   label: Constant.detail,
//                                   onTap: () {
//                                     onShowDetail(
//                                       bulletin: bulletin,
//                                     );
//                                   },
//                                   color: null, // couleur null
//                                 ),
//                                 (
//                                   label: Constant.download,
//                                   onTap: () {
//                                     downloadcurrentBulletin(
//                                       currentBulletin: bulletin,
//                                     );
//                                   },
//                                   color: null, // couleur null
//                                 ),
//                               ],

//                             ),
//                           ],
//                         )
//                       : TableRow(
//                           decoration: tableDecoration(context),
//                           children: [
//                             TableBodyMiddle(
//                               valeur: bulletin.personnel.nom,
//                             ),
//                             TableBodyMiddle(
//                               valeur: bulletin.personnel.prenom,
//                             ),
//                             TableBodyMiddle(
//                                 valeur: getStringDate(
//                               time: bulletin.dateEdition,
//                             )),
//                             TableBodyMiddle(
//                               valeur: Formatter.formatAmount(bulletin.montant),
//                             ),
//                             TableBodyLast(
//                               items: [
//                                 (
//                                   label: Constant.detail,
//                                   onTap: () {
//                                     onShowDetail(
//                                       bulletin: bulletin,
//                                     );
//                                   },
//                                   color: null, // couleur null
//                                 ),
//                                 (
//                                   label: Constant.download,
//                                   onTap: () {
//                                     downloadcurrentBulletin(
//                                       currentBulletin: bulletin,
//                                     );
//                                   },
//                                   color: null, // couleur null
//                                 ),
//                               ],

//                             ),
//                           ],
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
