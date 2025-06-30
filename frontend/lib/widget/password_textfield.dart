import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../style/app_style.dart';

class PasswordTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool required;

  const PasswordTextField({
    super.key,
    required this.label,
    required this.controller,
    this.required = true,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;
  String _actualPassword = '';
  late TextEditingController _displayController;
  String obscureChar = "•";
  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController();
    _actualPassword = widget.controller.text;
    _updateDisplayText();
  }

  @override
  void dispose() {
    _displayController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
      _updateDisplayText();
    });
  }

  void _updateDisplayText() {
    if (_obscureText) {
      _displayController.text = obscureChar * _actualPassword.length;
    } else {
      _displayController.text = _actualPassword;
    }
  }

  void _onTextChanged(String value) {
    if (_obscureText) {
      // Calculer les changements dans le mot de passe réel
      if (value.length > _actualPassword.length) {
        // Caractère ajouté
        String newChar = value[value.length - 1];
        if (newChar != obscureChar) {
          _actualPassword = _actualPassword + newChar;
        }
      } else if (value.length < _actualPassword.length) {
        // Caractère supprimé
        _actualPassword = _actualPassword.substring(0, value.length);
      }

      // Mettre à jour le controller principal avec le vrai mot de passe
      widget.controller.text = _actualPassword;

      // Afficher les points
      _displayController.text = obscureChar * _actualPassword.length;

      // Repositionner le curseur à la fin
      _displayController.selection = TextSelection.fromPosition(
        TextPosition(offset: _displayController.text.length),
      );
    } else {
      // Mode visible - synchroniser directement
      _actualPassword = value;
      widget.controller.text = _actualPassword;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.label,
                textAlign: TextAlign.left,
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
          const Gap(4),
          SizedBox(
            height: 40,
            child: TextField(
              enableInteractiveSelection: true,
              controller: _obscureText ? _displayController : widget.controller,
              obscureText: false, // On gère l'obscurcissement manuellement
              keyboardType: TextInputType.visiblePassword,
              onChanged: _onTextChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    strokeAlign: BorderSide.strokeAlignInside,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    strokeAlign: BorderSide.strokeAlignInside,
                    width: 0.5,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: _toggleVisibility,
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                suffixIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                contentPadding: const EdgeInsets.all(8),
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              style: DestopAppStyle.normalText.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
