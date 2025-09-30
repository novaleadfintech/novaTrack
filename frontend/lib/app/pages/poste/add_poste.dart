import 'package:flutter/material.dart';
import 'package:frontend/service/poste_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../../helper/string_helper.dart';
 import '../../../../widget/simple_text_field.dart';
import '../../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class AddPoste extends StatefulWidget {
  final Future<void> Function() refresh;

  const AddPoste({super.key, required this.refresh});

  @override
  State<AddPoste> createState() => _AddPosteState();
}

class _AddPosteState extends State<AddPoste> {
  final _libelleController = TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleTextField(
          label: "Libellé",
          textController: _libelleController,
          keyboardType: TextInputType.text,
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              onPressed: addPoste,
            ),
          ),
        ),
      ],
    );
  }

  void addPoste() async {
    String? errMessage;
    if (_libelleController.text.isEmpty) {
      errMessage = "Veuillez remplir tous les champs marqués.";
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
      var result = await PosteService.createPoste(
        libelle:
            capitalizeFirstLetter(word: _libelleController.text.toLowerCase()),
      );

      _dialog.hide();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
            status: PopupStatus.success,
            customMessage: "Poste créé avec succès");
        await widget.refresh();
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
        customMessage: "Erreur lors de la création du poste: $err",
      );
    }
  }
}
