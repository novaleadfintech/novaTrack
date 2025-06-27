import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../../model/bulletin_paie/bulletin_model.dart';
import '../../../../model/request_response.dart';
import '../../../../service/bulletin_service.dart';
import '../../../../style/app_color.dart';
import '../../../../widget/research_bar.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import '../../../pdf/bulletin_generate/bulletin.dart';
import '../../error_page.dart';
import '../../no_data_page.dart';

class MultipleBulletnPage extends StatefulWidget {
  const MultipleBulletnPage({super.key});

  @override
  State<MultipleBulletnPage> createState() => _MultipleBulletnPageState();
}

class _MultipleBulletnPageState extends State<MultipleBulletnPage> {
  final TextEditingController _researchController = TextEditingController();
  List<BulletinPaieModel> bulletinData = [];
  late SimpleFontelicoProgressDialog _dialog;

  String searchQuery = "";
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  List<BulletinPaieModel> selectedBulletins = [];

  List<BulletinPaieModel> filteredBulletinData() {
    return bulletinData.where((bulletin) {
      return bulletin.salarie.personnel
          .toStringify()
          .toLowerCase()
          .contains(searchQuery.toLowerCase().trim());
    }).toList();
  }

  Future<void> _loadServiceData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = "";
      });

      bulletinData = await BulletinService.getCurrentValidateBulletins();
      selectedBulletins.addAll(bulletinData);
    } catch (error) {
      setState(() {
        hasError = true;
        errorMessage =
            "Erreur lors du chargement des données : ${error.toString()}";
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

  @override
  void initState() {
    _loadServiceData();
    _researchController.addListener(_onSearchChanged);
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<BulletinPaieModel> filteredData = filteredBulletinData();
    return Column(
      children: [
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (hasError)
          ErrorPage(
            message: errorMessage ?? "Erreur lors de la recuperation",
            onPressed: () => setState(() {}),
          )
        else if (filteredBulletinData().isEmpty)
          const NoDataPage(
            data: [],
            message: "Aucun bulletin de paie",
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ResearchBar(
                    hintText: "Rechercher par salarié",
                    controller: _researchController,
                  ),
                  Gap(16),
                  if (selectedBulletins.isNotEmpty)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        // padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColor.primaryColor,
                        ),
                        child: IconButton(
                          onPressed: () {
                            generateAllBulletinPdf(
                                bulletins: selectedBulletins);
                          },
                          icon: Icon(
                            Icons.picture_as_pdf,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
                    )
                ],
              ),
              Table(
                children: [
                  ...filteredData.map((bulletin) {
                    return TableRow(children: [
                      ListTile(
                        title: Text(bulletin.salarie.personnel.toStringify()),
                        selected: selectedBulletins.contains(bulletin),
                        trailing: Checkbox(
                          value: selectedBulletins.contains(bulletin),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedBulletins.add(bulletin);
                              } else {
                                selectedBulletins.remove(bulletin);
                              }
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (selectedBulletins.contains(bulletin)) {
                              selectedBulletins.remove(bulletin);
                            } else {
                              selectedBulletins.add(bulletin);
                            }
                          });
                        },
                      )
                    ]);
                  })
                ],
              ),
            ],
          ),
      ],
    );
  }

  void generateAllBulletinPdf(
      {required List<BulletinPaieModel> bulletins}) async {
    try {
      _dialog.show(
        message: '',
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse? result =
          await BulletinPdfGenerator.generateAndDownloadMultipleBulletins(
        bulletins: bulletins,
      );

      _dialog.hide();
      if (result!.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: "Les bulletins ont eté générés avec succès.",
        );
      } else {
        MutationRequestContextualBehavior.showPopup(
            status: result.status, customMessage: result.message);
        return;
      }
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: "Erreur lors de la génération ${e.toString()}",
      );
      return;
    }
  }
}
