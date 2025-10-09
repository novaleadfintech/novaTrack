import 'package:flutter/material.dart';
import 'package:frontend/model/grille_salariale/echelon_model.dart';
import 'package:frontend/service/echelon_service.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../widget/add_element_button.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../app_dialog_box.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';
import 'add_echelon.dart';
import 'elon_table.dart';

class EchelonPage extends StatefulWidget {
  const EchelonPage({
    super.key,
  });

  @override
  State<EchelonPage> createState() => _EchelonPageState();
}

class _EchelonPageState extends State<EchelonPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<EchelonModel> echelonData = [];
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
    _loadEchelon();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadEchelon() async {
    try {
      echelonData = await EchelonService.getEchelons();
    } catch (error) {
      debugPrint(error.toString());
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

  List<EchelonModel> filterEchelon() {
    return echelonData.where((poste) {
      return poste.libelle
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
      title: "Nouveau échelon",
      content: AddEchelon(
        refresh: _loadEchelon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<EchelonModel> filteredData = filterEchelon();

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
                //   permission: PermissionAlias.createEchelon.label,
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
                        label: "Ajouter un échelon",
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const Gap(4),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : hasError
                    ? ErrorPage(
                        message: errorMessage ??
                            "Erreur lors du chargement des données.",
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                            hasError = false;
                          });
                          await _loadEchelon();
                        },
                      )
                    : filteredData.isEmpty
                        ? NoDataPage(
                            data: filteredData,
                            message: "Aucun echelon trouvé",
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: EchelonTable(
                                  echelons: getPaginatedData(
                                    data: filteredData,
                                    currentPage: currentPage,
                                  ),
                                  refresh: _loadEchelon,
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
