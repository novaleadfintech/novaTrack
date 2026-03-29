import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/style/app_color.dart';
import '../helper/amout_formatter.dart';
import '../style/app_style.dart';
import 'package:gap/gap.dart';

class SimpleTextField extends StatefulWidget {
  final String label;
  final TextEditingController textController;
  final bool required;
  final int? maxLines;
  final bool expands;
  final Function? onChanged;
  final double height;
  final Color? color;
  final bool putUniqueKey;
  final TextInputType keyboardType;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormaters;
  final int? maxlength;
  final String? hintText;
  final IconData? prefixIcon;

  const SimpleTextField({
    super.key,
    required this.label,
    required this.textController,
    this.required = true,
    this.onChanged,
    this.putUniqueKey = true,
    this.maxLines = 1,
    this.expands = false,
    this.height = 44,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.inputFormaters,
    this.color,
    this.maxlength,
    this.hintText,
    this.prefixIcon,
  });

  @override
  State<SimpleTextField> createState() => _SimpleTextFieldState();
}

class _SimpleTextFieldState extends State<SimpleTextField> {
  late final TextEditingController _displayController;
  bool _isUpdating = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    _displayController = TextEditingController(
      text: widget.keyboardType == TextInputType.number &&
              widget.textController.text.isNotEmpty
          ? Formatter.formatAmount(
              double.tryParse(widget.textController.text) ?? 0)
          : widget.textController.text,
    );

    widget.textController.addListener(_syncFromTextController);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _syncFromTextController() {
    if (_isUpdating) return;

    String currentText = widget.textController.text;

    if ((widget.keyboardType == TextInputType.number ||
            widget.keyboardType ==
                const TextInputType.numberWithOptions(decimal: true)) &&
        currentText.isNotEmpty) {
      final rawValue = double.tryParse(currentText) ?? 0;
      final formattedValue = Formatter.formatAmount(rawValue);

      if (_displayController.text != formattedValue) {
        _displayController.value = TextEditingValue(
          text: formattedValue,
          selection: TextSelection.collapsed(offset: formattedValue.length),
          composing: TextRange.empty,
        );
      }
    } else {
      if (_displayController.text != currentText) {
        _displayController.value = TextEditingValue(
          text: currentText,
          selection: TextSelection.collapsed(offset: currentText.length),
          composing: TextRange.empty,
        );
      }
    }
  }

  void _syncToTextController(String value) {
    if (_isUpdating) return;

    _isUpdating = true;

    if (widget.keyboardType == TextInputType.number ||
        widget.keyboardType == const TextInputType.numberWithOptions(decimal: true)) {
      final rawValue = Formatter.parseAmount(value);

      if (widget.textController.text != rawValue) {
        widget.textController.value = TextEditingValue(
          text: rawValue,
          selection: widget.textController.selection,
          composing: TextRange.empty,
        );
      }
    } else {
      if (widget.textController.text != value) {
        widget.textController.value = TextEditingValue(
          text: value,
          selection: widget.textController.selection,
          composing: TextRange.empty,
        );
      }
    }

    _isUpdating = false;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.textController.removeListener(_syncFromTextController);
    _displayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.color ?? Theme.of(context).colorScheme.onSecondary;
    final focusedBorderColor = AppColor.adaptivePrimaryColor(context);
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  widget.label,
                  style: DestopAppStyle.fieldTitlesStyle.copyWith(
                    color: _isFocused 
                        ? focusedBorderColor
                        : borderColor,
                  ),
                ),
              ),
              if (widget.required)
                Text(
                  " *",
                  style: DestopAppStyle.normalText.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          const Gap(6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isFocused && !widget.readOnly
                  ? [
                      BoxShadow(
                        color: focusedBorderColor.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              focusNode: _focusNode,
              inputFormatters: widget.keyboardType == TextInputType.number
                  ? [FilteringTextInputFormatter.digitsOnly, _AmountFormatter()]
                  : widget.keyboardType ==
                          const TextInputType.numberWithOptions(decimal: true)
                      ? [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^[\d ]*(\.[\d ]*)?$'),
                          ),
                          _AmountFormatter()
                        ]
                      : widget.inputFormaters,
              readOnly: widget.readOnly,
              maxLines: widget.maxLines,
              expands: widget.expands,
              textAlignVertical: TextAlignVertical.center,
              controller: widget.keyboardType == TextInputType.number ||
                      widget.keyboardType ==
                          const TextInputType.numberWithOptions(decimal: true)
                  ? _displayController
                  : widget.textController,
              keyboardType: widget.keyboardType,
              enabled: !widget.readOnly,
              maxLength: widget.maxlength,
              onChanged: (value) {
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
                if (widget.keyboardType == TextInputType.number ||
                    widget.keyboardType ==
                        const TextInputType.numberWithOptions(decimal: true)) {
                  _syncToTextController(value);
                }
              },
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: DestopAppStyle.normalText.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.6),
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: _isFocused ? focusedBorderColor : borderColor,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    width: 1,
                    color: borderColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    width: 1,
                    color: borderColor.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    width: 1.5,
                    color: focusedBorderColor,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    width: 1,
                    color: borderColor.withValues(alpha: 0.3),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                fillColor: widget.readOnly
                    ? AppColor.adaptivePopGrey(context).withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.surface,
                filled: true,
              ),
              style: DestopAppStyle.normalText.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final double? numericValue =
        double.tryParse(newValue.text.replaceAll(' ', ''));
    if (numericValue == null) return oldValue;

    final String formatted = Formatter.formatAmount(numericValue);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}
