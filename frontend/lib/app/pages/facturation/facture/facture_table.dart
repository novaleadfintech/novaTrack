import 'package:flutter/material.dart';
import '../../../../model/habilitation/role_model.dart';
import '../../utils/facture_util.dart';
import '../../../responsitvity/responsivity.dart';
import '../../../../model/facturation/facture_model.dart';
import '../../../../widget/facture_tile.dart';
import '../../../../widget/table_header.dart';

class FactureTable extends StatefulWidget {
  final RoleModel role;

  final List<FactureModel> paginatedFactureData;
  final Future<void> Function() refresh;

  const FactureTable({
    super.key,
    required this.role,

    required this.paginatedFactureData,
    required this.refresh,
  });

  @override
  State<FactureTable> createState() => _FactureTableState();
}

class _FactureTableState extends State<FactureTable> {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Table(
          columnWidths: {
            4: Responsive.isDesktop(context)
                ? const FixedColumnWidth(202)
                : const FixedColumnWidth(132),
            2: Responsive.isMobile(context)
                ? const FixedColumnWidth(50)
                : const FlexColumnWidth(),
            3: Responsive.isDesktop(context)
                ? const FixedColumnWidth(148)
                : const FixedColumnWidth(170),
          },
          children: [
            tableHeader(
              context,
              tablesTitles:
                  isMobile ? factureTableTitlesSmall : factureTableTitles,
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.paginatedFactureData.length,
            itemBuilder: (context, index) {
              final facture = widget.paginatedFactureData[index];
              return FactureTile(
                role: widget.role,
                facture: facture,
                refresh: widget.refresh,
              );
            },
          ),
        ),
      ],
    );
  }
}
