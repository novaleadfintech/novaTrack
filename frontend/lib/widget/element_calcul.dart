import 'package:flutter/material.dart';
 import 'package:frontend/widget/future_dropdown_field.dart';
import '../model/bulletin_paie/rubrique.dart';
import '../model/bulletin_paie/tranche_model.dart';
import '../service/bulletin_rubrique_service.dart';
import 'enum_selector_radio.dart';
import 'simple_text_field.dart';

class CalculBuilderWidget extends StatefulWidget {
  final Calcul? calcul;
  final void Function(Calcul newCalcul) onChanged;

  const CalculBuilderWidget({
    super.key,
    required this.onChanged,
    this.calcul,
  });

  @override
  State<CalculBuilderWidget> createState() => _CalculBuilderWidgetState();
}

class _CalculBuilderWidgetState extends State<CalculBuilderWidget> {
  Operateur? selectedOperateur;
  List<ElementCalcul> elements = [];

  @override
  void initState() {
    if (widget.calcul != null) {
      selectedOperateur = widget.calcul!.operateur;
      elements.addAll(widget.calcul!.elements);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnumRadioSelector<Operateur>(
          title: "Sélectionnez un opérateur",
          selectedValue: selectedOperateur,
          values: Operateur.values,
          getLabel: (value) => value.label,
          onChanged: (value) {
            setState(() {
              selectedOperateur = value;
            });
            _notifyChange();
          },
          isRequired: true,
        ),
        ...elements.map((element) => ElementCalculWidget(
            elementCalcul: element,
            onChanged: (newElement) {
              setState(() {
                final index = elements.indexOf(element);
                if (index != -1) {
                  elements[index] = newElement;
                }
              });
              _notifyChange();
            })),
        if (elements.length < 2)
          ElevatedButton(
            onPressed: () {
              setState(() {
                elements
                    .add(ElementCalcul(type: BaseType.valeur, valeur: null));
              });
            },
            child: Text(
              "Ajouter un élément de calcul",
            ),
          ),
      ],
    );
  }

  void _notifyChange() {
    if (selectedOperateur == null) return;

    if (elements.length < 2) return;
    widget.onChanged(
      Calcul(
        operateur: selectedOperateur!,
        elements: elements,
      ),
    );
  }
}

class ElementCalculWidget extends StatefulWidget {
  final ElementCalcul? elementCalcul;
  final void Function(ElementCalcul newElement) onChanged;

  const ElementCalculWidget({
    super.key,
    this.elementCalcul,
    required this.onChanged,
  });

  @override
  State<ElementCalculWidget> createState() => _ElementCalculWidgetState();
}

class _ElementCalculWidgetState extends State<ElementCalculWidget> {
  BaseType? selectedType;
  RubriqueBulletin? rubrique;
  double? valeur;
  final TextEditingController _tauxController = TextEditingController();
  @override
  void initState() {
    if (widget.elementCalcul != null) {
      selectedType = widget.elementCalcul!.type;
      rubrique = widget.elementCalcul!.rubrique;
      valeur = widget.elementCalcul!.valeur;
      _tauxController.text = widget.elementCalcul!.valeur?.toString() ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnumRadioSelector<BaseType>(
          title: "Sélectionnez un type",
          selectedValue: selectedType,
          values: BaseType.values,
          getLabel: (value) => value.label,
          onChanged: (value) {
            setState(() {
              selectedType = value;
              if (value != BaseType.rubrique) {
                rubrique = null;
              }
              if (value != BaseType.valeur) {
                valeur = null;
              }
            });
            _notifyChange();
          },
          isRequired: true,
        ),
        if (selectedType == BaseType.valeur)
          SimpleTextField(
            label: "Valeur",
            textController: _tauxController,
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
            ),
            
            onChanged: (text) {
              setState(() {
                valeur = double.tryParse(text);
              });
              _notifyChange();
            },
          ),
        if (selectedType == BaseType.rubrique)
          FutureCustomDropDownField<RubriqueBulletin>(
            label: "Rubrique",
            showSearchBox: true,
            selectedItem: rubrique,
            fetchItems: fetchRubriqueItems,
            onChanged: (RubriqueBulletin? value) {
              if (value != null) {
                setState(() {
                  _tauxController.clear();
                  rubrique = value;
                });
                _notifyChange();
              }
            },
            canClose: false,
            itemsAsString: (s) => s.rubrique,
          ),
      ],
    );
  }

  void _notifyChange() {
    if (selectedType == null) return;

    if (selectedType == BaseType.valeur && valeur == null) return;

    if (selectedType == BaseType.rubrique && rubrique == null) return;

    widget.onChanged(
      ElementCalcul(
        type: selectedType!,
        valeur: valeur,
        rubrique: rubrique,
      ),
    );
  }

  Future<List<RubriqueBulletin>> fetchRubriqueItems() async {
    return await BulletinRubriqueService.getBulletinRubriques();
  }
}
