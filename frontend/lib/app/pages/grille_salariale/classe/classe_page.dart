import 'package:flutter/material.dart';
import 'package:frontend/app/pages/grille_salariale/classe/add_classe.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../model/grille_salariale/classe_model.dart';
import '../../../../service/classe_service.dart';
import '../../../../widget/add_element_button.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../app_dialog_box.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';
import 'classe_table.dart';
 
class ClassePage extends StatefulWidget {
  const ClassePage({
    super.key,
  });

  @override
  State<ClassePage> createState() => _ClassePageState();
}

class _ClassePageState extends State<ClassePage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<ClasseModel> classeData = [];
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
    _loadClasse();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadClasse() async {
    try {
      classeData = await ClasseService.getClasses();
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

  List<ClasseModel> filterClasse() {
    return classeData.where((classe) {
      return classe.libelle
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
      title: "Nouvelle classe",
      content: AddClasse(
        refresh: _loadClasse,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ClasseModel> filteredData = filterClasse();
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
                //   permission: PermissionAlias.createClasse.label,
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
                    Container(
                      alignment: Alignment.centerRight,
                      child: AddElementButton(
                        addElement: onClickAddFluxButton,
                        icon: Icons.add_outlined,
                        isSmall: true,
                        label: "Ajouter une classe",
                      ),
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
                          await _loadClasse();
                        },
                      )
                    : filteredData.isEmpty
                        ? NoDataPage(
                            data: filteredData,
                            message: "Aucune classe de grille salariale.",
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: ClasseTable(
                                    classe: getPaginatedData(
                                      data: filteredData,
                                      currentPage: currentPage,
                                    ),
                                    refresh: _loadClasse,
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

