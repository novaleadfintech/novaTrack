import 'package:flutter/material.dart';
import 'package:frontend/app/pages/grille_salariale/add_categorie_paie.dart';
import 'package:frontend/app/pages/custom_popup.dart';
import 'package:frontend/app/pages/grille_salariale/grille_parameter_page.dart';
import 'package:frontend/app/responsitvity/responsivity.dart';
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

class GrillepaieCategoriePage extends StatefulWidget {
  const GrillepaieCategoriePage({
    super.key,
  });

  @override
  State<GrillepaieCategoriePage> createState() =>
      _GrillepaieCategoriePageState();
}

class _GrillepaieCategoriePageState extends State<GrillepaieCategoriePage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<GrillepaieCategorieModel> grillepaieCategorieData = [];
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
    _loadGrillepaieCategorie();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadGrillepaieCategorie() async {
    try {
      grillepaieCategorieData =
          await GrillepaieCategorieService.getGrillepaieCategories();
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

  List<GrillepaieCategorieModel> filterGrillepaieCategorie() {
    return grillepaieCategorieData.where((grillepaieCategorie) {
      return grillepaieCategorie.libelle
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
      content: AddGrillepaieCategoriePage(
        refresh: _loadGrillepaieCategorie,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<GrillepaieCategorieModel> filteredData = filterGrillepaieCategorie();

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        floatingActionButton: FloatingActionButton(
          onPressed: onClickAddCategorieButton,
          mini: true,
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        body: Padding(
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
                    //   permission: PermissionAlias.createBulletinGrillepaieCategoriepaieCategorie.label,
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
                            if (!Responsive.isMobile(context)) ...[
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
                            ],
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
                        message: errorMessage ??
                            "Erreur lors du chargement des données.",
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                            hasError = false;
                          });
                              await _loadGrillepaieCategorie();
                        },
                      )
                    : filteredData.isEmpty
                        ? NoDataPage(
                            data: filteredData,
                            message: "Aucune catégorie de paie.",
                          )
                        : Column(
                            children: [
                              Expanded(
                                    child: GrillepaieCategorieTable(
                                      grillepaieCategorie: getPaginatedData(
                                      data: filteredData,
                                      currentPage: currentPage),
                                      refresh: _loadGrillepaieCategorie,
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
      
        ));
  }

  void onClickOnParameter() {
    showCustomPoppup(
      context,
      content: GrilleParameterPage(),
      title: "Paramétrer la grille salariale",
    );
  }
}
