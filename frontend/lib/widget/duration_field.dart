import 'package:flutter/material.dart';
 import '../app/responsitvity/responsivity.dart';
import '../helper/date_helper.dart';
import '../style/app_color.dart';
import '../style/app_style.dart';
import 'drop_down_text_field.dart';
import 'simple_text_field.dart';
import 'package:gap/gap.dart';

class DurationField extends StatelessWidget {
  final String label;

  final Function(String?) onUnityChanged;
  final bool required;
  final String? unitSelectItem;
  final TextEditingController controller;

  const DurationField({
    super.key,
    required this.label,
    required this.onUnityChanged,
    this.required = true,
    required this.unitSelectItem,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
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
          const Gap(4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.5,
                color: AppColor.popGrey,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomDropDownField(
                        items: unitMultipliers.keys.toList(),
                        onChanged: onUnityChanged,
                        label: "Unité",
                        required: required,
                        selectedItem: unitSelectItem,
                        canClose: !required,
                      ),
                    ),
                    if (!Responsive.isMobile(context))
                      Expanded(
                        child: SimpleTextField(
                        
                          required: required,
                          label:
                              "Compteur${unitSelectItem == null ? "" : "($unitSelectItem)"}",
                          textController: controller,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                  ],
                ),
                if (Responsive.isMobile(context))
                  SimpleTextField(
                    required: required,
                     label:
                        "Compteur${unitSelectItem == null ? "" : "($unitSelectItem)"}",
                    textController: controller,
                    keyboardType: TextInputType.number,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
