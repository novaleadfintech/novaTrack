import 'package:flutter/material.dart';
import '../../../../model/habilitation/role_model.dart';
import '../facture/facture_table.dart';
import '../../no_data_page.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../model/facturation/facture_model.dart';
import '../../../../service/facture_service.dart';
import '../../../../widget/filter_bar.dart';
import '../../../../widget/pagination.dart';
import 'package:gap/gap.dart';
import '../../../../widget/research_bar.dart';
import '../../error_page.dart';

class FactureRecurrentePage extends StatefulWidget {
  final RoleModel role;

  const FactureRecurrentePage({
    super.key,
    required this.role,
  });

  @override
  State<FactureRecurrentePage> createState() => _FactureRecurrentePageState();
}

class _FactureRecurrentePageState extends State<FactureRecurrentePage> {
  final TextEditingController _researchController = TextEditingController();

  String searchQuery = "";
  String? selectedFilter;
  int currentPage = GlobalValue.currentPage;
  List<FactureModel> factureData = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "";

  List<String> selectedFilterOption = [
    "Tout",
    "Aujourd'hui",
    "Demain",
    "Dans cette semaine",
    "Dans 2 semaines",
    "Dans 1 mois",
    "Dans 2 mois",
    "Dans 3 mois",
    "Dans plus de 3 mois"
  ];

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _loadFactureData();
  }

  String determineRegenerationTime(FactureModel facture) {
    DateTime now = DateTime.now();
    DateTime regenerationDate = facture.dateDebutFacturation!.add(
      Duration(milliseconds: facture.generatePeriod!),
    );

    Duration difference = regenerationDate.difference(now);
    int days = difference.inDays;

    if (days < 0) return "Déjà régénérée";
    if (days == 0) return "Aujourd'hui";
    if (days == 1) return "Demain";
    if (days <= 7) return "Dans cette semaine";
    if (days <= 14) return "Dans 2 semaines";
    if (days <= 30) return "Dans 1 mois";
    if (days <= 60) return "Dans 2 mois";
    if (days <= 90) return "Dans 3 mois";
    return "Dans plus de 3 mois";
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
      });
      factureData = await FactureService.getNewReccurenteFactures();
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

  List<FactureModel> filteredFactureData() {
    return factureData.where((facture) {
      bool matchesSearch = facture.reference
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim()) ||
          facture.client!
              .toStringify()
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim());

      bool matchesFilter = selectedFilter == null ||
          selectedFilter == "Tout" ||
          determineRegenerationTime(facture) == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void onSelected(String value) {
    setState(() {
      selectedFilter = value == "Tout" ? null : value;
    });
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<FactureModel> filteredData = filteredFactureData();

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
              label: selectedFilter ?? "Tout",
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
            child: filteredData.isEmpty
                ? NoDataPage(
                    data: factureData,
                    message: "Aucune facture",
                  )
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Container(
                          color: Theme.of(context).colorScheme.surfaceBright,
                          child: FactureTable(
                            role: widget.role,
                            paginatedFactureData: getPaginatedData(
                              data: filteredData,
                              currentPage: currentPage,
                            ),
                            refresh: _loadFactureData,
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
    );
  }
}
