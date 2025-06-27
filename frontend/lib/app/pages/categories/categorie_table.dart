import 'package:flutter/material.dart';
import 'package:frontend/app/pages/categories/edit_categorie.dart';
import 'package:frontend/model/client/categorie_model.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/request_response.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../service/categorie_service.dart';
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
 import 'detail_categorie.dart';

class CategorieTable extends StatefulWidget {
  final List<CategorieModel> categories;
  final Future<void> Function() refresh;
  const CategorieTable({
    super.key,
    required this.categories,
    required this.refresh,
  });

  @override
  State<CategorieTable> createState() => _InputTableState();
}

class _InputTableState extends State<CategorieTable> {
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
  }

  editLibelle({
    required CategorieModel categorie,
  }) {
    showResponsiveDialog(
      context,
      content: EditCategoriePage(
        categorie: categorie,
        refresh: widget.refresh,
      ),
      title: "Modifier un moyen de paiement",
    );
  }

  detailCategorie({required CategorieModel categorie}) {
    showDetailDialog(
      context,
      content: DetailCategoriePage(
        categorie: categorie,
      ),
      title: "Détail de moyen de paiement",
    );
  }

  Future<void> deleteLibelle({
    required CategorieModel categorie,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer le moyen de paiement \"${categorie.libelle}\"?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result = await CategorieService.deleteCategorie(
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
                        valeur: categorie.libelle.toUpperCase(),
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailCategorie(categorie: categorie);
                            },
                            color: null, // couleur null
                          ),
                          if (hasPermission(
                            roles: roles,
                            permission: PermissionAlias
                                .updateCategorieClient.label,
                          ))
                            (
                              label: Constant.edit,
                              onTap: () {
                                editLibelle(categorie: categorie);
                              },
                              color: null, // couleur null
                            ),
                          if (hasPermission(
                            roles: roles,
                            permission: PermissionAlias
                                .deleteCategorieClient.label,
                          ))
                            (
                              label: Constant.delete,
                              onTap: () {
                                deleteLibelle(categorie: categorie);
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
