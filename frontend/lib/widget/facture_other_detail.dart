import 'package:flutter/material.dart';

import 'table_body_middle.dart';

TableRow factureOtherDelailTableRow({
  required int emptyCells,
  required Decoration decoration,
  required (
    String,
    String,
  ) value,
}) {
  return TableRow(
    decoration: decoration,
    children: [
      ...List.generate(
        emptyCells,
        (index) => const TableBodyMiddle(
          valeur: "",
        ),
      ),
      TableBodyMiddle(
        valeur: value.$1,
      ),
      TableBodyMiddle(
        valeur: value.$2,
      ),
    ],
  );
}
