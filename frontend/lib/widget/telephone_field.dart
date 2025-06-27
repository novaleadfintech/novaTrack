import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../style/app_style.dart';
import 'package:gap/gap.dart';

class TelephoneTextField extends StatelessWidget {
  final String label;
  final TextEditingController textController;
  final bool required;
  final String contryCode;
  final double height;
  final int maxLength;

  final bool readOnly;
  const TelephoneTextField({
    super.key,
    required this.label,
    required this.textController,
    this.required = true,
    required this.contryCode,
    this.height = 40,
    required this.maxLength,
    this.readOnly = false,
  });

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
              Expanded(
                child: Row(
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.left,
                      style: DestopAppStyle.fieldTitlesStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    if (required)
                      Text(
                        "*",
                        style: DestopAppStyle.normalText.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
              /*Text(
                '${_text.length}/${widget.maxLength + 1}',
                style: DestopAppStyle.normalText.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),*/
            ],
          ),
          const Gap(4),
          SizedBox(
            height: height,
            child: TextField(
              readOnly: readOnly,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLength: maxLength,
              keyboardType: TextInputType.phone,
              textAlignVertical: TextAlignVertical.top,
              controller: textController,
              decoration: InputDecoration(
                counterText: '',
                  prefix: Text(
                    '+$contryCode ',
                    style: DestopAppStyle.normalText.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
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
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(8),
                  fillColor: readOnly
                      ? const Color.fromARGB(255, 219, 217, 217)
                      : Theme.of(context).colorScheme.surface,
                  filled: readOnly),
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
