import 'package:flutter/material.dart';
import 'package:frontend/helper/string_helper.dart';
import 'package:frontend/model/entreprise/type_canaux_paiement.dart';
import 'package:frontend/service/moyen_paiement_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../widget/drop_down_text_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class AddMoyenPayement extends StatefulWidget {
  final Future<void> Function() refresh;

  const AddMoyenPayement({super.key, required this.refresh});

  @override
  State<AddMoyenPayement> createState() => _AddMoyenPayementState();
}

class _AddMoyenPayementState extends State<AddMoyenPayement> {
  final _libelleController = TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;
  CanauxPaiement? type;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDropDownField<CanauxPaiement>(
          items: CanauxPaiement.values.map((e) => e).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                type = value;
              });
            }
          },
          itemsAsString: (p0) => p0.label,
          selectedItem: type,
          label: "Type",
        ),
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
    if (_libelleController.text.isEmpty || type == null) {
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
      var result = await MoyenPaiementService.createMoyenPaiement(
          libelle: capitalizeFirstLetter(
              word: _libelleController.text.toLowerCase()),
          type: type!
      );

      _dialog.hide();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
            status: PopupStatus.success,
            customMessage: "Moyen de paiement créé avec succès");
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
        customMessage: "Erreur lors de la création du moyen de paiement: $err",
      );
    }
  }
}
