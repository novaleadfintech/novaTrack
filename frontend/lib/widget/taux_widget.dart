import 'package:flutter/material.dart';
 import 'package:frontend/model/bulletin_paie/rubrique.dart';
import 'package:frontend/service/bulletin_rubrique_service.dart';
import 'package:frontend/widget/future_dropdown_field.dart';
import 'package:frontend/widget/simple_text_field.dart';
import '../model/bulletin_paie/tranche_model.dart';

class TauxBuilderWidget extends StatefulWidget {
  final Taux? taux;
  final void Function(Taux newTaux) onChanged;

  const TauxBuilderWidget({
    super.key,
    this.taux,
    required this.onChanged,
  });

  @override
  State<TauxBuilderWidget> createState() => _TauxBuilderWidgetState();
}

class _TauxBuilderWidgetState extends State<TauxBuilderWidget> {
  RubriqueBulletin? _base;
  final TextEditingController _tauxController = TextEditingController();

  @override
  void initState() {
    if (widget.taux != null) {
      _base = widget.taux!.base;
      _tauxController.text = widget.taux!.taux.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureCustomDropDownField<RubriqueBulletin>(
          label: "Base",
          showSearchBox: true,
          selectedItem: _base,
          fetchItems: fetchRubriqueItems,
          onChanged: (RubriqueBulletin? value) {
            setState(() {
              _base = value;
            });
            _notifyChange();
          },
          canClose: false,
          itemsAsString: (s) => s.rubrique,
        ),
        const SizedBox(height: 12),
        SimpleTextField(
          label: "Taux (%)",
          textController: _tauxController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _notifyChange(),
        ),
      ],
    );
  }

  Future<List<RubriqueBulletin>> fetchRubriqueItems() async {
    return await BulletinRubriqueService.getBulletinRubriques();
  }

  void _notifyChange() {
    final tauxValue = double.tryParse(_tauxController.text);

    if (_base != null && tauxValue != null) {
      widget.onChanged(
        Taux(
          base: _base!,
          taux: tauxValue,
        ),
      );
    }
  }
}
