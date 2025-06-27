import 'package:flutter/material.dart';

class ValidateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String libelle;
  const ValidateButton({
    super.key,
    this.libelle = "Enregistrer",
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: const ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
          ),
        ),
        textStyle: WidgetStatePropertyAll(
          TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      child: Text(
        libelle,
      ),
    );
  }
}
