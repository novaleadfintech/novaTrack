import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../style/app_color.dart';
import '../../style/app_style.dart';
import '../responsitvity/responsivity.dart';

class CustomPopPop extends StatelessWidget {
  final Widget content;
  final VoidCallback onClose;
  final String title;
  final double mobileWidthFactor;
  final double tabletWidthFactor;
  final double destopWidthFactor;

  const CustomPopPop({
    super.key,
    required this.content,
    required this.onClose,
    required this.title,
    required this.mobileWidthFactor,
    required this.tabletWidthFactor,
    required this.destopWidthFactor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobile(context);

        return Dialog(
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          insetPadding: isMobile
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 300.0, vertical: 50.0),
          child: IntrinsicWidth(
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: DestopAppStyle.titleText.copyWith(
                              fontSize: 16.0,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 20.0,
                          hoverColor:
                              Theme.of(context).colorScheme.surfaceBright,
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                    const Gap(4),
                    const Divider(
                      color: AppColor.popGrey,
                      height: 1,
                    ),
                    const Gap(4),
                    Flexible(
                      child: SingleChildScrollView(
                        child: content,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Exemple d'utilisation
void showCustomPoppup(
  BuildContext context, {
  required Widget content,
  required String title,
  double mobileWidthFactor = 0.8,
  double tabletWidthFactor = 0.7,
  double destopWidthFactor = 0.5,
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => CustomPopPop(
      onClose: () {
        Navigator.of(context).pop();
      },
      title: title,
      content: content,
      destopWidthFactor: destopWidthFactor,
      mobileWidthFactor: mobileWidthFactor,
      tabletWidthFactor: tabletWidthFactor,
    ),
  );
}
