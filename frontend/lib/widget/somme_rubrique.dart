import 'package:flutter/material.dart';
import 'package:frontend/widget/future_dropdown_field.dart';
import '../model/bulletin_paie/rubrique.dart';
import '../model/bulletin_paie/tranche_model.dart';
import '../service/bulletin_rubrique_service.dart';

class SommeRubriqueBuilderWidget extends StatefulWidget {
  final Calcul? sommeRubrique;
  final void Function(Calcul? newCalcul) onChanged;

  const SommeRubriqueBuilderWidget({
    super.key,
    required this.onChanged,
    this.sommeRubrique,
  });

  @override
  State<SommeRubriqueBuilderWidget> createState() =>
      _SommeRubriqueBuilderWidgetState();
}

class _SommeRubriqueBuilderWidgetState
    extends State<SommeRubriqueBuilderWidget> {
  List<ElementCalcul> elements = [];
@override
  void initState() {
    if (widget.sommeRubrique != null) {
      elements.addAll(widget.sommeRubrique!.elements);
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...elements.map((element) => Row(
              children: [
                Expanded(
                  child: RubriqueSelectionWidget(
                    rubrique: element.rubrique,
                    onChanged: (RubriqueBulletin? newRubrique) {
                      if (newRubrique != null) {
                        setState(() {
                          final index = elements.indexOf(element);
                          if (index != -1) {
                            elements[index] = ElementCalcul(
                              type: BaseType.rubrique,
                              rubrique: newRubrique,
                              valeur: null,
                            );
                          }
                        });
                        _notifyChange();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      elements.remove(element);
                    });
                    _notifyChange();
                  },
                ),
              ],
            )),
        ElevatedButton(
          onPressed: () {
            setState(() {
              elements.add(ElementCalcul(
                type: BaseType.rubrique,
                rubrique: null,
                valeur: null,
              ));
            });
          },
          child: const Text("Ajouter une rubrique"),
        ),
      ],
    );
  }

  void _notifyChange() {
    if (elements.length < 2) {
      widget.onChanged(null);
      return;
    }
    widget.onChanged(
      Calcul(
        operateur: Operateur.addition,
        elements: elements,
      ),
    );
  }
}

class RubriqueSelectionWidget extends StatelessWidget {
  final RubriqueBulletin? rubrique;
  final void Function(RubriqueBulletin?) onChanged;

  const RubriqueSelectionWidget({
    super.key,
    required this.rubrique,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureCustomDropDownField<RubriqueBulletin>(
      label: "Rubrique",
      selectedItem: rubrique,
      fetchItems: fetchRubriqueItems,
      showSearchBox: true,
      onChanged: onChanged,
      canClose: false,
      itemsAsString: (r) => r.rubrique,
    );
  }

  Future<List<RubriqueBulletin>> fetchRubriqueItems() async {
    return await BulletinRubriqueService.getBulletinRubriques();
  }
}
