import 'package:flutter/material.dart';
import 'package:frontend/app/pages/creance/creance_to_be_pay.dart';
import 'package:frontend/app/pages/creance/unpaid_creance_page.dart';

import '../app_tab_bar.dart';

class CreancePage extends StatefulWidget {
  const CreancePage({super.key});

  @override
  State<CreancePage> createState() => _CreancePageState();
}

class _CreancePageState extends State<CreancePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        8,
      ),
      child: Column(
        children: [
          Expanded(
            child: AppTabBar(
              tabTitles: ["Impayées", "A payer"],
              views: const [UnpaidCreancePage(), CreanceToBePayPage()],
            ),
          )
        ],
      ),
    );
  }
}
