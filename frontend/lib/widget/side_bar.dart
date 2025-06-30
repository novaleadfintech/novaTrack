import 'package:flutter/material.dart';
import '../app/responsitvity/responsivity.dart';
import 'menu_tile.dart';
import 'package:gap/gap.dart';
import '../style/app_style.dart';

class SideBar extends StatelessWidget {
  final Function(int) getcurrentIndex;
  final int currentIndex;
  final bool? isMobile;
  final List<(String, String, int)> menu;

  const SideBar({
    super.key,
    this.isMobile = false,
    required this.getcurrentIndex,
    required this.currentIndex,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 2.0),
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        height: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: 18,
                  right: 0,
                  top: Responsive.isDesktop(context) ? 20 : 40,
                  bottom: 20,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo.jpg",
                      width: 28,
                      height: 33,
                    ),
                    const Gap(8),
                    const Text(
                      "Nova Lead",
                      style: DestopAppStyle.simpleBoldText,
                    )
                  ],
                ),
              ),
              MenuTile(
                isMobile: isMobile,
                currentIndex: currentIndex,
                menu: menu,
                getcurrentIndex: getcurrentIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
