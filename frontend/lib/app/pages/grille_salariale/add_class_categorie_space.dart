import 'package:flutter/material.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/grille_salariale/remplir_indice.dart';
import 'package:frontend/model/grille_salariale/classe_model.dart';
import 'package:frontend/model/grille_salariale/echelon_indice_model.dart';
import 'package:frontend/model/grille_salariale/echelon_model.dart';
import 'package:gap/gap.dart';

class AddClassCategorieSpace extends StatefulWidget {
  const AddClassCategorieSpace({super.key});

  @override
  State<AddClassCategorieSpace> createState() => _AddClassCategorieSpaceState();
}

class _AddClassCategorieSpaceState extends State<AddClassCategorieSpace> {
  List<ClasseModel> selectedClasses = [
    ClasseModel(
      id: "id",
      libelle: "libelle",
      echelons: [
        EchelonIndiceModel(
          echelon: EchelonModel(id: "id", libelle: "1er échelon"),
          indice: 3355,
        ),
        EchelonIndiceModel(
          echelon: EchelonModel(id: "id", libelle: "2eme échelon"),
          indice: 3355,
        ),
        EchelonIndiceModel(
          echelon: EchelonModel(id: "id", libelle: "3eme échelon"),
          indice: 3355,
        ),
        EchelonIndiceModel(
          echelon: EchelonModel(id: "id", libelle: "4eme échelon"),
          indice: 3355,
        ),
      ],
    ),
    ClasseModel(
      id: "id",
      libelle: "libelle",
      echelons: [
        EchelonIndiceModel(
          echelon: EchelonModel(id: "id", libelle: "libelle"),
          indice: 3355,
        )
      ],
    ),
    ClasseModel(
      id: "id",
      libelle: "libelle",
      echelons: [
        EchelonIndiceModel(
          echelon: EchelonModel(id: "id", libelle: "libelle"),
          indice: 3355,
        )
      ],
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ...selectedClasses.map((classe) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        classe.libelle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(8),
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: Theme.of(context).colorScheme.primary),
                        onPressed: () {
                          setState(() {
                            showResponsiveDialog(
                              context,
                              content: FillIndice(
                                classe: classe,
                                refresh: () {
                                  setState(() {});
                                },
                              ),
                              title: "Remplir les indices",
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  ...?classe.echelons?.map((echelonIndice) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Échelon: ${echelonIndice.echelon.libelle}"),
                          Text("Indice: ${echelonIndice.indice}"),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}
