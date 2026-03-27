import 'package:flutter/material.dart';
import 'package:frontend/app/pages/categories_bulletin/edit_categorie_bulletin.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/bulletin_paie/bulletin_categorie_model.dart';
import '../../../model/request_response.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../service/bulletin_categorie_service.dart';
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
import 'detail_categorie_bulletin.dart';

class BulletinCategorieTable extends StatefulWidget {
  final List<BulletinCategorieModel> categories;
  final Future<void> Function() refresh;
  const BulletinCategorieTable({
    super.key,
    required this.categories,
    required this.refresh,
  });

  @override
  State<BulletinCategorieTable> createState() => _BulletinCategorieTableState();
}

class _BulletinCategorieTableState extends State<BulletinCategorieTable> {
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

  editBulletinCategorie({
    required BulletinCategorieModel bulletinCategorie,
  }) {
    showResponsiveDialog(
      context,
      content: EditBulletinCategoriePage(
        bulletinCategorie: bulletinCategorie,
        refresh: widget.refresh,
      ),
      title: "Modifier une catégorie de bulletin",
    );
  }

  detailBulletinCategorie({required BulletinCategorieModel bulletinCategorie}) {
    showDetailDialog(
      context,
      content: DetailBulletinCategoriePage(
        bulletinCategorie: bulletinCategorie,
      ),
      title: "Détail de catégorie de bulletin",
    );
  }

  Future<void> deleteBulletinCategorie({
    required BulletinCategorieModel bulletinCategorie,
  }) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Voulez-vous vraiment supprimer la catégorie de bulletin \"${bulletinCategorie.bulletinCategorie}\"?",
    );
    if (confirmed) {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result =
          await BulletinCategorieservice.deleteBulletinCategorie(
        key: bulletinCategorie.key,
      );
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "La catégorie a été supprimée avec succès",
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
                  (bulletinCategorie) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: bulletinCategorie.bulletinCategorie,
                      ),
                      TableBodyLast(
                        items: [
                          (
                            label: Constant.detail,
                            onTap: () {
                              detailBulletinCategorie(
                                  bulletinCategorie: bulletinCategorie);
                            },
                            color: null,
                          ),
                          if (hasPermission(
                            role: role,
                            permission: PermissionAlias
                                .updateBulletinCategorie.label,
                          ))
                            (
                              label: Constant.edit,
                              onTap: () {
                                editBulletinCategorie(
                                    bulletinCategorie: bulletinCategorie);
                              },
                              color: null,
                            ),
                          if (hasPermission(
                            role: role,
                            permission: PermissionAlias
                                .deleteBulletinCategorie.label,
                          ))
                            (
                              label: Constant.delete,
                              onTap: () {
                                deleteBulletinCategorie(
                                    bulletinCategorie: bulletinCategorie);
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
