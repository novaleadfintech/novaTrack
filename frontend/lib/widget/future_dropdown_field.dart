import 'package:custom_dropdown_search/custom_dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../helper/assets/asset_icon.dart';
import '../style/app_color.dart';
import '../style/app_style.dart';
import 'package:gap/gap.dart';

class FutureCustomDropDownField<T> extends StatefulWidget {
  final String label;
  final T? selectedItem;
  final Future<List<T>> Function() fetchItems;
  final void Function(T?) onChanged;
  final String Function(T) itemsAsString;
  final bool canClose;
  final bool required;
  final bool showSearchBox;
  final String? hintText;
  final IconData? prefixIcon;

  const FutureCustomDropDownField({
    super.key,
    required this.label,
    required this.selectedItem,
    required this.fetchItems,
    this.canClose = false,
    this.required = true,
    this.showSearchBox = false,
    required this.onChanged,
    required this.itemsAsString,
    this.hintText,
    this.prefixIcon,
  });

  @override
  State<FutureCustomDropDownField<T>> createState() =>
      _CustomDropDownFieldState<T>();
}

class _CustomDropDownFieldState<T> extends State<FutureCustomDropDownField<T>> {
  List<T> items = [];
  bool isLoading = true;
  bool hasError = false;
  bool _isOpen = false;
  Key dropdownKey = UniqueKey();

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final data = await widget.fetchItems();

      setState(() {
        items = data;
        isLoading = false;
        dropdownKey = UniqueKey();
      });
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.onSecondary;
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
                  color: _isOpen ? focusedBorderColor : borderColor,
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
            ),
            child: DropdownSearch<T>(
              key: dropdownKey,
              clearButtonProps: ClearButtonProps(
                isVisible: widget.canClose && widget.selectedItem != null,
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              dropdownBuilder: (context, selectedItem) {
                return Container(
                  constraints: const BoxConstraints(minWidth: 100),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.prefixIcon != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            widget.prefixIcon,
                            size: 20,
                            color: _isOpen ? focusedBorderColor : borderColor,
                          ),
                        ),
                      if (selectedItem != null)
                        Flexible(
                          child: Text(
                            widget.itemsAsString(selectedItem),
                            style: DestopAppStyle.normalText.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        Text(
                          widget.hintText ?? "Sélectionner",
                          style: DestopAppStyle.normalText.copyWith(
                            color: borderColor.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                );
              },
              dropdownButtonProps: DropdownButtonProps(
                icon: AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _isOpen ? focusedBorderColor : borderColor,
                  ),
                ),
              ),
              popupProps: PopupProps.menu(
                menuProps: MenuProps(
                  borderRadius: BorderRadius.circular(12),
                  elevation: 8,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
                onDismissed: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _isOpen = false;
                  });
                },
                showSelectedItems: true,
                showSearchBox: widget.showSearchBox,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Rechercher...",
                    hintStyle: DestopAppStyle.normalText.copyWith(
                      color: borderColor.withValues(alpha: 0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: borderColor.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: borderColor.withValues(alpha: 0.3),
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
                      color: borderColor,
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
                    child: Row(
                      children: [
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: focusedBorderColor,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            widget.itemsAsString(item),
                            style: DestopAppStyle.normalText.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                errorBuilder: (context, searchEntry, exception) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 40,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const Gap(8),
                          Text(
                            "Erreur de chargement",
                            style: DestopAppStyle.normalText.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const Gap(12),
                          TextButton.icon(
                            icon: SvgPicture.asset(
                              AssetsIcons.refresh,
                              width: 16,
                              height: 16,
                            ),
                            label: const Text("Réessayer"),
                            onPressed: () async {
                              await _loadData();
                              if (mounted) setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                emptyBuilder: (context, searchEntry) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 40,
                            color: borderColor.withValues(alpha: 0.5),
                          ),
                          const Gap(8),
                          Text(
                            "Aucune donnée",
                            style: DestopAppStyle.normalText.copyWith(
                              color: borderColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              asyncItems: (String filter) async {
                if (!mounted) return [];
                setState(() {
                  isLoading = true;
                });
                final data = await widget.fetchItems();
                if (!mounted) return [];
                setState(() {
                  items = data;
                  isLoading = false;
                });
                return items;
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                baseStyle: DestopAppStyle.normalText.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: borderColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: focusedBorderColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              onBeforePopupOpening: (selectedItem) async {
                setState(() => _isOpen = true);
                return true;
              },
              onChanged: (T? newValue) {
                widget.onChanged(newValue);
              },
              selectedItem: widget.selectedItem,
              itemAsString: widget.itemsAsString,
              compareFn: (T? item, T? selectedItem) => item == selectedItem,
            ),
          ),
        ],
      ),
    );
  }
}
