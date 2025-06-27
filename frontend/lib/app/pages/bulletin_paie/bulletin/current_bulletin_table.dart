import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/utils/bulletin_util.dart';
import 'package:frontend/model/bulletin_paie/bulletin_model.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../../widget/table_header.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../global/constant/constant.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../helper/date_helper.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../../model/request_response.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_last.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import '../../../pdf/bulletin_generate/bulletin.dart';
import '../../../responsitvity/responsivity.dart';
import '../../detail_pop.dart';
import '../detail_bulletin.dart';
import 'edit_bulletin.dart';
import 'validate_current_bulletin.dart';

class CurrentBulletinTable extends StatefulWidget {
  final List<BulletinPaieModel> paginatedCurrentBulletintData;
  final VoidCallback refresh;

  const CurrentBulletinTable({
    super.key,
    required this.refresh,
    required this.paginatedCurrentBulletintData,
  });

  @override
  State<CurrentBulletinTable> createState() => _CurrentBulletinTableState();
}

class _CurrentBulletinTableState extends State<CurrentBulletinTable> {
  late SimpleFontelicoProgressDialog _dialog;
  late List<RoleModel> roles = [];

  onShowDetail({required BulletinPaieModel bulletin}) {
    showDetailDialog(
      context,
      content: DetailBulletinPage(
        bulletin: bulletin,
      ),
      title: "Détail de bulletin",
    );
  }

  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
    setState(() {});
  }

  onValidate({required BulletinPaieModel bulletin}) {
    Responsive.isMobile(context)
        ? showResponsiveDialog(
            context,
            content: ValidateCurrentBulletintPage(
              currentBulletin: bulletin,
              refresh: widget.refresh,
            ),
            title: "Validation de bulletin",
          )
        : showDetailDialog(
            context,
            content: ValidateCurrentBulletintPage(
              currentBulletin: bulletin,
              refresh: widget.refresh,
            ),
            title: "Validation de bulletin",
          );
  }

  onEditBulletin({required BulletinPaieModel bulletin}) {
    showResponsiveDialog(
      context,
      content: EditBulletinPage(
        bulletinPaie: bulletin,
        refresh: widget.refresh,
      ),
      title: "Modifier de bulletin",
    );
  }

  // validateCurrentBulletin({
  //   required BulletinModel bulletin,
  // }) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return Dialog(
  //         surfaceTintColor: Theme.of(context).colorScheme.surface,
  //         backgroundColor: Theme.of(context).colorScheme.surface,
  //         shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.zero,
  //         ),
  //         child: Container(
  //           width: Responsive.isMobile(context) ? 300 : 500,
  //           decoration: const BoxDecoration(
  //             border: Border(
  //               top: BorderSide(
  //                 color: AppColor.primaryColor,
  //                 width: 8,
  //                 style: BorderStyle.solid,
  //               ),
  //             ),
  //           ),
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     const Text(
  //                       "",
  //                       style: TextStyle(
  //                         fontSize: 16.0,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     Align(
  //                       alignment: Alignment.topRight,
  //                       child: IconButton(
  //                         icon: const Icon(Icons.close),
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 10),
  //                 SingleChildScrollView(
  //                   child: ValidateCurrentBulletintPage(
  //                     refresh: widget.refresh,
  //                     currentBulletinId: bulletin.id,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  downloadcurrentBulletin({
    required BulletinPaieModel currentBulletin,
  }) async {
    try {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse? result =
          await BulletinPdfGenerator.generateAndDownloadPdf(
        bulletin: currentBulletin,
      );

      _dialog.hide();
      if (result!.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage:
              "Bulletin de ${currentBulletin.salarie.personnel.toStringify()} téléchargé avec succès.",
        );
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: "result.message",
        );
        return;
      }
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: "Erreur lors du téléchargement ${e.toString()}",
      );
      return;
    }
  }

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    getRoles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Table(
          columnWidths: {
            3: const FixedColumnWidth(50),
            1: const FlexColumnWidth(),
            2: Responsive.isMobile(context)
                ? const FixedColumnWidth(50)
                : const FlexColumnWidth(),
          },
          children: [
            Responsive.isMobile(context)
                ? tableHeader(
                    tablesTitles: bulletinTableTitlesSmall,
                    context,
                  )
                : tableHeader(
                    tablesTitles: bulletinTableTitles,
                    context,
                  ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: {
                3: const FixedColumnWidth((50)),
                1: const FlexColumnWidth(),
                2: Responsive.isMobile(context)
                    ? const FixedColumnWidth(50)
                    : const FlexColumnWidth(),
              },
              children: [
                ...widget.paginatedCurrentBulletintData.map(
                  (bulletin) => Responsive.isMobile(context)
                      ? TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: bulletin.salarie.personnel.toStringify(),
                            ),
                            TableBodyMiddle(
                              valeur:
                                  "du ${getShortStringDate(time: bulletin.debutPeriodePaie)} au ${getShortStringDate(time: bulletin.finPeriodePaie)}",
                            ),
                            TableBodyLast(
                              items: [

                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    onShowDetail(
                                      bulletin: bulletin,
                                    );
                                  },
                                  color: null, // couleur null
                                ),
                                if (hasPermission(
                                  roles: roles,
                                  permission:
                                      PermissionAlias.validBulletin.label,
                                ))
                                (
                                  label: Constant.validate,
                                  onTap: () {
                                    onValidate(
                                      bulletin: bulletin,
                                    );
                                  },
                                  color: null, // couleur null
                                ),
                                (
                                  label: Constant.download,
                                  onTap: () {
                                    downloadcurrentBulletin(
                                        currentBulletin: bulletin);
                                  },
                                  color: null, // couleur null
                                ),
                                if (hasPermission(
                                  roles: roles,
                                  permission:
                                      PermissionAlias.updateBulletin.label,
                                ))
                                (
                                  label: Constant.edit,
                                  onTap: () {
                                    onEditBulletin(
                                      bulletin: bulletin,
                                    );
                                  },
                                  color: null, // couleur null
                                ),
                                // (
                                //   label: Constant.editer,
                                //   onTap: () {
                                //     validateCurrentBulletin(
                                //       bulletin: bulletin,
                                //     );
                                //   },
                                //   color: null, // couleur null
                                // ),
                              ],
                            )
                          ],
                        )
                      : TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: bulletin.salarie.personnel.nom,
                            ),
                            TableBodyMiddle(
                              valeur: bulletin.salarie.personnel.prenom,
                            ),
                            TableBodyMiddle(
                              valeur:
                                  "du ${getShortStringDate(time: bulletin.debutPeriodePaie)} au ${getShortStringDate(time: bulletin.finPeriodePaie)}",
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // ...[
                                //   Responsive.isTablet(context)
                                //       ? IconButton(
                                //           onPressed: () {
                                //             validateCurrentBulletin(
                                //               bulletin: bulletin,
                                //             );
                                //           },
                                //           icon: SvgPicture.asset(
                                //             AssetsIcons.validate,
                                //           ),
                                //         )
                                //       : ValidateButton(
                                //           onPressed: () {
                                //             validateCurrentBulletin(
                                //               bulletin: bulletin,
                                //             );
                                //           },
                                //           libelle: Constant.editer,
                                //         ),
                                // ],
                                TableBodyLast(
                                  items: [
                                    (
                                      label: Constant.detail,
                                      onTap: () {
                                        onShowDetail(
                                          bulletin: bulletin,
                                        );
                                      },
                                      color: null, // couleur null
                                    ),
                                    if (hasPermission(
                                      roles: roles,
                                      permission:
                                          PermissionAlias.validBulletin.label,
                                    ))
                                    (
                                      label: Constant.validate,
                                      onTap: () {
                                        onValidate(
                                          bulletin: bulletin,
                                        );
                                      },
                                      color: null, // couleur null
                                    ),
                                    (
                                      label: Constant.download,
                                      onTap: () {
                                        downloadcurrentBulletin(
                                            currentBulletin: bulletin);
                                      },
                                      color: null, // couleur null
                                    ),
                                    if (hasPermission(
                                      roles: roles,
                                      permission:
                                          PermissionAlias.updateBulletin.label,
                                    ))
                                    (
                                      label: Constant.edit,
                                      onTap: () {
                                        onEditBulletin(
                                          bulletin: bulletin,
                                        );
                                      },
                                      color: null, // couleur null
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
