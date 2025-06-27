import 'package:flutter/material.dart';
import 'package:frontend/model/bulletin_paie/rubrique.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/request_response.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../service/bulletin_rubrique_service.dart';
import '../../../../widget/confirmation_dialog_box.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import '../../utils/libelle_flux.dart';

import '../../app_dialog_box.dart';
import '../../detail_pop.dart';
import '../../../../global/constant/constant.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_last.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../../widget/table_header.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import 'detail_rubrique.dart';
import 'edit_rubrique.dart';

class RubriqueTable extends StatefulWidget {
  final List<RubriqueBulletin> rubriques;
  final Future<void> Function() refresh;
  const RubriqueTable({
    super.key,
    required this.rubriques,
    required this.refresh,
  });

  @override
  State<RubriqueTable> createState() => _InputTableState();
}

class _InputTableState extends State<RubriqueTable> {
  late SimpleFontelicoProgressDialog _dialog;
  late List<RoleModel> roles = [];
  late Future<void> _futureRoles;

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _futureRoles = getRoles();
    super.initState();
  }

  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
    setState(() {
      
    });
  }

  editLibelle({
    required RubriqueBulletin rubrique,
  }) {
    showResponsiveDialog(
      context,
      content: EditRubriquePage(
        rubrique: rubrique,
        refresh: widget.refresh,
      ),
      title: "Modifier un rubrique",
    );
  }

  detailRubrique({required RubriqueBulletin rubrique}) {
    showDetailDialog(
      context,
      content: DetailRubriquePage(
        rubrique: rubrique,
      ),
      title: "Détail de rubrique",
    );
  }

  Future<void> deleteLibelle({
    required RubriqueBulletin rubrique,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer la rubrique \"${rubrique.rubrique}\"?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result =
          await BulletinRubriqueService.deleteBulletinRubrique(
        key: rubrique.id,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "La rubrique a été supprimé avec succcès",
        );
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _futureRoles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Erreur de chargement des rôles'));
        } else {
          return buildContent(context);
        }
      },
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        Table(
          columnWidths: {
            0: const FlexColumnWidth(2),
            1: const FixedColumnWidth(50)
          },
          children: [
            tableHeader(
              tablesTitles: rubriqueTableTitles,
              context,
            )
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: {
                0: const FlexColumnWidth(2),
                1: const FixedColumnWidth(50)
              },
              children: [
                ...widget.rubriques.map(
                  (rubrique) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: rubrique.rubrique,
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailRubrique(rubrique: rubrique);
                            },
                            color: null, // couleur null
                          ),
                          if (hasPermission(
                            roles: roles,
                            permission: PermissionAlias
                                .updateBulletinRubrique.label,
                          ))
                            (
                              label: Constant.edit,
                              onTap: () {
                                editLibelle(rubrique: rubrique);
                              },
                              color: null, // couleur null
                            ),
                          // if (!hasPermission(
                          //   roles: roles,
                          //   permission: PermissionAlias
                          //       .deletebu.label,
                          // ))
                          //   (
                          //     label: Constant.delete,
                          //     onTap: () {
                          //       deleteLibelle(rubrique: rubrique);
                          //     },
                          //     color: null, // couleur null
                          //   ),
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
}
