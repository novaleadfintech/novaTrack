import 'package:flutter/material.dart';
import 'package:frontend/model/bulletin_paie/nature_rubrique.dart';
import 'package:frontend/model/bulletin_paie/rubrique.dart';
import 'package:frontend/model/bulletin_paie/section_bulletin.dart';
import 'package:frontend/model/bulletin_paie/tranche_model.dart';
import 'package:frontend/model/bulletin_paie/type_rubrique.dart';
import 'package:frontend/service/bulletin_rubrique_service.dart';
import 'package:frontend/service/section_service.dart';
import 'package:frontend/widget/bareme_widget.dart';
import '../../../../widget/drop_down_text_field.dart';
import '../../../../widget/element_calcul.dart';
import '../../../../widget/enum_selector_radio.dart';
import '../../../../widget/future_dropdown_field.dart';
import '../../../../widget/somme_rubrique.dart';
import '../../../../widget/taux_widget.dart';
import '../../../integration/popop_status.dart';
import '../../../integration/request_frot_behavior.dart';
import '../../../../widget/simple_text_field.dart';
import '../../../../widget/validate_button.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class AddRubriquePage extends StatefulWidget {
  final Future<void> Function() refresh;
  const AddRubriquePage({
    super.key,
    required this.refresh,
  });

  @override
  State<AddRubriquePage> createState() => _AddRubriquePageState();
}

class _AddRubriquePageState extends State<AddRubriquePage> {
  final TextEditingController _libelleController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  NatureRubrique? selectNatureValue;
  TypeRubrique? selectTypeValue;
  BaseType? typeValeurCalcul;
  late SimpleFontelicoProgressDialog _dialog;
  SectionBulletin? _selectedSectionBulletin;
  Calcul? _calcul;
  PorteeRubrique? _portee;
  RubriqueRole? _rubriqueRole;
  Calcul? _sommeRubrique;
  RubriqueIdentity? _constantIdentity;
  Bareme? _bareme;
  Taux? _taux;

  @override
  void initState() {
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(context: context);
  }

  Future<void> _addRubrique() async {
    String? errMessage;
    if (_libelleController.text.isEmpty ||
        _codeController.text.isEmpty ||
        selectNatureValue == null) {
      errMessage = "Veuillez remplir tous les champs marqués.";
    }

if (selectNatureValue == NatureRubrique.constant && _rubriqueRole == null) {
      errMessage = "Veuillez choisir le role de rubrique.";
    }
    if (selectNatureValue == NatureRubrique.constant &&
        _rubriqueRole == RubriqueRole.variable &&
        _portee == null) {
      errMessage = "Veuillez choisir la portée de rubrique.";
    }
    if ((selectNatureValue != null &&
                selectNatureValue != NatureRubrique.constant ||
            (selectNatureValue == NatureRubrique.constant &&
                _rubriqueRole == RubriqueRole.rubrique)) &&
        selectTypeValue == null) {
      errMessage = "Veuillez choisir le type de rubrique.";
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

    try {
      var result = await BulletinRubriqueService.createBulletinRubrique(
        rubrique: _libelleController.text,
        bareme: _bareme,
        calcul: _calcul,
        portee: _portee,
        rubriqueRole: _rubriqueRole,
        code: _codeController.text,
        nature: selectNatureValue!,
        section: _selectedSectionBulletin,
        taux: _taux,
        rubriqueIdentity: _constantIdentity,
        type: selectTypeValue,
        sommeRubrique: _sommeRubrique,
      );

      _dialog.hide();

      if (result.status == PopupStatus.success) {
        MutationRequestContextualBehavior.closePopup();
        MutationRequestContextualBehavior.showPopup(
          status: PopupStatus.success,
          customMessage: "Rubrique crée avec succès",
        );
        await widget.refresh();
      } else {
        MutationRequestContextualBehavior.showPopup(
          status: result.status,
          customMessage: result.message,
        );
      }
    } catch (e) {
      _dialog.hide();
      MutationRequestContextualBehavior.showPopup(
        status: PopupStatus.customError,
        customMessage: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      // //key: UniqueKey(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SimpleTextField(
            label: "Libellé",
            textController: _libelleController,
          ),
          SimpleTextField(
            label: "Code",
            textController: _codeController,
          ),
          EnumRadioSelector<NatureRubrique>(
            title: "Nature",
            selectedValue: selectNatureValue,
            values: NatureRubrique.values,
            getLabel: (value) => value.label,
            onChanged: (value) {
              setState(() {
                selectNatureValue = value;
                if (value != NatureRubrique.constant) {
                  _constantIdentity = null;
                  _portee = null;
                  _rubriqueRole = null;
                }
                if (value != NatureRubrique.taux) {
                  _taux = null;
                }
                if (value != NatureRubrique.calcul) {
                  _calcul = null;
                }
                if (value != NatureRubrique.sommeRubrique) {
                  _sommeRubrique = null;
                }
                if (value != NatureRubrique.bareme) {
                  _bareme = null;
                }
              });
            },
            isRequired: true,
          ),
          if (selectNatureValue == NatureRubrique.constant) ...[
            EnumRadioSelector<RubriqueRole>(
              title: "Role de rubrique",
              selectedValue: _rubriqueRole,
              values: RubriqueRole.values,
              getLabel: (value) => value.label,
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    _rubriqueRole = value;
                  }
                });
              },
              isRequired: true,
            ),
            EnumRadioSelector<PorteeRubrique>(
              title: "Portée de rubrique",
              selectedValue: _portee,
              values: PorteeRubrique.values,
              getLabel: (value) => value.label,
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    _portee = value;
                  }
                });
              },
              isRequired: true,
            ),
          ],
          if (selectNatureValue == NatureRubrique.taux) ...[
            TauxBuilderWidget(
              onChanged: (newTaux) {
                setState(() {
                  _taux = newTaux;
                });
              },
            )
          ],
          if (selectNatureValue == NatureRubrique.calcul) ...[
            CalculBuilderWidget(
              onChanged: (newElement) {
                setState(() {
                  _calcul = newElement;
                });
              },
            ),
          ],
          if (selectNatureValue == NatureRubrique.sommeRubrique) ...[
            SommeRubriqueBuilderWidget(
              onChanged: (newSommeRubrique) {
                setState(() {
                  _sommeRubrique = newSommeRubrique;
                });
              },
            )
          ],
          if (selectNatureValue == NatureRubrique.bareme) ...[
            BaremeBuilderWidget(
              onChanged: (newBareme) {
                setState(() {
                  _bareme = newBareme;
                });
              },
            )
          ],
          if (selectNatureValue != null &&
                  selectNatureValue != NatureRubrique.constant ||
              (selectNatureValue == NatureRubrique.constant &&
                  _rubriqueRole == RubriqueRole.rubrique)) ...[
            EnumRadioSelector<TypeRubrique>(
              title: "Type",
              selectedValue: selectTypeValue,
              values: TypeRubrique.values,
              getLabel: (value) => value.label,
              onChanged: (value) {
                setState(() {
                  selectTypeValue = value;
                });
              },
              isRequired: true,
            ),
            FutureCustomDropDownField<SectionBulletin>(
              label: "Section de bulletin",
              showSearchBox: true,
              selectedItem: _selectedSectionBulletin,
              fetchItems: fetchSectionItems,
              onChanged: (SectionBulletin? value) {
                setState(() {
                  _selectedSectionBulletin = value;
                });
              },
              required: false,
              itemsAsString: (s) => s.section,
            ),
          ],
          CustomDropDownField<RubriqueIdentity>(
            items: RubriqueIdentity.values,
            onChanged: (RubriqueIdentity? value) {
              setState(() {
                _constantIdentity = value;
              });
            },
            label: "Identité du rubrique",
            selectedItem: _constantIdentity,
            canClose: false,
            required: false,
            itemsAsString: (RubriqueIdentity c) => c.label,
          ),
          if ((selectNatureValue == NatureRubrique.constant &&
                  _rubriqueRole != null) ||
              ((selectNatureValue != NatureRubrique.constant) &&
                  (_bareme != null ||
                      _taux != null ||
                      _calcul != null ||
                      _sommeRubrique != null)))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ValidateButton(
                  onPressed: () async {
                    await _addRubrique();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<List<SectionBulletin>> fetchSectionItems() async {
    return await SectionService.getSections();
  }

  Future<List<RubriqueBulletin>> fetchRubriqueItems() async {
    return await BulletinRubriqueService.getBulletinRubriques();
  }
}
