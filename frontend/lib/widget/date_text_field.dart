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
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: widget.firstDate ?? DateTime(2024),
      lastDate: widget.lastDate ?? DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        widget.dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
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
    final borderColor = Theme.of(context).colorScheme.onSecondary;
    final focusedBorderColor = AppColor.adaptivePrimaryColor(context);
    
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
                  color: _isFocused ? focusedBorderColor : borderColor,
                ),
              ),
              if (widget.required)
                Text(
                  " *",
                  style: DestopAppStyle.fieldTitlesStyle.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          const Gap(6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: focusedBorderColor.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              focusNode: _focusNode,
              controller: widget.dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              style: DestopAppStyle.normalText.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: _isFocused ? focusedBorderColor : borderColor,
                ),
                suffixIcon: widget.reset && widget.dateController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: _resetDate,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 12.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: borderColor,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: borderColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: focusedBorderColor,
                    width: 1.5,
                  ),
                ),
                fillColor: Theme.of(context).colorScheme.surface,
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
