import 'package:flutter/material.dart';
import 'package:frontend/helper/date_helper.dart' show getStringDate;
import 'package:frontend/model/bulletin_paie/pay_calendar_model.dart';
import 'package:frontend/widget/table_body_middle.dart'
    show TabledetailBodyMiddle;
  import '../../../../style/app_style.dart';

class DetailPayCalendarPage extends StatefulWidget {
  final PayCalendarModel payCalendar;
  const DetailPayCalendarPage({
    super.key,
    required this.payCalendar,
  });

  @override
  State<DetailPayCalendarPage> createState() => _DetailPayCalendarPageState();
}

class _DetailPayCalendarPageState extends State<DetailPayCalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Libellé",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur: widget.payCalendar.libelle,
            ),
          ],
        ),
        TableRow(
          decoration: tableDecoration(context),
          children: [
            const TabledetailBodyMiddle(
              valeur: "Période de paie",
              isbold: true,
            ),
            TabledetailBodyMiddle(
              valeur:
                  "Du ${getStringDate(time: widget.payCalendar.dateDebut)} au ${getStringDate(time: widget.payCalendar.dateFin)}",
            ),
          ],
        ),
      ],
    );
  }
}
