import 'package:flutter/material.dart';
import 'package:frontend/helper/paginate_data.dart';
import 'package:gap/gap.dart';
import '../../../global/global_value.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../model/flux_financier/type_flux_financier.dart';
import '../../../model/habilitation/role_model.dart';
import '../../../service/flux_financier_service.dart';
import '../../../widget/filter_bar.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import '../error_page.dart';
import '../no_data_page.dart';
import 'flux_table.dart';

class ArchivesPage extends StatefulWidget {
  final RoleModel role;
  const ArchivesPage({
    super.key,
required this.role,
  });

  @override
  State<ArchivesPage> createState() => _ArchivesPageState();
}

class _ArchivesPageState extends State<ArchivesPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<FluxFinancierModel> fluxFinancierData = [];
  bool isLoading = true;
  bool hasError = false;
  String errMessage = "";
  String searchQuery = "";
  String? selectedFilter;

  @override
  void initState() {
    super.initState();
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
    FluxFinancierStatus.reject.label,
    FluxFinancierStatus.valid.label,
  ];

  Future<void> _loadFluxFinancierData() async {
    try {
      fluxFinancierData = await FluxFinancierService.getArchiveFlux();
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

  @override
  Widget build(BuildContext context) {
    List<FluxFinancierModel> filteredData = filterFluxFinancierData();

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
                label: selectedFilter == null
                    ? "Filtrer par statut"
                    : selectedFilter!,
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
                      message: "Aucune archive financière",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: FinanceTable(
                              role: widget.role,
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
