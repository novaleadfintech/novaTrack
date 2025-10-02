import 'package:flutter/material.dart';
import 'package:frontend/app/pages/categories/add_categorie.dart';
import 'package:frontend/app/pages/custom_popup.dart';
import 'package:frontend/app/pages/grille_salariale/grille_parameter_page.dart';
import 'package:frontend/widget/app_action_button.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../widget/add_element_button.dart';
import '../../../../widget/research_bar.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import '../app_dialog_box.dart';
import '../error_page.dart';

class GrillePage extends StatefulWidget {
  const GrillePage({
    super.key,
  });

  @override
  State<GrillePage> createState() => _GrillePageState();
}

class _GrillePageState extends State<GrillePage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  // List<GrilleBulletin> sectionData = [];
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
    _loadGrille();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadGrille() async {
    try {
      // sectionData = await GrilleService.getGrilles();
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

  // List<GrilleBulletin> filterGrille() {
  //   return sectionData.where((section) {
  //     return section.section
  //         .toLowerCase()
  //         .contains(searchQuery.toLowerCase().trim());
  //   }).toList();
  // }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void onClickAddCategorieButton() {
    showResponsiveDialog(
      context,
      title: "Nouvelle section",
      content: AddCategoriePage(
        refresh: _loadGrille,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // List<GrilleBulletin> filteredData = filterGrille();

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
                //   permission: PermissionAlias.createBulletinGrille.label,
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
                  await _loadGrille();
                },
              ),
            )
          // else
          // Expanded(
          //   child: filteredData.isEmpty
          //       ? NoDataPage(
          //           data: filteredData,
          //           message: "Aucun libellé",
          //         )
          //       : Column(
          //           children: [
          //             Expanded(
          //               child: Container(
          //                 color: Theme.of(context).colorScheme.surface,
          //                 child: GrilleTable(
          //                   section: getPaginatedData(
          //                       data: filteredData, currentPage: currentPage),
          //                   refresh: _loadGrille,
          //                 ),
          //               ),
          //             ),
          //             if (filteredData.isNotEmpty)
          //               PaginationSpace(
          //                 currentPage: currentPage,
          //                 onPageChanged: updateCurrentPage,
          //                 filterDataCount: filteredData.length,
          //               ),
          //           ],
          //         ),
          // ),
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
