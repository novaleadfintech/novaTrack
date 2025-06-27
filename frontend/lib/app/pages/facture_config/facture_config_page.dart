import 'package:flutter/material.dart';
import 'facture_config_table.dart';
import '../../../helper/paginate_data.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../model/facturation/facture_global_value_model.dart';
import '../../../service/client_facture_global_value_service.dart';
import '../error_page.dart';
import '../no_data_page.dart';

class FactureConfigPage extends StatefulWidget {
  const FactureConfigPage({
    super.key,
  });

  @override
  State<FactureConfigPage> createState() => _CategoriePaieClientPageState();
}

class _CategoriePaieClientPageState extends State<FactureConfigPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<ClientFactureGlobaLValueModel> clientFactureGlobalValueDate = [];
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = "";
  late Future<void> _futureRoles;
  late List<RoleModel> roles = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _futureRoles = getRoles();
    _loadCategoriePaie();
  }

  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadCategoriePaie() async {
    try {
      clientFactureGlobalValueDate =
          await ClientFactureGlobalValuesService.getClientFactureGlobalValues();
    } catch (error) {
      setState(() {
         errorMessage = error.toString();
        hasError = true;
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  List<ClientFactureGlobaLValueModel> filterCategoriePaieClient() {
    return clientFactureGlobalValueDate.where((clientFactureGlobalValue) {
      return clientFactureGlobalValue.client
          .toStringify()
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<ClientFactureGlobaLValueModel> filteredData =
        filterCategoriePaieClient();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 4),
      child: Column(
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
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ResearchBar(
                      hintText: "Rechercher par libellé",
                      controller: _researchController,
                    ),
                  ],
                );
              }
            },
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
                message:
                    errorMessage ?? "Erreur lors du chargement des données.",
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                  await _loadCategoriePaie();
                },
              ),
            )
          else
            Expanded(
              child: filteredData.isEmpty
                  ? NoDataPage(
                      data: filteredData,
                      message: "Aucune catégorie de paie",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: FactureConfigTable(
                              clientFactureGlobaLValues: getPaginatedData(
                                  data: filteredData, currentPage: currentPage),
                              refresh: _loadCategoriePaie,
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
      ),
    );
  }
}
