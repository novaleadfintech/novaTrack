import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/bulletin_paie/archive/archive_bulletin_table.dart';
import 'package:frontend/app/pages/bulletin_paie/archive/period_bulletin.dart';
import 'package:frontend/app/pages/bulletin_paie/decouverte/decouverte_table.dart';
import 'package:frontend/app/pages/bulletin_paie/salarie/salaire_table.dart';
import 'package:frontend/app/pages/configure_page_dialog.dart';
import 'package:frontend/model/bulletin_paie/calendar_model.dart'
    show EtatPayCalendar, PayCalendarModel;
import 'package:frontend/model/bulletin_paie/decouverte_model.dart';
import 'package:frontend/model/bulletin_paie/etat_bulletin.dart';
import 'package:frontend/model/bulletin_paie/salarie_model.dart';
import 'package:frontend/model/personnel/enum_personnel.dart';
import 'package:frontend/service/decouverte_service.dart';
import 'package:frontend/service/salarie_service.dart';
import 'package:frontend/widget/reponsive_conf_card.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../model/bulletin_paie/bulletin_model.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../../service/pay_calendar_service.dart';
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
  List<PayCalendarModel> payCalendarData = [];
  String? errorMessage;
  List<String> selectedFilterOption = [
    "Bulletin",
    "Salarié",
    // "Découverte",
  ];
  String searchQuery = "";
  List<DecouverteModel> decouvertData = [];
  List<SalarieModel> salarieData = [];

  Future<void> _loadArchiveData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      if (selectedFilter == "Bulletin" || selectedFilter == null) {
        payCalendarData =
            (await PayCalendarService.getPayCalendars()).where((pay) {
          return pay.etat != EtatPayCalendar.tobeOpen;
        }).toList();
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

  // Future<void> _loadPayCalendar() async {
  //   try {
  //     final data
  //     setState(() {
  //       payCalendarData = data;
  //       isLoading = false;
  //     });
  //   } catch (error) {
  //     setState(() {
  //       errorMessage = error.toString();
  //       hasError = true;
  //       isLoading = false;
  //     });
  //   }
  // }


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

  List<PayCalendarModel> filteredPeriod() {
    return payCalendarData.where((period) {
      bool matchesSearch = period.libelle
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
    List<SalarieModel> filteredSalarie = filteredSalarieData();
    List<DecouverteModel> filteredDecouverte = filteredDecouverteData();
    List<PayCalendarModel> filterPeriod = filteredPeriod();

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
                        ? filterPeriod.isEmpty
                            ? NoDataPage(
                                data: filterPeriod,
                                message: "Aucune archive de bulletin",
                              )
                            : Wrap(
                                children: [
                                  ...filterPeriod.map((payCalendar) {
                                    return InkWell(
                                      onTap: () {
                                        onTapPeriod(
                                            role: widget.role,
                                            period: payCalendar);
                                      },
                                      child: ResponsiveCard(
                                        label: payCalendar.libelle,
                                      ),
                                    );
                                  }),
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
      // if (selectedFilter == "Bulletin" &&
      //     !Responsive.isDesktop(context) &&
      //     hasPermission(
      //         role: widget.role,
      //         permission: PermissionAlias.readBulletin.label) &&
      //     bulletinData.isNotEmpty)
      //   Padding(
      //     padding: const EdgeInsets.only(bottom: 60, right: 8),
      //     child: Align(
      //       alignment: Alignment.bottomRight,
      //       child: FloatingActionButton(
      //         onPressed: onGetManyBulletin,
      //         child: Icon(Icons.picture_as_pdf),
      //       ),
      //     ),
      //   )
    ]);
  }

  periodShow({required List<BulletinPaieModel> filteredBulletin}) {
    InkWell(
      child: ResponsiveCard(label: "Catégories de partenaire"),
      onTap: () {
        showResponsiveConfigPageDialogBox(context,
            title: "Catégories de partenaire",
            content: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceBright,
                    child: ArchiveBulletinTable(
                      paginatedCurrentBulletintData: getPaginatedData(
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
            ));
      },
    );
  }

  void onTapPeriod({
    required RoleModel role,
    required PayCalendarModel period,
  }) {
    showResponsiveConfigPageDialogBox(context,
        maxHeightFactor: 1,
        widthFactor: 0.9,
        title: "Bulltetins - ${period.libelle}",
        content: PeriodBulletinPage(
          role: role,
          payCalendar: period,
        ));
  }
}
