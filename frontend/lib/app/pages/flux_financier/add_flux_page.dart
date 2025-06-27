import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/client/client_model.dart';
import 'package:frontend/model/entreprise/banque.dart';
import 'package:frontend/model/flux_financier/libelle_flux.dart';
import 'package:frontend/model/moyen_paiement_model.dart';
import 'package:frontend/service/banque_service.dart';
import 'package:frontend/service/client_service.dart';
import 'package:frontend/service/libelle_flux_financier_service.dart';
import 'package:frontend/service/moyen_paiement_service.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../auth/authentification_token.dart';
import '../../../helper/date_helper.dart';
import '../../../model/flux_financier/type_flux_financier.dart';
import '../../../model/habilitation/user_model.dart';
import '../../../service/flux_financier_service.dart';
import '../../../widget/date_text_field.dart';
import '../../../widget/file_field.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/request_response.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/validate_button.dart';

import '../../integration/popop_status.dart';

class AddFluxPage extends StatefulWidget {
  final Future<void> Function() refresh;
  final FluxFinancierType type;
  const AddFluxPage({
    super.key,
    required this.refresh,
    required this.type,
  });

  @override
  State<AddFluxPage> createState() => _AddFluxPageState();
}

class _AddFluxPageState extends State<AddFluxPage> {
  final libelleFieldController = TextEditingController();
  final amountFieldController = TextEditingController();
  final referenceTransactionFieldController = TextEditingController();
  final dateFieldController = TextEditingController();
  DateTime? dateOperation;
  MoyenPaiementModel? moyenPayement;
  PlatformFile? file;
  late SimpleFontelicoProgressDialog _dialog;
  UserModel? user;
  LibelleFluxModel? libelleType;
  ClientModel? client;
  BanqueModel? banque;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> addFlux() async {
    if (libelleFieldController.text.isEmpty ||
        amountFieldController.text.isEmpty ||
        referenceTransactionFieldController.text.isEmpty ||
        moyenPayement == null ||
        banque == null ||
        client == null ||
        libelleType == null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: "Veuiller renprir tous les champs marqué",
      );
      return;
    }
    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );
    try {
      user = await AuthService().decodeToken();
    } catch (err) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.serverError,
        customMessage: "Enégistrement échoué",
      );
      return;
    }
    RequestResponse result = await FluxFinancierService.createFluxFinancier(
      libelle: "${libelleType!.libelle} : ${libelleFieldController.text}",
      montant: double.parse(amountFieldController.text),
      moyenPayement: moyenPayement!,
      type: widget.type,
      referenceTransaction: referenceTransactionFieldController.text,
      dateOperation: dateOperation,
      client: client!,
      file: file,
      banque: banque!,
      userId: user!.id!,
    );
    _dialog.hide();
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: widget.type == FluxFinancierType.input
            ? "Entrée enrégistrée avec succès"
            : "Sortie enrégistrée avec succès",
      );
      await widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
  }

  Future<List<BanqueModel>> fetchBanqueItems() async {
    return moyenPayement == null
        ? await BanqueService.getAllBanques()
        : (await BanqueService.getAllBanques())
            .where((b) => b.type == moyenPayement!.type)
            .toList();
  }

  Future<List<LibelleFluxModel>> fetchLibelleItems() async {
    return await LibelleFluxFinancierService.getLibelleFluxFinanciers(
        type: widget.type);
  }

  Future<List<ClientModel>> fetchClientItems() async {
    return await ClientService.getUnarchivedClients();
  }
  Future<List<MoyenPaiementModel>> fetchMoyenPaiementItems() async {
    return banque == null
        ? await MoyenPaiementService.getMoyenPaiements()
        : (await MoyenPaiementService.getMoyenPaiements())
            .where((m) => m.type == banque!.type)
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
              fetchItems: widget.type == FluxFinancierType.input
                  ? fetchClientItems
                  : fetchFournisseurItems,
              onChanged: (value) {
                setState(() {
                  client = value;
                });
              },
              label: widget.type == FluxFinancierType.input
                  ? "Client"
                  : "Fournisseur",
              selectedItem: client,
              itemsAsString: (l) => l.toStringify(),
            ),
            FutureCustomDropDownField<LibelleFluxModel>(
              fetchItems: fetchLibelleItems,
              onChanged: (value) {
                setState(() {
                  libelleType = value;
                });
              },
              label: "Type de libellé",
              selectedItem: libelleType,
              itemsAsString: (l) => l.libelle,
            ),
            SimpleTextField(
              label: "Libellé",
              textController: libelleFieldController,
              keyboardType: TextInputType.text,
            ),
            SimpleTextField(
              label: "Montant",
              textController: amountFieldController,
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
              selectedItem: banque,
              fetchItems: fetchBanqueItems,
              onChanged: (BanqueModel? value) {
                // if (value != null) {
                setState(() {
                  banque = value;
                });
                // }
              },
              canClose: true,
              itemsAsString: (s) => s.name,
            ),
            DateField(
              onCompleteDate: (value) {
                setState(() {
                  dateOperation = value!;
                  dateFieldController.text = getStringDate(time: value);
                });
              },
              label: "Date de paiement",
              dateController: dateFieldController,
              lastDate: DateTime.now(),
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
              required: false,
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: addFlux,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
