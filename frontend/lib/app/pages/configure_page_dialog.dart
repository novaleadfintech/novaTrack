import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../style/app_color.dart';
import '../../style/app_style.dart';
import '../responsitvity/responsivity.dart';

class ResponsiveConfigPageDialogBox extends StatelessWidget {
  final Widget content;
  final VoidCallback onClose;
  final String title;
  final double widthFactor;
  final bool canClose;
  final double maxHeightFactor;

  const ResponsiveConfigPageDialogBox({
    super.key,
    required this.content,
    required this.onClose,
    required this.title,
    this.canClose = true,
    this.widthFactor = 0.7,
    required this.maxHeightFactor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = Responsive.isMobile(context);
        final bool isTablet = Responsive.isMobile(context);

        final double maxHeight = constraints.maxHeight * maxHeightFactor;

        return isMobile
            ? GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight,
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        color: AppColor.whiteColor,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // correct
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: DestopAppStyle.titleText.copyWith(
                                        fontSize: 16.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                  if (canClose)
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
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
                                child: content,
                              ),
                            ],
                          ),
                        ),
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
                insetPadding: const EdgeInsets.symmetric(
                    horizontal: 50.0, vertical: 50.0),
                child: SizedBox(
                  width: isTablet
                      ? constraints.maxWidth * 0.8
                      : constraints.maxWidth * widthFactor,
                  height: isMobile ? constraints.maxHeight : null,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                              if (canClose)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1),
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
                            child: content,
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
void showResponsiveConfigPageDialogBox(
  BuildContext context, {
  required Widget content,
  required String title,
  bool canClose = true,
  double maxHeightFactor = 0.95,
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => ResponsiveConfigPageDialogBox(
      onClose: () {
        Navigator.of(context).pop();
      },
      canClose: canClose,
      title: title,
      content: content,
      maxHeightFactor: maxHeightFactor,
    ),
  );
}
