import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/pages/facturation/initial_edit_ligne.dart';
import 'package:frontend/model/facturation/enum_facture.dart';
import 'package:gap/gap.dart';

import '../../../dto/facturation/ligne_dto.dart';
import '../../../helper/assets/asset_icon.dart';
import '../../../model/pays_model.dart';
import '../../../style/app_color.dart';
import '../../../style/app_style.dart';
import '../app_dialog_box.dart';
import 'intial_add_ligne.dart';

class InitialLigneSpace extends StatefulWidget {
  final List<LigneDto> controllers;
  final PaysModel country;
  final TypeFacture type;
  const InitialLigneSpace({
    super.key,
    required this.type,
    required this.controllers,
    required this.country,
  });

  @override
  State<InitialLigneSpace> createState() => _InitialLigneSpaceState();
}

class _InitialLigneSpaceState extends State<InitialLigneSpace> {
  void lignePartRefresh() {
    setState(() {});
  }

  void _removeField(int index) {
    setState(() {
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
            children: [
              Flexible(
                child: Text(
                  "Services",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DestopAppStyle.fieldTitlesStyle.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
              // if (required)
              Text(
                "*",
                style: DestopAppStyle.normalText.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          Gap(4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.controllers.isEmpty)
                    Text(
                      "Aucun Service",
                    )
                  else
                    for (var i = 0; i < widget.controllers.length; i++) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        margin: EdgeInsets.symmetric(vertical: 4),
                        color: AppColor.backgroundColor,
                        child: Row(children: [
                          Expanded(
                            child: Text(
                              style: TextStyle(fontWeight: FontWeight.bold),
                              widget.controllers[i].designation,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                              icon: SvgPicture.asset(
                                AssetsIcons.edit,
                              ),
                              onPressed: () {
                                showResponsiveDialog(
                                  context,
                                  content: EditInitialLigne(
                                    controllers: widget.controllers,
                                    refresh: () {
                                      lignePartRefresh();
                                    },
                                    index: i,
                                  ),
                                  title: "Modifier la demande",
                                );
                              }),
                          IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () {
                                _removeField(i);
                              }),
                        ]),
                      ),
                    ],
                  IconButton(
                    onPressed: () {
                      showResponsiveDialog(
                        context,
                        content: AddInitialLigne(
                          // ton formulaire d'ajout
                          controllers: widget.controllers,
                          type: widget.type,
                          refresh: () {
                            lignePartRefresh();
                          },
                          country: widget.country,
                        ),
                        title: "Nouvelle commande",
                      );
                    },
                    icon: SvgPicture.asset(
                      AssetsIcons.simpleAdd,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
