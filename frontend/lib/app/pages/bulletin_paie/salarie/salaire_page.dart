import 'package:flutter/material.dart';
import 'package:frontend/app/pages/bulletin_paie/salarie/add_salarie.dart';
import 'package:frontend/app/pages/bulletin_paie/salarie/salaire_table.dart';
import 'package:frontend/model/personnel/enum_personnel.dart';
import 'package:frontend/service/salarie_service.dart';
import 'package:gap/gap.dart';
import '../../../../auth/authentification_token.dart';
import '../../../../global/constant/permission_alias.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../helper/user_helper.dart';
import '../../../../model/bulletin_paie/salarie_model.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../../widget/add_element_button.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../app_dialog_box.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';

class SalariePage extends StatefulWidget {
  const SalariePage({super.key});

  @override
  State<SalariePage> createState() => _PersonnelPageState();
}

class _PersonnelPageState extends State<SalariePage> {
  final TextEditingController _researchController = TextEditingController();
  late Future<void> _futureRoles;
  late RoleModel role;

  String searchQuery = "";
  String? selectedFilter;
  int currentPage = GlobalValue.currentPage;
  // List<String> selectedFilterOptions = [
  //   "Tout",
  //   Sexe.F.label,
  //   Sexe.M.label,
  // ];

  bool isLoading = true;
  bool hasError = false;
  List<SalarieModel> salarieData = [];
  String? errMessage;
  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _futureRoles = getRole();
    _loadPersonnelData();
  }

  Future<void> getRole() async {
    role = await AuthService().getRole();
  }

  Future<void> _loadPersonnelData() async {
    try {
      salarieData = (await SalarieService.getSalaries()).where((salarie) {
        return salarie.personnel.etat == EtatPersonnel.unarchived;
      }).toList();
    } catch (error) {
      setState(() {
        hasError = true;
        errMessage = error.toString();
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

  List<SalarieModel> filteredPersonnelData() {
    return salarieData.where((salarie) {
      bool matchesSearch = salarie.personnel.nom
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim()) ||
          (salarie.personnel.poste != null
                  ? salarie.personnel.poste!.libelle
                  : "Aucun")
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim()) ||
          salarie.personnel.prenom
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim()) ||
          salarie.categoriePaie.categoriePaie
              .toLowerCase()
              .contains(searchQuery.toLowerCase().trim());

      return matchesSearch;
    }).toList();
  }

  void onSelected(String value) {
    setState(() {
      selectedFilter = value == "Tout" ? null : value;
    });
  }

  onClickAddPersonnelButton() {
    showResponsiveDialog(
      context,
      title: "Nouveau salarie",
      content: AddSalariePage(
        refresh: _loadPersonnelData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<SalarieModel> filteredData = filteredPersonnelData();

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
            Row(
              children: [
                
                // FilledButton(
                //     onPressed: () {
                //       // onEditBulletin(salarie: salarie);
                //     },
                //     style: const ButtonStyle(
                //       padding: WidgetStatePropertyAll(EdgeInsets.zero),
                //       shape: WidgetStatePropertyAll(
                //         RoundedRectangleBorder(
                //           borderRadius: BorderRadius.all(
                //             Radius.circular(4),
                //           ),
                //         ),
                //       ),
                //       textStyle: WidgetStatePropertyAll(
                //         TextStyle(
                //           fontWeight: FontWeight.w600,
                //           color: Colors.white,
                //           fontSize: 16,
                //         ),
                //       ),
                //     ),
                //     child: SvgPicture.asset(
                //       AssetsIcons.validInvoice,
                //       height: 20,
                //       colorFilter: ColorFilter.mode(
                //         Theme.of(context).colorScheme.onPrimary,
                //         BlendMode.srcIn,
                //       ),
                //     )),
               
                Gap(8),
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
                          permission: PermissionAlias.createSalarie.label)) {
                        return Container(
                          alignment: Alignment.centerRight,
                          child: AddElementButton(
                            addElement: onClickAddPersonnelButton,
                            icon: Icons.add_outlined,
                            label: "Ajouter un salarié",
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }
                  },
                ),
              ],
            ),
            
            // FilterBar(
            //   label:
            //       selectedFilter == null ? "Filtrer par sexe" : selectedFilter!,
            //   items: selectedFilterOptions,
            //   onSelected: onSelected,
            // ),
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
              message: errMessage ?? "Erreur lors du chargement des données.",
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
                    message: "Aucun salarié trouvé",
                  )
                : Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: SalarieTable(
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
