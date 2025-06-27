import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import '../style/app_style.dart';

class SideBarTile extends StatelessWidget {
  final String label;
  final String assetName;
  final bool isSelected;
  final VoidCallback onTap;

  const SideBarTile({
    super.key,
    required this.label,
    required this.assetName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 210,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: SvgPicture.asset(
                assetName,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const Gap(8),
            Text(
              label,
              overflow: TextOverflow.clip,
              maxLines: 1,
              style: isSelected
                  ? DestopAppStyle.normalSemiBoldText.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : DestopAppStyle.normalText.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
