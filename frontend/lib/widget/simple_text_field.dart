import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  const SimpleTextField({
    super.key,
    required this.label,
    required this.textController,
    this.required = true,
    this.onChanged,
    this.putUniqueKey = true,
    this.maxLines = 1,
    this.expands = false,
    this.height = 40,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.inputFormaters,
    this.color,
    this.maxlength,
  });

  @override
  State<SimpleTextField> createState() => _SimpleTextFieldState();
}

class _SimpleTextFieldState extends State<SimpleTextField> {
  late final TextEditingController _displayController;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController(
      text: widget.keyboardType == TextInputType.number &&
              widget.textController.text.isNotEmpty
          ? Formatter.formatAmount(
              double.tryParse(widget.textController.text) ?? 0)
          : widget.textController.text,
    );

    widget.textController.addListener(_syncFromTextController);
  }

  void _syncFromTextController() {
    if (widget.keyboardType == TextInputType.number ||
        widget.keyboardType == TextInputType.numberWithOptions(decimal: true) &&
            widget.textController.text.isNotEmpty) {
      final rawValue = double.parse(widget.textController.text);
      final formattedValue = Formatter.formatAmount(rawValue);
      if (_displayController.text != formattedValue) {
        _displayController.text = formattedValue;
      }
    } else {
      _displayController.text = widget.textController.text;
    }
  }

  void _syncToTextController(String value) {
    if (widget.keyboardType == TextInputType.number ||
        widget.keyboardType == TextInputType.numberWithOptions(decimal: true)) {
      final rawValue = Formatter.parseAmount(value);
      if (widget.textController.text != rawValue) {
        widget.textController.text = rawValue;
      }
    } else {
      widget.textController.text = value;
    }
  }

  @override
  void dispose() {
    widget.textController.removeListener(_syncFromTextController);
    _displayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    color: widget.color ??
                        Theme.of(context).colorScheme.onSecondary,
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
          SizedBox(
            height: widget.height,
            child: TextField(
              // key: widget.putUniqueKey ? UniqueKey() : null,
              inputFormatters: widget.inputFormaters != null &&
                      widget.keyboardType == TextInputType.number
                  ? [FilteringTextInputFormatter.digitsOnly, _AmountFormatter()]
                  : widget.keyboardType ==
                          TextInputType.numberWithOptions(decimal: true)
                      ? [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^[\d ]*(\.[\d ]*)?$'),
                          ),
                          // _AmountFormatter()
                        ]
                      : widget.inputFormaters,
              // enableInteractiveSelection: true,
              readOnly: widget.readOnly,
              maxLines: widget.maxLines,
              expands: widget.expands,
              textAlignVertical: TextAlignVertical.top,
              controller: widget.keyboardType == TextInputType.number ||
                      widget.keyboardType ==
                          TextInputType.numberWithOptions(decimal: true)
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
                        TextInputType.numberWithOptions(decimal: true)) {
                  _syncToTextController(value);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    strokeAlign: BorderSide.strokeAlignInside,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    strokeAlign: BorderSide.strokeAlignInside,
                    width: 0.5,
                    color: widget.color ??
                        Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                contentPadding: const EdgeInsets.all(8),
                fillColor: widget.readOnly
                    ? const Color.fromARGB(255, 219, 217, 217)
                    : Theme.of(context).colorScheme.surface,
                filled: widget.readOnly,
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
    final formatted = newValue.text.isEmpty
        ? newValue.text
        : Formatter.formatAmount(
            double.parse(newValue.text),
          );

    return TextEditingValue(
      text: formatted,
    );
  }
}
