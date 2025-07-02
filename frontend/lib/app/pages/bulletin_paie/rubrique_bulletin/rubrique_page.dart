import 'package:flutter/material.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/paginate_data.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:frontend/service/bulletin_rubrique_service.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../model/bulletin_paie/rubrique.dart';
import '../../../../widget/add_element_button.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../app_dialog_box.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import 'add_rubrique.dart';
import 'rubrique_table.dart';

class RubriquePaiePage extends StatefulWidget {
  const RubriquePaiePage({
    super.key,
  });

  @override
  State<RubriquePaiePage> createState() => _RubriquePaiePageState();
}

class _RubriquePaiePageState extends State<RubriquePaiePage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<RubriqueBulletin> rubriqueClientData = [];
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
    _loadRubrique();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
    setState(() {
    
  });
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadRubrique() async {
    try {
      rubriqueClientData = await BulletinRubriqueService.getBulletinRubriques();
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
        errorMessage = error.toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  List<RubriqueBulletin> filterRubriquePaie() {
    return rubriqueClientData.where((rubrique) {
      return rubrique.rubrique
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
      title: "Nouvelle rubrique de bulletin",
      content: AddRubriquePage(
        refresh: _loadRubrique,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<RubriqueBulletin> filteredData = filterRubriquePaie();

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
                  permission: PermissionAlias.createBulletinRubrique.label,
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
                        label: "Ajouter une catégorie",
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
                  await _loadRubrique();
                },
              ),
            )
          else
            Expanded(
              child: filteredData.isEmpty
                  ? NoDataPage(
                      data: filteredData,
                      message: "Aucune rubrique",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: RubriqueTable(
                              rubriques: getPaginatedData(
                                data: filteredData,
                                currentPage: currentPage,
                              ),
                              refresh: _loadRubrique,
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
