import 'package:flutter/material.dart';
import '../../../../model/request_response.dart';
import '../../../../service/echelon_service.dart';
import '../../../../widget/confirmation_dialog_box.dart';
import '../../../../global/constant/constant.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_last.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../../widget/table_header.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../../model/grille_salariale/echelon_model.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import '../../app_dialog_box.dart';
import '../../detail_pop.dart';
import '../../utils/grille_salariale_util.dart';
import 'detail_echelon.dart';
import 'edit_echelon.dart';

class EchelonTable extends StatefulWidget {
  final List<EchelonModel> echelons;
  final Future<void> Function() refresh;
  const EchelonTable({
    super.key,
    required this.echelons,
    required this.refresh,
  });

  @override
  State<EchelonTable> createState() => _EchelonTableState();
}

class _EchelonTableState extends State<EchelonTable> {
  late SimpleFontelicoProgressDialog _dialog;
  late RoleModel role;
  late Future<void> _futureRoles;

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _futureRoles = getRole();
    super.initState();
  }

  Future<void> getRole() async {
    RoleModel currentRole = await AuthService().getRole();
    setState(() {
      role = currentRole;
    });
  }

  editLibelle({
    required EchelonModel echelon,
  }) {
    showResponsiveDialog(
      context,
      content: EditEchelon(
          // echelon: echelon,
          // refresh: widget.refresh,
          ),
      title: "Modifier un echelon",
    );
  }

  detailEchelon({required EchelonModel echelon}) {
    showDetailDialog(
      context,
      content: DetailEchelonPage(
        echelon: echelon,
      ),
      title: "Détail de echelon",
    );
  }

  Future<void> deleteLibelle({
    required EchelonModel echelon,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer la echelon de bulletin \"${echelon.libelle}\"?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await EchelonService.deleteEchelon(
        key: echelon.id,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Le echelon a été supprimé avec succcès",
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
              tablesTitles: echelonTableTitles,
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
                ...widget.echelons.map(
                  (echelon) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: echelon.libelle,
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailEchelon(echelon: echelon);
                            },
                            color: null, // couleur null
                          ),
                          // if (hasPermission(
                          //   role: role,
                          //   permission:
                          //       PermissionAlias.updateBulletinEchelon.label,
                          // ))
                          (
                            label: Constant.edit,
                            onTap: () {
                              editLibelle(echelon: echelon);
                            },
                            color: null,
                          ),
                          // if (hasPermission(
                          //   role: role,
                          //   permission:
                          //       PermissionAlias.deleteBulletinEchelon.label,
                          // ))
                          (
                            label: Constant.delete,
                            onTap: () {
                              deleteLibelle(echelon: echelon);
                            },
                            color: null,
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
}
