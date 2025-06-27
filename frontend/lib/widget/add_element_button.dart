import 'package:flutter/material.dart';
import '../app/responsitvity/responsivity.dart';

class AddElementButton extends StatelessWidget {
  final Function() addElement;
  final String label;
  final IconData icon;
  final bool isSmall;
  const AddElementButton({
    super.key,
    required this.addElement,
    this.isSmall = false,
    this.icon = Icons.add,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return !Responsive.isMobile(context) && !isSmall
        ? ElevatedButton.icon(
            onPressed: () {
              addElement();
            },
            icon: Icon(icon),
            label: Text(
              label,
            ),
            style: ButtonStyle(
              backgroundColor:
                  WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
              foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.onPrimary),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              ),
              shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          )
        : IconButton.filled(
            onPressed: () {
              addElement();
            },
            icon: Icon(icon),
            style: const ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          );
  }
}
