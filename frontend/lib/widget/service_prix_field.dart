import 'package:flutter/material.dart';
 import 'package:flutter_svg/svg.dart';
import '../helper/assets/asset_icon.dart';
import '../style/app_style.dart';
import 'simple_text_field.dart';
import 'package:gap/gap.dart';

class ServiceTariffields extends StatefulWidget {
  final List<Map<String, dynamic>> controllers;
  final bool required;
  const ServiceTariffields({
    super.key,
    required this.controllers,
    this.required = true,
  });

  @override
  State<ServiceTariffields> createState() => _ServiceTariffieldsState();
}

class _ServiceTariffieldsState extends State<ServiceTariffields> {
  void _addField() {
    setState(() {
      // Créez de nouveaux contrôleurs pour chaque champ
      widget.controllers.add({
        'minQuantity': TextEditingController(),
        'maxQuantity': TextEditingController(),
        'prix': TextEditingController(),
      });
    });
  }

  void _removeField(int index) {
    setState(() {
      // Disposez correctement les contrôleurs pour éviter les fuites de mémoire
      widget.controllers[index]['minQuantity']?.dispose();
      widget.controllers[index]['maxQuantity']?.dispose();
      widget.controllers[index]['prix']?.dispose();
      widget.controllers.removeAt(index);
    });
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
                    "Tranches",
                    style: DestopAppStyle.fieldTitlesStyle.copyWith(
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
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                for (int i = 0;
                    i < widget.controllers.length;
                    i++)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tranche ${i + 1}",
                              style: DestopAppStyle.normalText.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeField(i),
                              icon: SvgPicture.asset(
                                AssetsIcons.block,
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
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SimpleTextField(
                                          label: "Min",
                                          keyboardType: TextInputType.number,
                                           textController: widget.controllers[i][
                                              'minQuantity'], // Utilisation correcte
                                        ),
                                      ),
                                      Expanded(
                                        child: SimpleTextField(
                                          label: "Max",
                                          textController: widget.controllers[i][
                                              'maxQuantity'], // Utilisation correcte
                                          keyboardType: TextInputType.number,
                                           required: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SimpleTextField(
                                    label: "Prix",
                                    textController: widget.controllers[i]
                                        ['prix'], // Correct
                                    keyboardType: TextInputType.number,
                                     ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _addField,
                      icon: SvgPicture.asset(
                        AssetsIcons.simpleAdd,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
