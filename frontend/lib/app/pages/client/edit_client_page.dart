import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/model/client/responsable_model.dart';
import '../../../helper/telephone_number_helper.dart';
import '../../../service/categorie_service.dart';
import '../../../service/pays_service.dart';
import '../../../style/app_color.dart';
import '../../../widget/future_dropdown_field.dart';
import '../../integration/popop_status.dart';
import '../../integration/request_frot_behavior.dart';
import '../../../model/client/categorie_model.dart';
import '../../../model/client/client_model.dart';
import '../../../model/client/client_moral_model.dart';
import '../../../model/client/client_physique_model.dart';
import '../../../model/client/enum_client.dart';
import '../../../model/pays_model.dart';
import '../../../service/client_service.dart';
import '../../../widget/drop_down_text_field.dart';
import '../../../widget/file_field.dart';
import '../../../widget/simple_text_field.dart';
import '../../../widget/telephone_field.dart';
import '../../../widget/validate_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../../../model/common_type.dart';

class EditClientPage extends StatefulWidget {
  final Future<void> Function() refresh;
  final ClientModel client;
  const EditClientPage({
    super.key,
    required this.refresh,
    required this.client,
  });

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _raisonSocialeController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _responsableNomController =
      TextEditingController();
  final TextEditingController _responsablePrenomControlller =
      TextEditingController();
  final TextEditingController _responsableEmailController =
      TextEditingController();
  final TextEditingController _responsableTelephoneController =
      TextEditingController();
  final TextEditingController _responsablePosteController =
      TextEditingController();
  //final List<Map<String, dynamic>> _agenceControllers = [];

  late TypeClient type;
  late NatureClient nature;
  Sexe? sexe;
  CategorieModel? categorie;
  PlatformFile? file;
  PaysModel? _selectedCountry;
  Civilite? responsableCivilite;
  Sexe? responsableSexe;
  late SimpleFontelicoProgressDialog _dialog;
  String? adresse;
  String? prenom;
  String? nom;
  String? raisonSociale;
  String? email;
  int? telephone;
  String? responsable;
  PaysModel? pays;
  String? categorieId;
  Sexe? newsexe;
  NatureClient? newNature;
  String? responsableEmail;
  String? responsableNom;
  String? responsablePrenom;
  String? responsablePoste;
  Sexe? newResponsableSexe;
  Civilite? newResponsableCivilite;
  int? responsableTelephone;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
    _adresseController.text = widget.client.adresse;
    _emailController.text = widget.client.email;
    _telephoneController.text = widget.client.telephone.toString();
    nature = widget.client.nature!;
    _selectedCountry = widget.client.pays;
    type = widget.client.typeName!;
    /* if (widget.client.agences != null) {
      _agenceControllers.addAll(widget.client.agences!.map((e) => {
            'nom': TextEditingController(text: e.nom),
          }));
    } */
    if (type == TypeClient.moral) {
      ClientMoralModel client = widget.client as ClientMoralModel;
      categorie = client.categorie;
      file = PlatformFile(
          name: client.logo!.split("/").last, size: 10, path: client.logo);
      _raisonSocialeController.text = client.raisonSociale;
      _responsableEmailController.text = client.responsable!.email;
      _responsableNomController.text = client.responsable!.nom;
      _responsablePrenomControlller.text = client.responsable!.prenom;
      _responsablePosteController.text = client.responsable!.poste;
      responsableSexe = client.responsable!.sexe;
      responsableCivilite = client.responsable!.civilite;
      _responsableTelephoneController.text =
          client.responsable!.telephone.toString();
    } else {
      ClientPhysiqueModel client = widget.client as ClientPhysiqueModel;
      sexe = client.sexe;
      _nomController.text = client.nom;
      _prenomController.text = client.prenom;
    }
  }

  String? validateClientFields() {
    if (_adresseController.text.isEmpty ||
        _selectedCountry == null ||
        _telephoneController.text.isEmpty ||
        _emailController.text.isEmpty) {
      return "Veuillez remplir tous les champs marqués.";
    }
    if (type == TypeClient.moral) {
      if (_raisonSocialeController.text.isEmpty ||
          categorie == null ||
          _responsableEmailController.text.isEmpty ||
          _responsableNomController.text.isEmpty ||
          _responsablePrenomControlller.text.isEmpty ||
          _responsablePosteController.text.isEmpty ||
          _responsableTelephoneController.text.isEmpty ||
          file == null || 
          responsableSexe == null ||
          responsableCivilite == null) {
        return "Veuillez remplir tous les champs marqués.";
      }
    } else {
      if (_nomController.text.isEmpty ||
          _prenomController.text.isEmpty ||
          sexe == null) {
        return "Veuillez remplir tous les champs marqués.";
      }
    }
    return null;
  }

  Future<void> _editClient() async {
    String? errMessage = validateClientFields();

    errMessage ??= checkPhoneNumber(
      phoneNumber: _telephoneController.text.trim(),
      pays: _selectedCountry!,
    );

    if (errMessage == null) {
      if (type == TypeClient.moral) {
        errMessage = checkPhoneNumber(
          phoneNumber: _responsableTelephoneController.text.trim(),
          pays: _selectedCountry!,
        );
      }
    }
    if (errMessage != null) {
      MutationRequestContextualBehavior.showCustomInformationPopUp(
        message: errMessage,
      );
      return;
    }

    _dialog.show(
      message: "",
      type: SimpleFontelicoProgressDialogType.phoenix,
      backgroundColor: Colors.transparent,
    );

    ClientModel initialClient = widget.client;

    // Vérification des modifications générales
    if (_adresseController.text != initialClient.adresse) {
      adresse = _adresseController.text;
    }
    if (_emailController.text != initialClient.email) {
      email = _emailController.text;
    }
    if (_telephoneController.text != initialClient.telephone.toString()) {
      telephone = int.tryParse(_telephoneController.text);
    }

    final selectedCountry = _selectedCountry;

    if (selectedCountry!.code != initialClient.pays!.code ||
        selectedCountry.name != initialClient.pays!.name) {
      pays = selectedCountry;
    }

    if (nature != widget.client.nature) newNature = nature;

    if (type == TypeClient.moral) {
      final client = initialClient as ClientMoralModel;

      if (categorie != client.categorie) categorieId = categorie?.id;
      if (_raisonSocialeController.text != client.raisonSociale) {
        raisonSociale = _raisonSocialeController.text;
      }

      bool responsableModified =
          _responsablePrenomControlller.text != client.responsable!.prenom ||
              _responsableNomController.text != client.responsable!.nom ||
              responsableSexe != client.responsable!.sexe ||
              responsableCivilite != client.responsable!.civilite ||
              _responsableEmailController.text != client.responsable!.email ||
              _responsableTelephoneController.text !=
                  client.responsable!.telephone.toString() ||
              _responsablePosteController.text != client.responsable!.poste;

      if (adresse == null &&
          email == null &&
          telephone == null &&
          pays == null &&
          newNature == null &&
          categorieId == null &&
          raisonSociale == null &&
          !responsableModified &&
          file?.bytes == null) {
        _dialog.hide();
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: "Aucune modification n'a été faite.",
        );
        return;
      }
    } else {
      final client = initialClient as ClientPhysiqueModel;

      if (_nomController.text != client.nom) nom = _nomController.text;
      if (_prenomController.text != client.prenom) {
        prenom = _prenomController.text;
      }
      if (sexe != client.sexe) newsexe = sexe;

      if (adresse == null &&
          email == null &&
          telephone == null &&
          pays == null &&
          newsexe == null &&
          newNature == null &&
          nom == null &&
          prenom == null) {
        _dialog.hide();
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message: "Aucune modification n'a été faite.",
        );
        return;
      }
    }

    var result = type == TypeClient.moral
        ? await ClientService.updateClientMoral(
            id: initialClient.id,
            adresse: adresse,
            categorieId: categorieId,
            email: email,
            nature: newNature,
            pays: pays,
            file: file?.bytes == null ? null : file,
            raisonSociale: raisonSociale,
            telephone: telephone,
            responsable: (responsableEmail == null &&
                    newResponsableCivilite == null &&
                    responsableNom == null &&
                    responsablePoste != null &&
                    newResponsableSexe != null &&
                    responsableTelephone != null)
                ? null
                : ResponsableModel(
                    prenom: _responsablePrenomControlller.text,
                    nom: _responsableNomController.text,
                    sexe: responsableSexe!,
                    civilite: responsableCivilite!,
                    email: _responsableEmailController.text,
                    telephone: int.parse(
                      _responsableTelephoneController.text,
                    ),
                    poste: _responsablePosteController.text,
                  ),
          )
        : await ClientService.updatePhysiqueClient(
            clientId: initialClient.id,
            adresse: adresse,
            nom: nom,
            prenom: prenom,
            nature: newNature,
            sexe: sexe,
            email: email,
            pays: pays,
            telephone: telephone,
          );

    _dialog.hide();

    // Gestion du résultat
    if (result.status == PopupStatus.success) {
      MutationRequestContextualBehavior.closePopup();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.success,
        customMessage: "Le partenaire a été mis à jour avec succès",
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
    return SingleChildScrollView(
      child: Form(
        //key: UniqueKey(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropDownField<NatureClient>(
              items: NatureClient.values.toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    nature = value;
                  });
                }
              },
              label: "Nature",
              selectedItem: nature,
              itemsAsString: (p0) => p0.label,
            ),
            if (type == TypeClient.physique)
              PhysiqueFields(
                nomController: _nomController,
                prenomController: _prenomController,
                sexe: sexe,
                onSexeChanged: (newSexe) {
                  setState(() {
                    sexe = newSexe;
                  });
                },
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
            SimpleTextField(
              label: "Adresse",
              textController: _adresseController,
              keyboardType: TextInputType.streetAddress,
            ),
            SimpleTextField(
              label: "Email",
              textController: _emailController,
              keyboardType: TextInputType.emailAddress,
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
            /* AgencesFields(
              controllers: _agenceControllers,
            ), */
            if (type == TypeClient.moral) ...[
              FileField(
                canTakePhoto: false,
                label: "Logo",
                platformFile: file,
                removeFile: () => setState(() {
                  file = null;
                }),
                canBePdf: false,
                pickFile: (p0) {
                  setState(() {
                    file = p0;
                  });
                },
              ),
              MoralFields(
                categorie: categorie,
                onCategorieChanged: (newCategorie) {
                  setState(() {
                    categorie = newCategorie;
                  });
                },
                country: _selectedCountry,
                responsableCivilite: responsableCivilite,
                responsableSexe: responsableSexe,
                raisonSocialeController: _raisonSocialeController,
                responsableEmailController: _responsableEmailController,
                onResponsableCiviliteChanged: (newCivilite) {
                  setState(() {
                    responsableCivilite = newCivilite;
                  });
                },
                onResponsableSexeChanged: (newSexe) {
                  setState(() {
                    responsableSexe = newSexe;
                  });
                },
                responsableNomController: _responsableNomController,
                responsablePosteController: _responsablePosteController,
                responsablePrenomControlller: _responsablePrenomControlller,
                responsableTelephoneController: _responsableTelephoneController,
              ),
            ],
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: () async {
                    await _editClient();
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

class PhysiqueFields extends StatefulWidget {
  final TextEditingController nomController;
  final TextEditingController prenomController;
  final Sexe? sexe;
  final void Function(Sexe?) onSexeChanged;

  const PhysiqueFields({
    super.key,
    required this.prenomController,
    required this.nomController,
    required this.sexe,
    required this.onSexeChanged,
  });

  @override
  State<PhysiqueFields> createState() => _PhysiqueFieldsState();
}

class _PhysiqueFieldsState extends State<PhysiqueFields> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SimpleTextField(
            label: "Nom",
            textController: widget.nomController,
          ),
          SimpleTextField(
            label: "Prénoms",
            textController: widget.prenomController,
          ),
          CustomDropDownField<Sexe>(
            items: Sexe.values.toList(),
            onChanged: widget.onSexeChanged,
            label: "Sexe",
            selectedItem: widget.sexe,
            itemsAsString: (s) => s.label,
          ),
        ],
      ),
    );
  }
}

class MoralFields extends StatefulWidget {
  final TextEditingController raisonSocialeController;
  final CategorieModel? categorie;
  final void Function(CategorieModel?) onCategorieChanged;
  final Sexe? responsableSexe;
  final Civilite? responsableCivilite;
  final void Function(Sexe?) onResponsableSexeChanged;
  final void Function(Civilite?) onResponsableCiviliteChanged;
  final TextEditingController responsableNomController;
  final TextEditingController responsablePrenomControlller;
  final TextEditingController responsableEmailController;
  final TextEditingController responsablePosteController;
  final TextEditingController responsableTelephoneController;
  final PaysModel? country;

  const MoralFields({
    super.key,
    required this.raisonSocialeController,
    required this.onResponsableCiviliteChanged,
    required this.responsableCivilite,
    required this.responsableEmailController,
    required this.responsableSexe,
    required this.responsableNomController,
    required this.country,
    required this.responsablePosteController,
    required this.responsablePrenomControlller,
    required this.responsableTelephoneController,
    required this.onResponsableSexeChanged,
    this.categorie,
    required this.onCategorieChanged,
  });

  @override
  State<MoralFields> createState() => _MoralFieldsState();
}

class _MoralFieldsState extends State<MoralFields> {

  void _handleCategoryChange(CategorieModel? newValue) {
    setState(() {
      widget.onCategorieChanged(newValue);
    });
  }

  void _handleResponsableSexeChange(Sexe? newValue) {
    setState(() {
      widget.onResponsableSexeChanged(newValue);
    });
  }

  void _handleResponsableCiviliteChange(Civilite? newValue) {
    setState(() {
      widget.onResponsableCiviliteChanged(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SimpleTextField(
            label: "Raison sociale",
            textController: widget.raisonSocialeController,
          ),
          FutureCustomDropDownField(
            label: "Catégorie",
            selectedItem: widget.categorie,
            fetchItems: fetchCategorieItems,
            onChanged: _handleCategoryChange,
            itemsAsString: (CategorieModel c) => c.libelle,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: AppColor.primaryColor.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Personne contact",
                    style: TextStyle(fontWeight: FontWeight.w200),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6), border: Border.all()),
              child: Column(
                children: [
                  SimpleTextField(
                    label: "Nom",
                    textController: widget.responsableNomController,
                  ),
                  SimpleTextField(
                    label: "Prénoms",
                    textController: widget.responsablePrenomControlller,
                  ),
                  CustomDropDownField<Sexe>(
                    items: Sexe.values.toList(),
                    onChanged: _handleResponsableSexeChange,
                    label: "Sexe",
                    selectedItem: widget.responsableSexe,
                    itemsAsString: (s) => s.label,
                  ),
                  CustomDropDownField<Civilite>(
                    items: Civilite.values.toList(),
                    onChanged: _handleResponsableCiviliteChange,
                    label: "Civilité",
                    selectedItem: widget.responsableCivilite,
                    itemsAsString: (s) => s.label,
                  ),
                  TelephoneTextField(
                    label: "Téléphone",
                    textController: widget.responsableTelephoneController,
                    contryCode: widget.country == null
                        ? ""
                        : widget.country!.code.toString(),
                    maxLength: widget.country == null
                        ? 1
                        : widget.country!.phoneNumber!,
                  ),
                  SimpleTextField(
                    label: "Email",
                    textController: widget.responsableEmailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SimpleTextField(
                    label: "Poste",
                    textController: widget.responsablePosteController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<CategorieModel>> fetchCategorieItems() async {
    return await CategorieService.getCategories();
  }
}
