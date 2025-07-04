import 'package:flutter/material.dart';
import '../../../model/habilitation/role_model.dart';
import '../error_page.dart';
import '../no_data_page.dart';
import '../../../global/global_value.dart';
import '../../../helper/paginate_data.dart';
import '../../../model/client/client_model.dart';
import '../../../service/client_service.dart';
import '../../../widget/filter_bar.dart';
import '../../../widget/research_bar.dart';
import '../../../widget/pagination.dart';
import 'package:gap/gap.dart';
import 'client_table.dart';
import '../../../model/client/enum_client.dart';

class ArchivedClientPage extends StatefulWidget {
  final RoleModel role;

  final Function(ClientModel) onDetailClients;
  const ArchivedClientPage({
    super.key,
    required this.role,

    required this.onDetailClients,

  });

  @override
  State<ArchivedClientPage> createState() => _ArchivedClientPageState();
}

class _ArchivedClientPageState extends State<ArchivedClientPage> {
  final TextEditingController _researchController = TextEditingController();
  String searchQuery = "";
  String? selectedFilter;
  int currentPage = GlobalValue.currentPage;
  List<ClientModel> clientData = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  List<String> selectedFilterOptions = [
    "Tout",
    ...NatureClient.values.map((nature) => nature.label)
  ];

  @override
  void initState() {
    super.initState();
    _loadClientData();
    _researchController.addListener(_onSearchChanged);
  }

  Future<void> _loadClientData() async {
    try {
      clientData = await ClientService.getArchivedClientsAndProspect();
      
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
        hasError = errorMessage != null;
      });
    }
  }

  List<ClientModel> filterClientData() {
    return clientData.where((client) {
      final searchText = searchQuery.toLowerCase().trim();

      final matchesSearch =
          client.toStringify().toLowerCase().contains(searchText) ||
              (client.pays!.name.toLowerCase().contains(searchText));

      final matchesFilter = selectedFilter == null ||
          selectedFilter == "Tout" ||
          client.nature!.label == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  void onSelectedFilter(String value) {
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
    List<ClientModel> filteredData = filterClientData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResearchBar(
              hintText: "Rechercher par nom, pays",
              controller: _researchController,
            ),
            FilterBar(
              label: selectedFilter == null
                  ? "Filtrer par nature"
                  : selectedFilter!,
              items: selectedFilterOptions,
              onSelected: onSelectedFilter,
            ),
          ],
        ),
        const Gap(4),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError
                  ? ErrorPage(
                      message:
                          errorMessage ?? "Erreur lors de la reécupération",
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                          hasError = false;
                        });
                        await _loadClientData();
                      },
                    )
                  : filteredData.isEmpty
                      ? NoDataPage(
                          data: clientData,
                          message: "Aucun client",
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: ClientTable(
                                  role: widget.role,
                                  paginatedClientData: getPaginatedData(
                                    data: filteredData,
                                    currentPage: currentPage,
                                  ),
                                  onDetailClients: widget.onDetailClients,
                                  refresh: _loadClientData,
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
