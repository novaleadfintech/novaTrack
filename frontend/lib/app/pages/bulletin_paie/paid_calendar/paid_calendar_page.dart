import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../global/global_value.dart';
import '../../../../model/bulletin_paie/pay_Calendar_model.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../../../widget/add_element_button.dart';
import '../../../../widget/pagination.dart';
import '../../../../widget/research_bar.dart';
import '../../app_dialog_box.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';
import 'add_paid_calendar.dart';

class PayCalendarPage extends StatefulWidget {
  final RoleModel role;
  const PayCalendarPage({
    super.key,
    required this.role,
  });

  @override
  State<PayCalendarPage> createState() => _PayCalendarPageState();
}

class _PayCalendarPageState extends State<PayCalendarPage> {
  final TextEditingController _researchController = TextEditingController();
  int currentPage = GlobalValue.currentPage;
  List<PayCalendarModel> payCalendarData = [];
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = "";
  late Future<void> _futureRoles;
  late RoleModel role;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    role = widget.role;
    _loadPayCalendar();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  Future<void> _loadPayCalendar() async {
    try {
      // payCalendarData = await PayCalendarService.getPayCalendars();
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

  List<PayCalendarModel> filterPayCalendar() {
    return payCalendarData.where((payCalendar) {
      return payCalendar.libelle
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
      title: "Nouvelle période de paie",
      content: AddPayCalendar(
        refresh: _loadPayCalendar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<PayCalendarModel> filteredData = filterPayCalendar();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ResearchBar(
                hintText: "Rechercher par libellé",
                controller: _researchController,
              ),
              // if (canCreate)
              Container(
                alignment: Alignment.centerRight,
                child: AddElementButton(
                  addElement: onClickAddFluxButton,
                  icon: Icons.add_outlined,
                  isSmall: true,
                  label: "Ajouter un calendrier de paie",
                ),
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
                message:
                    errorMessage ?? "Erreur lors du chargement des données.",
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                  await _loadPayCalendar();
                },
              ),
            )
          else
            Expanded(
              child: filteredData.isEmpty
                  ? NoDataPage(
                      data: filteredData,
                      message: "Aucune période de paie définie",
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            // child: PayCalendarTable(
                            //   payCalendar: getPaginatedData(
                            //       data: filteredData, currentPage: currentPage),
                            //   refresh: _loadPayCalendar,
                            // ),
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
