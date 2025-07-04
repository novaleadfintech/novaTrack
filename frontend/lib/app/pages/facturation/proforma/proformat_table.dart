import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/model/habilitation/role_model.dart';

import '../../../../model/facturation/proforma_model.dart';
import '../../../../widget/proforma_tile.dart';
import '../../../../widget/table_header.dart';
import '../../../responsitvity/responsivity.dart';
import '../../utils/facture_util.dart';


class ProformaTable extends StatefulWidget {
  final List<ProformaModel> paginatedProformatData;
  final Future<void> Function() refresh;
  final RoleModel role;

  const ProformaTable({
    super.key,
    required this.refresh,
    required this.role,
    
    required this.paginatedProformatData,
  });

  @override
  State<ProformaTable> createState() => _FactureTableState();
}

class _FactureTableState extends State<ProformaTable> {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Table(
          columnWidths: {
            4: Responsive.isDesktop(context)
                ? const FixedColumnWidth(175)
                : const FixedColumnWidth(150),
            3: Responsive.isDesktop(context)
                ? const FixedColumnWidth(200)
                : const FixedColumnWidth(145),
            2: isMobile
                ? const FixedColumnWidth(50)
                : const FlexColumnWidth(),
          },
          children: [
            tableHeader(
              context,
              tablesTitles:
                  isMobile ? factureTableTitlesSmall : proformaTableTitles,
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: widget.paginatedProformatData
                  .map(
                    (proforma) => ProformaTile(
                      refresh: widget.refresh,
                      proforma: proforma,
                      role: widget.role,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
