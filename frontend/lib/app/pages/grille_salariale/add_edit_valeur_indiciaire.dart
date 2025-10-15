import 'package:flutter/material.dart';
import 'package:frontend/service/entreprise_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../widget/simple_text_field.dart';
import '../../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class AddOrEditValeurIndiciaire extends StatefulWidget {
  const AddOrEditValeurIndiciaire({
    super.key,
  });

  @override
  State<AddOrEditValeurIndiciaire> createState() =>
      _AddOrEditValeurIndiciaireState();
}

class _AddOrEditValeurIndiciaireState extends State<AddOrEditValeurIndiciaire> {
  final _valeurIndiciaireController = TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    await _loadValeurIndiciaire();
  }

  _loadValeurIndiciaire() async {
    _valeurIndiciaireController.text =
        ((await EntrepriseService.getindiceInciciaire()) ?? "").toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleTextField(
          label: "Valeur indiciaire",
          textController: _valeurIndiciaireController,
          keyboardType: TextInputType.text,
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              onPressed: addValeurIndiciaire,
            ),
          ),
        ),
      ],
    );
  }

  void addValeurIndiciaire() async {
    String? errMessage;
    if (_valeurIndiciaireController.text.isEmpty) {
      errMessage = "Veuillez remplir le champs de valeur indiciaire.";
    }

    if (errMessage != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: errMessage,
      );
      return;
    }

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    try {
      var result = await EntrepriseService.updateEntreprise(
        valeurIndiciaire: int.parse(_valeurIndiciaireController.text.trim()),
      );

      _dialog.hide();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Succès",
        );
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    } catch (err) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: "Erreur lors de l'enregistrement: $err",
      );
    }
  }
}
