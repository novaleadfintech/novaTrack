import 'package:flutter/material.dart';
import '../style/app_style.dart';

class CustomPopupMenu extends StatelessWidget {
  final Function(String) onSelected;
  final Widget child;
  final List<({String value, Color? color})> items;
  final String tooltip;

  const CustomPopupMenu({
    super.key,
    required this.onSelected,
    required this.child,
    required this.items,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      tooltip: tooltip,
      itemBuilder: (BuildContext context) {
        return items.map<PopupMenuItem<String>>((item) {
          return PopupMenuItem<String>(
            value: item.value,
            child: Text(
              item.value,
              style: DestopAppStyle.normalText.copyWith(
                color: item.color 
              ),
            ),
          );
        }).toList();
      },
      child: child,
    );
  }
}
