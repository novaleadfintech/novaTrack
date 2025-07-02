import 'package:flutter/material.dart';
import 'package:frontend/app/pages/categories_paie/edit_categorie_paie.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/bulletin_paie/categorie_paie.dart';
import '../../../model/request_response.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../service/categorie_paie_service.dart';
import '../../../widget/confirmation_dialog_box.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../utils/libelle_flux.dart';

import '../app_dialog_box.dart';
import '../detail_pop.dart';
import '../../../global/constant/constant.dart';
import '../../../style/app_style.dart';
import '../../../widget/table_body_last.dart';
import '../../../widget/table_body_middle.dart';
import '../../../widget/table_header.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
 import 'detail_categorie_paie.dart';

class CategoriePaieTable extends StatefulWidget {
  final List<CategoriePaieModel> categories;
  final Future<void> Function() refresh;
  const CategoriePaieTable({
    super.key,
    required this.categories,
    required this.refresh,
  });

  @override
  State<CategoriePaieTable> createState() => _InputTableState();
}

class _InputTableState extends State<CategoriePaieTable> {
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
    role = await AuthService().getRole();
  }

  editCategoriePaie({
    required CategoriePaieModel categorie,
  }) {
    showResponsiveDialog(
      context,
      content: EditCategoriePaiePage(
        categorie: categorie,
        refresh: widget.refresh,
      ),
      title: "Modifier une catégorie de paie",
    );
  }

  detailCategoriePaie({required CategoriePaieModel categorie}) {
    showDetailDialog(
      context,
      content: DetailCategoriePaiePage(
        categorie: categorie,
      ),
      title: "Détail de moyen de paiement",
    );
  }

  Future<void> deleteCategoriePaie({
    required CategoriePaieModel categorie,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer le moyen de paiement \"${categorie.categoriePaie}\"?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await CategoriePaieService.deleteCategoriePaie(
        key: categorie.id,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Le categorie a été supprimé avec succcès",
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
              tablesTitles: categorieTableTitles,
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
                ...widget.categories.map(
                  (categorie) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: categorie.categoriePaie,
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailCategoriePaie(categorie: categorie);
                            },
                            color: null, // couleur null
                          ),
                          if (hasPermission(
                            role: role,
                            permission: PermissionAlias
                                .updateCategoriePaie.label,
                          ))
                            (
                              label: Constant.edit,
                              onTap: () {
                                editCategoriePaie(categorie: categorie);
                              },
                              color: null, // couleur null
                            ),
                          if (hasPermission(
                            role: role,
                            permission: PermissionAlias
                                .deleteCategoriePaie.label,
                          ))
                            (
                              label: Constant.delete,
                              onTap: () {
                                deleteCategoriePaie(categorie: categorie);
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
}
