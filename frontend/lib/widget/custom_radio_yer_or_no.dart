import 'package:flutter/material.dart';
import '../style/app_style.dart';

class CustomRadioGroup extends StatelessWidget {
  final String label;
  final bool groupValue;
  final ValueChanged<bool?> onChanged;
  final bool required;
  final bool defaultValue;

  const CustomRadioGroup({
    super.key,
    required this.label,
    required this.groupValue,
    required this.onChanged,
    this.required = true,
    required this.defaultValue,
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
                label,
                style: DestopAppStyle.fieldTitlesStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              Text(
                "*",
                style: DestopAppStyle.normalText.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text(defaultValue ? 'Oui' : "Non"),
                  leading: Radio<bool>(
                    value: defaultValue ? true : false,
                    groupValue: groupValue,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text(defaultValue ? "Non" : 'Oui'),
                  leading: Radio<bool>(
                    value: defaultValue ? false : true,
                    groupValue: groupValue,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
