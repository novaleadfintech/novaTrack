import 'package:flutter/material.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/paginate_data.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:frontend/model/flux_financier/libelle_flux.dart';
import 'package:frontend/service/libelle_flux_financier_service.dart';
import 'package:gap/gap.dart';
import '../../../global/global_value.dart';
import '../../../widget/add_element_button.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import '../app_dialog_box.dart';
import '../error_page.dart';
import '../no_data_page.dart';
import 'add_libelle_flux_page.dart';
import 'libelle_flux_table.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
 
class LibelleFluxFinancierPage extends StatefulWidget {
  const LibelleFluxFinancierPage({
    super.key,
  });

  @override
  State<LibelleFluxFinancierPage> createState() =>
      _LibelleFluxFinancierPageState();
}

class _LibelleFluxFinancierPageState extends State<LibelleFluxFinancierPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<LibelleFluxModel> fluxFinancierData = [];
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
    _loadFluxFinancierData();
  }

  Future<void> getRoles() async {
    roles = await AuthService().getRoles();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadFluxFinancierData() async {
    try {
      fluxFinancierData =
          await LibelleFluxFinancierService.getLibelleFluxFinanciers();
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

  List<LibelleFluxModel> filterFluxFinancierData() {
    return fluxFinancierData.where((flux) {
      return flux.libelle
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void onClickAddFluxButton() {
    showResponsiveDialog(
      context,
      title: "Nouveau libellé financier",
      content: AddLibellePage(
        refresh: _loadFluxFinancierData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<LibelleFluxModel> filteredData = filterFluxFinancierData();

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
                bool canCreate = hasPermission(
                  roles: roles,
                  permission: PermissionAlias.createLibelleFluxFinancier.label,
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ResearchBar(
                      hintText: "Rechercher par libellé",
                      controller: _researchController,
                    ),
                    if (canCreate)
                      Container(
                        alignment: Alignment.centerRight,
                        child: AddElementButton(
                          addElement: onClickAddFluxButton,
                          icon: Icons.add_outlined,
                          isSmall: true,
                          label: "Ajouter une libellé",
                        ),
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
                  await _loadFluxFinancierData();
                },
              ),
            )
          else
            Expanded(
              child: filteredData.isEmpty
                  ? NoDataPage(
                      data: filteredData,
                      message: "Aucun libellé",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: LibelleFluxTable(
                              libelleFlux: getPaginatedData(
                                  data: filteredData, currentPage: currentPage),
                              refresh: _loadFluxFinancierData,
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
