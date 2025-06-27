import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/flux_financier/bilan_during.dart';
import 'package:frontend/model/flux_financier/type_flux_financier.dart';
import 'package:frontend/style/app_color.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/request_response.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../pdf/flux_fiancier.dart/transaction_periode.dart';
import '../../responsitvity/responsivity.dart';
import 'package:gap/gap.dart';
import '../../../helper/amout_formatter.dart';
import '../../../helper/date_helper.dart';
import '../../../helper/paginate_data.dart';
import '../../../model/flux_financier/bilan.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../service/flux_financier_service.dart';
import '../../../widget/add_element_button.dart';
import '../../../global/global_value.dart';
import '../../../app/pages/no_data_page.dart';
import '../../../app/pages/error_page.dart';
import '../../../widget/pagination.dart';
import '../../../widget/research_bar.dart';
 import 'bilan_table.dart';

class BilanPage extends StatefulWidget {
  const BilanPage({super.key});

  @override
  State<BilanPage> createState() => _BilanPageState();
}

class _BilanPageState extends State<BilanPage> {
  final TextEditingController _researchController = TextEditingController();
  String searchQuery = "";
  int currentPage = GlobalValue.currentPage;
  late SimpleFontelicoProgressDialog _dialog;
  String? selectedType;
  String? errorMessage;
  late Bilan bilanData;
  bool isLoading = true;
  bool hasError = false;
  final TextEditingController _debutController = TextEditingController();
  final TextEditingController _finController = TextEditingController();
  DateTime? selectedDebut;
  DateTime? selectedFin;

  @override
  void initState() {
    super.initState();
    _researchController.addListener(_onSearchChanged);
    _loadBilanData();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _researchController.text;
    });
  }

  List<FluxFinancierModel> filteredBilanData() {
    return bilanData.fluxFinanciers.where((flux) {
      return flux.libelle!
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
    }).toList();
  }

  void updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  Future<void> _loadBilanData(
      {DateTime? debut, DateTime? fin, FluxFinancierType? type}) async {
    try {
      setState(() {
        isLoading = true;
      });
      bilanData = await FluxFinancierService.getAllBilanData(
        debut: debut,
        fin: fin,
        type: type,
      );
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> onSelectedDates({
    DateTime? debut,
    DateTime? fin,
  }) async {
    setState(() {
      selectedDebut = debut;
      selectedFin = fin;
      _debutController.text = debut != null ? getStringDate(time: debut) : '';
      _finController.text = fin != null ? getStringDate(time: fin) : '';
    });

    if (debut == null || fin == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez renseigner la date de debut et de fin.",
      );
      return;
    }
    final type = switch (selectedType) {
      "Entrée" => FluxFinancierType.input,
      "Sortie" => FluxFinancierType.output,
      "Tous" => null,
      _ => null
    };

    await _loadBilanData(
      debut: selectedDebut,
      fin: selectedFin,
      type: type,
    );
    // MutationRequestContextualBehavior.closePopup();
  }

  void onClickDurationButton() {
    showResponsiveDialog(
      context,
      content: BilanChangeDuring(
        debutController: _debutController,
        finController: _finController,
        onDatesSelected: (debut, fin) async {
          await onSelectedDates(debut: debut, fin: fin);
        },
        onselectedType: (value) {
          setState(() {
            selectedType = value;
          });
        },
      ),
      title: "Choisir la durée",
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (hasError) {
      return SizedBox.expand(
        child: ErrorPage(
          message: errorMessage != null
              ? errorMessage!
              : "Erreur lors du chargement des données.",
          onPressed: () async {
            setState(() {
              isLoading = true;
              hasError = false;
            });
            await _loadBilanData();
          },
        ),
      );
    }
    List<FluxFinancierModel> filteredData = filteredBilanData();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8)
          .copyWith(bottom: 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ResearchBar(
                hintText: "Rechercher par libellé",
                controller: _researchController,
              ),
              Row(
                children: [
                  if (!Responsive.isMobile(context) &&
                      filteredData.isNotEmpty) ...[
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            AppColor.primaryColor,
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            AppColor.whiteColor,
                          )),
                      onPressed: () {
                        getTransaction(debut: selectedDebut, fin: selectedFin);
                      },
                      child: Icon(Icons.picture_as_pdf),
                    ),
                    Gap(4),
                  ],
                  AddElementButton(
                    addElement: onClickDurationButton,
                    icon: Icons.date_range_outlined,
                    label: "Choisir une durée",
                  ),
                ],
              )
            ],
          ),
          Gap(2),
          if (Responsive.isMobile(context) && filteredData.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        AppColor.primaryColor,
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        AppColor.whiteColor,
                      )),
                  onPressed: () {
                    getTransaction(debut: selectedDebut, fin: selectedFin);
                  },
                  child: Icon(Icons.picture_as_pdf),
                ),
              ],
            ),
          const Gap(4),
          Expanded(
            child: filteredData.isEmpty
                ? NoDataPage(
                    data: filteredData,
                    message: "Aucune opération financière",
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: BilanTable(
                            paginatedBilanData: getPaginatedData(
                              currentPage: currentPage,
                              data: filteredData,
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),
                      if (!Responsive.isMobile(context)) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ResultCard(
                              label: "Entrée",
                              couleur: const Color.fromARGB(255, 171, 204, 120),
                              montant: bilanData.input,
                            ),
                            ResultCard(
                              label: "Sortie",
                              couleur: const Color.fromARGB(255, 216, 153, 133),
                              montant: bilanData.output,
                            ),
                          ],
                        ),
                      ],
                      if (Responsive.isMobile(context)) ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MobileResultCard(
                              label: "Entrée",
                              couleur: const Color.fromARGB(255, 171, 204, 120),
                              montant: bilanData.input,
                            ),
                            const Gap(4),
                            MobileResultCard(
                              label: "Sortie",
                              couleur: const Color.fromARGB(255, 216, 153, 133),
                              montant: bilanData.output,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
          ),
          const Gap(4),
          if (filteredData.isNotEmpty)
            PaginationSpace(
              filterDataCount: filteredData.length,
              currentPage: currentPage,
              onPageChanged: updateCurrentPage,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debutController.clear();
    _finController.clear();
    super.dispose();
  }

  void getTransaction({
    required DateTime? debut,
    required DateTime? fin,
  }) async {
    if (filteredBilanData().isEmpty) {
      MutationRequestContextualBehavior.showPopup(
        customMessage: "Aucune opération financières",
        status: PopupStatus.information,
      );
    } else {
      _dialog.show(
        message: "",
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      try {
        RequestResponse response =
            await FluxPdfGenerator.generateAndDownloadPdf(
          fluxFinanciers: filteredBilanData(),
          dateDebut: debut,
          dateFin: fin,
          type: selectedType == "Sortie"
              ? FluxFinancierType.output
              : selectedType == "Tous"
                  ? null
                  : FluxFinancierType.input,
        );
        _dialog.hide();
        if (response.status == PopupStatus.success) {
          MutationRequestContextualBehavior.showPopup(
            customMessage: "Les transactions ont été téléchargées avec succès.",
            status: PopupStatus.success,
          );
        } else {
          MutationRequestContextualBehavior.showCustomInformationPopUp(
            message:
                "Une erreur est survenue lors du téléchargement. ${response.message}",
          );
        }
      } catch (e) {
        _dialog.hide();
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message:
              "Erreur lors de la génération du fichier PDF : ${e.toString()}",
        );
        return;
      }
    }
  }
}

class ResultCard extends StatelessWidget {
  final double montant;
  final Color couleur;
  final String label;
  const ResultCard({
    super.key,
    required this.couleur,
    required this.montant,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: couleur,
          ),
          child: Text(
            "$label : ${Formatter.formatAmount(
              montant,
            )} FCFA",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class MobileResultCard extends StatelessWidget {
  final double montant;
  final Color couleur;
  final String label;
  const MobileResultCard({
    super.key,
    required this.couleur,
    required this.montant,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: couleur,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${Formatter.formatAmount(
              montant,
            )} FCFA",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
