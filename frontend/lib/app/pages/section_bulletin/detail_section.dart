import 'package:flutter/material.dart';
import '../../../../model/bulletin_paie/section_bulletin.dart';
import '../../../../style/app_style.dart';
import '../../../../widget/table_body_middle.dart';

class DetailSectionPage extends StatefulWidget {
  final SectionBulletin section;
  const DetailSectionPage({
    super.key,
    required this.section,
  });

  @override
  State<DetailSectionPage> createState() => _DetailSectionPageState();
}

class _DetailSectionPageState extends State<DetailSectionPage> {
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
              valeur: widget.section.section,
            ),
          ],
        ),
      ],
    );
  }
}
