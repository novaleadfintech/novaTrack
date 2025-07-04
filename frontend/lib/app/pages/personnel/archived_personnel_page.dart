import 'package:flutter/material.dart';
import '../../../model/habilitation/role_model.dart';
import 'personnel_table.dart';
import '../no_data_page.dart';
import '../../../global/global_value.dart';
import '../../../helper/paginate_data.dart';
import '../../../model/common_type.dart';
import '../../../model/personnel/personnel_model.dart';
import '../../../service/personnel_service.dart';
import '../../../widget/pagination.dart';
import 'package:gap/gap.dart';
import '../../../widget/research_bar.dart';
import '../../../widget/filter_bar.dart';
import '../error_page.dart';

class ArchivedPersonnelPage extends StatefulWidget {
    final RoleModel role;

  const ArchivedPersonnelPage({super.key,     required this.role,
  });

  @override
  State<ArchivedPersonnelPage> createState() => _PersonnelPageState();
}

class _PersonnelPageState extends State<ArchivedPersonnelPage> {
  final TextEditingController _researchController = TextEditingController();

  String searchQuery = "";
  String? selectedFilter;
  int currentPage = GlobalValue.currentPage;
  List<String> selectedFilterOptions = [
    "Tout",
    Sexe.F.label,
    Sexe.M.label,
  ];
  String? errorMessage;
  bool isLoading = true;
  bool hasError = false;
  List<PersonnelModel> personnelData = [];

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _loadPersonnelData();
  }

  Future<void> _loadPersonnelData() async {
    try {
      personnelData = await PersonnelService.getArchivedPersonnels();
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

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  List<PersonnelModel> filteredPersonnelData() {
    return personnelData.where((personnel) {
      bool matchesSearch = personnel.nom
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim()) ||
          personnel.poste!
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim()) ||
          personnel.prenom
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim());
      bool matchesFilter =
          selectedFilter == null || personnel.sexe!.label == selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void onSelected(String value) {
    setState(() {
      selectedFilter = value == "Tout" ? null : value;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<PersonnelModel> filteredData = filteredPersonnelData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResearchBar(
              hintText: "Rechercher par nom, poste",
              controller: _researchController,
            ),
            FilterBar(
              label:
                  selectedFilter == null ? "Filtrer par sexe" : selectedFilter!,
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
              message: errorMessage ?? "Erreur lors du chargement des données.",
              onPressed: () async {
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
                await _loadPersonnelData();
              },
            ),
          )
        else
          Expanded(
            child: filteredData.isEmpty
                ? NoDataPage(
                    data: filteredData,
                    message: "Aucun personnel trouvé",
                  )
                : Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: PersonnelTable(
                      role: widget.role,
                      paginatedPersonnelData: getPaginatedData(
                        data: filteredData,
                        currentPage: currentPage,
                      ),
                      refresh: _loadPersonnelData,
                    ),
                  ),
          ),
        if (filteredData.isNotEmpty)
          PaginationSpace(
            filterDataCount: filteredData.length,
            currentPage: currentPage,
            onPageChanged: updateCurrentPage,
          ),
      ],
    );
  }
}
