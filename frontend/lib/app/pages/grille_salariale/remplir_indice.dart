import 'package:flutter/material.dart';
import 'package:frontend/model/grille_salariale/classe_model.dart';
import 'package:frontend/widget/simple_text_field.dart';
import 'package:gap/gap.dart';

import '../../../widget/validate_button.dart';

class FillIndice extends StatefulWidget {
  final ClasseModel classe;
  final void Function(ClasseModel updatedClasse)? onChanged;

  const FillIndice({
    super.key,
    required this.classe,
    this.onChanged,
  });

  @override
  State<FillIndice> createState() => _FillIndiceState();
}

class _FillIndiceState extends State<FillIndice> {
  // Liste des contrôleurs, un par échelon
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs avec les valeurs existantes
    for (var echelon in widget.classe.echelons!) {
      _controllers[echelon.echelon.libelle] =
          TextEditingController(text: echelon.indice?.toString() ?? "");
    }
  }

  @override
  void dispose() {
    // Nettoyer les contrôleurs
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.classe.libelle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...widget.classe.echelons!.map((echelon) {
            final controller = _controllers[echelon.echelon.libelle] ??
                TextEditingController();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: SimpleTextField(
                label: echelon.echelon.libelle,
                textController: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) =>
                    _onIndiceChanged(echelon.echelon.libelle, value),
              ),
            );
          }),
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ValidateButton(
                libelle: "Fermer",
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onIndiceChanged(String libelle, String value) {
    final newIndice = double.tryParse(value);

    if (newIndice == null) return; // On ignore si la valeur n’est pas un nombre

    // On met à jour la valeur d’indice dans la liste des échelons
    setState(() {
      for (var echelon in widget.classe.echelons!) {
        if (echelon.echelon.libelle == libelle) {
          echelon.setIndice(newIndice.toInt());
          break;
        }
      }
    });

    // Si un callback parent est défini, on le notifie du changement
    if (widget.onChanged != null) {
      widget.onChanged!(
        ClasseModel(
          id: widget.classe.id,
          libelle: widget.classe.libelle,
          echelons: widget.classe.echelons!,
        ),
      );
    }
  }
}
