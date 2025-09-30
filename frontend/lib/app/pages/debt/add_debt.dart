import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/service/debt_service.dart';
import '../../../model/client/client_model.dart';
import '../../../model/entreprise/banque.dart';
import '../../../model/moyen_paiement_model.dart';
import '../../../service/client_service.dart';
import '../../../service/moyen_paiement_service.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../auth/authentification_token.dart';
import '../../../helper/date_helper.dart';
 import '../../../model/habilitation/user_model.dart';
import '../../../widget/date_text_field.dart';
import '../../../widget/file_field.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/request_response.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';

import '../../integration/popop_status.dart';

class AddDebtPage extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddDebtPage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddDebtPage> createState() => _AddDebtPageState();
}

class _AddDebtPageState extends State<AddDebtPage> {
  final _libelleFieldController = TextEditingController();
  final _amountFieldController = TextEditingController();
  final _referenceTransactionFieldController = TextEditingController();
  final _dateFieldController = TextEditingController();
  DateTime? _dateOperation;
  PlatformFile? _file;
  late SimpleFontelicoProgressDialog _dialog;
  UserModel? _user;
  ClientModel? _client;
  BanqueModel? _banque;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> addDebt() async {
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
    try {
      _user = await AuthService().decodeToken();
    } catch (err) {
       _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.serverError,
        customMessage: "Enégistrement échoué",
      );
      return;
    }
    RequestResponse result = await DebtService.createDebt(
      libelle: _libelleFieldController.text,
      montant: double.parse(_amountFieldController.text),
      referenceFacture: _referenceTransactionFieldController.text,
      dateOperation: _dateOperation,
      client: _client!,
      file: _file,
      userId: _user!.id!,
    );
    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Dette enrégistrée avec succès",
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
                  onPressed: addDebt,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
