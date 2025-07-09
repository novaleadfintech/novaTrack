import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:gap/gap.dart';

import '../../helper/assets/asset_icon.dart';
import '../../style/app_style.dart';
import '../responsitvity/responsivity.dart';

class ErrorPage extends StatelessWidget {
  final String message;
  final VoidCallback onPressed;

  const ErrorPage({
    super.key,
    required this.message,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
           
            AssetsIcons.error,
            width: Responsive.isMobile(context) ? 75 : 120,
          ),
          const Gap(8),
          Column(
            children: [
              Text(
                message,
                style: DestopAppStyle.normalSemiBoldText.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              ElevatedButton.icon(
                onPressed: onPressed,
                icon: SvgPicture.asset(
                  AssetsIcons.refresh,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                  //width: Responsive.isMobile(context) ? 75 : 120,
                ),
                label: const Text(
                  textAlign: TextAlign.center,

                  "Actualisez",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
