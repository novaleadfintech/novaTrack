import 'package:flutter/material.dart';
import 'package:frontend/app/pages/flux_financier/validation_table.dart';
import 'package:frontend/helper/paginate_data.dart';
import '../../../auth/authentification_token.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/habilitation/role_model.dart';
import '../../../model/habilitation/user_model.dart';
import '../../../widget/filter_bar.dart';
import 'add_flux_page.dart';
import '../no_data_page.dart';
import '../../../global/global_value.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../model/flux_financier/type_flux_financier.dart';
import '../../../service/flux_financier_service.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import 'package:gap/gap.dart';
import '../app_dialog_box.dart';
import '../error_page.dart';

class ValidationPage extends StatefulWidget {
  final RoleModel role;

  const ValidationPage({
    super.key,
    required this.role,
  });

  @override
  State<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<FluxFinancierModel> fluxFinancierData = [];
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = "";
  String selectedFilter = "Autre";
  late RoleModel role;

  String? errorMessage;
  UserModel? user;
  Future<void> getCurrentUser() async {
    UserModel? currentUser = await AuthService().decodeToken();
    setState(() {
      user = currentUser;
    });
  }


  List<String> selectedFilterOptions = [
    "Autre",
    "Pour moi",
  ];

  @override
  void initState() {
    role = widget.role; // getRole();
    _researchController.addListener(_onSearchChanged);
    _initializeData();
    super.initState();
    
  }

  Future<void> _initializeData() async {
    await getCurrentUser();
    // await getRole();
    await _loadFluxFinancierData();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadFluxFinancierData() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (hasPermission(
          role: role,
              permission: PermissionAlias.validFluxFinancier.label)) {
        fluxFinancierData = await FluxFinancierService.getUnValidatedFlux();
      } else {
        fluxFinancierData = (await FluxFinancierService.getUnValidatedFlux())
            .where((flux) => flux.user?.equalTo(user: user!) ?? false)
            .toList();
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    setState(() {});
  }

  List<FluxFinancierModel> filterValidateFlux() {
    return fluxFinancierData.where((flux) {
      bool matchesFilter = true;
      final matchesSearch = flux.libelle!
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
      if (selectedFilterOptions.last == selectedFilter) {
        matchesFilter = flux.user!.equalTo(user: user!);
      } else {
        matchesFilter = !flux.user!.equalTo(user: user!);
      }
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void onSelectedFilter(String value) {
    setState(() {
      selectedFilter = value;
    });
  }

  void onClickAddFluxButton() {
    showResponsiveDialog(
      context,
      title: "Nouvelle sortie financière",
      content: AddFluxPage(
        refresh: _loadFluxFinancierData,
        type: FluxFinancierType.output,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    List<FluxFinancierModel> filteredData = filterValidateFlux();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ResearchBar(
                hintText: "Rechercher par libellé",
                controller: _researchController,
              ),
              FilterBar(
                label: selectedFilter,
                items: selectedFilterOptions,
                onSelected: onSelectedFilter,
              ),
            ],
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
                  await _loadFluxFinancierData();
                },
              ),
            )
          else
            Expanded(
              child: filteredData.isEmpty
                  ? NoDataPage(
                      data: filteredData,
                      message: "Aucun flux à valider",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: ValidationTable(
                              fluxFinanciers: getPaginatedData(
                                data: filteredData,
                                currentPage: currentPage,
                              ),
                              refresh: _loadFluxFinancierData,
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
