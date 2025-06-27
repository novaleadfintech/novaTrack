import 'package:flutter/material.dart';
import 'package:frontend/model/bulletin_paie/etat_bulletin.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../app_dialog_box.dart';
import 'edit_decouverte.dart';
import '../../detail_pop.dart';
import '../../utils/decouverte_util.dart';
import '../../../../helper/amout_formatter.dart';
import '../../../../helper/date_helper.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../global/constant/constant.dart';
import '../../../../model/bulletin_paie/decouverte_model.dart';
import '../../../../model/request_response.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_last.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../../widget/table_header.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import '../../../responsitvity/responsivity.dart';
import 'detail_decouvert.dart';
import '../../../pdf/bulletin_generate/situation_de_decouverte.dart';

class DecouverteTable extends StatefulWidget {
  final List<DecouverteModel> paginatedDecouverteData;
  final VoidCallback refresh;

  const DecouverteTable({
    super.key,
    required this.paginatedDecouverteData,
    required this.refresh,
  });

  @override
  State<DecouverteTable> createState() => _DecouverteTableState();
}

class _DecouverteTableState extends State<DecouverteTable> {
  late SimpleFontelicoProgressDialog _dialog;
  late List<RoleModel> roles = [];

  _onShowDetail({required DecouverteModel decouverte}) {
    showDetailDialog(
      context,
      content: MoreDetaildecouvertePage(
        decouverte: decouverte,
      ),
      title: "Détail de decouverte",
    );
  }

  _downloadDecouverte({
    required DecouverteModel decouverte,
  }) async {
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    try {
      RequestResponse? result =
          await DecouvertePdfGenerator.generateAndDownloadPdf(
        decouverte: decouverte,
      );

      _dialog.hide();
      if (result!.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage:
              "Decouverte de ${decouverte.salarie.personnel.nom} ${decouverte.salarie.personnel.prenom} téléchargé avec succès.",
        );
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
        return;
      }
    } catch (e) {
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: "Erreur lors du téléchargement",
      );
      return;
    }
  }

  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
    setState(() {});
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
            4: const FixedColumnWidth(50),
            2: Responsive.isMobile(context)
                ? const FixedColumnWidth(50)
                : const FlexColumnWidth(),
          },
          children: [
            Responsive.isMobile(context)
                ? tableHeader(
                    tablesTitles: decouverteTableTitlesSmall,
                    context,
                  )
                : tableHeader(
                    tablesTitles: decouverteTableTitles,
                    context,
                  ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: {
                4: const FixedColumnWidth(50),
                2: Responsive.isMobile(context)
                    ? const FixedColumnWidth(50)
                    : const FlexColumnWidth(),
                3: Responsive.isMobile(context)
                    ? const FixedColumnWidth(50)
                    : const FlexColumnWidth(),
              },
              children: [
                ...widget.paginatedDecouverteData.map(
                  (decouverte) => Responsive.isMobile(context)
                      ? TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur:
                                  '${decouverte.salarie.personnel.nom} ${decouverte.salarie.personnel.prenom}',
                            ),
                            TableBodyMiddle(
                              valeur: getShortStringDate(
                                time: decouverte.dateEnregistrement,
                              ),
                            ),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    _onShowDetail(
                                      decouverte: decouverte,
                                    );
                                  },
                                  color: null, // couleur null
                                ),
                                if (decouverte.status ==
                                        DecouverteStatus.unpaid &&
                                    hasPermission(
                                  roles: roles,
                                  permission:
                                      PermissionAlias.updateAvance.label,
                                ))
                                (
                                  label: Constant.edit,
                                  onTap: () {
                                    _onEdit(decouverte: decouverte);
                                  },
                                  color: null, // couleur null
                                ),
                                (
                                  label: Constant.download,
                                  onTap: () {
                                    _downloadDecouverte(
                                      decouverte: decouverte,
                                    );
                                  },
                                  color: null, // couleur null
                                ),
                              ],
                            )
                          ],
                        )
                      : TableRow(
                          decoration: tableDecoration(context),
                          children: [
                            TableBodyMiddle(
                              valeur: decouverte.salarie.personnel.nom,
                            ),
                            TableBodyMiddle(
                              valeur: decouverte.salarie.personnel.prenom,
                            ),
                            TableBodyMiddle(
                                valeur: getStringDate(
                              time: decouverte.dateEnregistrement,
                            )),
                            TableBodyMiddle(
                              valeur:
                                  Formatter.formatAmount(decouverte.montant),
                            ),
                            TableBodyLast(
                              items: [
                                (
                                  label: Constant.detail,
                                  onTap: () {
                                    _onShowDetail(
                                      decouverte: decouverte,
                                    );
                                  },
                                  color: null, // couleur null
                                ),
                                if (decouverte.status ==
                                        DecouverteStatus.unpaid &&
                                    hasPermission(
                                  roles: roles,
                                  permission:
                                      PermissionAlias.updateAvance.label,
                                ))
                                (
                                  label: Constant.edit,
                                  onTap: () {
                                    _onEdit(decouverte: decouverte);
                                  },
                                  color: null, // couleur null
                                ),
                                (
                                  label: Constant.download,
                                  onTap: () {
                                    _downloadDecouverte(
                                      decouverte: decouverte,
                                    );
                                  },
                                  color: null, // couleur null
                                ),
                              ],
                            )
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

  void _onEdit({required DecouverteModel decouverte}) {
    showResponsiveDialog(
      context,
      content: EditDecouvertePage(
        decouverte: decouverte,
        refresh: widget.refresh,
      ),
      title: "Modifier un découvert",
    );
  }
}
