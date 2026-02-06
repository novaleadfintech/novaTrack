import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/bulletin_paie/archive/archive_bulletin_table.dart';
import 'package:frontend/app/responsitvity/responsivity.dart';
import 'package:frontend/global/constant/permission_alias.dart';
import 'package:frontend/helper/user_helper.dart';
import 'package:frontend/model/bulletin_paie/calendar_model.dart'
    show PayCalendarModel;
import 'package:frontend/service/bulletin_service.dart';
import 'package:frontend/style/app_color.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../helper/paginate_data.dart';
import '../../../../model/bulletin_paie/bulletin_model.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';
import 'get_multiple_bulletin.dart';

class PeriodBulletinPage extends StatefulWidget {
  final RoleModel role;
  final PayCalendarModel payCalendar;
  const PeriodBulletinPage({
    super.key,
    required this.role,
    required this.payCalendar,
  });

  @override
  State<PeriodBulletinPage> createState() => _PeriodBulletinState();
}

class _PeriodBulletinState extends State<PeriodBulletinPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  String searchQuery = "";
  List<BulletinPaieModel> bulletinData = [];

  Future<void> _loadArchiveData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      bulletinData = (await BulletinService.getArchiveBulletins());
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

  List<BulletinPaieModel> filteredBulletinData() {
    return bulletinData.where((bulletin) {
      bool matchesSearch = bulletin.salarie.personnel
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
                  if (Responsive.isDesktop(context) &&
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
                      : filteredBulletin.isEmpty
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
                            )),
        ],
      ),
      if (!Responsive.isDesktop(context) &&
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

  // periodShow({required List<BulletinPaieModel> filteredBulletin}) {
  //   InkWell(
  //     child: ResponsiveCard(label: "Catégories de partenaire"),
  //     onTap: () {
  //       showResponsiveConfigPageDialogBox(context,
  //           title: "Catégories de partenaire",
  //           content: Column(
  //             mainAxisSize: MainAxisSize.max,
  //             children: [
  //               Expanded(
  //                 child: Container(
  //                   color: Theme.of(context).colorScheme.surfaceBright,
  //                   child: ArchiveBulletinTable(
  //                     paginatedCurrentBulletintData: getPaginatedData(
  //                       data: filteredBulletin,
  //                       currentPage: currentPage,
  //                     ),
  //                     refresh: _loadArchiveData,
  //                   ),
  //                 ),
  //               ),
  //               if (filteredBulletin.isNotEmpty)
  //                 PaginationSpace(
  //                   currentPage: currentPage,
  //                   onPageChanged: updateCurrentPage,
  //                   filterDataCount: filteredBulletin.length,
  //                 ),
  //             ],
  //           ));
  //     },
  //   );
  // }

  // void onTapPeriod() {
  //   showResponsiveConfigPageDialogBox(context,
  //       title: "Catégories de partenaire", content: Container());
  // }
}
