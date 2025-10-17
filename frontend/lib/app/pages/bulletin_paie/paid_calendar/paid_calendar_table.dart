// import 'package:flutter/material.dart';
// import 'package:frontend/helper/string_helper.dart';
// import 'package:frontend/style/app_style.dart' show tableDecoration;
// import 'package:frontend/widget/table_body_middle.dart' show TableBodyMiddle;
// import '../../../../../auth/authentification_token.dart';
// import '../../../../../global/constant/constant.dart';
// import '../../../../../global/constant/permission_alias.dart';
// import '../../../../../model/bulletin_paie/pay_Calendar_model.dart';
// import '../../../../../model/habilitation/role_model.dart';
// import '../../../../../widget/confirmation_dialog_box.dart';
// import '../../../../../widget/table_body_last.dart';
// import '../../../../global/constant/permission_alias.dart';
// import '../../../../helper/user_helper.dart';
// import '../../../../model/request_response.dart';
// import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
// import '../../../../widget/confirmation_dialog_box.dart';

// import '../../../../global/constant/constant.dart';
// import '../../../../style/app_style.dart';
// import '../../../../widget/table_body_last.dart';
// import '../../../../widget/table_body_middle.dart';
// import '../../../../widget/table_header.dart';
// import '../../../../auth/authentification_token.dart';
// import '../../../../model/habilitation/role_model.dart';
// import '../../../app_dialog_box.dart';
// import '../../../detail_pop.dart';
// import '../../../model/personnel/payCalendar_model.dart';
// import '../../../service/payCalendar_service.dart';
// import '../../integration/popop_status.dart';
// import '../../integration/request_frot_behavior.dart';
// import '../app_dialog_box.dart';
// import '../detail_pop.dart';
// import '../utils/libelle_flux.dart';
// import 'detail_paid_Calendar.dart';
// import 'edit_paid_Calendar.dart';

// class PayCalendarTable extends StatefulWidget {
//   final List<PayCalendarModel> payCalendar;
//   final Future<void> Function() refresh;
//   const PayCalendarTable({
//     super.key,
//     required this.payCalendar,
//     required this.refresh,
//   });

//   @override
//   State<PayCalendarTable> createState() => _PayCalendarTableState();
// }

// class _PayCalendarTableState extends State<PayCalendarTable> {
//   late SimpleFontelicoProgressDialog _dialog;
//   late RoleModel role;
//   late Future<void> _futureRoles;

//   @override
//   void initState() {
//     _dialog = SimpleFontelicoProgressDialog(context: context);
//     _futureRoles = getRole();
//     super.initState();
//   }

//   Future<void> getRole() async {
//     RoleModel currentRole = await AuthService().getRole();
//     setState(() {
//       role = currentRole;
//     });
//   }

//   editLibelle({
//     required PayCalendarModel payCalendar,
//   }) {
//     showResponsiveDialog(
//       context,
//       content: EditPayCalendar(
//         payCalendar: payCalendar,
//         refresh: widget.refresh,
//       ),
//       title: "Modifier un payCalendar",
//     );
//   }

//   detailPayCalendar({required PayCalendarModel payCalendar}) {
//     showDetailDialog(
//       context,
//       content: DetailPayCalendarPage(
//         payCalendar: payCalendar,
//       ),
//       title: "Détail de payCalendar",
//     );
//   }

//   Future<void> deletePayCalendar({
//     required PayCalendarModel payCalendar,
//   }) async {
//     bool confirmed = await handleOperationButtonPress(
//       context,
//       content:
//           "Voulez-vous vraiment supprimer la payCalendar de bulletin \"${payCalendar.libelle}\"?",
//     );
//     if (confirmed) {
//       _dialog.show(
//         message: '',
//         type: SimpleFontelicoProgressDialogType.phoenix,
//         backgroundColor: Colors.transparent,
//       );

//       RequestResponse result = await PayCalendarService.deletePayCalendar(
//         key: payCalendar.id,
//       );
//       _dialog.hide();
//       if (result.status == PopupStatus.success) {
//         MutationRequestContextualBehavior.showPopup(
//           status: PopupStatus.success,
//           customMessage: "Le payCalendar a été supprimé avec succcès",
//         );
//         await widget.refresh();
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
//     return FutureBuilder<void>(
//       future: _futureRoles,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return const Center(child: Text('Erreur de chargement des rôles'));
//         } else {
//           return buildContent(context);
//         }
//       },
//     );
//   }

//   Widget buildContent(BuildContext context) {
//     return Column(
//       children: [
//         Table(
//           columnWidths: {
//             0: const FlexColumnWidth(2),
//             1: const FixedColumnWidth(50)
//           },
//           children: [
//             tableHeader(
//               tablesTitles: payCalendarTableTitles,
//               context,
//             )
//           ],
//         ),
//         Expanded(
//           child: SingleChildScrollView(
//             child: Table(
//               columnWidths: {
//                 0: const FlexColumnWidth(2),
//                 1: const FixedColumnWidth(50)
//               },
//               children: [
//                 ...widget.payCalendar.map(
//                   (payCalendar) => TableRow(
//                     decoration: tableDecoration(context),
//                     children: [
//                       TableBodyMiddle(
//                         valeur: capitalizeFirstLetter(word: payCalendar.),
//                       ),
//                       TableBodyLast(
//                         items: [
//                           (
//                             label: Constant.detail,
//                             onTap: () {
//                               detailPayCalendar(payCalendar: payCalendar);
//                             },
//                             color: null, // couleur null
//                           ),
//                           // if (hasPermission(
//                           //   role: role,
//                           //   permission: PermissionAlias.updatePayCalendar.label,
//                           // ))
//                             (
//                               label: Constant.edit,
//                               onTap: () {
//                                 editLibelle(payCalendar: payCalendar);
//                               },
//                               color: null,
//                             ),
//                           // if (hasPermission(
//                           //   role: role,
//                           //   permission: PermissionAlias
//                           //       .deletePayCalendar.label,
//                           // ))
//                           //   (
//                           //     label: Constant.delete,
//                           //     onTap: () {
//                           //       deleteLibelle(payCalendar: payCalendar);
//                           //     },
//                           //     color: null,
//                           //   ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
