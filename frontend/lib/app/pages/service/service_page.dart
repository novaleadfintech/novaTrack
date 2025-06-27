import 'package:flutter/material.dart';

import 'archived_service.dart';
import '../../../model/service/enum_service.dart';
import '../app_tab_bar.dart';
import 'unarchived_service_page.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});
  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
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
                EtatService.unarchived.label,
                EtatService.archived.label,
              ],
              views: const [
                UnarchivedServicePage(),
                ArchivedServicePage(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
