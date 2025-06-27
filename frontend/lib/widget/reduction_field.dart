import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widget/filter_bar.dart';
import 'package:gap/gap.dart';

import '../style/app_style.dart';

class ReductionField extends StatefulWidget {
  final Function(String) onSelected;
  final String? label;
  final TextEditingController reductionController;
  const ReductionField({
    super.key,
    required this.reductionController,
    required this.onSelected,
    required this.label,
  });

  @override
  State<ReductionField> createState() => _ReductionFieldState();
}

class _ReductionFieldState extends State<ReductionField> {
  List<String> selectedFilterOption = [
    "",
    "%",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Réduction",
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DestopAppStyle.normalText.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    // if (required)
                    //   Text(
                    //     "*",
                    //     style: DestopAppStyle.normalText.copyWith(
                    //       color: Theme.of(context).colorScheme.error,
                    //     ),
                    //   ),
                  ],
                ),
                const Gap(4),
                SizedBox(
                  height: 40,
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*[.,]?\d*$'))
                    ],
                    textAlignVertical: TextAlignVertical.top,
                    controller: widget.reductionController,
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
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    style: DestopAppStyle.normalText.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(4),
          FilterBar(
            label: widget.label ?? "",
            items: selectedFilterOption,
            onSelected: widget.onSelected,
          ),
        ],
      ),
    );
  }
}
