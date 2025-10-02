import 'package:flutter/material.dart';

class AppActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const AppActionButton(
      {super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8)),
        child: child,
      ),
    );
  }
}
