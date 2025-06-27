import 'package:flutter/material.dart';
import 'package:frontend/global/constant/constant.dart';
import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/flux_financier/type_flux_financier.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../helper/date_helper.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../model/request_response.dart';
import '../../../service/flux_financier_service.dart';
import '../../../widget/date_text_field.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../pdf/flux_fiancier.dart/banque_transaction.dart';

class ChooseTransactionDuration extends StatefulWidget {
  final BanqueModel banque;

  const ChooseTransactionDuration({
    super.key,
    required this.banque,
  });
  @override
  State<ChooseTransactionDuration> createState() =>
      _ChooseTransactionDurationState();
}

class _ChooseTransactionDurationState extends State<ChooseTransactionDuration> {
  final TextEditingController finController = TextEditingController();
  final TextEditingController debutController = TextEditingController();
  DateTime? dateDebut;
  FluxFinancierStatus? status;
  DateTime? dateFin;
  late SimpleFontelicoProgressDialog _dialog;
  @override
  void dispose() {
    debutController.clear();
    finController.clear();

    super.dispose();
  }

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vous allez importer les transactions de la banque pour une période donnée. "
            "Veuillez choisir la période de début et de fin.",
            style: TextStyle(fontSize: 16),
          ),
          const Gap(8),
          DateField(
            onCompleteDate: (value) {
              debutController.text = getStringDate(time: value!);
              setState(() {
                dateDebut = value;
              });
            },
            lastDate: dateFin ?? DateTime.now(),
            label: "Début",
            dateController: debutController,
          ),
          const Gap(4),
          DateField(
            onCompleteDate: (value) {
              finController.text = getStringDate(time: value!);
              setState(() {
                dateFin = value;
              });
            },
            firstDate: dateDebut,
            lastDate: DateTime.now(),
            label: "Fin",
            dateController: finController,
          ),
          CustomDropDownField<FluxFinancierStatus>(
            items: FluxFinancierStatus.values,
            onChanged: (FluxFinancierStatus? value) {
              setState(() {
                if (value != null) {
                  status = value;
                }
              });
            },
            required: false,
            label: "Status de flux",
            selectedItem: status,
            canClose: true,
            itemsAsString: (FluxFinancierStatus c) => c.label,
          ),
          const Gap(8),
          Align(
            alignment: Alignment.bottomRight,
            child: ValidateButton(
              libelle: Constant.download,
              onPressed: () async {
                _downloadTransactions();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _downloadTransactions() async {
    if (dateDebut == null || dateFin == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez renseigner et la date de début et la date de fin",
      );
      return;
    }
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    List<FluxFinancierModel> flux = [];
    try {
      flux = await FluxFinancierService.getBanqueTransaction(
        banqueId: widget.banque.id,
        debut: dateDebut!,
        fin: dateFin!,
        status: status,
      );

      if (flux.isEmpty) {
        _dialog.hide();
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message:
              "Aucune opération financière ${status == null ? status!.label.toLowerCase() : ""} n'a été effectuée à ${widget.banque.name} entre le ${getStringDate(time: dateDebut!)} et le ${getStringDate(time: dateFin!)}.",
        );
        return;
      }
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage:
            "Erreur lors de la récupération des transactions : ${e.toString()}",
      );
      return;
    }

    try {
      RequestResponse response =
          await TransactionPdfGenerator.generateAndDownloadPdf(
        banque: widget.banque,
        fluxFinanciers: flux,
        dateDebut: dateDebut!,
        dateFin: dateFin!,
      );
      MutationRequestContextualBehavior.closePopup();
      _dialog.hide();
      if (response.status == PopupStatus.success) {
        MutationRequestContextualBehavior.showPopup(
          customMessage: "Les transactions ont été téléchargées avec succès.",
          status: PopupStatus.success,
        );
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.customError,
          customMessage:
              "Une erreur est survenue lors du téléchargement. ${response.message}",
        );
      }
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message:
            "Erreur lors de la génération du fichier PDF : ${e.toString()}",
      );
    }
  }
}
