import 'package:flutter/material.dart';
 import 'app_menu_popup.dart';

class TableBodyLast extends StatefulWidget {
  final List<({String label, VoidCallback onTap, Color? color})> items;

  const TableBodyLast({
    super.key,
    required this.items,
  });

  @override
  State<TableBodyLast> createState() => _TableBodyLastState();
}

class _TableBodyLastState extends State<TableBodyLast> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12).copyWith(left: 8),
      child: CustomPopupMenu(
        onSelected: (value) {
          final index = widget.items.indexWhere((item) => item.label == value);
          if (index != -1) {
            widget.items[index].onTap();
          }
        },
        items: widget.items
            .map((item) =>
                (
                  value: item.label,
                  color: item.color ?? Theme.of(context).colorScheme.onSurface
                ))
            .toList(),
        tooltip: "Actions",
        child: const Icon(Icons.more_vert),
      ),
    );
  }
}
