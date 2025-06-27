import 'package:custom_dropdown_search/custom_dropdown_search.dart';
import 'package:flutter/material.dart';
import '../style/app_color.dart';
import '../style/app_style.dart';
import 'package:gap/gap.dart';

class CustomDropDownField<T> extends StatelessWidget {
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

  const CustomDropDownField({
    super.key,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    this.itemsAsString,
    required this.label,
    this.borderColor = AppColor.popGrey,
    this.borderWidth = 0.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.required = true,
    this.filter = false,
    this.canClose = true,
  });

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
                label,
                textAlign: TextAlign.left,
                style: DestopAppStyle.fieldTitlesStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              if (required)
                Text(
                  "*",
                  style: DestopAppStyle.fieldTitlesStyle.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          const Gap(4),
          SizedBox(
            height: 40,
            child: DropdownSearch<T>(
              clearButtonProps: ClearButtonProps(isVisible: !required),
              popupProps: PopupProps.menu(
                showSelectedItems: true,
                showSearchBox: filter,
                searchFieldProps: const TextFieldProps(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.search,
                    ),
                    prefixIconColor: AppColor.popGrey,
                  ),
                ),
                emptyBuilder: (context, _) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Aucune donnée disponible.",
                      style: TextStyle(color: AppColor.popGrey),
                    ),
                  ),
                ),
              ),
              items: items,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.popGrey, width: 0.5),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.popGrey, width: 0.5),
                  ),
                  contentPadding: padding,
                ),
              ),
              onChanged: (value) {
                onChanged(value);
              },
              selectedItem: selectedItem,
              itemAsString: itemsAsString,
              compareFn: (T? item, T? selectedItem) {
                return item == selectedItem;
              },
              filterFn: filter
                  ? (T item, String researsh) {
                      final itemString = itemsAsString?.call(item) ?? '';
                      return itemString
                          .toLowerCase()
                          .contains(researsh.toLowerCase());
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
