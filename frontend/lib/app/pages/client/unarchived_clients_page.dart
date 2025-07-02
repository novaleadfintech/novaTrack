import 'package:flutter/material.dart';
import '../../../global/constant/permission_alias.dart';
import '../../../helper/user_helper.dart';
import '../app_dialog_box.dart';
import 'add_client_page.dart';
import '../error_page.dart';
import '../no_data_page.dart';
import '../../../global/global_value.dart';
import '../../../helper/paginate_data.dart';
import '../../../model/client/client_model.dart';
import '../../../service/client_service.dart';
import '../../../widget/add_element_button.dart';
import '../../../widget/filter_bar.dart';
import '../../../widget/research_bar.dart';
import '../../../widget/pagination.dart';
import 'client_table.dart';
import '../../../model/client/enum_client.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';

class UnarchivedClientPage extends StatefulWidget {
  final Function(ClientModel) onDetailClients;
  const UnarchivedClientPage({
    super.key,
    required this.onDetailClients,
  });

  @override
  State<UnarchivedClientPage> createState() => _UnarchivedClientPageState();
}

class _UnarchivedClientPageState extends State<UnarchivedClientPage> {
  final TextEditingController _researchController = TextEditingController();
  late Future<void> _futureRoles;
  late RoleModel role;

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
    _researchController.addListener(_onSearchChanged);
    _futureRoles = getRole();
    _loadClientData();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  Future<void> _loadClientData() async {
    try {
      setState(() {
        isLoading = true;
      });
      clientData = await ClientService.getUnarchivedAllPartenaire();
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

  void onClickAddClientButton() {
    showResponsiveDialog(
      context,
      title: "Nouveau partenaire",
      content: AddClientPage(
        refresh: _loadClientData,
      ),
    );
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
                  permission: PermissionAlias.createClient.label)) {
                return Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: AddElementButton(
                    addElement: onClickAddClientButton,
                    icon: Icons.add_outlined,
                    label: "Ajouter un partenaire",
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
                          message: "Aucun partenaire",
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: ClientTable(
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
