import 'package:flutter/material.dart';

class AppActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  
  const AppActionButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: const ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
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
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        child: child);
  }
}