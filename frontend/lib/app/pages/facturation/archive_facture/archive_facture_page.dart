import 'package:flutter/material.dart';
import 'package:frontend/service/proforma_service.dart';

import 'package:gap/gap.dart';

import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../model/facturation/facture_model.dart';
import '../../../../model/facturation/proforma_model.dart';
import '../../../../service/facture_service.dart';
import '../../../../widget/filter_bar.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';
import '../facture/facture_table.dart';
import '../proforma/proformat_table.dart';

class ArchiveFacturePage extends StatefulWidget {
  const ArchiveFacturePage({super.key});

  @override
  State<ArchiveFacturePage> createState() => _ArchiveFacturePageState();
}

class _ArchiveFacturePageState extends State<ArchiveFacturePage> {
  final TextEditingController _researchController = TextEditingController();

  String searchQuery = "";
  String? selectedFilter;
  int currentPage = GlobalValue.currentPage;
  List<FactureModel> factureData = [];
  List<ProformaModel> proformaData = [];

  bool isLoading = true;
  bool hasError = false;
  static String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _loadFactureData();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadFactureData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      if (selectedFilter == "Facture" || selectedFilter == null) {
        factureData = await FactureService.getPaidFacture();
      } else if (selectedFilter == "Proforma") {
        proformaData = await ProformaService.getArchivedProformas();
      }
    } catch (error) {
      setState(() {
        hasError = true;
        errorMessage = error.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onSelected(String value) {
    setState(() {
      selectedFilter = value;
    });
    _loadFactureData();
  }

  List<FactureModel> filteredFactureData() {
    return factureData.where((facture) {
      bool matchesSearch = facture.reference
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim()) ||
          facture.client!
              .toStringify()
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim());

      return matchesSearch;
    }).toList();
  }

  List<ProformaModel> filteredProformaData() {
    return proformaData.where((proforma) {
      bool matchesSearch = proforma.reference
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim()) ||
          proforma.client!
              .toStringify()
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim());

      return matchesSearch;
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  List<String> selectedFilterOption = ["Facture", "Proforma"];

  @override
  @override
  Widget build(BuildContext context) {
    List<FactureModel> filteredFactures = filteredFactureData();
    List<ProformaModel> filteredProformas = filteredProformaData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResearchBar(
              hintText: "Rechercher par client, ref",
              controller: _researchController,
            ),
            FilterBar(
              label: selectedFilter != null ? selectedFilter! : "Facture",
              items: selectedFilterOption,
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
              message: errorMessage.isNotEmpty
                  ? errorMessage
                  : 'Erreur lors du chargement des données',
              onPressed: () async {
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
                await _loadFactureData();
              },
            ),
          )
        else
          Expanded(
            child: selectedFilter == "Proforma"
                ? filteredProformas.isEmpty
                    ? NoDataPage(
                        data: proformaData,
                        message: "Aucune archive de proforma",
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Container(
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                              child: ProformaTable(
                                paginatedProformatData: getPaginatedData(
                                  data: filteredProformas,
                                  currentPage: currentPage,
                                ),
                                refresh: _loadFactureData,
                              ),
                            ),
                          ),
                          if (filteredProformas.isNotEmpty)
                            PaginationSpace(
                              currentPage: currentPage,
                              onPageChanged: updateCurrentPage,
                              filterDataCount: filteredProformas.length,
                            ),
                        ],
                      )
                : filteredFactures.isEmpty
                    ? NoDataPage(
                        data: factureData,
                        message: "Aucune archive de facture",
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Container(
                              color:
                                  Theme.of(context).colorScheme.surfaceBright,
                              child: FactureTable(
                                paginatedFactureData: getPaginatedData(
                                  data: filteredFactures,
                                  currentPage: currentPage,
                                ),
                                refresh: _loadFactureData,
                              ),
                            ),
                          ),
                          if (filteredFactures.isNotEmpty)
                            PaginationSpace(
                              currentPage: currentPage,
                              onPageChanged: updateCurrentPage,
                              filterDataCount: filteredFactures.length,
                            ),
                        ],
                      ),
          ),
      ],
    );
  }
}
