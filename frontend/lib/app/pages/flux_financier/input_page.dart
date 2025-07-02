import 'package:flutter/material.dart';
import 'package:frontend/helper/paginate_data.dart';
import 'package:gap/gap.dart';
import '../../../auth/authentification_token.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../global/global_value.dart';
import '../../../helper/user_helper.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../model/flux_financier/type_flux_financier.dart';
import '../../../model/habilitation/role_model.dart';
import '../../../service/flux_financier_service.dart';
import '../../../widget/add_element_button.dart';
import '../../../widget/filter_bar.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import '../app_dialog_box.dart';
import '../error_page.dart';
import '../no_data_page.dart';
import 'add_flux_page.dart';
import 'flux_table.dart';

class InputPage extends StatefulWidget {
  const InputPage({
    super.key,
  });

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<FluxFinancierModel> fluxFinancierData = [];
  bool isLoading = true;
  bool hasError = false;
  String errMessage = "";
  String searchQuery = "";
  String? selectedFilter;
  late RoleModel role;

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

  List<String> selectedFilterOptions = [
    "Tout",
    FluxFinancierStatus.wait.label,
    FluxFinancierStatus.returne.label,
    // FluxFinancierStatus.valid.label,
  ];

  Future<void> _loadFluxFinancierData() async {
    try {
      fluxFinancierData = await FluxFinancierService.getInputs();
    } catch (error) {
      setState(() {
        hasError = true;
        errMessage = error.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

  List<FluxFinancierModel> filterFluxFinancierData() {
    return fluxFinancierData.where((flux) {
      // Vérification de la recherche
      bool matchesSearch = flux.libelle!
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());

      // Vérification du filtre sélectionné
bool matchesFilter =
          selectedFilter == null || flux.status!.label == selectedFilter;
      // if (selectedFilter != null) {
      //   switch (selectedFilter) {
      //     case "Validé":
      //       matchesFilter = flux.validated?.validateStatus == true;
      //       break;
      //     case "En attente":
      //       matchesFilter = flux.validated == null;
      //       break;
      //     case "Rejeté":
      //       matchesFilter = flux.validated?.validateStatus == false;
      //       break;
      //   }
      // }

      return matchesSearch && matchesFilter;
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
      title: "Nouvelle entrée financière",
      content: AddFluxPage(
        refresh: _loadFluxFinancierData,
        type: FluxFinancierType.input,
      ),
    );
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }
  @override
  Widget build(BuildContext context) {
    List<FluxFinancierModel> filteredData = filterFluxFinancierData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPermission(
              role: role,
                  permission: PermissionAlias.createFluxFinancier.label))
          Container(
            alignment: Alignment.centerRight,
            child: AddElementButton(
              addElement: onClickAddFluxButton,
              icon: Icons.add_outlined,
              label: "Ajouter une entrée",
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ResearchBar(
                hintText: "Rechercher par libellé",
                controller: _researchController,
              ),
              FilterBar(
                label: selectedFilter == null ? "Filtrer par statut" : selectedFilter!,
                items: selectedFilterOptions,
                onSelected: onSelected,
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
                message: errMessage.isEmpty
                    ? "Erreur lors du chargement des données."
                    : errMessage,
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
                      message: "Aucune entrée financière",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: FinanceTable(
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
