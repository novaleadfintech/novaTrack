import 'package:flutter/material.dart';
import '../utils/creance_util.dart';
import '../../responsitvity/responsivity.dart';
import '../../../model/flux_financier/creance_model.dart';
import '../../../widget/creance_tile.dart';
import '../../../widget/table_header.dart';

class CreanceTable extends StatelessWidget {
  final List<CreanceModel> paginatedCreanceData;
  final VoidCallback refresh;

  const CreanceTable({
    super.key,
    required this.refresh,
    required this.paginatedCreanceData,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    return Column(
      children: [
        Table(
          columnWidths: {
            1: Responsive.isMobile(context)
                ? const FixedColumnWidth(120)
                : const FlexColumnWidth(),
            2: Responsive.isMobile(context)
                ? const FixedColumnWidth(80)
                : const FlexColumnWidth(),
            3: Responsive.isDesktop(context)
                ? const FixedColumnWidth(130)
                : Responsive.isTablet(context)
                    ? const FixedColumnWidth(130)
                    : const FixedColumnWidth(20),
                

          },
          children: [
            tableHeader(
              context,
              tablesTitles:
                  isMobile ? creanceTableTitlesSmall : creanceTableTitles,
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ...paginatedCreanceData.map(
                  (e) => CreanceTile(
                    creance: e,
                    refresh: refresh,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
