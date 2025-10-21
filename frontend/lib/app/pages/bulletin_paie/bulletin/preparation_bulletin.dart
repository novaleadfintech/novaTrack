import 'package:flutter/material.dart';
import 'package:frontend/app/pages/no_data_page.dart';
import 'package:frontend/widget/app_action_button.dart';
import 'package:gap/gap.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../../../../model/bulletin_paie/bulletin_model.dart';
import '../../../../service/bulletin_service.dart';
import '../../../../widget/confirmation_dialog_box.dart';
import '../../../../widget/research_bar.dart';

class PreparationBulletinPage extends StatefulWidget {
  const PreparationBulletinPage({super.key});

  @override
  State<PreparationBulletinPage> createState() =>
      _PreparationBulletinPagState();
}

class _PreparationBulletinPagState extends State<PreparationBulletinPage> {
  final TextEditingController _researchController = TextEditingController();
  late SimpleFontelicoProgressDialog _dialog;

  // Future<List<BulletinPaieModel>> _loadBulletinData() async {
  //   try {
  //     return await BulletinService.getCurrentBulletins();
  //   } catch (error) {
  //     throw error.toString();
  //   }
  // }

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          ResearchBar(
            hintText: "Rechercher par N° matricule...",
            controller: _researchController,
          ),
        ],
      ),
      Gap(16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NoDataPage(
              data: [],
              message: "Aucun bulletin de paie à préparer pour le moment.",
            ),
            Gap(8),
            AppActionButton(
              onPressed: () {
                preparerBulletin();
              },
              child: Text(
                "Commencez par preparer les bulletins",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            )
          ],
        ),
      ),
    ]);
  }

  void preparerBulletin() async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content: "Vous êtes sur le point de préparer le bulletin du mois courant",
    );
    if (confirmed) {
      _dialog.show(
        message: 'Edition du bulletin en cours',
        type: SimpleFontelicoProgressDialogType.bullets,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary,
        width: 250,
      );
      Future.delayed(Duration(seconds: 5), () async {
        _dialog.hide();
      });
    }
  }
}
