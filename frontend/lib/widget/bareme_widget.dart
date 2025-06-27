import 'package:flutter/material.dart';
import 'package:frontend/widget/taux_widget.dart';
import '../model/bulletin_paie/rubrique.dart';
import '../model/bulletin_paie/tranche_model.dart';
import '../service/bulletin_rubrique_service.dart';
import 'future_dropdown_field.dart';
import 'simple_text_field.dart';
import 'enum_selector_radio.dart';

class BaremeBuilderWidget extends StatefulWidget {
  final Bareme? bareme;
  final void Function(Bareme? newBareme) onChanged;

  const BaremeBuilderWidget({
    super.key,
    required this.onChanged,
    this.bareme,
  });

  @override
  State<BaremeBuilderWidget> createState() => _BaremeBuilderWidgetState();
}

class _BaremeBuilderWidgetState extends State<BaremeBuilderWidget> {
  List<GlobalKey<_TrancheBuilderWidgetState>> trancheKeys = [];
  RubriqueBulletin? _reference;
  @override
  void initState() {
    if (widget.bareme != null) {
      _reference = widget.bareme!.reference;
      trancheKeys = widget.bareme!.tranches
          .map((tranche) => GlobalKey<_TrancheBuilderWidgetState>())
          .toList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureCustomDropDownField<RubriqueBulletin>(
          label: "Référence",
          showSearchBox: true,
          selectedItem: _reference,
          fetchItems: fetchRubriqueItems,
          onChanged: (RubriqueBulletin? value) {
            setState(() {
              _reference = value;
            });
            _notifyChange();
          },
          canClose: false,
          itemsAsString: (s) => s.rubrique,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...trancheKeys.asMap().entries.map((entry) {
              final index = entry.key;
              final key = entry.value;
              final tranche = widget.bareme?.tranches[index];

              return TrancheBuilderWidget(
                key: key,
                tranche: tranche,
                onDelete: () {
                  setState(() {
                    trancheKeys.remove(key);
                  });
                  _notifyChange();
                },
                onChanged: _notifyChange,
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  trancheKeys.add(GlobalKey<_TrancheBuilderWidgetState>());
                });
                _notifyChange();
              },
              child: const Text("Ajouter une tranche"),
            ),
          ],
        ),
      ],
    );
  }

  Future<List<RubriqueBulletin>> fetchRubriqueItems() async {
    return await BulletinRubriqueService.getBulletinRubriques();
  }

  void _notifyChange() {
    try {
      if (_reference == null) {
        widget.onChanged(null);
        return;
      }

      if (trancheKeys.any((key) => key.currentState == null)) {
        widget.onChanged(null);
        return;
      }

      final tranches =
          trancheKeys.map((key) => key.currentState!.buildTranche()).toList();

      final isValid = tranches.every((t) => t != null);

      if (!isValid || tranches.isEmpty) {
        widget.onChanged(null);
        return;
      }

      final nonNullTranches = tranches.cast<Tranche>();

      // Vérifie que chaque min <= max (en tenant compte que max peut être null à la fin uniquement)
      final areMinValid = nonNullTranches
          .sublist(0, nonNullTranches.length - 1)
          .every((t) => t.max != null && t.min <= t.max!);

      final isLastMaxNull = nonNullTranches.last.max == null;

      // Vérifie que les tranches sont ordonnées
      final areOrdered = List.generate(nonNullTranches.length - 1, (i) {
        final current = nonNullTranches[i];
        final next = nonNullTranches[i + 1];
        if (current.max == null) return false;
        return next.min >= current.max!;
      }).every((valid) => valid);

      if (areMinValid && areOrdered && isLastMaxNull) {
        widget.onChanged(
            Bareme(tranches: nonNullTranches, reference: _reference!));
      } else {
        widget.onChanged(null);
      }
    } catch (e) {
      widget.onChanged(null);
    }
  }
}

class TrancheBuilderWidget extends StatefulWidget {
  final VoidCallback onDelete;
  final VoidCallback onChanged;
  final Tranche? tranche;

  const TrancheBuilderWidget({
    super.key,
    required this.onDelete,
    required this.onChanged,
    this.tranche,
  });

  @override
  State<TrancheBuilderWidget> createState() => _TrancheBuilderWidgetState();
}

class _TrancheBuilderWidgetState extends State<TrancheBuilderWidget> {
  int? min;
  int? max;
  TrancheValueType? selectedType;
  double? valeur;
  Taux? taux;

  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  @override
  void initState() {
    if (widget.tranche != null) {
      _minController.text = widget.tranche!.min.toString();
      min = int.tryParse(_minController.text);
      max = int.tryParse(_maxController.text);
      _maxController.text =
          widget.tranche!.max == null ? "" : widget.tranche!.max.toString();
      selectedType = widget.tranche!.value.type;
      if (widget.tranche!.value.type == TrancheValueType.valeur) {
        _valueController.text = widget.tranche!.value.valeur.toString();
      } else {
        taux = widget.tranche!.value.taux;
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _updateState(VoidCallback fn) {
    setState(fn);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SimpleTextField(
                    label: "Min",
                    textController: _minController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateState(() {
                      min = int.tryParse(value);
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SimpleTextField(
                    label: "Max",
                    textController: _maxController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateState(() {
                      max = int.tryParse(value);
                    }),
                    required: false,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            EnumRadioSelector<TrancheValueType>(
              title: "Sélectionnez un type",
              selectedValue: selectedType,
              values: TrancheValueType.values,
              getLabel: (value) => value.label,
              onChanged: (value) => _updateState(() {
                selectedType = value;
              }),
              isRequired: true,
            ),
            const SizedBox(height: 8),
            if (selectedType == TrancheValueType.valeur)
              SimpleTextField(
                label: "Valeur",
                textController: _valueController,
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateState(() {
                  if (value != null) {
                    valeur = double.tryParse(_valueController.text);
                  }
                }),
              )
            else if (selectedType == TrancheValueType.taux)
              TauxBuilderWidget(
                taux: taux,
                onChanged: (newTaux) => _updateState(() {
                  taux = newTaux;
                }),
              ),
          ],
        ),
      ),
    );
  }

  Tranche? buildTranche() {
    if (min == null || selectedType == null) {
      return null;
    }

    if (selectedType == TrancheValueType.valeur && valeur == null) {
      return null;
    }

    if (selectedType == TrancheValueType.taux && taux == null) {
      return null;
    }

    return Tranche(
      min: min!,
      max: max,
      value: TrancheValue(
        type: selectedType!,
        valeur: selectedType == TrancheValueType.valeur ? valeur : null,
        taux: selectedType == TrancheValueType.taux ? taux : null,
      ),
    );
  }
}
