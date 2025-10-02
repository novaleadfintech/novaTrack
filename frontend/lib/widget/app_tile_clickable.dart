import 'package:flutter/material.dart';

class AppTileClickable extends StatelessWidget {
  final String tileTitle;
  final VoidCallback onClick;
  const AppTileClickable({
    super.key,
    required this.tileTitle,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
       child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: DefaultSelectionStyle.defaultColor))),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                tileTitle,
                textAlign: TextAlign.start,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: DefaultSelectionStyle.defaultColor,
            )
          ],
        ),
      ),
    );
  }
}
