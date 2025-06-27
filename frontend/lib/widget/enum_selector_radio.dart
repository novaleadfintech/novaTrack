import 'package:flutter/material.dart';

import '../style/app_style.dart';

class EnumRadioSelector<T extends Enum> extends StatelessWidget {
  final String title;
  final T? selectedValue;
  final List<T> values;
  final void Function(T?) onChanged;
  final String Function(T) getLabel;
  final bool isRequired;

  const EnumRadioSelector({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.getLabel,
    required this.values,
    required this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: DestopAppStyle.fieldTitlesStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              if (isRequired)
                const Text(
                  '*',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
          ...values.map(
            (value) => Row(
              children: [
                Radio<T>(
                  value: value,
                  groupValue: selectedValue,
                  onChanged: onChanged,
                ),
                Text(getLabel(value)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
