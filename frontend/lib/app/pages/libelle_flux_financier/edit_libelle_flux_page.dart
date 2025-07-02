import 'package:flutter/material.dart';
import 'package:frontend/service/libelle_flux_financier_service.dart';
import '../../../model/entreprise/banque.dart';
import '../../../model/flux_financier/libelle_flux.dart';
import '../../../model/flux_financier/type_flux_financier.dart';
import '../../../model/request_response.dart';
import '../../../service/banque_service.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class EditLibellePage extends StatefulWidget {
  final LibelleFluxModel libelleFlux;
  final Future<void> Function() refresh;
  const EditLibellePage({
    super.key,
    required this.libelleFlux,
    required this.refresh,
  });

  @override
  State<EditLibellePage> createState() => _EditLibellePageState();
}

class _EditLibellePageState extends State<EditLibellePage> {
  late SimpleFontelicoProgressDialog _dialog;

  final TextEditingController _libelleFieldController = TextEditingController();
  FluxFinancierType? type;
  FluxFinancierType? newType;
  String? libelle;

  Future<void> editLibelle({required LibelleFluxModel libelleFlux}) async {
    if (_libelleFieldController.text.isEmpty || type == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez remplir tous les champs",
      );
      return;
    }
    if (_libelleFieldController.text != widget.libelleFlux.libelle) {
      libelle = _libelleFieldController.text;
    }
    if (type != widget.libelleFlux.type) {
      newType = type;
    }

    if (libelle == null && type == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Aucune donnée n'a été modifiée",
      );
      return;
    }
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    RequestResponse result =
        await LibelleFluxFinancierService.updateLibelleFluxFinancier(
      key: libelleFlux.id,
      libelle: libelle,
      type: newType,
    );

    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
        customMessage: "Libellé modifié avec succès",
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
  void initState() {
    _libelleFieldController.text = widget.libelleFlux.libelle;
    type = widget.libelleFlux.type;
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  Future<List<BanqueModel>> fetchBanqueItems() async {
    return await BanqueService.getAllBanques();
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
                onPressed: () async {
                  await editLibelle(libelleFlux: widget.libelleFlux);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
