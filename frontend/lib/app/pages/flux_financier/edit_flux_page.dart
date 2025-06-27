import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../helper/date_helper.dart';
import '../../../model/client/client_model.dart';
import '../../../model/entreprise/banque.dart';
import '../../../model/flux_financier/flux_financier_model.dart';
import '../../../model/moyen_paiement_model.dart';
import '../../../model/request_response.dart';
import '../../../service/banque_service.dart';
import '../../../service/client_service.dart';
import '../../../service/flux_financier_service.dart';
import '../../../service/moyen_paiement_service.dart';
import '../../../widget/date_text_field.dart';
import '../../../widget/file_field.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/flux_financier/type_flux_financier.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';

class EditFluxFiancierPage extends StatefulWidget {
  final FluxFinancierModel flux;
  final Future<void> Function() refresh;
  const EditFluxFiancierPage({
    super.key,
    required this.flux,
    required this.refresh,
  });

  @override
  State<EditFluxFiancierPage> createState() => _EditFluxFiancierPageState();
}

class _EditFluxFiancierPageState extends State<EditFluxFiancierPage> {
  late SimpleFontelicoProgressDialog _dialog;

  final libelleFieldController = TextEditingController();
  final amountFieldController = TextEditingController();
  final dateOperationController = TextEditingController();
  final referenceTransactionFieldController = TextEditingController();
  MoyenPaiementModel? moyenPayement;
  DateTime? dateOperation;
  ClientModel? client;
  MoyenPaiementModel? newmoyenPayement;
  DateTime? newdateOperation;
  double? montant;
  String? libelle;
  String? referenceTransaction;
  PlatformFile? file;
  BanqueModel? _selectedBank;
  BanqueModel? newbanque;
  ClientModel? newclient;
  MultiSelectController<BanqueModel> comptesController =
      MultiSelectController<BanqueModel>();

  bool isBanqueEqual({
    required List<BanqueModel>? list1,
    required List<BanqueModel>? list2,
  }) {
    if (list1 == null || list2 == null) return list1 == list2;
    if (list1.length != list2.length) return false;
    final set1 = list1.map((item) => item.id).toSet();
    final set2 = list2.map((item) => item.id).toSet();
    return set1.containsAll(set2) && set2.containsAll(set1);
  }

  editFlux({required FluxFinancierModel flux}) async {
    if (libelleFieldController.text.isEmpty ||
        amountFieldController.text.isEmpty ||
        referenceTransactionFieldController.text.isEmpty ||
        moyenPayement == null ||
        _selectedBank == null ||
        client == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuiller renprir tous les champs marqué",
      );
      return;
    }
    if (libelleFieldController.text != widget.flux.libelle) {
      libelle = libelleFieldController.text;
    }
    if (referenceTransactionFieldController.text !=
        widget.flux.referenceTransaction) {
      referenceTransaction = referenceTransactionFieldController.text;
    }

    if (amountFieldController.text != widget.flux.montant.toString()) {
      montant = double.tryParse(amountFieldController.text);
    }

    if (dateOperation != widget.flux.dateOperation) {
      newdateOperation = dateOperation;
    }
    if (!client!.equalTo(client: flux.client)) {
      newclient = client;
    }

    if (dateOperation != widget.flux.dateOperation) {
      newdateOperation = dateOperation;
    }
    if (!_selectedBank!.equalTo(bank: widget.flux.bank!)) {
      newbanque = _selectedBank;
    }

    if (moyenPayement != widget.flux.moyenPayement) {
      newmoyenPayement = moyenPayement;
    }

    if (newdateOperation == null &&
        newmoyenPayement == null &&
        libelle == null &&
        newclient == null &&
        montant == null &&
        newbanque == null &&
        referenceTransaction == null &&
        file?.bytes == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Aucune donnée n'a été modifiée",
      );
      return;
    }

    _dialog.show(
      message: "Modification en cours...",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

 
    RequestResponse result = await FluxFinancierService.updateFluxFinancier(
      key: flux.id,
      dateOperation: newdateOperation,
      montant: montant,
      moyenPayement: newmoyenPayement,
      file: file,
      referenceTransaction: referenceTransaction,
      libelle: libelle,
      banque: newbanque,
      client: newclient,
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: flux.type == FluxFinancierType.input
            ? "Entrée enregistrée avec succès"
            : "Sortie enregistrée avec succès",
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
    libelleFieldController.text = widget.flux.libelle!;
    amountFieldController.text = widget.flux.montant.toString();
    moyenPayement = widget.flux.moyenPayement;
    dateOperationController.text = getStringDate(
      time: widget.flux.dateOperation!,
    );
    client = widget.flux.client;
    _selectedBank = widget.flux.bank!;
    referenceTransactionFieldController.text =
        widget.flux.referenceTransaction!;
    file = widget.flux.pieceJustificative == null
        ? null
        : PlatformFile(
            name: widget.flux.pieceJustificative!.split("/").last,
            size: 10,
            path: widget.flux.pieceJustificative);
    dateOperation = widget.flux.dateOperation;
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<List<BanqueModel>> fetchBanqueItems() async {
    return moyenPayement == null
        ? await BanqueService.getAllBanques()
        : (await BanqueService.getAllBanques())
            .where((b) => b.type == moyenPayement!.type)
            .toList();
  }

  Future<List<ClientModel>> fetchClientItems() async {
    return await ClientService.getUnarchivedClients();
  }

  Future<List<MoyenPaiementModel>> fetchMoyenPaiementItems() async {
    return _selectedBank == null
        ? await MoyenPaiementService.getMoyenPaiements()
        : (await MoyenPaiementService.getMoyenPaiements())
            .where((m) => m.type == _selectedBank!.type)
            .toList();
  }

  Future<List<ClientModel>> fetchFournisseurItems() async {
    return await ClientService.getUnarchivedFournisseur();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: UniqueKey(),
        child: Column(
          children: [
            FutureCustomDropDownField<ClientModel>(
              fetchItems: widget.flux.type == FluxFinancierType.input
                  ? fetchClientItems
                  : fetchFournisseurItems,
              onChanged: (value) {
                setState(() {
                  client = value;
                });
              },
              label: widget.flux.type == FluxFinancierType.input
                  ? "Client"
                  : "Fournisseur",
              selectedItem: client,
              itemsAsString: (l) => l.toStringify(),
            ),
            SimpleTextField(
              label: "Libellé",
              textController: libelleFieldController,
              keyboardType: TextInputType.text,
            ),
            SimpleTextField(
              label: "Montant",
              textController: amountFieldController,
              readOnly: widget.flux.factureId != null,
              keyboardType: TextInputType.number,
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
            DateField(
              onCompleteDate: (value) {
                setState(() {
                  dateOperation = value;
                  dateOperationController.text = getStringDate(time: value!);
                });
              },
              lastDate: DateTime.now(),
              label: "Date de paiement",
              dateController: dateOperationController,
            ),
            SimpleTextField(
              label:
                  "Référence de la transaction ${moyenPayement != null ? " (${moyenPayement!.libelle})" : ""}",
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: () async {
                    await editFlux(flux: widget.flux);
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
