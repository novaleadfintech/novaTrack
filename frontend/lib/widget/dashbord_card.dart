import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/responsitvity/responsivity.dart';
import 'package:frontend/widget/dot_animation.dart';
import '../style/app_style.dart';
import 'package:gap/gap.dart';

class DashboardInfo extends StatelessWidget {
  final String title;
  final String icon;
  final Future<String> futureValue;

  const DashboardInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.futureValue,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Container(
      margin: isMobile
          ? const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 16)
          : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF858C94).withValues(alpha: 0.1),
            child: SvgPicture.asset(
              icon,
              height: 18,
              width: 18,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6F767E),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const Gap(4),
                FutureBuilder<String>(
                  future: futureValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return DotLoading();
                    } else if (snapshot.hasError) {
                      return Text("!!!",
                          style: DestopAppStyle.normalText.copyWith(
                            color: Colors.red,
                          ));
                    } else if (snapshot.hasData) {
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          snapshot.data!,
                          style: DestopAppStyle.simpleBoldText,
                          maxLines: 1,
                        ),
                      );
                    } else {
                      return const Text(
                        '-- --',
                        style: DestopAppStyle.normalText,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
