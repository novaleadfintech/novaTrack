import 'package:flutter/material.dart';
import 'package:frontend/model/grille_salariale/classe_model.dart';
import 'package:frontend/widget/simple_text_field.dart';
import 'package:gap/gap.dart';
import '../../../widget/validate_button.dart';
import '../../integration/request_frot_behavior.dart';

class FillIndice extends StatefulWidget {
  final ClasseModel classe;
  final VoidCallback refresh;

  const FillIndice({
    super.key,
    required this.classe,
    required this.refresh,
  });

  @override
  State<FillIndice> createState() => _FillIndiceState();
}

class _FillIndiceState extends State<FillIndice> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var echelon in widget.classe.echelonIndiciciaires!) {
      _controllers[echelon.echelon.libelle] =
          TextEditingController(text: echelon.indice?.toString() ?? "");
    }
  }

  @override
  void dispose() {
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
          ...widget.classe.echelonIndiciciaires!.map((echelon) {
            final controller = _controllers[echelon.echelon.libelle]!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: SimpleTextField(
                label: echelon.echelon.libelle,
                textController: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            );
          }),
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ValidateButton(
                libelle: "Valider",
                onPressed: _onValidatePressed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onValidatePressed() {
    for (var echelon in widget.classe.echelonIndiciciaires!) {
      final controller = _controllers[echelon.echelon.libelle];
      final newIndice = double.tryParse(controller?.text ?? "");
      print(echelon.indice);      
      if (newIndice != null) {
        echelon.setIndice(newIndice.toInt());
        print(echelon.indice);
      } else {
        MutationRequestContextualBehavior.showCustomInformationPopUp(
          message:
              "Veuillez entrer un indice valide pour l'échelon ${echelon.echelon.libelle}.",
        );
        return;
      }
    }

    widget.refresh();
    MutationRequestContextualBehavior.closePopup();
  }
}
