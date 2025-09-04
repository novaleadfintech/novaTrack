import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../service/debt_service.dart';
import '../../../model/client/client_model.dart';
import '../../../model/entreprise/banque.dart';
import '../../../model/flux_financier/debt_model.dart';
import '../../../model/moyen_paiement_model.dart';
import '../../../service/client_service.dart';
import '../../../service/moyen_paiement_service.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../helper/date_helper.dart';
import '../../../widget/date_text_field.dart';
import '../../../widget/file_field.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/request_response.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';

import '../../integration/popop_status.dart';

class EditDebtPage extends StatefulWidget {
  final DebtModel debt;
  final Future<void> Function() refresh;
  const EditDebtPage({
    super.key,
    required this.debt,
    required this.refresh,
  });

  @override
  State<EditDebtPage> createState() => _EditDebtPageState();
}

class _EditDebtPageState extends State<EditDebtPage> {
  final _libelleFieldController = TextEditingController();
  final _amountFieldController = TextEditingController();
  final _referenceTransactionFieldController = TextEditingController();
  final _dateFieldController = TextEditingController();
  DateTime? _dateOperation;
  PlatformFile? _file;
  late SimpleFontelicoProgressDialog _dialog;
  ClientModel? _client;
  BanqueModel? _banque;

  @override
  void initState() {
    super.initState();
    _initData();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  _initData() {
    _libelleFieldController.text = widget.debt.libelle;
    _amountFieldController.text = widget.debt.montant.toString();
    _referenceTransactionFieldController.text =
        widget.debt.referenceFacture ?? '';
    _dateOperation = widget.debt.dateOperation;
    _dateFieldController.text = getStringDate(time: widget.debt.dateOperation);
    _client = widget.debt.client;
  }

  Future<void> editDebt() async {
    if (_libelleFieldController.text.isEmpty ||
        _amountFieldController.text.isEmpty ||
        _referenceTransactionFieldController.text.isEmpty ||
        _dateOperation == null ||
        _client == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuiller remplir tous les champs marqués",
      );
      return;
    }
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    RequestResponse result = await DebtService.updateDebt(
      libelle: _libelleFieldController.text,
      montant: double.parse(_amountFieldController.text),
      referenceFacture: _referenceTransactionFieldController.text,
      dateOperation: _dateOperation,
      client: _client!,
      file: _file,
      key: widget.debt.id,
    );
    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Dette modifiée avec succès",
      );
      await widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
  }

  Future<List<MoyenPaiementModel>> fetchMoyenPaiementItems() async {
    return _banque == null
        ? await MoyenPaiementService.getMoyenPaiements()
        : (await MoyenPaiementService.getMoyenPaiements())
            .where((m) => m.type == _banque!.type)
            .toList();
  }

  Future<List<ClientModel>> fetchFournisseurItems() async {
    return await ClientService.getUnarchivedFournisseur();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        child: Column(
          children: [
            FutureCustomDropDownField<ClientModel>(
              fetchItems: fetchFournisseurItems,
              onChanged: (value) {
                setState(() {
                  _client = value;
                });
              },
              label: "Fournisseur",
              selectedItem: _client,
              itemsAsString: (l) => l.toStringify(),
            ),
            SimpleTextField(
              label: "Libellé",
              textController: _libelleFieldController,
              keyboardType: TextInputType.text,
            ),
            SimpleTextField(
              label: "Montant",
              textController: _amountFieldController,
              keyboardType: TextInputType.number,
            ),
            DateField(
              onCompleteDate: (value) {
                setState(() {
                  _dateOperation = value!;
                  _dateFieldController.text = getStringDate(time: value);
                });
              },
              label: "Date d'achat",
              dateController: _dateFieldController,
              lastDate: DateTime.now(),
            ),
            SimpleTextField(
              label: "Réference de la facture / transaction / opération",
              textController: _referenceTransactionFieldController,
              keyboardType: TextInputType.text,
            ),
            FileField(
              canTakePhoto: true,
              label: "Pièce justificative",
              platformFile: _file,
              removeFile: () => setState(() {
                _file = null;
              }),
              pickFile: (p0) {
                setState(() {
                  _file = p0;
                });
              },
              required: false,
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: editDebt,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
