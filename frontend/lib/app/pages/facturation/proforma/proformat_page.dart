import 'package:flutter/material.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../app_dialog_box.dart';
import '../../error_page.dart';
import 'add_proforma.dart';
import 'proformat_table.dart';
import '../../no_data_page.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../model/facturation/enum_facture.dart';
import '../../../../model/facturation/proforma_model.dart';
import '../../../../service/proforma_service.dart';
import '../../../../widget/add_element_button.dart';
import '../../../../widget/filter_bar.dart';
import '../../../../widget/pagination.dart';
import 'package:gap/gap.dart';
import '../../../../widget/research_bar.dart';

class ProformaPage extends StatefulWidget {
  const ProformaPage({super.key});

  @override
  State<ProformaPage> createState() => _ProformaPageState();
}

class _ProformaPageState extends State<ProformaPage> {
  final TextEditingController _researchController = TextEditingController();
  List<RoleModel> roles = [];

  String searchQuery = "";
  String? selectedFilter = StatusProforma.wait.label;
  int currentPage = GlobalValue.currentPage;
  List<ProformaModel> proformaData = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "";
  List<String> selectedFilterOption = [
    StatusProforma.wait.label,
  ];

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _loadProformaData();
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
  
  Future<void> _loadProformaData() async {
    try {
      setState(() {
        isLoading = true;
      });
      proformaData = await ProformaService.getProformas();
    } catch (error) {
      errorMessage = error.toString();
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<ProformaModel> filterProformaData() {
    return proformaData.where((proforma) {
      bool matchesSearch = proforma.reference
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim()) ||
          (proforma.client != null &&
              proforma.client!
                  .toStringify()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase().trim()));
      bool matchesFilter = selectedFilter == null ||
          (proforma.status != null && proforma.status!.label == selectedFilter);

      return matchesSearch && matchesFilter;
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

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void onClickAddProformaButton() {
    showResponsiveDialog(
      context,
      title: "Nouveau proforma",
      content: AddFactureProformat(
        refresh: _loadProformaData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ProformaModel> filteredData = filterProformaData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (
            hasPermission(
          roles: roles,
              permission: PermissionAlias.createProforma.label,
            ))
        Container(
          width: double.infinity,
          alignment: Alignment.centerRight,
          child: AddElementButton(
            addElement: onClickAddProformaButton,
            icon: Icons.add_outlined,
            label: "Ajouter un proforma",
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
            FilterBar(
              label: selectedFilter == null ? "Tout" : selectedFilter!,
              items: selectedFilterOption.map((e) => e).toList(),
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
                  : "Erreur lors du chargement des proformas",
              onPressed: () async {
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
                await _loadProformaData();
              },
            ),
          )
        else
          Expanded(
            child: filteredData.isEmpty || proformaData.isEmpty
                ? NoDataPage(
                    data: proformaData,
                    message: "Aucun proformat",
                  )
                : Container(
                    color: Theme.of(context).colorScheme.surfaceBright,
                    child: ProformaTable(
                      refresh: _loadProformaData,
                      paginatedProformatData: getPaginatedData(
                        data: filteredData,
                        currentPage: currentPage,
                      ),
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
    );
  }
}
