import 'package:custom_dropdown_search/custom_dropdown_search.dart';
import 'package:flutter/material.dart';
import '../style/app_color.dart';
import '../style/app_style.dart';
import 'package:gap/gap.dart';

class CustomDropDownField<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final Function(T?) onChanged;
  final String Function(T)? itemsAsString;
  final String label;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;
  final bool required;
  final bool filter;
  final bool canClose;
  final String? hintText;
  final IconData? prefixIcon;

  const CustomDropDownField({
    super.key,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    this.itemsAsString,
    required this.label,
    this.borderColor,
    this.borderWidth = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    this.required = true,
    this.filter = false,
    this.canClose = true,
    this.hintText,
    this.prefixIcon,
  });

  @override
  State<CustomDropDownField<T>> createState() => _CustomDropDownFieldState<T>();
}

class _CustomDropDownFieldState<T> extends State<CustomDropDownField<T>> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final defaultBorderColor =
        widget.borderColor ?? Theme.of(context).colorScheme.onSecondary;
    final focusedBorderColor = AppColor.adaptivePrimaryColor(context);
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.label,
                textAlign: TextAlign.left,
                style: DestopAppStyle.fieldTitlesStyle.copyWith(
                  color: _isOpen ? focusedBorderColor : defaultBorderColor,
                ),
              ),
              if (widget.required)
                Text(
                  " *",
                  style: DestopAppStyle.fieldTitlesStyle.copyWith(
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
            ),
            child: DropdownSearch<T>(
              clearButtonProps: ClearButtonProps(
                isVisible: !widget.required && widget.selectedItem != null,
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              popupProps: PopupProps.menu(
                showSelectedItems: true,
                showSearchBox: widget.filter,
                menuProps: MenuProps(
                  borderRadius: BorderRadius.circular(12),
                  elevation: 8,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
                onDismissed: () {
                  setState(() {
                    _isOpen = false;
                  });
                },
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Rechercher...",
                    hintStyle: DestopAppStyle.normalText.copyWith(
                      color: defaultBorderColor.withValues(alpha: 0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: defaultBorderColor.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: defaultBorderColor.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: focusedBorderColor,
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: defaultBorderColor,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                itemBuilder: (context, item, isSelected) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? focusedBorderColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: Text(
                      widget.itemsAsString?.call(item) ?? item.toString(),
                      style: DestopAppStyle.normalText.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                },
                emptyBuilder: (context, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 40,
                          color: defaultBorderColor.withValues(alpha: 0.5),
                        ),
                        const Gap(8),
                        Text(
                          "Aucune donnée disponible",
                          style: DestopAppStyle.normalText.copyWith(
                            color: defaultBorderColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              dropdownButtonProps: DropdownButtonProps(
                icon: AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _isOpen ? focusedBorderColor : defaultBorderColor,
                  ),
                ),
              ),
              items: widget.items,
              dropdownDecoratorProps: DropDownDecoratorProps(
                baseStyle: DestopAppStyle.normalText.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                dropdownSearchDecoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: DestopAppStyle.normalText.copyWith(
                    color: defaultBorderColor.withValues(alpha: 0.6),
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          size: 20,
                          color:
                              _isOpen ? focusedBorderColor : defaultBorderColor,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: defaultBorderColor,
                      width: widget.borderWidth!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: defaultBorderColor.withValues(alpha: 0.5),
                      width: widget.borderWidth!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: focusedBorderColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: widget.padding,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              onBeforePopupOpening: (selectedItem) async {
                setState(() => _isOpen = true);
                return true;
              },
              
              onChanged: (value) {
                widget.onChanged(value);
              },
              selectedItem: widget.selectedItem,
              itemAsString: widget.itemsAsString,
              compareFn: (T? item, T? selectedItem) {
                return item == selectedItem;
              },
              filterFn: widget.filter
                  ? (T item, String research) {
                      final itemString = widget.itemsAsString?.call(item) ?? '';
                      return itemString
                          .toLowerCase()
                          .contains(research.toLowerCase());
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
