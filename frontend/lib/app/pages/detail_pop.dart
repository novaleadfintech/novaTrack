import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../style/app_color.dart';
import '../../style/app_style.dart';
import '../responsitvity/responsivity.dart';


class DetailDialogBox extends StatelessWidget {
  final Widget content;
  final VoidCallback onClose;
  final String title;
  final double widthFactor;

  const DetailDialogBox({
    super.key,
    required this.content,
    required this.onClose,
    required this.title,
    required this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobile(context);
        final isTablet = Responsive.isTablet(context);

        return isMobile
            ? Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                body: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColor.primaryColor,
                        width: 8,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: isMobile
                          ? constraints.maxWidth
                          : isTablet
                              ? constraints.maxWidth * 0.8
                              : constraints.maxWidth * widthFactor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: DestopAppStyle.titleText.copyWith(
                                  fontSize: 16.0,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1),
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  iconSize: 20.0,
                                  icon: Icon(
                                    Icons.close,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  onPressed: onClose,
                                ),
                              ),
                            ],
                          ),
                          const Gap(4),
                          const Divider(
                            color: AppColor.popGrey,
                            height: 1,
                          ),
                          const Gap(4),
                          Expanded(
                            child: SingleChildScrollView(
                              child: content,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Dialog(
                surfaceTintColor: Theme.of(context).colorScheme.surface,
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                insetPadding: isMobile
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 50.0),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColor.primaryColor,
                        width: 8,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: isMobile
                          ? constraints.maxWidth
                          : isTablet
                              ? constraints.maxWidth * 0.8
                              : constraints.maxWidth * widthFactor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: DestopAppStyle.titleText.copyWith(
                                  fontSize: 16.0,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1),
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  iconSize: 20.0,
                                  icon: Icon(
                                    Icons.close,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  onPressed: onClose,
                                ),
                              ),
                            ],
                          ),
                          const Gap(4),
                          const Divider(
                            color: AppColor.popGrey,
                            height: 1,
                          ),
                          const Gap(4),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  content,
                                ],
                              ),
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

void showDetailDialog(
  BuildContext context, {
  required Widget content,
  required String title,
  double widthFactor = 0.6,
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => DetailDialogBox(
      onClose: () {
        Navigator.of(context).pop();
      },
      title: title,
      content: content,
      widthFactor: widthFactor,
    ),
  );
}