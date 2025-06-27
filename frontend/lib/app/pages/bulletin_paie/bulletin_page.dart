import 'package:flutter/material.dart';
import '../app_tab_bar.dart';
import 'archive/archive_bulletin_page.dart';
import 'bulletin/bulletin_page.dart';
import 'decouverte/decouverte_page.dart';
import 'salarie/salaire_page.dart';

class BulletinLayout extends StatelessWidget {
  const BulletinLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 0,
        left: 8,
        right: 8,
      ),
      child: Column(
        children: [
          Expanded(
            child: AppTabBar(
              tabTitles: [
                "Salarié",
                "Bulletin",
                "Découvert",
                "Archives",
              ],
              views: const [
                SalariePage(),
                BulletinPage(),
                DecouvertePage(),
                ArchiveBulletinPage(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
