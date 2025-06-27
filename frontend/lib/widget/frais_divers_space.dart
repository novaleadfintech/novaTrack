import 'package:flutter/material.dart';
 import 'package:flutter_svg/svg.dart';
import '../app/responsitvity/responsivity.dart';
import '../helper/assets/asset_icon.dart';
import '../style/app_style.dart';
import 'simple_text_field.dart';
import 'package:gap/gap.dart';

class FraisDiversFields extends StatefulWidget {
  final List<Map<String, dynamic>> controllers;

  const FraisDiversFields({
    super.key,
    required this.controllers,
  });

  @override
  State<FraisDiversFields> createState() => _FraisDiversFieldsState();
}

class _FraisDiversFieldsState extends State<FraisDiversFields> {
  void _addField() {
    setState(() {
      widget.controllers.add({
        'libelle': TextEditingController(),
        'montant': TextEditingController(),
        'tva': false,
      });
    });
  }

  void _removeField(int index) {
    setState(() {
      widget.controllers[index]['libelle']?.dispose();
      widget.controllers[index]['montant']?.dispose();
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
              Text(
                "Frais divers",
                style: DestopAppStyle.fieldTitlesStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
                           
            ],
          ),
          Gap(4),
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
                for (int i = 0; i < widget.controllers.length; i++)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Frais divers ${i + 1}",
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
                              Responsive.isMobile(context)
                                  ? Column(
                                      children: [
                                        SimpleTextField(
                                          label: "Libellé",
                                          textController: widget.controllers[i]
                                              ['libelle']!,

                                          required: true,
                                        ),
                                        SimpleTextField(
                                          label: "Montant",
                                          textController: widget.controllers[i]
                                              ['montant']!,
                                          keyboardType: TextInputType.number,
                                          
                                          required: true,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: SimpleTextField(
                                            label: "Libellé",
                                            textController: widget
                                                .controllers[i]['libelle']!,
                                            required: false,
                                          ),
                                        ),
                                        Expanded(
                                          child: SimpleTextField(
                                            label: "Montant",
                                            textController: widget
                                                .controllers[i]['montant']!,
                                            keyboardType: TextInputType.number,
                                            
                                            required: false,
                                          ),
                                        ),
                                      ],
                                    ),
                              const Gap(4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Appliquer TVA",
                                      style: DestopAppStyle.normalText.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: widget.controllers[i]['tva'],
                                    onChanged: (bool value) {
                                      setState(() {
                                        widget.controllers[i]['tva'] = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
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
