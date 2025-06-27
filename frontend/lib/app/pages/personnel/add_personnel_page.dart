import 'package:flutter/material.dart';
import 'package:frontend/model/personnel/personne_prevenir.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../global/constant/request_management_value.dart';
import '../../../helper/date_helper.dart';
import '../../../helper/personne_helper.dart';
import '../../../helper/telephone_number_helper.dart';
import '../../../model/pays_model.dart';
import '../../../model/common_type.dart';
import '../../../model/personnel/enum_personnel.dart';
import '../../../service/pays_service.dart';
import '../../../service/personnel_service.dart';
import '../../../widget/date_text_field.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/telephone_field.dart';
import '../../../widget/validate_button.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../responsitvity/responsivity.dart';

class AddPersonnelPage extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddPersonnelPage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddPersonnelPage> createState() => _AddPersonnelPageState();
}

class _AddPersonnelPageState extends State<AddPersonnelPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentaireController = TextEditingController();
  final TextEditingController _posteController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _telephone1Controller = TextEditingController();
  final TextEditingController _telephone2Controller = TextEditingController();
  final TextEditingController _nombreEnfantController = TextEditingController();
  final TextEditingController _nomPersonnePrevenirController =
      TextEditingController();
  final TextEditingController _lienController = TextEditingController();
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();
  final TextEditingController _dureeEssaiController = TextEditingController();
  final TextEditingController _nombrePersonneChargeController =
      TextEditingController();
  final TextEditingController _dateNaissanceController =
      TextEditingController();
  final TextEditingController _adresseController = TextEditingController();

  late SimpleFontelicoProgressDialog _dialog;
  Sexe? sexe;
  PaysModel? _selectedCountry;
  SituationMatrimoniale? situationMatrimoniale;
  DateTime? dateNaissance;
  DateTime? dateDebut;
  DateTime? dateFin;
  TypePersonnel? typePersonnel;
  TypeContrat? typeContrat;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> addPersonnel() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final String email = _emailController.text.trim();
    final String adresse = _adresseController.text.trim();
    final String commentaire = _commentaireController.text.trim();
    final poste = _posteController.text.trim();

    final telephone = _telephoneController.text.trim();
    final telephone1 = _telephone1Controller.text.trim();
    final telephone2 = _telephone2Controller.text.trim();
    final nombreEnfant = _nombreEnfantController.text.trim();
    final nombrePersonneCharge = _nombrePersonneChargeController.text.trim();
    final lien = _lienController.text.trim();
    final nomPersonnePrevenir = _nomPersonnePrevenirController.text.trim();

    String? errorMessage;
    if (nom.isEmpty ||
        prenom.isEmpty ||
        poste.isEmpty ||
        sexe == null ||
        dateDebut == null ||
        dateNaissance == null ||
        typePersonnel == null ||
        _selectedCountry == null ||
        situationMatrimoniale == null ||
        telephone.isEmpty ||
        telephone1.isEmpty ||
        email.isEmpty ||
        nombrePersonneCharge.isEmpty ||
        nombreEnfant.isEmpty ||
        nomPersonnePrevenir.isEmpty ||
        lien.isEmpty) {
      errorMessage = "Tous les champs marqués doivent être remplis.";
    }

    if ((typePersonnel == TypePersonnel.employe && typeContrat == null) ||
        (typeContrat == TypeContrat.cdd && dateFin == null) ||
        (typePersonnel == TypePersonnel.stagiaire && dateFin == null)) {
      errorMessage = "Tous les champs marqués doivent être remplis.";
    }

    if (dateDebut != null && dateFin != null) {
      if (dateDebut!
          .add(Duration(
              milliseconds: ((int.tryParse(_dureeEssaiController.text) ?? 0) *
                  (unitMultipliers['mois'] ?? 0))))
          .isAfter(dateFin!)) {
        errorMessage =
            "La date de fin du contrat ne peut pas être antérieure à la fin de la période d'essai.";
      }
    }

    errorMessage = errorMessage ??
        checkPhoneNumber(
          phoneNumber: _telephoneController.text.trim(),
          pays: _selectedCountry!,
        ) ??
        checkPhoneNumber(
          phoneNumber: _telephone1Controller.text.trim(),
          pays: _selectedCountry!,
        );
    if (errorMessage == null && _telephone2Controller.text.isNotEmpty) {
      errorMessage = checkPhoneNumber(
        phoneNumber: _telephone2Controller.text.trim(),
        pays: _selectedCountry!,
      );
    }
    if (errorMessage != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: errorMessage,
      );
      return;
    }

    _dialog.show(
      message: RequestMessage.loadinMessage,
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    var result = await PersonnelService.createPersonnel(
      nom: nom,
      prenom: prenom,
      email: email,
      pays: _selectedCountry!,
      commentaire: commentaire.isNotEmpty ? commentaire : null,
      poste: poste,
      sexe: sexe!,
      telephone: int.parse(telephone),
      situationMatrimoniale: situationMatrimoniale!,
      adresse: adresse,
      dureeEssai: _dureeEssaiController.text.isEmpty
          ? null
          : int.parse(
              _dureeEssaiController.text,
            ),
      dateDebut: dateDebut!,
      dateFin: dateFin,
      nombreEnfant: int.parse(nombreEnfant),
      nombrePersonneCharge: int.parse(nombrePersonneCharge),
      dateNaissance: dateNaissance!,
      personnePrevenir: PersonnePrevenirModel(
        nom: nomPersonnePrevenir,
        lien: lien,
        telephone1: int.parse(telephone1),
        telephone2: int.tryParse(telephone2),
      ),
      typeContrat: typeContrat,
      typePersonnel: typePersonnel!,
    );

    _dialog.hide();

    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();

      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Personnel ajouté avec succès",
      );
      await widget.refresh();
    } else {
      MutationRequestContextualBehavior.showPopup(
        status: result.status,
        customMessage: result.message,
      );
    }
  }

  Future<List<PaysModel>> fetchCountryItems() async {
    return await PaysService.getAllPays();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    return SingleChildScrollView(
      child: Form(
        key: UniqueKey(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SimpleTextField(
              label: "Nom",
              textController: _nomController,
            ),
            SimpleTextField(
              label: "Prénoms",
              textController: _prenomController,
            ),
            CustomDropDownField(
              items: Sexe.values.map((e) => e.label).toList(),
              onChanged: (value) {
                setState(() {
                  sexe = Sexe.values.firstWhere((s) => s.label == value);
                });
              },
              label: "Sexe",
              selectedItem: sexe?.label,
            ),
            FutureCustomDropDownField<PaysModel>(
              label: "Pays",
              showSearchBox: true,
              selectedItem: _selectedCountry,
              fetchItems: fetchCountryItems,
              onChanged: (PaysModel? value) {
                if (value != null) {
                  setState(() {
                    _selectedCountry = value;
                  });
                }
              },
              canClose: false,
              itemsAsString: (s) => s.name,
            ),
            TelephoneTextField(
              label: "Téléphone",
              maxLength:
                  _selectedCountry == null ? 1 : _selectedCountry!.phoneNumber!,
              textController: _telephoneController,
              contryCode: _selectedCountry == null
                  ? ""
                  : _selectedCountry!.code.toString(),
            ),
            SimpleTextField(
              label: "Email",
              textController: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            CustomDropDownField(
              items: SituationMatrimoniale.values.map((e) => e).toList(),
              onChanged: (value) {
                setState(() {
                  situationMatrimoniale = value;
                });
              },
              label: "Situation Matrimoniale",
              itemsAsString: (SituationMatrimoniale p0) => p0.label,
              selectedItem: situationMatrimoniale,
            ),
            SimpleTextField(
              label: "Adresse",
              textController: _adresseController,
              keyboardType: TextInputType.text,
              expands: true,
              maxLines: null,
              height: 50,
            ),
            SimpleTextField(
              label: "Poste",
              textController: _posteController,
              keyboardType: TextInputType.text,
            ),
            DateField(
              label: "Date de naissance",
              dateController: _dateNaissanceController,
              required: true,
              firstDate: DateTime(1900),
              lastDate: DateTime(
                DateTime.now().year - 15,
                DateTime.now().month,
                DateTime.now().day,
              ),
              onCompleteDate: (DateTime? date) {
                setState(() {
                  _dateNaissanceController.text = getStringDate(time: date!);
                  dateNaissance = date;
                });
              },
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: SimpleTextField(
                    label: "Nombre d'enfants",
                    textController: _nombreEnfantController,
                    keyboardType: TextInputType.number,
                    
                  ),
                ),
                if (!isMobile)
                  Expanded(
                    child: SimpleTextField(
                      label: "Nombre de personnes à charge",
                      textController: _nombrePersonneChargeController,
                      keyboardType: TextInputType.number,
                       
                    ),
                  ),
              ],
            ),
            if (isMobile)
              SimpleTextField(
                label: "Nombre de personnes à charge",
                textController: _nombrePersonneChargeController,
                keyboardType: TextInputType.number,
              ),
            CustomDropDownField(
              items: TypePersonnel.values,
              onChanged: (value) {
                setState(() {
                  typePersonnel = value;
                });
              },
              selectedItem: typePersonnel,
              label: "Type de personnel",
              itemsAsString: (TypePersonnel p0) => p0.label,
            ),
            CustomDropDownField(
              items: typePersonnel == null
                  ? []
                  : getContratsFor(type: typePersonnel!),
              onChanged: (value) {
                setState(() {
                  typeContrat = value;
                  if (typeContrat == TypeContrat.cdi) {
                    dateFin == null;
                    _dateFinController.clear();
                  }
                });
              },
              label: "Type de contrat",
              itemsAsString: (p0) => p0.label,
            ),
            Row(
              children: [
                Expanded(
                  child: DateField(
                    label: "Date de début",
                    dateController: _dateDebutController,
                    required: true,
                    lastDate: dateFin,
                    onCompleteDate: (DateTime? date) {
                      setState(() {
                        _dateDebutController.text = getStringDate(time: date!);
                        dateDebut = date;
                      });
                    },
                  ),
                ),
                if (!isMobile && typeContrat != TypeContrat.cdi)
                  Expanded(
                    child: DateField(
                      label: "Date de fin",
                      dateController: _dateFinController,
                      firstDate: dateDebut,
                      required: false,
                      onCompleteDate: (DateTime? date) {
                        setState(() {
                          dateFin = date;
                          _dateFinController.text = getStringDate(time: date!);
                        });
                      },
                    ),
                  ),
              ],
            ),
            if (isMobile && typeContrat != TypeContrat.cdi)
              DateField(
                label: "Date de fin",
                dateController: _dateFinController,
                required: false,
                onCompleteDate: (date) {
                  setState(() {
                    dateFin = date;
                    _dateFinController.text = getStringDate(time: date!);
                  });
                },
              ),
            SimpleTextField(
              label: "Période d'essai (mois)",
              textController: _dureeEssaiController,
              keyboardType: TextInputType.number,
              required: false,
            ),
            SimpleTextField(
              label: "Commentaire",
              textController: _commentaireController,
              expands: true,
              maxLines: null,
              height: 80,
              required: false,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Personnel à preprenir",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SimpleTextField(
              label: "Nom",
              textController: _nomPersonnePrevenirController,
            ),
            SimpleTextField(
              label: "Lien d'affiliation",
              textController: _lienController,
            ),
            Row(
              children: [
                Expanded(
                  child: TelephoneTextField(
                    label: "Téléphone 1",
                    maxLength: _selectedCountry == null
                        ? 1
                        : _selectedCountry!.phoneNumber!,
                    textController: _telephone1Controller,
                    contryCode: _selectedCountry == null
                        ? ""
                        : _selectedCountry!.code.toString(),
                  ),
                ),
                if (!isMobile)
                  Expanded(
                    child: TelephoneTextField(
                      label: "Téléphone 2",
                      required: false,
                      maxLength: _selectedCountry == null
                          ? 1
                          : _selectedCountry!.phoneNumber!,
                      textController: _telephone2Controller,
                      contryCode: _selectedCountry == null
                          ? ""
                          : _selectedCountry!.code.toString(),
                    ),
                  ),
              ],
            ),
            if (isMobile)
              TelephoneTextField(
                label: "Téléphone 2",
                required: false,
                maxLength: _selectedCountry == null
                    ? 1
                    : _selectedCountry!.phoneNumber!,
                textController: _telephone2Controller,
                contryCode: _selectedCountry == null
                    ? ""
                    : _selectedCountry!.code.toString(),
              ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: () {
                    addPersonnel();
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
