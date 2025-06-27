import 'package:flutter/material.dart';

import '../main.dart';
import '../style/app_style.dart';
import 'table_body_middle.dart';

TableRow buildTableRow(
  String title,
  String value,
) {
  final context = navigatorKey.currentContext;
  return TableRow(
    decoration: tableDecoration(context!),
    children: [
      TabledetailBodyMiddle(
        valeur: title,
        isbold: true,
      ),
      TabledetailBodyMiddle(
        valeur: value,
      ),
    ],
  );
}
