import 'package:flutter/material.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/paginate_data.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:gap/gap.dart';
import '../../../global/global_value.dart';
import '../../../model/bulletin_paie/bulletin_categorie.dart';
import '../../../service/categorie_bulletin_service.dart';
import '../../../widget/add_element_button.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import '../app_dialog_box.dart';
import '../error_page.dart';
import '../no_data_page.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import 'add_categorie_bulletin.dart';
import 'categorie_bulletin_table.dart';

class BulletinCategoriePage extends StatefulWidget {
  const BulletinCategoriePage({
    super.key,
  });

  @override
  State<BulletinCategoriePage> createState() => _BulletinCategoriePageState();
}

class _BulletinCategoriePageState extends State<BulletinCategoriePage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<BulletinCategorieModel> bulletinCategorieData = [];
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = "";
  late Future<void> _futureRoles;
  late RoleModel role;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _futureRoles = getRole();
    _loadBulletinCategorie();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadBulletinCategorie() async {
    try {
      bulletinCategorieData =
          await BulletinCategorieservice.getBulletinCategories();
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        hasError = true;
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  List<BulletinCategorieModel> filterBulletinCategorie() {
    return bulletinCategorieData.where((bulletinCategorie) {
      return bulletinCategorie.bulletinCategorie
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void onClickAddFluxButton() {
    showResponsiveDialog(
      context,
      title: "Nouveau catégorie de bulletin",
      content: AddBulletinCategoriePage(
        refresh: _loadBulletinCategorie,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<BulletinCategorieModel> filteredData = filterBulletinCategorie();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<void>(
            future: _futureRoles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const SizedBox();
              } else {
                bool canCreate = hasPermission(
                  role: role,
                  permission: PermissionAlias.createBulletinCategorie.label,
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ResearchBar(
                      hintText: "Rechercher par libellé",
                      controller: _researchController,
                    ),
                     if (canCreate)
                    Container(
                      alignment: Alignment.centerRight,
                      child: AddElementButton(
                        addElement: onClickAddFluxButton,
                        icon: Icons.add_outlined,
                        isSmall: true,
                        label: "Ajouter une catégorie de bulletin",
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const Gap(4),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (hasError)
            Expanded(
              child: ErrorPage(
                message:
                    errorMessage ?? "Erreur lors du chargement des données.",
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                  await _loadBulletinCategorie();
                },
              ),
            )
          else
            Expanded(
              child: filteredData.isEmpty
                  ? NoDataPage(
                      data: filteredData,
                      message: "Aucune catégorie de bulletin",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: BulletinCategorieTable(
                              categories: getPaginatedData(
                                  data: filteredData, currentPage: currentPage),
                              refresh: _loadBulletinCategorie,
                            ),
                          ),
                        ),
                        if (filteredData.isNotEmpty)
                          PaginationSpace(
                            currentPage: currentPage,
                            onPageChanged: updateCurrentPage,
                            filterDataCount: filteredData.length,
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
