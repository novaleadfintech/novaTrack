import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../helper/assets/asset_icon.dart';
import 'table_header_cell.dart';

TableRow subTableHeader(
  BuildContext context, {
  required List<String> tablesTitles,
  required Function()? onTap,
  bool hideButton = false,
}) {
  return TableRow(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.075),
    ),
    children: [
      ...tablesTitles.map(
        (value) {
          return TableHeaderCell(title: value);
        },
      ),
      //if (!Responsive.isMobile(context))
      if (!hideButton)
        IconButton(
          onPressed: onTap,
          icon: SvgPicture.asset(
            AssetsIcons.simpleAdd,
          ),
        )
      else
        Container(),
    ],
  );
}
