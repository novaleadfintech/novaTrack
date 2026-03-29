import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../style/app_color.dart';
import '../style/app_style.dart';

class PasswordTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final String? hintText;

  const PasswordTextField({
    super.key,
    required this.label,
    required this.controller,
    this.required = true,
    this.hintText,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.onSecondary;
    final focusedBorderColor = AppColor.adaptivePrimaryColor(context);
    
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
                  color: _isFocused ? focusedBorderColor : borderColor,
                ),
              ),
              if (widget.required)
                Text(
                  " *",
                  style: DestopAppStyle.normalText.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          const Gap(6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: focusedBorderColor.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              obscureText: _obscureText,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: DestopAppStyle.normalText.copyWith(
                  color: borderColor.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                  color: _isFocused ? focusedBorderColor : borderColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    width: 1,
                    color: borderColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    width: 1,
                    color: borderColor.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    width: 1.5,
                    color: focusedBorderColor,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: _toggleVisibility,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      key: ValueKey(_obscureText),
                      size: 20,
                    ),
                  ),
                ),
                suffixIconColor: _isFocused 
                    ? focusedBorderColor 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                fillColor: Theme.of(context).colorScheme.surface,
                filled: true,
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
