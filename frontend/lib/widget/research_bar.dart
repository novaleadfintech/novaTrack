import 'package:flutter/material.dart';
import '../style/app_color.dart';
import '../style/app_style.dart';

class ResearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const ResearchBar({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        //horizontal: 0,
        vertical: 16,
      ),
      child: SizedBox(
        width: 250,
        height: 40,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintMaxLines: 1,
            hintStyle: DestopAppStyle.normalText.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            border: const OutlineInputBorder(
              borderSide: BorderSide(),
            ),

            //hoverColor: Color(0xFFDADCE0),
            suffixIcon: const Icon(
              Icons.search,
              color: AppColor.popGrey,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
          ),
        ),
      ),
    );
  }
}
