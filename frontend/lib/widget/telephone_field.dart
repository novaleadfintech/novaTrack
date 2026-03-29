import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/model/pays_model.dart';

import '../style/app_color.dart';
import '../style/app_style.dart';
import 'package:gap/gap.dart';

class TelephoneTextField extends StatefulWidget {
  final String label;
  final TextEditingController textController;
  final bool required;
  final PaysModel? country;
  final double height;
  final bool readOnly;
  final String? hintText;

  const TelephoneTextField({
    super.key,
    required this.label,
    required this.textController,
    this.required = true,
    required this.country,
    this.height = 44,
    this.readOnly = false,
    this.hintText,
  });

  @override
  State<TelephoneTextField> createState() => _TelephoneTextFieldState();
}

class _TelephoneTextFieldState extends State<TelephoneTextField> {
  bool _isFocused = false;
  late FocusNode _focusNode;
  late TextEditingController _displayController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    // // Initialiser le displayController avec la valeur formatée
    // _displayController = TextEditingController(
    //   text: _formatPhoneNumber(widget.textController.text),
    // );

    // Écouter les changements du textController externe
    widget.textController.addListener(_syncFromTextController);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  // Formater le numéro pour l'affichage (avec espaces)
  // String _formatPhoneNumber(String digits) {
  //   final digitsOnly = digits.replaceAll(' ', '');
  //   if (digitsOnly.isEmpty) return '';

  //   final buffer = StringBuffer();
  //   for (int i = 0; i < digitsOnly.length; i++) {
  //     if (i > 0 && i % 2 == 0) {
  //       buffer.write(' ');
  //     }
  //     buffer.write(digitsOnly[i]);
  //   }
  //   return buffer.toString();
  // }

  // Sync depuis textController vers displayController
  void _syncFromTextController() {
    if (_isUpdating) return;

    // final formatted = _formatPhoneNumber(widget.textController.text);
    // if (_displayController.text != formatted) {
    //   _displayController.text = formatted;
    // }
  }

  // Sync depuis displayController vers textController (sans espaces)
  void _syncToTextController(String displayValue) {
    if (_isUpdating) return;

    _isUpdating = true;
    final digitsOnly = displayValue.replaceAll(' ', '');
    if (widget.textController.text != digitsOnly) {
      widget.textController.text = digitsOnly;
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
    final borderColor = Theme.of(context).colorScheme.onSecondary;
    final focusedBorderColor = AppColor.adaptivePrimaryColor(context);
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
            ),
            child: TextField(
              focusNode: _focusNode,
              readOnly: widget.readOnly,
              enabled: !widget.readOnly,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                // _PhoneNumberFormatter(),
              ],
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLength: (widget.country?.phoneNumber ?? 0) > 0
                  ? widget.country!.phoneNumber
                  : null,
              keyboardType: TextInputType.phone,
              textAlignVertical: TextAlignVertical.center,
              controller: _displayController,
              onChanged: (value) {
                _syncToTextController(value);
              },
              decoration: InputDecoration(
                counterText: '',
                hintText:
                    widget.hintText ?? "X" * (widget.country?.phoneNumber ?? 0),
                hintStyle: DestopAppStyle.normalText.copyWith(
                  color: borderColor.withValues(alpha: 0.5),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 20,
                        color: _isFocused ? focusedBorderColor : borderColor,
                      ),
                      const Gap(8),
                      if (widget.country != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                (_isFocused ? focusedBorderColor : borderColor)
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.country!.code,
                            style: DestopAppStyle.normalText.copyWith(
                              color:
                                  _isFocused ? focusedBorderColor : borderColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                fillColor: widget.readOnly
                    ? AppColor.adaptivePopGrey(context).withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.surface,
                filled: true,
              ),
              style: DestopAppStyle.normalText.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class _PhoneNumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     if (newValue.text.isEmpty) {
//       return newValue;
//     }

//     final newDigitsOnly = newValue.text.replaceAll(' ', '');

//     // Calculer la position du curseur en termes de chiffres
//     int cursorPositionInDigits = 0;
//     for (int i = 0;
//         i < newValue.selection.baseOffset && i < newValue.text.length;
//         i++) {
//       if (newValue.text[i] != ' ') {
//         cursorPositionInDigits++;
//       }
//     }

//     // Formater avec espaces
//     final buffer = StringBuffer();
//     for (int i = 0; i < newDigitsOnly.length; i++) {
//       if (i > 0 && i % 2 == 0) {
//         buffer.write(' ');
//       }
//       buffer.write(newDigitsOnly[i]);
//     }

//     final formatted = buffer.toString();

//     // Calculer la nouvelle position du curseur
//     int newCursorPosition = 0;
//     int digitCount = 0;
//     for (int i = 0; i < formatted.length; i++) {
//       if (digitCount == cursorPositionInDigits) {
//         newCursorPosition = i;
//         break;
//       }
//       if (formatted[i] != ' ') {
//         digitCount++;
//       }
//       newCursorPosition = i + 1;
//     }

//     newCursorPosition = newCursorPosition.clamp(0, formatted.length);

//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: newCursorPosition),
//     );
//   }
// }
