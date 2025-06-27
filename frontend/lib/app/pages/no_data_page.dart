import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:gap/gap.dart';

import '../../helper/assets/asset_icon.dart';
import '../../style/app_style.dart';
import '../responsitvity/responsivity.dart';

class NoDataPage extends StatelessWidget {
  final List data;
  final String message;

  const NoDataPage({
    super.key,
    required this.data,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AssetsIcons.nodata,
            width: Responsive.isMobile(context) ? 75 : 120,
          ),
          const Gap(8),
          data.isEmpty
              ? Column(
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: DestopAppStyle.normalSemiBoldText.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                )
              : Text(
                  "Aucun résultat trouvé.",
                  textAlign: TextAlign.center,
                  style: DestopAppStyle.normalSemiBoldText.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                )
        ],
      ),
    );
  }
}
