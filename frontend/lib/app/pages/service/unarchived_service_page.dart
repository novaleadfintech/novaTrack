import 'package:flutter/material.dart';
import '../../../auth/authentification_token.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../../../model/habilitation/role_model.dart';
 import '../app_dialog_box.dart';
import 'add_service_page.dart';
import '../../../widget/add_element_button.dart';
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

class UnarchivedServicePage extends StatefulWidget {
  const UnarchivedServicePage({super.key});

  @override
  State<UnarchivedServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<UnarchivedServicePage> {
  final TextEditingController _researchController = TextEditingController();
  late Future<void> _futureRoles;
  late RoleModel role;

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

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _futureRoles = getRole();
    _loadServiceData();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadServiceData() async {
    try {
      setState(() {
        isLoading = true;
      });
      serviceData = await ServiceService.getUnarchivedService();
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

  void onClickAddServiceButton() {
    showResponsiveDialog(
      context,
      title: "Nouveau service",
      content: AddServicePage(refresh: _loadServiceData),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ServiceModel> filteredData = filterServiceData();

    return Column(
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
             
              if (hasPermission(
                  role: role,
                  permission: PermissionAlias.createService.label)) {
                return Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: AddElementButton(
                    addElement: onClickAddServiceButton,
                    icon: Icons.add_outlined,
                    label: "Ajouter un service",
                  ),
                );
              } else {
                return const SizedBox();
              }
            }
          },
        ),
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
