import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/model/flux_financier/bilan.dart';
import '../error_page.dart';
import '../../responsitvity/responsivity.dart';
import '../../../helper/amout_formatter.dart';
import '../../../service/flux_financier_service.dart';
import '../../../style/app_color.dart';
import '../../../style/app_style.dart';
import 'package:gap/gap.dart';
import '../no_data_page.dart';

class FinancialBarChart extends StatefulWidget {
  const FinancialBarChart({super.key});

  @override
  State<StatefulWidget> createState() => FinancialBarChartState();
}

class FinancialBarChartState extends State<FinancialBarChart> {
  final Color leftBarColor = AppColor.primaryColor;
  final Color rightBarColor = Colors.orange;

  int _selectedYear = DateTime.now().year;

  void _updateYear(int year) {
    setState(() {
      _selectedYear = year;
      _chartDataFuture = _fetchChartData(year: _selectedYear);
    });
  }

  late Future<ChartData> _chartDataFuture;
  @override
  void initState() {
    super.initState();
    _chartDataFuture = _fetchChartData(year: _selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChartData>(
      future: _chartDataFuture,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            height: MediaQuery.of(context).size.height - 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          const Gap(24),
                          Text(
                            'Situation Financière',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: Responsive.isMobile(context) ? 16 : 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16)
                            .copyWith(right: 24),
                        child: ElevatedButton(
                          onPressed: () => _showYearPicker(context),
                          child: Text(
                            '$_selectedYear',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: (snapshot.connectionState == ConnectionState.waiting)
                      ? const Center(child: CircularProgressIndicator())
                      : (snapshot.hasError)
                          ? ErrorPage(
                              message: snapshot.error.toString(),
                              onPressed: () {
                                setState(() {
                                  _chartDataFuture =
                                      _fetchChartData(year: _selectedYear);
                                });
                              },
                            )
                          : (snapshot.hasData &&
                                  snapshot.data!.showingBarGroups.isNotEmpty &&
                                  snapshot.data!.subdivisionUnit > 0)
                              ? Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: BarChart(
                                          BarChartData(
                                            maxY:
                                                snapshot.data!.subdivisionUnit *
                                                    snapshot.data!
                                                        .nombreSubdivision,
                                            barTouchData: BarTouchData(
                                              touchTooltipData:
                                                  BarTouchTooltipData(
                                                getTooltipItem: (group,
                                                    groupIndex, rod, rodIndex) {
                                                  String month = [
                                                    'Janvier',
                                                    'Février',
                                                    'Mars',
                                                    'Avril',
                                                    'Mai',
                                                    'Juin',
                                                    'Juillet',
                                                    'Août',
                                                    'Septembre',
                                                    'Octobre',
                                                    'Novembre',
                                                    'Décembre',
                                                  ][group.x];

                                                  String typeFlux =
                                                      rodIndex == 0
                                                          ? 'Entrée'
                                                          : 'Sortie';
                                                  double montant = rod.toY;

                                                  return BarTooltipItem(
                                                    '$month\n$typeFlux: ${Formatter.formatAmount(montant)} FCFA',
                                                    const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                },
                                              ),
                                              touchCallback:
                                                  (FlTouchEvent event,
                                                      response) {
                                                if (response == null ||
                                                    response.spot == null) {
                                                  setState(() {});
                                                  return;
                                                }
                                                setState(() {});
                                              },
                                            ),
                                            titlesData: FlTitlesData(
                                              show: true,
                                              rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false),
                                              ),
                                              topTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: bottomTitles,
                                                  reservedSize: 42,
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 40,
                                                  interval: (snapshot.data!
                                                              .subdivisionUnit >
                                                          0)
                                                      ? snapshot
                                                          .data!.subdivisionUnit
                                                      : 1,
                                                  getTitlesWidget:
                                                      (value, meta) =>
                                                          leftTitles(
                                                    value: value,
                                                    meta: meta,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            borderData:
                                                FlBorderData(show: false),
                                            barGroups:
                                                snapshot.data!.showingBarGroups,
                                            gridData:
                                                const FlGridData(show: true),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                              horizontal: 16)
                                          .copyWith(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  Responsive.isMobile(context)
                                                      ? MainAxisAlignment
                                                          .spaceBetween
                                                      : MainAxisAlignment.start,
                                              children: [
                                                LegendItem(
                                                  color: leftBarColor,
                                                  text: 'Entrées',
                                                ),
                                                const SizedBox(width: 8),
                                                LegendItem(
                                                  color: rightBarColor,
                                                  text: 'Dépenses',
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!Responsive.isMobile(context) &&
                                              snapshot.connectionState !=
                                                  ConnectionState.waiting &&
                                              !snapshot.hasError)
                                            Text(
                                              'Division par ${formatNumber(number: snapshot.data!.subdivisionUnit)} ${snapshot.data!.unit}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: NoDataPage(
                                    data: [],
                                    message: "Aucune donnée disponible",
                                  ),
                                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showYearPicker(BuildContext context) {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.height * 0.3,
            child: YearPicker(
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
              selectedDate: DateTime(_selectedYear),
              onChanged: (DateTime date) {
                _updateYear(date.year);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  Future<ChartData> _fetchChartData({int? year}) async {
    try {
      final List<YearsBilan> yearData =
          await FluxFinancierService.getYearsBilan(year: year);
      final List<BarChartGroupData> items = [];
      Map<int, List<double>> monthData = {
        for (var i = 0; i < 12; i++) i: [0, 0]
      };

      for (var data in yearData) {
        int mois = data.mois;
        double input = data.input;
        double output = data.output;
        monthData[mois] = [input, output];
      }

      monthData.forEach((mois, values) {
        items.add(makeGroupData(mois, values[0], values[1]));
      });
      double maxY = calculateMaxY(groups: items);

      String unit = determineUnit(maxY: maxY);

      double subdivisionUnit = calculateSubdivisionUnit(maxY: maxY);

      return ChartData(
        showingBarGroups: items,
        maxY: maxY,
        unit: unit,
        subdivisionUnit: subdivisionUnit,
        nombreSubdivision: 4,
      );
    } catch (err) {
      rethrow;
    }
  }

  double calculateMaxY({required List<BarChartGroupData> groups}) {
    double maxY = 0;
    for (var group in groups) {
      for (var rod in group.barRods) {
        if (rod.toY > maxY) {
          maxY = rod.toY;
        }
      }
    }
    return maxY;
  }

  double calculateSubdivisionUnit({required double maxY}) {
    double baseSubdivision;
    if (maxY >= 1e6) {
      baseSubdivision = 1e6;
    } else if (maxY >= 1e3) {
      baseSubdivision = 1e3;
    } else {
      baseSubdivision = 1;
    }

    double subdivisions = maxY / baseSubdivision;
    return (subdivisions / 4).ceil() * baseSubdivision;
  }

  String determineUnit({required double maxY}) {
    if (maxY >= 1e6) {
      return 'M';
    } else if (maxY >= 1e3) {
      return 'K';
    } else {
      return '';
    }
  }

  Widget leftTitles({required double value, required TitleMeta meta}) {
    final formattedValue = formatNumber(number: value);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(
        '$formattedValue${determineUnit(maxY: value)}',
        style: DestopAppStyle.simpleBoldText
            .copyWith(color: const Color(0xff7589a2)),
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = Responsive.isMobile(context)
        ? [
            'J',
            'F',
            'M',
            'A',
            'M',
            'J',
            'J',
            'A',
            'S',
            'O',
            'N',
            'D',
          ]
        : [
            'Jan',
            'Fév',
            'Mar',
            'Avr',
            'Mai',
            'Jun',
            'Jul',
            'Août',
            'Sep',
            'Oct',
            'Nov',
            'Déc',
          ];

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(
        titles[value.toInt()],
        style: DestopAppStyle.simpleBoldText.copyWith(
          color: const Color(0xff7589a2),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.circular(0),
          toY: y1,
          color: leftBarColor,
          width: Responsive.isMobile(context)
              ? 4
              : Responsive.isTablet(context)
                  ? 10
                  : 20,
        ),
        BarChartRodData(
          borderRadius: BorderRadius.circular(0),
          toY: y2,
          color: rightBarColor,
          width: Responsive.isMobile(context)
              ? 4
              : Responsive.isTablet(context)
                  ? 10
                  : 20,
        ),
      ],
    );
  }

  String formatNumber({required double number}) {
    if (number >= 1e6) {
      return (number / 1e6).toStringAsFixed(0);
    } else if (number >= 1e3) {
      return (number / 1e3).toStringAsFixed(0);
    } else {
      return number.toStringAsFixed(0);
    }
  }
}

class ChartData {
  final List<BarChartGroupData> showingBarGroups;
  final double maxY;
  final String unit;
  final double subdivisionUnit;
  final int nombreSubdivision;

  ChartData({
    required this.showingBarGroups,
    required this.maxY,
    required this.unit,
    required this.subdivisionUnit,
    required this.nombreSubdivision,
  });
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
