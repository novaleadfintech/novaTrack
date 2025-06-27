import 'package:flutter/material.dart';
import 'package:frontend/widget/calendar_filter.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../app_dialog_box.dart';
import 'add_facture.dart';
import 'facture_table.dart';
import '../../no_data_page.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../model/facturation/enum_facture.dart';
import '../../../../model/facturation/facture_model.dart';
import '../../../../service/facture_service.dart';
import '../../../../widget/add_element_button.dart';
import '../../../../widget/filter_bar.dart';
import '../../../../widget/pagination.dart';
import 'package:gap/gap.dart';
import '../../../../widget/research_bar.dart';
import '../../error_page.dart';

class FacturePage extends StatefulWidget {
  const FacturePage({super.key});

  @override
  State<FacturePage> createState() => _FacturePageState();
}

class _FacturePageState extends State<FacturePage> {
  final TextEditingController _researchController = TextEditingController();
  List<RoleModel> roles = [];

  String searchQuery = "";
  String? selectedFilter;
  int currentPage = GlobalValue.currentPage;
  List<FactureModel> factureData = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "";
  String? selectedPeriodFilter;

  List<String> selectedFilterOption = [
    "Tout",
    StatusFacture.tobepaid.label,
    StatusFacture.partialpaid.label,
    StatusFacture.unpaid.label,
    StatusFacture.paid.label,
    StatusFacture.blocked.label,
  ];

  List<String> selectedPeriodFilterOption = [
    "Tout",
    "En retard",
    "Aujourd'hui",
    "Demain",
    "Dans cette semaine",
    "Dans 2 semaines",
    "Dans 1 mois",
    "Dans 2 mois",
    "Dans 3 mois",
    "Dans plus de 3 mois"
  ];

  String determineRegenerationTime(FactureModel facture) {
    DateTime now = DateTime.now();
    DateTime todayAtMidnight = DateTime(now.year, now.month, now.day);

    List<DateTime> futureDates = facture.facturesAcompte
        .where((acompte) =>
            acompte.dateEnvoieFacture.isAfter(todayAtMidnight) ||
            acompte.datePayementEcheante == null)
        .map(
          (acompte) => acompte.dateEnvoieFacture,
        )
        .toList();

    if (futureDates.isEmpty) {
      return "Aucune date future trouvée";
    }
    
    futureDates.sort();
    DateTime closestDate = futureDates.first;
    int days = closestDate.difference(todayAtMidnight).inDays;
    if (days < 0) return "En retard";
    if (days == 0) return "Aujourd'hui";
    if (days == 1) return "Demain";
    if (days <= 7) return "Dans cette semaine";
    if (days <= 14) return "Dans 2 semaines";
    if (days <= 30) return "Dans 1 mois";
    if (days <= 60) return "Dans 2 mois";
    if (days <= 90) return "Dans 3 mois";
    return "Dans plus de 3 mois";
  }

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _loadFactureData();
    getRoles();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
  }

  Future<void> _loadFactureData() async {
    try {
      setState(() {
        isLoading = true;
      });
      factureData = await FactureService.getUnPaidFactures();
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

      bool matchesFilter =
          selectedFilter == null || facture.status!.label == selectedFilter;
      bool matchesPeriodFilter = selectedPeriodFilter == null ||
          selectedFilter == "Tout" ||
          determineRegenerationTime(facture) == selectedPeriodFilter;
      return matchesSearch && matchesFilter && matchesPeriodFilter;
    }).toList();
  }

  void onSelected(String value) {
    setState(() {
      if (value == "Tout") {
        selectedFilter = null;
      } else {
        selectedFilter =
            selectedFilterOption.firstWhere((element) => element == value);
      }
    });
  }

  void onPeriodSelected(String value) {
    setState(() {
      selectedPeriodFilter = value == "Tout" ? null : value;
    });
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void onClickAddFactureButton() {
    showResponsiveDialog(
      context,
      title: "Nouvelle facture",
      content: AddFacture(
        refresh: _loadFactureData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<FactureModel> filteredData = filteredFactureData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasPermission(
          roles: roles,
          permission: PermissionAlias.createFacture.label,
        ))
          Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            child: AddElementButton(
              addElement: onClickAddFactureButton,
              icon: Icons.add_outlined,
              label: "Ajouter une facture",
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResearchBar(
              hintText: "Rechercher par client, ref",
              controller: _researchController,
            ),
            Row(
              children: [
                CalendarFilter(
                  label: selectedPeriodFilter ?? "Filtrer par période",
                  items: selectedPeriodFilterOption,
                  onSelected: onPeriodSelected,
                ),
                FilterBar(
                  label: selectedFilter == null
                      ? "Filtrer par statut"
                      : selectedFilter!,
                  items: selectedFilterOption,
                  onSelected: onSelected,
                ),
              ],
            )
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
