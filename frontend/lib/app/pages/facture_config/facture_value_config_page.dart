import 'package:flutter/material.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/service/client_facture_global_value_service.dart';
import 'package:frontend/widget/simple_text_field.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../model/facturation/facture_global_value_model.dart';
import '../../../model/request_response.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';

class FactureValueConfigPage extends StatefulWidget {
  final ClientFactureGlobaLValueModel? clientFactureGlobaLValue;
  final VoidCallback refresh;
  const FactureValueConfigPage({
    super.key,
    this.clientFactureGlobaLValue,
    required this.refresh,
  });

  @override
  State<FactureValueConfigPage> createState() => _FactureValueConfigPageState();
}

class _FactureValueConfigPageState extends State<FactureValueConfigPage> {
  final TextEditingController nombreJrPenaliteController =
      TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    nombreJrPenaliteController.text =
        (widget.clientFactureGlobaLValue?.nbreJrMaxPenalty?.toString() ?? "")
            .trim();

    _dialog = SimpleFontelicoProgressDialog(context: context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleTextField(
            label: "Nombre de jour de penalité (Jour)",
            textController: nombreJrPenaliteController),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              onPressed: () {
                addConfigValue(
                    clientId: widget.clientFactureGlobaLValue!.client.id);
              },
            ),
          ),
        ),
      ],
    );
  }

  void addConfigValue({required clientId}) async {
    try {
      if (nombreJrPenaliteController.text.isEmpty) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
            message: "Veuillez renseigner le nombre de jour de pénalité");
        return;
      }
      final int? nbreJrMaxPenalty =
          int.tryParse(nombreJrPenaliteController.text.trim());
      if (nbreJrMaxPenalty == null || nbreJrMaxPenalty < 0) {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
            message:
                "Veuillez renseigner un nombre de jour de pénalité valide");
        return;
      }
      _dialog.show(
        message: "",
        type: SimpleFontelicoProgressDialogType.phoenix,
        backgroundColor: Colors.transparent,
      );

      RequestResponse result =
          await ClientFactureGlobalValuesService.configClientFactureGlobaLValue(
              nbreJrMaxPenalty: nbreJrMaxPenalty,
              client: widget.clientFactureGlobaLValue!.client);
      _dialog.hide();
      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
            status: PopupStatus.success,
            customMessage: "Enregistré avec succès");
        widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: e.toString(),
      );
    }
  }
}
