import 'package:flutter/material.dart';
import 'package:frontend/app/pages/moyen_de_payement/add_moyen_payement.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/paginate_data.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import 'package:frontend/service/moyen_paiement_service.dart';
import 'package:gap/gap.dart';
import '../../../global/global_value.dart';
import '../../../widget/add_element_button.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import '../app_dialog_box.dart';
import '../error_page.dart';
import '../no_data_page.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
 import 'moyen_paiement_table.dart';

class MoyenPaiementPage extends StatefulWidget {
  const MoyenPaiementPage({
    super.key,
  });

  @override
  State<MoyenPaiementPage> createState() => _MoyenPaiementPageState();
}

class _MoyenPaiementPageState extends State<MoyenPaiementPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<MoyenPaiementModel> moyenPaiementData = [];
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = "";
  String? errorMessage;
  late Future<void> _futureRoles;
  late RoleModel role;

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _futureRoles = getRole();
    _loadMoyenPayement();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadMoyenPayement() async {
    try {
      moyenPaiementData = await MoyenPaiementService.getMoyenPaiements();
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

  List<MoyenPaiementModel> filterMoyenPaiement() {
    return moyenPaiementData.where((flux) {
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
      title: "Nouveau moyen de paiement",
      content: AddMoyenPayement(
        refresh: _loadMoyenPayement,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MoyenPaiementModel> filteredData = filterMoyenPaiement();

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
                  role: role,
                  permission: PermissionAlias.createMoyenPaiement.label,
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
                  await _loadMoyenPayement();
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
                            child: MoyenPayementTable(
                              moyenPayementFlux: getPaginatedData(
                                  data: filteredData, currentPage: currentPage),
                              refresh: _loadMoyenPayement,
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
