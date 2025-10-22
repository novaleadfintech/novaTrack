import 'package:flutter/material.dart';
import 'package:frontend/app/integration/request_frot_behavior.dart';
import 'package:frontend/app/pages/no_data_page.dart';
import 'package:frontend/model/bulletin_paie/calendar_model.dart';
import 'package:frontend/service/bulletin_service.dart';
import 'package:frontend/service/pay_calendar_service.dart';
import 'package:frontend/widget/app_tile_clickable.dart';
import 'package:frontend/widget/confirmation_dialog_box.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class ChoosePeriodPage extends StatefulWidget {
  const ChoosePeriodPage({super.key});

  @override
  State<ChoosePeriodPage> createState() => _ChoosePeriodPageState();
}

class _ChoosePeriodPageState extends State<ChoosePeriodPage> {
  List<PayCalendarModel> payCalendarData = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    _dialog = SimpleFontelicoProgressDialog(context: context);

    super.initState();
    _loadPayCalendar();
  }

  Future<void> _loadPayCalendar() async {
    try {
      final data = await PayCalendarService.getPayCalendars();
      setState(() {
        payCalendarData = data;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Text(
          errorMessage ?? "Une erreur s'est produite lors du chargement.",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (payCalendarData.isEmpty) {
      return const NoDataPage(message: "Aucune période de paie trouvée");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...payCalendarData.map((e) {
          return AppTileClickable(
            tileTitle: e.libelle,
            onClick: () {
              onChoosePeriod(payCalendar: e);
            },
          );
        }),
      ],
    );
  }

  void onChoosePeriod({required PayCalendarModel payCalendar}) async {
    bool confirmed = await handleOperationButtonPress(
      context,
      content:
          "Vous êtes sur le point de préparer le bulletin pour la période du ${payCalendar.libelle}",
    );
    if (confirmed) {
      _dialog.show(
        message: 'Edition du bulletin en cours',
        type: SimpleFontelicoProgressDialogType.bullets,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary,
        width: 250,
      );
      try {
        await BulletinService.getReadyBulletins(
          dateDebut: payCalendar.dateDebut,
          dateFin: payCalendar.dateFin,
        );
        // Future.delayed(Duration(seconds: 5), () async {
        _dialog.hide();
        // });
      } catch (e) {
        _dialog.hide();
        MutationRequestContextualBehavior.showCustomInformationPopUp(
            message: e.toString());
      }
    }
  }
}
