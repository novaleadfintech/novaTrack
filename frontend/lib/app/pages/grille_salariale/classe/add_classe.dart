import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
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
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
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
          //pour les vrai donne TODO
          MultiCheckBox(
            label: "Selectionnez les échelons",
            initialSelectedValues: [1, 2, 3, 4],
            options: [2, 4, 7],
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
      // var result = await ClasseService.createClasse(
      //   section:
      //       capitalizeFirstLetter(word: _libelleController.text.toLowerCase()),
      // );

      // _dialog.hide();

      // if (result.status == PopupStatus.success) {
      //   MutationRequestContextualBehavior.closePopup();
      //   MutationRequestContextualBehavior.showPopup(
      //       status: PopupStatus.success,
      //       customMessage: "Classe créée avec succès");
      //   await widget.refresh();
      // } else {
      //   MutationRequestContextualBehavior.showPopup(
      //     status: result.status,
      //     customMessage: result.message,
      //   );
      // }
    } catch (err) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: "Erreur lors de la création du moyen de paiement: $err",
      );
    }
  }
}
