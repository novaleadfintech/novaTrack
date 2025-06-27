import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../app/responsitvity/responsivity.dart';
import '../helper/assets/asset_icon.dart';
import '../style/app_style.dart';
import 'simple_text_field.dart';
import 'package:gap/gap.dart';

class AgencesFields extends StatefulWidget {
  final List<Map<String, dynamic>> controllers;
  final bool required;

  const AgencesFields({
    super.key,
    required this.controllers,
    this.required = false,
  });

  @override
  State<AgencesFields> createState() => _AgencesFieldsState();
}

class _AgencesFieldsState extends State<AgencesFields> {
  void _addField() {
    setState(() {
      widget.controllers.add({
        'nom': TextEditingController(),
      });
    });
  }

  void _removeField(int index) {
    setState(() {
      widget.controllers[index]['nom']?.dispose();
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
                    "Agences",
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
                      "Agence ${widget.controllers.length - i}",
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
                                  label: "Nom",
                                  textController: widget.controllers[i]['nom']!,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: SimpleTextField(
                                    label: "Nom",
                                    textController: widget.controllers[i]
                                        ['nom']!,
                                  ),
                                ),
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
