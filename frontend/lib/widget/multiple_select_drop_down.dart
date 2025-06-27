import 'package:flutter/material.dart';
import 'package:frontend/style/app_color.dart';
import 'package:gap/gap.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../style/app_style.dart';

class DefaultMultipleDropdownField<T extends Object> extends StatefulWidget {
  final String labelText;
  final bool enableSearch;
  final bool singleSelect;
  final String? hintText;
  final Function(List<T>)? onSelectionChange;
  final int maxItems;
  final Future<List<DropdownItem<T>>> futureItems;
  final MultiSelectController<T>? controller;
  final bool required;

  const DefaultMultipleDropdownField({
    super.key,
    required this.labelText,
    required this.onSelectionChange,
    required this.futureItems,
    this.enableSearch = false,
    this.hintText,
    this.maxItems = 5,
    this.controller,
    this.singleSelect = false,
    this.required = true,
  });

  @override
  State<DefaultMultipleDropdownField<T>> createState() =>
      _DefaultMultipleDropdownFieldState<T>();
}

class _DefaultMultipleDropdownFieldState<T extends Object>
    extends State<DefaultMultipleDropdownField<T>> {
  bool isLoading = true;
  String? errorMessage;
  List<DropdownItem<T>> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedItems = await widget.futureItems;
      setState(() {
        items = fetchedItems;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.labelText,
                style: DestopAppStyle.fieldTitlesStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              if (widget.required)
                Text(
                  "*",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          const Gap(4),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (errorMessage != null)
            Center(
              child: Text(
                "Erreur : $errorMessage",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            )
          else if (items.isEmpty)
            const Center(
              child: Text(
                "Aucune donnée disponible",
                style: TextStyle(color: AppColor.popGrey),
              ),
            )
          else
            MultiDropdown<T>(
              itemBuilder: (item, index, onTap) {
                return ListTile(
                  title: Text(item.label.toString()),
                  trailing: item.selected
                      ? Icon(
                          Icons.check_box,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(Icons.check_box_outline_blank),
                  onTap: onTap,
                );
              },
              singleSelect: widget.singleSelect,
              onSelectionChange: (selectedItems) {
                widget.onSelectionChange?.call(selectedItems);
              },
              maxSelections: widget.maxItems,
              items: items,
              controller: widget.controller,
              enabled: true,
              searchEnabled: widget.enableSearch,
              chipDecoration: ChipDecoration(
                backgroundColor: Theme.of(context).colorScheme.surface,
                wrap: true,
                runSpacing: 2,
                spacing: 10,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              fieldDecoration: FieldDecoration(
                hintText: widget.hintText ?? 'Sélectionnez une option',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
                borderRadius: 6,
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    strokeAlign: BorderSide.strokeAlignInside,
                    width: 0.5,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    strokeAlign: BorderSide.strokeAlignInside,
                    width: 0.5,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
              dropdownDecoration: const DropdownDecoration(
                marginTop: 2,
                header: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Sélectionnez des options dans la liste',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                ),
              ),
              dropdownItemDecoration: DropdownItemDecoration(
                selectedIcon: const Icon(
                  Icons.check_box,
                  color: AppColor.primaryColor,
                ),
                disabledIcon: Icon(
                  Icons.lock,
                  color: Colors.grey.shade300,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner une option';
                }
                return null;
              },
            ),
        ],
      ),
    );
  }
}
