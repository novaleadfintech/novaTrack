import 'package:flutter/material.dart';
import '../style/app_style.dart';

class SideBarTitle extends StatelessWidget {
  final String label;
  const SideBarTitle({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 15,
          ),
          child: Text(
            label,
            textAlign: TextAlign.start,
            style: DestopAppStyle.smallSimpleText.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
