import 'package:flutter/material.dart';
import 'package:frontend/app/responsitvity/responsivity.dart';
import 'package:frontend/style/app_color.dart';

class ResponsiveCard extends StatelessWidget {
  final String label;
  final double width;
  final IconData iconData;
  final Color? color;
  const ResponsiveCard({
    super.key,
    required this.label,
    this.width = 250,
    this.iconData = Icons.settings,
      this.color = AppColor.whiteColor
  });

  bool isMobile(BuildContext context) {
    return Responsive.isMobile(context);
  }

  @override
  Widget build(BuildContext context) {
    return isMobile(context)
        ? SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 1,
              color: color,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(label),
              ),
            ),
          )
        : SizedBox(
            width: width,
            child: Card(
              color: color,
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        iconData,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
