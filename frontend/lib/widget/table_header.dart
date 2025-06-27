import 'package:flutter/material.dart';
import 'table_header_cell.dart';

TableRow tableHeader(BuildContext context,
    {required List<String> tablesTitles}) {
  return TableRow(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.2),
    ),
    children: tablesTitles.map(
      (value) => TableHeaderCell(
          title: value,
        ),
    ).toList(),
  );
}
