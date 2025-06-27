import 'package:flutter/material.dart';
import 'side_bar_tile.dart';

class MenuTile extends StatelessWidget {
  final Function(int) getcurrentIndex;
  final List<(String, String, int)> menu;
  final int currentIndex;
  const MenuTile({
    super.key,
    required this.currentIndex,
    required this.menu,
    required this.getcurrentIndex,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: menu
                .map(
                  (e) => SideBarTile(
                    label: e.$1,
                    assetName: e.$2,
                    isSelected: currentIndex == e.$3,
                    onTap: () {
                      getcurrentIndex(e.$3);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
