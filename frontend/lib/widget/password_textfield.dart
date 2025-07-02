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
  bool _isUpdating = false; // Flag pour éviter les boucles infinies

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
    if (_isUpdating) return;

    _isUpdating = true;

    if (_obscureText) {
      final cursorPosition = _displayController.selection.baseOffset;
      _displayController.text = obscureChar * _actualPassword.length;

      // Repositionner le curseur de manière sécurisée
      final newPosition =
          cursorPosition.clamp(0, _displayController.text.length);
      _displayController.selection = TextSelection.fromPosition(
        TextPosition(offset: newPosition),
      );
    } else {
      _displayController.text = _actualPassword;

      // Conserver la position du curseur
      final cursorPosition = _displayController.selection.baseOffset;
      final newPosition = cursorPosition.clamp(0, _actualPassword.length);
      _displayController.selection = TextSelection.fromPosition(
        TextPosition(offset: newPosition),
      );
    }

    _isUpdating = false;
  }

  void _onTextChanged(String value) {
    if (_isUpdating) return;

    final currentCursorPosition = _displayController.selection.baseOffset;

    if (_obscureText) {
      // Calculer les changements dans le mot de passe réel
      if (value.length > _actualPassword.length) {
        // Caractère ajouté - trouver la position d'insertion
        int insertPosition = 0;
        for (int i = 0; i < value.length && i < _actualPassword.length; i++) {
          if (value[i] == obscureChar) {
            insertPosition++;
          } else {
            break;
          }
        }

        // Extraire le nouveau caractère
        String newChar = '';
        for (int i = 0; i < value.length; i++) {
          if (value[i] != obscureChar) {
            newChar = value[i];
            insertPosition = i;
            break;
          }
        }

        if (newChar.isNotEmpty) {
          _actualPassword = _actualPassword.substring(0, insertPosition) +
              newChar +
              _actualPassword.substring(insertPosition);
        }
      } else if (value.length < _actualPassword.length) {
        // Caractère supprimé
        _actualPassword = _actualPassword.substring(0, value.length);
      }

      // Mettre à jour le controller principal
      widget.controller.text = _actualPassword;

      // Mettre à jour l'affichage
      _isUpdating = true;
      _displayController.text = obscureChar * _actualPassword.length;

      // Repositionner le curseur
      final newCursorPosition =
          currentCursorPosition.clamp(0, _displayController.text.length);
      _displayController.selection = TextSelection.fromPosition(
        TextPosition(offset: newCursorPosition),
      );
      _isUpdating = false;
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
              obscureText: false,
              keyboardType: TextInputType.visiblePassword,
              onChanged: _onTextChanged,
              onTap: () {
                // Empêcher la sélection automatique du texte complet
                // Ne rien faire de spécial, laisser le comportement par défaut
              },
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
