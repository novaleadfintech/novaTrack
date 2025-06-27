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

  const FutureCustomDropDownField({
    super.key,
    required this.label,
    required this.selectedItem,
    required this.fetchItems,
    this.canClose = true,
    this.required = true,
    this.showSearchBox = false,
    required this.onChanged,
    required this.itemsAsString,
  });

  @override
  State<FutureCustomDropDownField<T>> createState() =>
      _CustomDropDownFieldState<T>();
}

class _CustomDropDownFieldState<T> extends State<FutureCustomDropDownField<T>> {
  List<T> items = [];
  bool isLoading = true;
  bool hasError = false;
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
          GestureDetector(
            // onTap: () {
            //   FocusScope.of(context).unfocus()
            // },
            child: SizedBox(
              height: 40,
              child: DropdownSearch<T>(
                key: dropdownKey,
                clearButtonProps: ClearButtonProps(isVisible: widget.canClose),
                dropdownBuilder: (context, selectedItem) {
                  return Container(
                    constraints: const BoxConstraints(
                      minWidth: 100,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedItem != null)
                          Flexible(
                            child: Text(
                              widget.itemsAsString(selectedItem),
                              style: DestopAppStyle.normalText,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const Text(
                            "Sélectionner",
                            style: TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  );
                },
                popupProps: PopupProps.menu(      
                  onDismissed: () {
                    FocusScope.of(context).unfocus();
                  },
                  showSelectedItems: true,
                  showSearchBox: widget.showSearchBox,
                  itemBuilder: (context, item, isSelected) {
                    return ListTile(
                      title: Text(widget.itemsAsString(item)),
                      trailing: isSelected
                          ? Icon(
                              Icons.circle_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    );
                  },
                  errorBuilder: (context, searchEntry, exception) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(exception.toString()),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton.filled(
                                icon: SvgPicture.asset(
                                  AssetsIcons.refresh,
                                ),
                                onPressed: () async {
                                  await _loadData();
                                  if (mounted) setState(() {});
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  emptyBuilder: (context, searchEntry) {
                    return const Center(
                      child: Text("Aucune donnée"),
                    );
                  },
                ),
                asyncItems: (String filter) async {
                  setState(() {
                    isLoading = true;
                  });
                  final data = await widget.fetchItems();
                  setState(() {
                    items = data;
                    isLoading = false;
                  });
                  return items;
                },
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColor.popGrey, width: 0.5),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColor.popGrey, width: 0.5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
                onChanged: (T? newValue) {
                  widget.onChanged(newValue);
                },
                selectedItem: widget.selectedItem,
                itemAsString: widget.itemsAsString,
                compareFn: (T? item, T? selectedItem) => item == selectedItem,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
