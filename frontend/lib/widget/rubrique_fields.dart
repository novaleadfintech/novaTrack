import 'package:flutter/material.dart';
 import 'package:flutter_svg/svg.dart';
import '../app/responsitvity/responsivity.dart';
import '../helper/assets/asset_icon.dart';
import '../style/app_style.dart';
import 'simple_text_field.dart';
import 'package:gap/gap.dart';

class RubriquesFields extends StatefulWidget {
  final List<Map<String, dynamic>> controllers;
  final bool required;
  final String rubriqueName;

  const RubriquesFields({
    super.key,
    required this.controllers,
    this.required = false,
    required this.rubriqueName,
  });

  @override
  State<RubriquesFields> createState() => _RubriquesFieldsState();
}

class _RubriquesFieldsState extends State<RubriquesFields> {
  void _addField() {
    setState(() {
      widget.controllers.add({
        'libelle': TextEditingController(),
        'montant': TextEditingController(),
        'taux': TextEditingController(),
      });
    });
  }

  void _removeField(int index) {
    setState(() {
      widget.controllers[index]['libelle']?.dispose();
      widget.controllers[index]['montant']?.dispose();
      widget.controllers[index]['taux']?.dispose();
      widget.controllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "${widget.rubriqueName}s",
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
              IconButton(
                onPressed: _addField,
                icon: SvgPicture.asset(
                  AssetsIcons.simpleAdd,
                ),
              ),
            ],
          ),
        ),
        for (int i = widget.controllers.length - 1; i >= 0; i--)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.rubriqueName} ${i + 1}",
                      style: DestopAppStyle.normalText.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
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
                      Responsive.isMobile(context)
                          ? Column(
                              children: [
                                SimpleTextField(
                                  label: "Libellé",
                                  textController: widget.controllers[i]
                                      ['libelle']!,
                                ),
                                SimpleTextField(
                                  label: "Montant",
                                  textController: widget.controllers[i]
                                      ['montant']!,
                                  keyboardType: TextInputType.number,
                                  
                                ),
                                SimpleTextField(
                                  label: "Taux",
                                  textController: widget.controllers[i]
                                      ['taux']!,
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                SimpleTextField(
                                  label: "Libellé",
                                  textController: widget.controllers[i]
                                      ['libelle']!,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SimpleTextField(
                                        label: "Montant",
                                        textController: widget.controllers[i]
                                            ['montant']!,
                                        keyboardType: TextInputType.number,
                                       
                                      ),
                                    ),
                                    Expanded(
                                      child: SimpleTextField(
                                        label: "Taux",
                                        textController: widget.controllers[i]
                                            ['taux']!,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                       ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
