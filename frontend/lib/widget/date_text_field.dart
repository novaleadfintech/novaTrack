import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../style/app_color.dart';
import '../style/app_style.dart';

class DateField extends StatefulWidget {
  final Function(DateTime?) onCompleteDate;
  final String label;
  final bool reset;
  final bool required;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final TextEditingController dateController;
  const DateField({
    super.key,
    required this.onCompleteDate,
    required this.label,
    this.lastDate,
    this.firstDate,
    this.required = true,
    this.reset = false,
    required this.dateController,
  });

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      //initialDate: widget.firstDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(2024),
      lastDate: widget.lastDate ?? DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        widget.dateController.text =
            "${picked.day}/${picked.month}/${picked.year}"; // Format de date
      });
      widget.onCompleteDate(picked);
    }
  }

  void _resetDate() {
    setState(() {
      widget.dateController.clear();
    });
    widget.onCompleteDate(null);
  }

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
                widget.label,
                textAlign: TextAlign.left,
                style: DestopAppStyle.fieldTitlesStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              if (widget.required)
                Text(
                  "*",
                  style: DestopAppStyle.fieldTitlesStyle.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          const Gap(4),
          TextFormField(
            controller: widget.dateController,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month),
                  if (widget.reset && widget.dateController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: _resetDate,
                    ),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: AppColor.popGrey,
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: AppColor.popGrey,
                  width: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
