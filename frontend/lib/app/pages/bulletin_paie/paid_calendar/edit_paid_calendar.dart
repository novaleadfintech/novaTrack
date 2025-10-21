import 'package:flutter/material.dart';
 import 'package:frontend/model/bulletin_paie/calendar_model.dart';
 import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../widget/simple_text_field.dart';
import '../../../../widget/validate_button.dart';
 import '../../../integration/request_frot_behavior.dart';

class EditPayCalendar extends StatefulWidget {
  final Future<void> Function() refresh;
  final PayCalendarModel payCalendar;

  const EditPayCalendar(
      {super.key, required this.refresh, required this.payCalendar});

  @override
  State<EditPayCalendar> createState() => _EditPayCalendarState();
}

class _EditPayCalendarState extends State<EditPayCalendar> {
  final _libelleController = TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _libelleController.text = widget.payCalendar.libelle;
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
              onPressed: addLibelle,
            ),
          ),
        ),
      ],
    );
  }

  void addLibelle() async {
    String? errMessage;
    if (_libelleController.text.isEmpty) {
      errMessage = "Veuillez remplir tous les champs marqués.";
    }

    if (_libelleController.text == widget.payCalendar.libelle) {
      errMessage = "Aucune modification n'a été apportée.";
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

    // var result = await PayCalendarService.updatePayCalendar(
    //   key: widget.payCalendar.id,
    //   libelle:
    //       capitalizeFirstLetter(word: _libelleController.text.toLowerCase()),
    // );

    // _dialog.hide();

    // if (result.status == PopupStatus.success) {
    //   MutationRequestContextualBehavior.closePopup();
    //   MutationRequestContextualBehavior.showPopup(
    //       status: PopupStatus.success,
    //       customMessage: "PayCalendar modifié avec succès");
    //   await widget.refresh();
    // } else {
    //   MutationRequestContextualBehavior.showPopup(
    //     status: result.status,
    //     customMessage: result.message,
    //   );
    // }
  }
}
