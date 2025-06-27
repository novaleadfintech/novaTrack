import 'package:flutter/material.dart';

class CheckBox extends StatefulWidget {
  final String title;
  final ValueChanged<bool>? onChanged;
  const CheckBox({
    super.key,
    required this.title,
    required this.onChanged,
  });

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  @override
  @override
  Widget build(BuildContext context) {
    bool isChecked = false;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          Checkbox(
            value: isChecked,
            onChanged: (bool? value) {
              setState(() {
                isChecked = value ?? false;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(isChecked);
              }
            },
          ),
        ],
      ),
    );
  }
}
