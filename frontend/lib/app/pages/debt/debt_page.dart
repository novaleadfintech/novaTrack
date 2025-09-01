import 'package:flutter/material.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../widget/add_element_button.dart';
import '../app_dialog_box.dart';
import 'add_debt.dart';
import 'debt_table.dart';
import '../../../helper/paginate_data.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../no_data_page.dart';
import '../../../global/global_value.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../model/flux_financier/type_flux_financier.dart';
import '../../../service/flux_financier_service.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import 'package:gap/gap.dart';
import '../error_page.dart';

class DebtPage extends StatefulWidget {
  const DebtPage({
    super.key,
  });

  @override
  State<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<DebtPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<FluxFinancierModel> fluxFinancierData = [];
  String? errorMessage;
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = "";
  String? selectedFilter;
  RoleModel? role;

  List<String> selectedFilterOptions = [
    "Tout",
    FluxFinancierStatus.wait.label,
    FluxFinancierStatus.reject.label,
    // FluxFinancierStatus.valid.label,
  ];
  @override
  void initState() {
    super.initState();
    getRole();
    _researchController.addListener(_onSearchChanged);
    _loadFluxFinancierData();
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
      fluxFinancierData = await FluxFinancierService.getDebt();
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
  }

  Future<void> getRole() async {
    try {
      setState(() {
        isLoading = true;
      });
      role = await AuthService().getRole();
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
  }

  void onClickAddFluxButton() {
    showResponsiveDialog(
      context,
      title: "Nouvelle dette",
      content: AddDebtPage(
        refresh: _loadFluxFinancierData,
        type: FluxFinancierType.output,
      ),
    );
  }

  void onSelected(String value) {
    setState(() {
      if (value == "Tout") {
        selectedFilter = null;
      } else {
        selectedFilter =
            selectedFilterOptions.firstWhere((element) => element == value);
      }
    });
  }

  List<FluxFinancierModel> filteredOutputData() {
    return fluxFinancierData.where((flux) {
      // Vérification de la recherche
      bool matchesSearch = flux.libelle!
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());

      // Vérification du filtre sélectionné
      bool matchesFilter =
          selectedFilter == null || flux.status!.label == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void onSelectedFilter(String value) {
    setState(() {
      selectedFilter = value == "Tout" ? null : value;
    });
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  // Future<void> getRole() async {
  //   role = await AuthService().getRole();
  // }

  // void onClickAddFluxButton() {
  //   showResponsiveDialog(
  //     context,
  //     title: "Nouvelle sortie financière",
  //     content: AddFluxPage(
  //       refresh: _loadFluxFinancierData,
  //       type: FluxFinancierType.output,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    List<FluxFinancierModel> filteredData = filteredOutputData();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (hasPermission(
          //     role: role,
          //     permission: PermissionAlias.createFluxFinancier.label))
          //   Container(
          //     alignment: Alignment.centerRight,
          //     child: AddElementButton(
          //       addElement: onClickAddFluxButton,
          //       icon: Icons.add_outlined,
          //       label: "Ajouter une sortie",
          //     ),
          //   ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ResearchBar(
                hintText: "Rechercher par libellé",
                controller: _researchController,
              ),
              if (hasPermission(
                  role: role!,
                  permission: PermissionAlias.createFluxFinancier.label))
                Container(
                  alignment: Alignment.centerRight,
                  child: AddElementButton(
                    addElement: onClickAddFluxButton,
                    icon: Icons.add_outlined,
                    label: "Ajouter une dette",
                  ),
                ),
            ],
          ),
          const Gap(4),
          if (isLoading || role == null)
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

                  await _loadFluxFinancierData();
                },
              ),
            )
          else
            Expanded(
              child: filteredData.isEmpty
                  ? NoDataPage(
                      data: filteredData,
                      message: "Aucune dette financière trouvée.",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: DebtTable(
                              role: role!,
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
