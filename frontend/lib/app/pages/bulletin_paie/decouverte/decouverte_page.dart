import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../auth/authentification_token.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/bulletin_paie/decouverte_model.dart';
import '../../../../model/bulletin_paie/etat_bulletin.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../../service/decouverte_service.dart';
import '../../../../widget/add_element_button.dart';
import '../../../../widget/filter_bar.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../app_dialog_box.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';
import 'add_decouverte.dart';
import 'decouverte_table.dart';

class DecouvertePage extends StatefulWidget {
  const DecouvertePage({super.key});

  @override
  State<DecouvertePage> createState() => _DecouvertePageState();
}

class _DecouvertePageState extends State<DecouvertePage> {
  final TextEditingController _researchController = TextEditingController();
  String searchQuery = "";
  bool? isPaidFilter;
  int currentPage = GlobalValue.currentPage;
  List<DecouverteModel> decouverteData = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  late List<RoleModel> roles = [];

  List<String> selectedFilterOptions = [
    "Tout",
    "Soldée",
    "Non Soldées",
  ];

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadDecouverteData() async {
    try {
      setState(() {
        isLoading = true;
      });
      decouverteData =
          (await DecouverteService.getDecouvertes()).where((decouvert) {
        return decouvert.status != DecouverteStatus.paid;
      }).toList();
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

  List<DecouverteModel> filterDecouverteData() {
    return decouverteData.where((decouverte) {
      bool matchesSearch = decouverte.salarie.personnel.nom
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
      bool isSolde = decouverte.montantRestant == 0;
      bool matchesFilter = isPaidFilter == null || isPaidFilter == isSolde;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void onSelected(String value) {
    setState(() {
      if (value == "Tout") {
        isPaidFilter = null;
      } else if (value == "Soldée") {
        isPaidFilter = true;
      } else if (value == "Non Soldées") {
        isPaidFilter = false;
      }
    });
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
    setState(() {});
  }

  void onClickAddDecouverteButton() {
    showResponsiveDialog(
      context,
      title: "Nouveau découvert",
      content: AddDecouvertePage(refresh: _loadDecouverteData),
    );
  }

  @override
  void initState() {
    super.initState();
    getRoles();
    _researchController.addListener(_onSearchChanged);
    _loadDecouverteData();
  }

  @override
  Widget build(BuildContext context) {
    List<DecouverteModel> filteredData = filterDecouverteData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasPermission(
          roles: roles,
          permission: PermissionAlias.createAvance.label,
        ))
        Container(
          width: double.infinity,
          alignment: Alignment.centerRight,
          child: AddElementButton(
            addElement: onClickAddDecouverteButton,
            icon: Icons.add_outlined,
            label: "Ajouter un découvert",
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResearchBar(
              hintText: "Rechercher par nom du personnel",
              controller: _researchController,
            ),
            FilterBar(
              label: "Filtrer par état",
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
              message: errorMessage ??
                  "Erreur lors de la récupération des découverts.",
              onPressed: () async {
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
                await _loadDecouverteData();
              },
            ),
          )
        else
          Expanded(
            child: filteredData.isEmpty
                ? NoDataPage(
                    data: decouverteData,
                    message: "Aucune découverte",
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: DecouverteTable(
                            paginatedDecouverteData: getPaginatedData(
                              data: filteredData,
                              currentPage: currentPage,
                            ),
                            refresh: _loadDecouverteData,
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
