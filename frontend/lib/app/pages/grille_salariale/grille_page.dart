import 'package:flutter/material.dart';
import 'package:frontend/app/pages/grille_salariale/add_categorie_paie.dart';
import 'package:frontend/app/pages/custom_popup.dart';
import 'package:frontend/app/pages/grille_salariale/grille_parameter_page.dart';
import 'package:frontend/model/grille_salariale/categorie_paie.dart';
import 'package:frontend/widget/app_action_button.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../widget/add_element_button.dart';
import '../../../../widget/research_bar.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../helper/paginate_data.dart';
import '../../../service/grille_categorie_paie_service.dart';
import '../../../widget/pagination.dart';
import '../app_dialog_box.dart';
import '../error_page.dart';
import '../no_data_page.dart';
import 'grille_categorie_paie_table.dart';

class GrilleCategoriePaiePage extends StatefulWidget {
  const GrilleCategoriePaiePage({
    super.key,
  });

  @override
  State<GrilleCategoriePaiePage> createState() =>
      _GrilleCategoriePaiePageState();
}

class _GrilleCategoriePaiePageState extends State<GrilleCategoriePaiePage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<GrilleCategoriePaieModel> grilleCategoriePaieData = [];
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
    _loadGrilleCategoriePaie();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadGrilleCategoriePaie() async {
    try {
      grilleCategoriePaieData =
          await GrilleCategoriePaieService.getGrilleCategoriePaies();
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

  List<GrilleCategoriePaieModel> filterGrilleCategoriePaie() {
    return grilleCategoriePaieData.where((grilleCategoriePaie) {
      return grilleCategoriePaie.libelle
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void onClickAddCategorieButton() {
    showResponsiveDialog(
      context,
      title: "Nouvelle catégorie de paie",
      content: AddCategoriePaiePage(
        refresh: _loadGrilleCategoriePaie,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<GrilleCategoriePaieModel> filteredData = filterGrilleCategoriePaie();

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
                // var canCreate = hasPermission(
                //   role: role,
                //   permission: PermissionAlias.createBulletinGrilleCategoriePaieCategoriePaie.label,
                // );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ResearchBar(
                      hintText: "Rechercher par libellé",
                      controller: _researchController,
                    ),
                    // if (canCreate)
                    Row(
                      children: [
                        // IconButton.filled(
                        //     onPressed: () {}, icon: Icon(Icons.settings)),
                        Container(
                          alignment: Alignment.centerRight,
                          child: AddElementButton(
                            addElement: onClickAddCategorieButton,
                            icon: Icons.add_outlined,
                            isSmall: true,
                            label: "Ajouter une catégorie",
                          ),
                        ),
                        Gap(8),
                        AppActionButton(
                          onPressed: () {
                            onClickOnParameter();
                          },
                          child: Icon(
                            Icons.settings,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          const Gap(4),
          Expanded(
            child: (isLoading)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : (hasError)
                    ? ErrorPage(
                message:
                    errorMessage ?? "Erreur lors du chargement des données.",
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                          await _loadGrilleCategoriePaie();
                },
                      )
                    : filteredData.isEmpty
                        ? NoDataPage(
                            data: filteredData,
                            message: "Aucune catégorie de paie.",
                          )
                        : Column(
                            children: [
                              Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: GrilleCategoriePaieTable(
                                  grilleCategoriePaie: getPaginatedData(
                                      data: filteredData,
                                      currentPage: currentPage),
                                  refresh: _loadGrilleCategoriePaie,
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

  void onClickOnParameter() {
    showCustomPoppup(
      context,
      content: GrilleParameterPage(),
      title: "Paramétrer la grille salariale",
    );
  }
}
