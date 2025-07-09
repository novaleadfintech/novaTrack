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

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
              controller: widget.controller,
              obscureText: _obscureText,
              keyboardType: TextInputType.visiblePassword,
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
