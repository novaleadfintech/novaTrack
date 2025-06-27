import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../main.dart';
import '../style/app_color.dart';
import 'package:gap/gap.dart';

import '../helper/assets/asset_icon.dart';

Future<bool?> showConfirmationDialog(
 {
  required String title,
  required String content,
  Color? confirmButtonColor,
}) {
  final context = navigatorKey.currentContext;

  return showDialog<bool>(
    context: context!,
    barrierDismissible: false,
    builder: (
      BuildContext context,
    ) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        content: IntrinsicHeight(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              children: [
                SvgPicture.asset(
                  AssetsIcons.question,
                  height: 40,
                ),
                const Gap(16),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Non',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                confirmButtonColor ?? AppColor.redColor,
              ),
            ),
            child: const Text(
              'Oui',
              style: TextStyle(color: AppColor.whiteColor),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

Future<bool> handleOperationButtonPress(
  BuildContext context, {
  required String content,
  Color? confirmButtonColor,
}) async {
  final confirmed = await showConfirmationDialog(
    title: 'Confirmer l\'action',
    content: content,
    confirmButtonColor: confirmButtonColor,
  );
  return confirmed == true;
}
