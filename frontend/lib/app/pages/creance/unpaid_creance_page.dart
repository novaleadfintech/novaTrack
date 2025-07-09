import 'package:flutter/material.dart';
import 'package:frontend/app/pages/creance/unpaid_change_during.dart';
import '../../integration/request_frot_behavior.dart';
import '../custom_popup.dart';
import '../error_page.dart';
import '../../responsitvity/responsivity.dart';
import '../../../helper/date_helper.dart';
import '../../../model/flux_financier/creance_model.dart';
import '../../../service/creance_service.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
import '../../../helper/paginate_data.dart';
import 'package:gap/gap.dart';
import '../../../helper/amout_formatter.dart';
import '../../../style/app_color.dart';
import '../../../widget/add_element_button.dart';
import '../../../global/global_value.dart';
import '../../../app/pages/no_data_page.dart';
import 'creance_table.dart';

class UnpaidCreancePage extends StatefulWidget {
  const UnpaidCreancePage({super.key});

  @override
  State<UnpaidCreancePage> createState() => _UnpaidCreancePageState();
}

class _UnpaidCreancePageState extends State<UnpaidCreancePage> {
  final TextEditingController _researchController = TextEditingController();
  final TextEditingController _debutController = TextEditingController();
  final TextEditingController _finController = TextEditingController();

  late double creanceTotal;
  String searchQuery = "";
  DateTime? selectedDebut;
  DateTime? selectedFin;
  int currentPage = GlobalValue.currentPage;
  List<CreanceModel> creanceData = [];
  bool isLoading = true;
  bool hasError = false;
  String? errMessage;
  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _loadCreanceDataWithDates();
  }

  Future<void> _loadCreanceDataWithDates() async {
    setState(() {
      isLoading = true;
    });
    try {
      creanceData = await CreanceService.getPassCreanceWithDate(
        debut: selectedDebut,
        fin: selectedFin,
      );
      _calculateCreanceTotal();
      setState(() {});
    } catch (error) {
      errMessage = error.toString();
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _calculateCreanceTotal() {
    creanceTotal = creanceData.fold(
      0,
      (total, creance) => total + creance.montantRestant,
    );
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  List<CreanceModel> filterCreanceData() {
    return creanceData.where((creance) {
      final matchesSearch = creance.client!
          .toStringify()
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
      return matchesSearch;
    }).toList();
  }

  void onSelectedDates(DateTime? debut, DateTime? fin) {
    setState(() {
      selectedDebut = debut;
      selectedFin = fin;
      _debutController.text = debut != null ? getStringDate(time: debut) : '';
      _finController.text = fin != null ? getStringDate(time: fin) : '';
    });
    if (fin == null || debut == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez renseigner et la date de début et la date de fin!",
      );
      return;
    }
    MutationRequestContextualBehavior.closePopup();
    _loadCreanceDataWithDates();
  }

  @override
  Widget build(BuildContext context) {
    List<CreanceModel> filteredData = filterCreanceData();

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : hasError
            ? ErrorPage(
                message: errMessage ?? "Erreur lors du chargement des créances",
                onPressed: () async {
                  await _loadCreanceDataWithDates();
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!Responsive.isMobile(context)) ...[
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: AddElementButton(
                        addElement: () => _showChangeDuringPopup(),
                        icon: Icons.date_range_outlined,
                        label: "Choisir une durée",
                      ),
                    ),
                    const Gap(4),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ResearchBar(
                        hintText: "Rechercher par client",
                        controller: _researchController,
                      ),
                      if (!Responsive.isMobile(context)) ...[
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color.fromARGB(255, 171, 204, 120),
                          ),
                          child: Text(
                            "Créance totale: ${Formatter.formatAmount(
                              creanceTotal,
                            )} FCFA",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ] else
                        Container(
                          alignment: Alignment.centerRight,
                          child: AddElementButton(
                            addElement: () => _showChangeDuringPopup(),
                            icon: Icons.date_range_outlined,
                            label: "Choisir une durée",
                          ),
                        ),
                    ],
                  ),
                  const Gap(4),
                  Expanded(
                    child: filteredData.isEmpty
                        ? NoDataPage(
                            data: creanceData,
                            message: "Aucune créance.",
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceBright,
                                  child: CreanceTable(
                                    paginatedCreanceData: getPaginatedData(
                                      data: filteredData,
                                      currentPage: currentPage,
                                    ),
                                    refresh: _loadCreanceDataWithDates,
                                  ),
                                ),
                              ),
                              if (Responsive.isMobile(context))
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: AppColor
                                              .adaptiveGreenSecondary500(
                                                  context),
                                        ),
                                        child: Text(
                                          textAlign: TextAlign.end,
                                          "Créance Totale:  ${Formatter.formatAmount(
                                            creanceTotal,
                                          )} FCFA",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (filteredData.isNotEmpty)
                                PaginationSpace(
                                  currentPage: currentPage,
                                  onPageChanged: (page) {
                                    setState(() {
                                      currentPage = page;
                                    });
                                  },
                                  filterDataCount: filteredData.length,
                                ),
                            ],
                          ),
                  ),
                ],
              );
  }

  void _showChangeDuringPopup() {
    showCustomPoppup(
      context,
      content: UnpaidChangeDuring(
        debutController: _debutController,
        finController: _finController,
        onDatesSelected: onSelectedDates,
      ),
      title: "Choisir la durée",
    );
  }
}
