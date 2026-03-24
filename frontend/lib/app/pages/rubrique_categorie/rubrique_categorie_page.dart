import 'package:flutter/material.dart';
import 'package:frontend/helper/paginate_data.dart';
import 'package:frontend/model/bulletin_paie/bulletin_categorie.dart';
import 'package:frontend/service/categorie_bulletin_service.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
 import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
 import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
 import '../error_page.dart';
import '../no_data_page.dart';
import 'rubrique_categorie_table.dart';

class RubriquepaieCategorie extends StatefulWidget {
  const RubriquepaieCategorie({
    super.key,
  });

  @override
  State<RubriquepaieCategorie> createState() => _paieCategorieClientPageState();
}

class _paieCategorieClientPageState extends State<RubriquepaieCategorie> {
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
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ResearchBar(
                      hintText: "Rechercher par libellé",
                      controller: _researchController,
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
                      message: "Aucune catégorie de bulletin trouvée.",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: BulletinCategorieRubriqueTable(
                              bulletinCategories: getPaginatedData(
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
