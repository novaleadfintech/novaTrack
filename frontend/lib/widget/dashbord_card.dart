import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF858C94).withOpacity(0.1),
                child: SvgPicture.asset(
                  icon,
                  height: 16,
                  width: 16,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                ),
              ),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF6F767E),
                      fontWeight: FontWeight.w600,
                    ),
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
                        return Text(
                          snapshot.data!,
                          style: DestopAppStyle.simpleBoldText,
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
            ],
          ),
        ],
      ),
    );
  }
}
