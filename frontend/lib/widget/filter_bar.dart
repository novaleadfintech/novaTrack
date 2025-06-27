import 'package:flutter/material.dart';
import '../app/responsitvity/responsivity.dart';
import '../style/app_style.dart';
import 'app_menu_popup.dart';
import 'package:gap/gap.dart';

class FilterBar extends StatelessWidget {
  final String label;
  final Function(String) onSelected;
  final List<String> items;

  const FilterBar({
    super.key,
    required this.onSelected,
    required this.items,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      tooltip: "Filtrer",
      onSelected: onSelected,
items: items.map((toElement) => (value: toElement, color: null)).toList(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: const Color(0xFFDADCE0), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (Responsive.isDesktop(context) ||
                Responsive.isTablet(context)) ...[
              Text(
                label,
                style: DestopAppStyle.normalSemiBoldText.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const Gap(4),
            ],
            Icon(
              Icons.expand_more,
              color: Theme.of(context).colorScheme.secondary,
            )
         ],
        ),
      ),
    );
  }
}
