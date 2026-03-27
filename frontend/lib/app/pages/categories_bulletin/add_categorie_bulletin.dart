import 'package:flutter/material.dart';
import 'package:frontend/model/bulletin_paie/tranche_model.dart';
import 'package:frontend/widget/enum_selector_radio.dart';
import '../../../helper/string_helper.dart';
import '../../../service/bulletin_categorie_service.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class AddBulletinCategoriePage extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddBulletinCategoriePage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddBulletinCategoriePage> createState() =>
      _AddBulletinCategoriePageState();
}

class _AddBulletinCategoriePageState extends State<AddBulletinCategoriePage> {
  final TextEditingController _libelleController = TextEditingController();

  late SimpleFontelicoProgressDialog _dialog;
PaieClause? paieClause;
  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> _addBulletinCategorie() async {
    String? errMessage;
    if (_libelleController.text.isEmpty && paieClause == null) {
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

    var result = await BulletinCategorieservice.createBulletinCategorie(
      bulletinCategorie:
          capitalizeFirstLetter(word: _libelleController.text.toLowerCase()),
      paieClause: paieClause!,
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Catégorie de bulletin crée avec succès");
      await widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
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
                await _addBulletinCategorie();
                },
              ),
            ),
          ),
        ],
      
    );
  }
}
