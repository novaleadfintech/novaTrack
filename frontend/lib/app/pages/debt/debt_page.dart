import 'package:flutter/material.dart';
import 'package:frontend/service/debt_service.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/flux_financier/debt_model.dart';
import '../../../widget/add_element_button.dart';
import '../app_dialog_box.dart';
import 'add_debt.dart';
import 'debt_table.dart';
import '../../../helper/paginate_data.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../no_data_page.dart';
import '../../../global/global_value.dart';
 import '../../../model/flux_financier/type_flux_financier.dart';
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
  List<DebtModel> fluxFinancierData = [];
  String? errorMessage;
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = "";
  String? selectedFilter;
  RoleModel? role;

  List<String> selectedFilterOptions = [
    "Tout",
    DebtStatus.paid.label,
    DebtStatus.unpaid.label,
    // DebtStatus.valid.label,
  ];

  @override
  void initState() {
    super.initState();
    getRole();
    _researchController.addListener(_onSearchChanged);
    _loadDebtData();
  }

  @override
  void dispose() {
    _researchController.removeListener(_onSearchChanged);
    _researchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadDebtData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });
    try {
      fluxFinancierData = await DebtService.getDebts();
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
      role = await AuthService().getRole();
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        hasError = true;
        isLoading = false;
      });
    }
  }

  void onClickAddFluxButton() {
    showResponsiveDialog(
      context,
      title: "Nouvelle dette",
      content: AddDebtPage(
        refresh: _loadDebtData,
      ),
    );
  }

  List<DebtModel> filteredOutputData() {
    return fluxFinancierData.where((flux) {
      // Vérification de la recherche
      bool matchesSearch = flux.libelle != null &&
          flux.libelle!
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim());

      // Vérification du filtre sélectionné
      bool matchesFilter = selectedFilter == null ||
          (flux.status != null && flux.status!.label == selectedFilter);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (hasError) {
      return ErrorPage(
        message: errorMessage ?? "Erreur lors du chargement des données.",
        onPressed: () async {
          await _loadDebtData();
        },
      );
    }

    List<DebtModel> filteredData = filteredOutputData();

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
              // TODO METTRE CREATE DEBT
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
                            debts: getPaginatedData(
                              data: filteredData,
                              currentPage: currentPage,
                            ),
                            refresh: _loadDebtData,
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
