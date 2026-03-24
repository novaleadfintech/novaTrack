import 'package:flutter/material.dart';
import 'package:frontend/app/integration/popop_status.dart';
import 'package:frontend/helper/string_helper.dart' show capitalizeFirstLetter;
import 'package:frontend/service/pay_calendar_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../../helper/date_helper.dart';
import '../../../../model/bulletin_paie/calendar_model.dart';
import '../../../../widget/date_text_field.dart';
import '../../../../widget/simple_text_field.dart';
import '../../../../widget/validate_button.dart';
import '../../../integration/request_frot_behavior.dart';
 
class EditPayCalendar extends StatefulWidget {
  final PayCalendarModel payCalendar;
  final Future<void> Function() refresh;

  const EditPayCalendar({
    super.key,
    required this.payCalendar,
    required this.refresh,
  });

  @override
  State<EditPayCalendar> createState() => _EditPayCalendarState();
}

class _EditPayCalendarState extends State<EditPayCalendar> {
  late TextEditingController _libelleController;
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;
  DateTime? _dateFin;
  DateTime? _dateDebut;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _libelleController =
        TextEditingController(text: widget.payCalendar.libelle);
    // assume payCalendar.dateDebut/dateFin are DateTime or parseable strings
    _dateDebut = widget.payCalendar.dateDebut;
    if (_dateDebut != null) {
      _dateDebutController.text = getStringDate(time: _dateDebut!);
    }
    _dateFin = widget.payCalendar.dateFin;
    if (_dateFin != null) {
      _dateFinController.text = getStringDate(time: _dateFin!);
    }
  }

  @override
  void dispose() {
    _libelleController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    super.dispose();
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
        DateField(
          onCompleteDate: (value) {
            setState(() {
              _dateDebut = value!;
              _dateDebutController.text = getStringDate(time: value);
            });
          },
          lastDate: _dateFin,
          label: "Début de la période",
          dateController: _dateDebutController,
        ),
        DateField(
          onCompleteDate: (value) {
            setState(() {
              _dateFin = value!;
              _dateFinController.text = getStringDate(time: value);
            });
          },
          firstDate: _dateDebut,
          label: "Fin de la période",
          dateController: _dateFinController,
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              onPressed: editPayCalendar,
            ),
          ),
        ),
      ],
    );
  }

  void editPayCalendar() async {
    String? errMessage;
    if (_libelleController.text.isEmpty ||
        _dateDebut == null ||
        _dateFin == null) {
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
      // J'assume que PayCalendarService.updatePayCalendar existe et prend ces params
      var result = await PayCalendarService.updatePayCalendar(
        key: widget.payCalendar.key,
        libelle:
            capitalizeFirstLetter(word: _libelleController.text.toLowerCase()),
        dateDebut: _dateDebut!,
        dateFin: _dateFin!,
      );

      _dialog.hide();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
            status: PopupStatus.success,
            customMessage: "Période de paie modifiée avec succès");
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
        customMessage:
            "Erreur lors de la modification de la période de paie: $err",
      );
    }
  }
}
