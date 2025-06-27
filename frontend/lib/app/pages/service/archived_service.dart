import 'package:flutter/material.dart';
import "../error_page.dart";
import 'package:gap/gap.dart';
import '../../../global/global_value.dart';
import '../../../helper/paginate_data.dart';
import '../../../model/service/enum_service.dart';
import '../../../model/service/service_model.dart';
import '../../../service/service_service.dart';
import '../../../widget/filter_bar.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import '../no_data_page.dart';
import 'service_table.dart';

class ArchivedServicePage extends StatefulWidget {
  const ArchivedServicePage({super.key});

  @override
  State<ArchivedServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ArchivedServicePage> {
  final TextEditingController _researchController = TextEditingController();

  String searchQuery = "";
  String? selectedFilter;
  int currentPage = GlobalValue.currentPage;
  List<ServiceModel> serviceData = [];
  bool isLoading = true;
  bool hasError = false;
String? errorMessage;
  List<String> selectedFilterOptions = [
    "Tout",
    ServiceType.punctual.label,
    ServiceType.recurrent.label,
    ServiceType.produit.label,
  ];

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadServiceData() async {
    try {
      serviceData = await ServiceService.getArchivedService();
    } catch (error) {
      setState(() {
        hasError = true;
      });
      try {
        serviceData = await ServiceService.getArchivedService();
      } catch (error) {
        setState(() {
          hasError = true;
          errorMessage = error.toString();
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<ServiceModel> filterServiceData() {
    return serviceData.where((service) {
      bool matchesSearch = service.libelle
          .toLowerCase()
              .contains(searchQuery.toLowerCase().trim()) ||
          service.country.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim());
      bool matchesFilter =
          selectedFilter == null || service.type!.label == selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
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

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _loadServiceData();
  }

  @override
  Widget build(BuildContext context) {
    List<ServiceModel> filteredData = filterServiceData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResearchBar(
              hintText: "Rechercher par libelle, pays",
              controller: _researchController,
            ),
            FilterBar(
              label: selectedFilter == null ? "Filtrer par type" : selectedFilter!,
              items: selectedFilterOptions.map((e) => e).toList(),
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
              message: errorMessage!,
              onPressed: () async {
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
                await _loadServiceData();
              },
            ),
          )
        else
          Expanded(
            child: filteredData.isEmpty
                ? NoDataPage(
                    data: serviceData,
                    message: "Aucun service",
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: ServiceTable(
                            paginatedServiceData: getPaginatedData(
                              data: filteredData,
                              currentPage: currentPage,
                            ),
                            refresh: _loadServiceData,
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
