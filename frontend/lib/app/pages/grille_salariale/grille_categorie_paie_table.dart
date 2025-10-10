import 'package:flutter/material.dart';
import 'package:frontend/helper/string_helper.dart';
import '../../../../model/request_response.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../widget/confirmation_dialog_box.dart';
import '../../../../global/constant/constant.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_last.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../../widget/table_header.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../model/grille_salariale/categorie_paie.dart';
 import '../../../service/grille_categorie_paie_service.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../app_dialog_box.dart';
import '../detail_pop.dart';
import '../utils/grille_salariale_util.dart';
import 'detail_grille_categorie_paie.dart';
import 'edit_grille_categorie_paie.dart';

class GrilleCategoriePaieTable extends StatefulWidget {
  final List<GrilleCategoriePaieModel> grilleCategoriePaie;
  final Future<void> Function() refresh;
  const GrilleCategoriePaieTable({
    super.key,
    required this.grilleCategoriePaie,
    required this.refresh,
  });

  @override
  State<GrilleCategoriePaieTable> createState() =>
      _GrilleCategoriePaieTableState();
}

class _GrilleCategoriePaieTableState extends State<GrilleCategoriePaieTable> {
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
    required GrilleCategoriePaieModel grilleCategoriePaie,
  }) {
    showResponsiveDialog(
      context,
      content: EditGrilleCategoriePaiePage(
        // grilleCategoriePaie: grilleCategoriePaie,
        refresh: widget.refresh,
      ),
      title: "Modifier un grilleCategoriePaie",
    );
  }

  detailGrilleCategoriePaie(
      {required GrilleCategoriePaieModel grilleCategoriePaie}) {
    showDetailDialog(
      context,
      content: DetailGrilleCategoriePaiePage(
        grilleCategoriePaie: grilleCategoriePaie,
      ),
      title: "Détail de grilleCategoriePaie",
    );
  }

  Future<void> deleteGrilleCategoriePaie({
    required GrilleCategoriePaieModel grilleCategoriePaie,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer la grilleCategoriePaie de bulletin \"${grilleCategoriePaie.libelle}\"?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result =
          await GrilleCategoriePaieService.deleteGrilleCategoriePaie(
        key: grilleCategoriePaie.id,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Le grilleCategoriePaie a été supprimé avec succcès",
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
              tablesTitles: grilleCategoriePaieTableTitles,
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
                ...widget.grilleCategoriePaie.map(
                  (grilleCategoriePaie) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: capitalizeFirstLetter(
                            word: grilleCategoriePaie.libelle),
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailGrilleCategoriePaie(
                                  grilleCategoriePaie: grilleCategoriePaie);
                            },
                            color: null, // couleur null
                          ),
                          // if (hasPermission(
                          //   role: role,
                          //   permission: PermissionAlias.updateGrilleCategoriePaie.label,
                          // ))
                          (
                            label: Constant.edit,
                            onTap: () {
                              editLibelle(
                                  grilleCategoriePaie: grilleCategoriePaie);
                            },
                            color: null,
                          ),
                          // if (hasPermission(
                          //   role: role,
                          //   permission: PermissionAlias
                          //       .deleteGrilleCategoriePaie.label,
                          // ))
                          //   (
                          //     label: Constant.delete,
                          //     onTap: () {
                          //       deleteLibelle(grilleCategoriePaie: grilleCategoriePaie);
                          //     },
                          //     color: null,
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
