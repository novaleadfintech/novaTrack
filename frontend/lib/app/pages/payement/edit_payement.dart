import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../helper/date_helper.dart';
import '../../../model/entreprise/banque.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../model/moyen_paiement_model.dart';
import '../../../service/banque_service.dart';
import '../../../service/moyen_paiement_service.dart';
import '../../../widget/date_text_field.dart';
import '../../../widget/file_field.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/request_response.dart';
import '../../../service/flux_financier_service.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class EditPayement extends StatefulWidget {
  final FluxFinancierModel payement;
  final Future<void> Function() refresh;

  const EditPayement({
    super.key,
    required this.payement,
    required this.refresh,
  });

  @override
  State<EditPayement> createState() => _EditFluxPageState();
}

class _EditFluxPageState extends State<EditPayement> {
  final amountFieldController = TextEditingController();
  final dateOperationController = TextEditingController();
  final referenceTransactionFieldController = TextEditingController();
  MoyenPaiementModel? moyenPayement;
  DateTime? dateOperation;
  late SimpleFontelicoProgressDialog _dialog;
  BanqueModel? newbanque;
  BanqueModel? _selectedBank;
  MoyenPaiementModel? newmoyenPayement;
  String? referenceTransaction;
  DateTime? newdateOperation;

  double? montant;
  PlatformFile? file;

  editPayement({required FluxFinancierModel flux}) async {
    if (moyenPayement == null ||
        referenceTransactionFieldController.text.isEmpty ||
        _selectedBank == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuillez remplir tous les champs marqués.",
      );
      return;
    }
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    if (amountFieldController.text != flux.montant.toString()) {
      montant = double.tryParse(amountFieldController.text);
    }
    if (dateOperation != flux.dateOperation) {
      newdateOperation = dateOperation;
    }

    if (moyenPayement != flux.moyenPayement) {
      newmoyenPayement = moyenPayement;
    }
    if (_selectedBank!.equalTo(bank: flux.bank!)) {
      newmoyenPayement = moyenPayement;
    }
    if (referenceTransactionFieldController.text != flux.referenceTransaction) {
      referenceTransaction = referenceTransactionFieldController.text;
    }

    if (newdateOperation == null &&
        newmoyenPayement == null &&
        montant == null &&
        newbanque == null &&
        referenceTransaction == null &&
        file == null) {
      _dialog.hide();
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Aucune donnée n'a été modifiée",
      );
      return;
    }

    RequestResponse result = await FluxFinancierService.updateFluxFinancier(
      key: flux.id,
      dateOperation: newdateOperation,
      montant: montant,
      moyenPayement: newmoyenPayement,
      file: file,
      client: null,
      banque: newbanque,
      referenceTransaction: referenceTransaction,
    );

    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Payement enrégistré avec succès",
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
    amountFieldController.text = widget.payement.montant.toString();
    referenceTransactionFieldController.text =
        widget.payement.referenceTransaction.toString();
    dateOperationController.text = getStringDate(
      time: widget.payement.dateOperation!,
    );
    _dialog = SimpleFontelicoProgressDialog(context: context);
    setState(() {
      moyenPayement = widget.payement.moyenPayement;
    });
    super.initState();
  }

  Future<List<BanqueModel>> fetchBanqueItems() async {
    return moyenPayement == null
        ? await BanqueService.getAllBanques()
        : (await BanqueService.getAllBanques())
            .where((b) => b.type == moyenPayement!.type)
            .toList();
  }

Future<List<MoyenPaiementModel>> fetchMoyenPaiementItems() async {
    return _selectedBank == null
        ? await MoyenPaiementService.getMoyenPaiements()
        : (await MoyenPaiementService.getMoyenPaiements())
            .where((m) => m.type == _selectedBank!.type)
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: UniqueKey(),
        child: Column(
          children: [
            SimpleTextField(
              label: "Montant",
              textController: amountFieldController,
              keyboardType: TextInputType.number,
              readOnly: true,
            ),
            DateField(
              onCompleteDate: (value) {
                dateOperation = value!;
                dateOperationController.text = getStringDate(time: value);
              },
              label: "Date de paiement",
              dateController: dateOperationController,
            ),
            FutureCustomDropDownField<MoyenPaiementModel>(
              label: "Moyen de paiement",
              selectedItem: moyenPayement,
              fetchItems: fetchMoyenPaiementItems,
              onChanged: (MoyenPaiementModel? value) {
                // if (value != null) {
                setState(() {
                  moyenPayement = value;
                });
                // }
              },
              canClose: true,
              itemsAsString: (s) => s.libelle,
            ),
            FutureCustomDropDownField<BanqueModel>(
              label: "Compte de payement",
              showSearchBox: true,
              selectedItem: _selectedBank,
              fetchItems: fetchBanqueItems,
              onChanged: (BanqueModel? value) {
                // if (value != null) {
                setState(() {
                  _selectedBank = value;
                });
                // }
              },
              canClose: true,
              itemsAsString: (s) => s.name,
            ),
            SimpleTextField(
              label:
                  "Référence de la transaction${moyenPayement != null ? " (${moyenPayement!.libelle})" : ""}",
              textController: referenceTransactionFieldController,
              keyboardType: TextInputType.text,
            ),
            FileField(
              canTakePhoto: true,
              label: "Pièce justificative",
              platformFile: file,
              removeFile: () => setState(() {
                file = null;
              }),
              pickFile: (p0) {
                setState(() {
                  file = p0;
                });
              },
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: () {
                    editPayement(flux: widget.payement);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
