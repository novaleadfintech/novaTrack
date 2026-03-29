import 'package:flutter/material.dart';
import '../style/app_color.dart';
import '../style/app_style.dart';

class ResearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;

  const ResearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  State<ResearchBar> createState() => _ResearchBarState();
}

class _ResearchBarState extends State<ResearchBar> {
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

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.onSecondary;
    final focusedBorderColor = AppColor.adaptivePrimaryColor(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 280,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
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
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintMaxLines: 1,
            hintStyle: DestopAppStyle.normalText.copyWith(
              color: borderColor.withValues(alpha: 0.6),
            ),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                color: borderColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                color: focusedBorderColor,
                width: 1.5,
              ),
            ),
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.search_rounded,
                color: _isFocused ? focusedBorderColor : borderColor,
                size: 20,
              ),
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: borderColor,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                      setState(() {});
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
          style: DestopAppStyle.normalText.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
