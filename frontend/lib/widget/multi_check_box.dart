import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../style/app_style.dart';

class MultiCheckBox<T> extends StatefulWidget {
  final String label;
  final bool required;
  final List<T> initialSelectedValues;
  final List<T> options;
  final void Function(List<T>)? onChanged;

  const MultiCheckBox({
    super.key,
    required this.label,
    this.required = false,
    required this.initialSelectedValues,
    required this.options,
    this.onChanged,
  });

  @override
  State<MultiCheckBox<T>> createState() => _MultiCheckBoxState<T>();
}

class _MultiCheckBoxState<T> extends State<MultiCheckBox<T>> {
  late List<T> selectedOptions;

  @override
  void initState() {
    super.initState();
    // Copie initiale des valeurs sélectionnées
    selectedOptions = List<T>.from(widget.initialSelectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label du champ
          Row(
            children: [
              Flexible(
                child: Text(
                  widget.label,
                  style: DestopAppStyle.fieldTitlesStyle.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
              if (widget.required)
                Text(
                  "*",
                  style: DestopAppStyle.normalText.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          const Gap(4),

          // Liste des checkboxes
          ...widget.options.map((option) {
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option.toString()),
              value: selectedOptions.contains(option),
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }

                  // Si une fonction de callback est fournie, on la déclenche
                  widget.onChanged?.call(selectedOptions);
                });
              },
            );
          }),
        ],
      ),
    );
  }
}
