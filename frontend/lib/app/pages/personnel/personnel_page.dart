import 'package:flutter/material.dart';
import 'package:frontend/model/personnel/enum_personnel.dart';
import '../app_tab_bar.dart';
import 'archived_personnel_page.dart';
import 'unarchived_personnel_page.dart';

class PersonnelPage extends StatefulWidget {
  const PersonnelPage({super.key});

  @override
  State<PersonnelPage> createState() => _PersonnelPageState();
}

class _PersonnelPageState extends State<PersonnelPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 0, left: 8, right: 8),
      child: Column(
        children: [
          Expanded(
            child: AppTabBar(
              tabTitles: [
                EtatPersonnel.unarchived.label,
                EtatPersonnel.archived.label,
              ],
              views: const [
                UnarchivedPersonnelPage(),
                ArchivedPersonnelPage(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
