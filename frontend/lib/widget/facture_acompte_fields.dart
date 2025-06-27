
import 'package:flutter/material.dart';
 import 'package:flutter_svg/svg.dart';
import '../helper/assets/asset_icon.dart';
import '../helper/date_helper.dart';
import '../style/app_style.dart';
import 'date_text_field.dart';
import 'simple_text_field.dart';
import 'package:gap/gap.dart';

class FactureAcompteFields extends StatefulWidget {
  final List<Map<String, dynamic>> controllers;
  final bool required;
  final DateTime? dateEtablissement;

  const FactureAcompteFields({
    super.key,
    required this.controllers,
    this.required = true,
    required this.dateEtablissement,
  });

  @override
  State<FactureAcompteFields> createState() => _FactureAcompteFieldsState();
}

class _FactureAcompteFieldsState extends State<FactureAcompteFields> {
  void _addField() {
    setState(() {
      widget.controllers.add({
        'rang': TextEditingController(
            text: (widget.controllers.length + 1).toString()),
        'pourcentage': TextEditingController(),
        'canPenalty': true,
        'dateEnvoieFacture': TextEditingController(),
      });
    });
  }

  void _recalculateRanks() {
    for (int i = 0; i < widget.controllers.length; i++) {
      widget.controllers[i]['rang']?.text = (i + 1).toString();
    }
  }

  void _removeField(int index) {
    setState(() {
      widget.controllers[index]
          .forEach((_, controller) => controller.dispose());
      widget.controllers.removeAt(index);
      _recalculateRanks();
    });
  }

  Widget _buildAcompteField(int index) {
    var controller = widget.controllers[index];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Encaissement ${index + 1}",
                style: DestopAppStyle.normalText.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              IconButton(
                onPressed: () => _removeField(index),
                icon: SvgPicture.asset(AssetsIcons.block),
              ),
            ],
          ),
          const Gap(4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                SimpleTextField(
                  label: "Rang",
                  textController: controller['rang'],
                  readOnly: true,
                ),
                SimpleTextField(
                  label: "Pourcentage (en %)",
                  textController: controller['pourcentage'],
                  keyboardType: TextInputType.number,
                ),
                // CustomRadioGroup(
                //   label: "Appliquer les règles de pénalité",
                //   groupValue: controller['canPenalty'],
                //   onChanged: (bool? value) {
                //     setState(() {
                //       controller['canPenalty'] = value!;
                //     });
                //   },
                //   defaultValue: true,
                // ),
                DateField(
                  label: "Date d'envoi",
                  dateController: controller['dateEnvoieFacture'],
                  lastDate: (index + 1 < widget.controllers.length &&
                          widget.controllers[index + 1]["dateEnvoieFacture"]
                              .text.isNotEmpty)
                      ? convertToDateTime(widget
                          .controllers[index + 1]["dateEnvoieFacture"].text)
                      : null,
                  firstDate: (index - 1 >= 0 &&
                          widget.controllers[index - 1]["dateEnvoieFacture"]
                              .text.isNotEmpty)
                      ? convertToDateTime(widget
                          .controllers[index - 1]["dateEnvoieFacture"].text)
                      : widget.dateEtablissement,
                  onCompleteDate: (value) {
                    if (value != null) {
                      setState(() {
                        controller['dateEnvoieFacture'].text =
                            getStringDate(time: value);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Encaissements",
                    style: DestopAppStyle.normalText.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary,
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
            ],
          ),
          Gap(4),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  width: 0.5,
              ),
                borderRadius: BorderRadius.circular(4)),
            child: Column(
              children: [
                if (widget.controllers.isNotEmpty) ...[
                  for (int i = 0; i < widget.controllers.length; i++,)
                    _buildAcompteField(i),
                ] else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Aucun encaissement",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                Gap(4),
                IconButton(
                  onPressed: _addField,
                  icon: SvgPicture.asset(
                    AssetsIcons.simpleAdd,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
