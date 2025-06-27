import 'package:flutter/material.dart';

class TableHeaderCell extends StatelessWidget {
  const TableHeaderCell({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12)
            .copyWith(right: 12, left: 8),
        child: Row(
          children: [
            Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              title,
              style: TextStyle(
                fontSize: 14,
                fontFamily: "Inter",
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
