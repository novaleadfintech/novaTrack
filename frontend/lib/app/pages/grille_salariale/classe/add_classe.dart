import 'package:flutter/material.dart';
import 'package:frontend/model/grille_salariale/echelon_indice_model.dart';
import 'package:frontend/model/grille_salariale/echelon_model.dart';
import 'package:frontend/service/echelon_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../service/classe_service.dart';
import '../../../../widget/multi_check_box.dart';
import '../../../../widget/simple_text_field.dart';
import '../../../../widget/validate_button.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';

class AddClasse extends StatefulWidget {
  final Future<void> Function() refresh;

  const AddClasse({super.key, required this.refresh});

  @override
  State<AddClasse> createState() => _AddClasseState();
}

class _AddClasseState extends State<AddClasse> {
  final _libelleController = TextEditingController();
  List<EchelonIndiceModel> selectedEchelonsIciciare = [];
  List<EchelonModel> selectedEchelons = [];
  late SimpleFontelicoProgressDialog _dialog;
  List<EchelonModel> echelonOptions = [];
  bool isLoadingEchelons = true;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _loadEchelons();
  }

  Future<void> _loadEchelons() async {
    try {
      final echelons = await EchelonService.getEchelons();
      setState(() {
        echelonOptions = echelons;
        isLoadingEchelons = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des échelons: $e');
      setState(() {
        echelonOptions = [];
        isLoadingEchelons = false;
      });
    }
  }

  @override
  void dispose() {
    _libelleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SimpleTextField(
            label: "Libellé",
            textController: _libelleController,
            keyboardType: TextInputType.text,
          ),
          const Gap(16),
          isLoadingEchelons
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : echelonOptions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Aucun échelon disponible",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : MultiCheckBox<EchelonModel>(
                      label: "Sélectionnez les échelons",
                      initialSelectedValues: selectedEchelons,
                      options: echelonOptions,
                      onChanged: (selected) {
                        setState(() {
                          selectedEchelonsIciciare = selected
                              .map((e) => EchelonIndiceModel(
                                    echelon: e,
                                    indice: null,
                                  ))
                              .toList();
                        });
                      },
                    ),
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ValidateButton(
                onPressed: addClasse,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addClasse() async {
    String? errMessage;

    if (_libelleController.text.trim().isEmpty) {
      errMessage = "Le libellé est requis.";
    } else if (selectedEchelonsIciciare.isEmpty) {
      errMessage = "Veuillez sélectionner au moins un échelon.";
    }

    if (errMessage != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: errMessage,
      );
      return;
    }

    _dialog.show(
      message: "Création en cours...",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    try {
      var result = await ClasseService.createClasse(
        libelle: _libelleController.text.trim(),
        echelonIndiciciaires: selectedEchelonsIciciare,
      );

      _dialog.hide();

      if (result.status == PopupStatus.success) {
        if (mounted) {
          MutationRequestContextualBehavior.closePopup();
          MutationRequestContextualBehavior.showPopup(
            status: PopupStatus.success,
            customMessage: "Classe créée avec succès",
          );
          await widget.refresh();
        }
      } else {
        if (mounted) {
          MutationRequestContextualBehavior.showPopup(
            status: result.status,
            customMessage: result.message,
          );
        }
      }
    } catch (err) {
      _dialog.hide();
      if (mounted) {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.customError,
          customMessage: "Erreur lors de la création de la classe: $err",
        );
      }
    }
  }
}
