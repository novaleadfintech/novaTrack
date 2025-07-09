import 'package:flutter/material.dart';
 import '../responsitvity/responsivity.dart';

class AppTabBar extends StatefulWidget {
  final List<String> tabTitles;
  final List<Widget> views;

  const AppTabBar({
    super.key,
    required this.tabTitles,
    required this.views,
  }) : assert(tabTitles.length == views.length,
            'The number of tab titles must match the number of views.');

  @override
  State<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      animationDuration: Duration(microseconds: 0),
      length: widget.tabTitles.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              enableFeedback: true,
              indicatorPadding: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              automaticIndicatorColorAdjustment: true,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabAlignment: TabAlignment.center,
              tabs: widget.tabTitles.map((title) {
                return Tab(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: Responsive.isMobile(context) ? 4 : 16,
                      right: Responsive.isMobile(context) ? 8 : 24,
                    ),
                    child: Text(
                      title,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: widget.views,
            ),
          ),
        ],
      ),
    );
  }
}
