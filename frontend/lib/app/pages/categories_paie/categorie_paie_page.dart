import 'package:flutter/material.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/paginate_data.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:gap/gap.dart';
import '../../../global/global_value.dart';
import '../../../model/bulletin_paie/categorie_paie.dart';
import '../../../service/categorie_paie_service.dart';
import '../../../widget/add_element_button.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import '../app_dialog_box.dart';
import '../error_page.dart';
import '../no_data_page.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
 import 'add_categorie_paie.dart';
import 'categorie_paie_table.dart';

class CategoriePaiePage extends StatefulWidget {
  const CategoriePaiePage({
    super.key,
  });

  @override
  State<CategoriePaiePage> createState() => _CategoriePaieClientPageState();
}

class _CategoriePaieClientPageState extends State<CategoriePaiePage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<CategoriePaieModel> categoriePaieData = [];
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = "";
  late Future<void> _futureRoles;
  late List<RoleModel> roles = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _futureRoles = getRoles();
    _loadCategoriePaie();
  }

  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadCategoriePaie() async {
    try {
      categoriePaieData = await CategoriePaieService.getPaieCategories();
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

  List<CategoriePaieModel> filterCategoriePaieClient() {
    return categoriePaieData.where((categoriePaie) {
      return categoriePaie.categoriePaie
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
      title: "Nouveau catégorie de paie",
      content: AddCategoriePaiePage(
        refresh: _loadCategoriePaie,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<CategoriePaieModel> filteredData = filterCategoriePaieClient();

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
                  roles: roles,
                  permission: PermissionAlias.createCategoriePaie.label,
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
                        label: "Ajouter une catégorie de paie",
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
                  await _loadCategoriePaie();
                },
              ),
            )
          else
            Expanded(
              child: filteredData.isEmpty
                  ? NoDataPage(
                      data: filteredData,
                      message: "Aucune catégorie de paie",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: CategoriePaieTable(
                              categories: getPaginatedData(
                                  data: filteredData, currentPage: currentPage),
                              refresh: _loadCategoriePaie,
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
