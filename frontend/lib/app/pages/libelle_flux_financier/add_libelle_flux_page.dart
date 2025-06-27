import 'package:flutter/material.dart';
import 'package:frontend/service/libelle_flux_financier_service.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../model/flux_financier/type_flux_financier.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/request_response.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';

class AddLibellePage extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddLibellePage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddLibellePage> createState() => _AddLibellePageState();
}

class _AddLibellePageState extends State<AddLibellePage> {
  final _libelleFieldController = TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;
  FluxFinancierType? type;


  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> addLibelle() async {
    if (_libelleFieldController.text.isEmpty || type == null) { 
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez remplir tous les champs",
      );
      return;
    }
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    RequestResponse result =
        await LibelleFluxFinancierService.createLibelleFluxFinancier(
      libelle: _libelleFieldController.text,
      type: type!,
    );
    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: type == FluxFinancierType.input
            ? "Libellé d'entrée enrégistré avec succès"
            : "Libellé de sortie enrégistrée avec succès",
      );
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
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomDropDownField<FluxFinancierType>(
            items: FluxFinancierType.values.map((type) => type).toList(),
            onChanged: (FluxFinancierType? value) {
              setState(() {
                if (value != null) {
                  type = value;
                }
              });
            },
            label: "Type",
            selectedItem: type,
            itemsAsString: (FluxFinancierType type) => type.label,
          ),
          SimpleTextField(
            label: "Libellé",
            textController: _libelleFieldController,
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
      ),
    );
  }
}
