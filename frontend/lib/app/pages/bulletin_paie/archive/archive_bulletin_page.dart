import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/bulletin_paie/archive/archive_bulletin_table.dart';
import 'package:frontend/app/pages/bulletin_paie/decouverte/decouverte_table.dart';
import 'package:frontend/app/pages/bulletin_paie/salarie/salaire_table.dart';
import 'package:frontend/app/responsitvity/responsivity.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:frontend/model/bulletin_paie/decouverte_model.dart';
import 'package:frontend/model/bulletin_paie/etat_bulletin.dart';
import 'package:frontend/model/bulletin_paie/salarie_model.dart';
import 'package:frontend/model/personnel/enum_personnel.dart';
import 'package:frontend/service/bulletin_service.dart';
import 'package:frontend/service/decouverte_service.dart';
import 'package:frontend/service/salarie_service.dart';
import 'package:frontend/style/app_color.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../model/bulletin_paie/bulletin_model.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../../widget/filter_bar.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';
import 'get_multiple_bulletin.dart';

class ArchiveBulletinPage extends StatefulWidget {
  final RoleModel role;
  const ArchiveBulletinPage({
    super.key,
    required this.role,
  });

  @override
  State<ArchiveBulletinPage> createState() => _ArchiveBulletinState();
}

class _ArchiveBulletinState extends State<ArchiveBulletinPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  String? selectedFilter = "Bulletin";
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  List<String> selectedFilterOption = [
    "Bulletin",
    "Salarié",
    "Découverte",
  ];
  String searchQuery = "";
  List<BulletinPaieModel> bulletinData = [];
  List<DecouverteModel> decouvertData = [];
  List<SalarieModel> salarieData = [];

  Future<void> _loadArchiveData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      if (selectedFilter == "Bulletin" || selectedFilter == null) {
        bulletinData = await BulletinService.getArchiveBulletins();
      } else if (selectedFilter == "Salarié") {
        salarieData = (await SalarieService.getSalaries()).where((salarie) {
          return salarie.personnel.etat == EtatPersonnel.archived;
        }).toList();
      } else if (selectedFilter == "Découverte") {
        decouvertData =
            (await DecouverteService.getDecouvertes()).where((decouvert) {
          return decouvert.status == DecouverteStatus.paid;
        }).toList();
      }
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
        errorMessage = error.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  onGetManyBulletin() {
    showResponsiveDialog(context,
        content: MultipleBulletnPage(), title: "Selectionné les salariés");
  }

  void onSelected(String value) {
    setState(() {
      selectedFilter = value;
    });
    _loadArchiveData();
  }

  List<BulletinPaieModel> filteredBulletinData() {
    return bulletinData.where((bulletin) {
      bool matchesSearch = bulletin.salarie.personnel
          .toStringify()
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());

      return matchesSearch;
    }).toList();
  }

  List<SalarieModel> filteredSalarieData() {
    return salarieData.where((salarie) {
      bool matchesSearch = salarie.personnel
          .toStringify()
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());

      return matchesSearch;
    }).toList();
  }

  List<DecouverteModel> filteredDecouverteData() {
    return decouvertData.where((decouvert) {
      bool matchesSearch = decouvert.salarie.personnel
          .toStringify()
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());

      return matchesSearch;
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadArchiveData();
  }

  @override
  Widget build(BuildContext context) {
    List<BulletinPaieModel> filteredBulletin = filteredBulletinData();
    List<SalarieModel> filteredSalarie = filteredSalarieData();
    List<DecouverteModel> filteredDecouverte = filteredDecouverteData();

    return Stack(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ResearchBar(
                hintText: "Rechercher par nom",
                controller: _researchController,
              ),
              Row(
                children: [
                  if (selectedFilter == "Bulletin" &&
                      Responsive.isDesktop(context) &&
                      hasPermission(
                          role: widget.role,
                          permission: PermissionAlias.readBulletin.label)) ...[
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        // padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColor.primaryColor,
                        ),
                        child: IconButton(
                          onPressed: onGetManyBulletin,
                          icon: Icon(
                            Icons.picture_as_pdf,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
                    ),
                    Gap(8),
                  ],
                  FilterBar(
                    label:
                        selectedFilter != null ? selectedFilter! : "Bulletin",
                    items: selectedFilterOption,
                    onSelected: onSelected,
                  ),
                ],
              ),
            ],
          ),
          const Gap(4),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                    ? Center(
                        child: ErrorPage(
                        message: errorMessage ?? "Erreur",
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            hasError = false;
                          });
                          _loadArchiveData();
                        },
                      ))
                    : (selectedFilter == "Bulletin")
                        ? filteredBulletin.isEmpty
                            ? NoDataPage(
                                data: bulletinData,
                                message: "Aucune archive de bulletin",
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceBright,
                                      child: ArchiveBulletinTable(
                                        paginatedCurrentBulletintData:
                                            getPaginatedData(
                                          data: filteredBulletin,
                                          currentPage: currentPage,
                                        ),
                                        refresh: _loadArchiveData,
                                      ),
                                    ),
                                  ),
                                  if (filteredBulletin.isNotEmpty)
                                    PaginationSpace(
                                      currentPage: currentPage,
                                      onPageChanged: updateCurrentPage,
                                      filterDataCount: filteredBulletin.length,
                                    ),
                                ],
                              )
                        : selectedFilter == "Salarié"
                            ? filteredSalarie.isEmpty
                                ? NoDataPage(
                                    data: salarieData,
                                    message: "Aucune archive de salarié",
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceBright,
                                          child: SalarieTable(
                                            paginatedPersonnelData:
                                                getPaginatedData(
                                              data: filteredSalarie,
                                              currentPage: currentPage,
                                            ),
                                            refresh: _loadArchiveData,
                                          ),
                                        ),
                                      ),
                                      if (filteredSalarie.isNotEmpty)
                                        PaginationSpace(
                                          currentPage: currentPage,
                                          onPageChanged: updateCurrentPage,
                                          filterDataCount:
                                              filteredSalarie.length,
                                        ),
                                    ],
                                  )
                            : filteredDecouverte.isEmpty
                                ? NoDataPage(
                                    data: decouvertData,
                                    message:
                                        "Aucune archive d'avance sur salaire",
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceBright,
                                          child: DecouverteTable(
                                            role: widget.role,
                                            paginatedDecouverteData:
                                                getPaginatedData(
                                              data: filteredDecouverte,
                                              currentPage: currentPage,
                                            ),
                                            refresh: _loadArchiveData,
                                          ),
                                        ),
                                      ),
                                      if (filteredDecouverte.isNotEmpty)
                                        PaginationSpace(
                                          currentPage: currentPage,
                                          onPageChanged: updateCurrentPage,
                                          filterDataCount:
                                              filteredDecouverte.length,
                                        ),
                                    ],
                                  ),
          ),
        ],
      ),
      if (selectedFilter == "Bulletin" &&
          !Responsive.isDesktop(context) &&
          hasPermission(
              role: widget.role,
              permission: PermissionAlias.readBulletin.label) &&
          bulletinData.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 60, right: 8),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: onGetManyBulletin,
              child: Icon(Icons.picture_as_pdf),
            ),
          ),
        )
    ]);
  }
}
