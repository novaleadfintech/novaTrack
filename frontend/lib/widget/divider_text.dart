import 'package:flutter/material.dart';
import 'package:frontend/style/app_style.dart';
import 'package:gap/gap.dart';

class DividerText extends StatelessWidget {
  final String text;
  const DividerText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 2,
              height: 16,
            ),
          ),
          Gap(8),
          Text(
            text,
            style: DestopAppStyle.fieldTitlesStyle.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          Gap(8),
          Expanded(
            child: Divider(
              thickness: 2,
              height: 16,
            ),
          ),
        ],
      ),
    );
  }
}
