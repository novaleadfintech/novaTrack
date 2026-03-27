import 'package:flutter/material.dart';
import 'package:frontend/app/pages/configure_page_dialog.dart';
import 'package:frontend/model/bulletin_paie/bulletin_categorie_model.dart';
import 'package:frontend/style/app_color.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../helper/user_helper.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import 'rubrique_categorie_config_page.dart';
 
class BulletinCategorieRubriqueTable extends StatefulWidget {
  final List<BulletinCategorieModel> bulletinCategories;
  final Future<void> Function() refresh;
  const BulletinCategorieRubriqueTable({
    super.key,
    required this.bulletinCategories,
    required this.refresh,
  });

  @override
  State<BulletinCategorieRubriqueTable> createState() => _InputTableState();
}

class _InputTableState extends State<BulletinCategorieRubriqueTable> {
  late RoleModel role;
  late Future<void> _futureRoles;

  @override
  void initState() {
    _futureRoles = getRole();
    super.initState();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  // detailBulletinCategorieRubrique({required paieCategorieModel bulletincategorie}) {
  //   showDetailDialog(
  //     context,
  //     content: DetailBulletinCategorieRubriquePage(
  //       bulletincategorie: bulletincategorie,
  //     ),
  //     title: "Détail de moyen de paiement",
  //   );
  // }

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
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              columnWidths: {
                0: const FlexColumnWidth(),
                1: const IntrinsicColumnWidth()
              },
              children: [
                ...widget.bulletinCategories.map(
                  (bulletinCategorie) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: bulletinCategorie.bulletinCategorie,
                      ),
                      if (hasPermission(
                        role: role,
                        permission:
                            PermissionAlias
                            .assignRubriqueBulletinCategorie.label,
                      ))
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: IconButton(
                          onPressed: () {
                            showResponsiveConfigPageDialogBox(
                              context,
                              content: RubriqueCategorieConfigPage(
                                  bulletinCategorie: bulletinCategorie,
                              ),
                              title:
                                    "Configuration des catégories de paie - ${bulletinCategorie.bulletinCategorie}",
                            );
                          },
                          icon: Icon(
                            Icons.settings,
                            color: AppColor.primaryColor,
                          ),
                        ),
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
