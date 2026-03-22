import 'package:flutter/material.dart';
import 'package:frontend/model/bulletin_paie/tranche_model.dart';
import 'package:frontend/widget/enum_selector_radio.dart';
import '../../../helper/string_helper.dart';
import '../../../model/bulletin_paie/categorie_bulletin.dart';
import '../../../service/categorie_bulletin_service.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class EditCategorieBulletinPage extends StatefulWidget {
  final Future<void> Function() refresh;
  final CategorieBulletinModel categorieBulletin;
  const EditCategorieBulletinPage({
    super.key,
    required this.refresh,
    required this.categorieBulletin,
  });

  @override
  State<EditCategorieBulletinPage> createState() =>
      _EditCategorieBulletinPageState();
}

class _EditCategorieBulletinPageState extends State<EditCategorieBulletinPage> {
  final TextEditingController _libelleController = TextEditingController();
  PaieClause? paieClause;
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    super.initState();
    _libelleController.text = widget.categorieBulletin.categorieBulletin;
    paieClause = widget.categorieBulletin.paieClause;
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> _editCategorieBulletin() async {
    String? errMessage;
    if (_libelleController.text.isEmpty && paieClause == null) {
      errMessage = "Veuillez remplir tous les champs marqués.";
    }

    if (_libelleController.text == widget.categorieBulletin.categorieBulletin &&
        paieClause == widget.categorieBulletin.paieClause) {
      errMessage = "Aucune modification n'a été faite!";
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
      var result = await CategorieBulletinService.updateCategorieBulletin(
        categorieBulletin:
            capitalizeFirstLetter(word: _libelleController.text.toLowerCase()),
        paieClause: paieClause ?? widget.categorieBulletin.paieClause,
        key: widget.categorieBulletin.id,
      );

      _dialog.hide();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
            status: PopupStatus.success,
            customMessage: "Catégorie modifié avec succès");
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
        customMessage: err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleTextField(
          label: "Libellé",
          textController: _libelleController,
        ),
        EnumRadioSelector<PaieClause>(
          title: "Clause de paie",
          selectedValue: paieClause,
          values: PaieClause.values,
          getLabel: (value) => value.label,
          onChanged: (value) {
            setState(() {
              paieClause = value;
            });
          },
          isRequired: true,
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              onPressed: () async {
                await _editCategorieBulletin();
              },
            ),
          ),
        ),
      ],
    );
  }
}
