import 'package:flutter/material.dart';
import 'package:frontend/app/pages/configure_page_dialog.dart';
import 'package:frontend/style/app_color.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/bulletin_paie/categorie_paie.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import 'rubrique_categorie_config_page.dart';
 
class CategorieRubriqueTable extends StatefulWidget {
  final List<CategoriePaieModel> categories;
  final Future<void> Function() refresh;
  const CategorieRubriqueTable({
    super.key,
    required this.categories,
    required this.refresh,
  });

  @override
  State<CategorieRubriqueTable> createState() => _InputTableState();
}

class _InputTableState extends State<CategorieRubriqueTable> {
  late List<RoleModel> roles = [];
  late Future<void> _futureRoles;

  @override
  void initState() {
    _futureRoles = getRoles();
    super.initState();
  }

  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
  }

  // detailCategorieRubrique({required CategoriePaieModel categorie}) {
  //   showDetailDialog(
  //     context,
  //     content: DetailCategorieRubriquePage(
  //       categorie: categorie,
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
                ...widget.categories.map(
                  (categorie) => TableRow(
                    decoration: tableDecoration(context),
                    children: [
                      TableBodyMiddle(
                        valeur: categorie.categoriePaie,
                      ),
                      if (hasPermission(
                        roles: roles,
                        permission:
                            PermissionAlias.assignRubriqueCategoriePaie.label,
                      ))
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: IconButton(
                          onPressed: () {
                            showResponsiveConfigPageDialogBox(
                              context,
                              content: RubriqueCategorieConfigPage(
                                categoriePaie: categorie,
                              ),
                              title:
                                  "Configuration des catégories de paie - ${categorie.categoriePaie}",
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
