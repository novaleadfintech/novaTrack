import 'package:flutter/material.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/app/pages/app_dialog_box.dart';
import 'package:frontend/app/pages/grille_salariale/remplir_indice.dart';
import 'package:frontend/model/grille_salariale/classe_model.dart';
import 'package:frontend/service/classe_service.dart';
import 'package:gap/gap.dart';

class AddClassCategorieSpace extends StatefulWidget {
  final String categorieName;
  final List<ClasseModel> classes;
  const AddClassCategorieSpace({
    super.key,
    required this.categorieName,
    required this.classes,
  });

  @override
  State<AddClassCategorieSpace> createState() => _AddClassCategorieSpaceState();
}

class _AddClassCategorieSpaceState extends State<AddClassCategorieSpace> {
  // List<ClasseModel> selectedClasses = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final classes = await ClasseService.getClasses();
      setState(() {
        widget.classes.addAll(classes);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des classes: $e');
      setState(() {
        errorMessage = e.toString();
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const Gap(8),
                    Text(
                      errorMessage ?? 'Erreur lors du chargement',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    ElevatedButton.icon(
                      onPressed: _loadClasses,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
          else if (widget.classes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                    Gap(16),
                    Text(
                      'Aucune classe disponible',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...widget.classes.map((classe) {
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
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(4),
                            color: Theme.of(context).colorScheme.onSecondary,
                            child: Text(
                              classe.libelle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Gap(8),
                        IconButton(
                          icon: Icon(
                            Icons.list_alt,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            widget.categorieName.isEmpty
                                ? MutationRequestContextualBehavior
                                    .showCustomInformationPopUp(
                                    message:
                                        "Veuillez remplir le champs de libellé",
                                  )
                                : showResponsiveDialog(
                                    context,
                                    content: FillIndice(
                                      classe: classe,
                                      refresh: () {
                                        setState(() {});
                                      },
                                    ),
                                    title:
                                        "Remplir les indices de la ${classe.libelle} de la catégorie ${widget.categorieName}",
                                  );
                          },
                        ),
                      ],
                    ),
                    const Gap(8),
                    if (classe.echelonIndiciciaires != null &&
                        classe.echelonIndiciciaires!.isNotEmpty)
                      ...classe.echelonIndiciciaires!.map((echelonIndice) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  echelonIndice.echelon.libelle,
                                ),
                              ),
                              Text(
                                "Indice: ${echelonIndice.indice ?? 'Non défini'}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: echelonIndice.indice != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Aucun échelon défini',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
