import 'package:flutter/material.dart';
import 'package:frontend/style/app_color.dart';
import 'app_menu_popup.dart';

class TableBodyLast extends StatelessWidget {
  final List<({String label, VoidCallback onTap, Color? color})> items;

  const TableBodyLast({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12).copyWith(left: 8),
      child: CustomPopupMenu(
        onSelected: (value) {
          final index = items.indexWhere((item) => item.label == value);
          if (index != -1) {
            items[index].onTap();
          }
        },
        items: items
            .map((item) =>
                (value: item.label, color: item.color ?? AppColor.blackColor))
            .toList(),
        tooltip: "Actions",
        child: const Icon(Icons.more_vert),
      ),
    );
  }
}
