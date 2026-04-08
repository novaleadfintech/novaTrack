import 'package:flutter/material.dart';

import '../style/app_color.dart';

class ShowInformation extends StatelessWidget {
  final String libelle;
  final String content;
  const ShowInformation({super.key, required this.content, required this.libelle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        color: AppColor.greenSecondary,
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(libelle),
            Text(content),
          ],
        ),
      ),
    );
  }
}


class ShowNotificationInformation extends StatelessWidget {
  final String message;
  const ShowNotificationInformation({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        color: AppColor.primaryColor.withValues(alpha: 0.1),
        padding: EdgeInsets.all(8),
        child: Align(alignment: Alignment.center, child: Text(message)),
      ),
    );
  }
}

class ShowInstruction extends StatelessWidget {
  final String message;
  const ShowInstruction({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: IntrinsicWidth(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.bmodificationColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border(
              bottom: BorderSide(color: AppColor.bmodificationColor, width: 1),
              left: BorderSide(color: AppColor.bmodificationColor, width: 1),
            ),
          ),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: TextStyle(
                    color: AppColor.informationColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              )),
        ),
      ),
    );
  }
}
