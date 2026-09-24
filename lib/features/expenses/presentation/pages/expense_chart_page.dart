import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

/// Full-screen version of the home pie chart, with a readable breakdown list
/// instead of the cramped side legend.
class ExpenseChartPage extends StatelessWidget {
  final Map<String, double> dataMap;

  const ExpenseChartPage({super.key, required this.dataMap});

  static const _colors = [
    Color(0xff4E79A7),
    Color(0xffF28E2B),
    Color(0xffE15759),
    Color(0xff76B7B2),
    Color(0xff59A14F),
    Color(0xffEDC948),
    Color(0xffB07AA1),
    Color(0xffFF9DA7),
    Color(0xff9C755F),
    Color(0xffBAB0AC),
  ];

  @override
  Widget build(BuildContext context) {
    // Largest first; the chart colours slices in map order, so the list below
    // uses the same index to match.
    final entries = dataMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sorted = Map.fromEntries(entries);
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorUtil.kPrmiaryColor,
      appBar: AppBar(title: const Text('Expenses by category')),
      body: total <= 0
          ? const Center(child: Text('No categorised expenses'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Total  Rs. ${total.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: ColorUtil.kTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                PieChart(
                  dataMap: sorted,
                  colorList: _colors,
                  chartRadius: width * 0.8,
                  chartType: ChartType.disc,
                  animationDuration: const Duration(milliseconds: 600),
                  legendOptions: const LegendOptions(showLegends: false),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValuesInPercentage: true,
                    showChartValueBackground: false,
                    decimalPlaces: 0,
                  ),
                ),
                const SizedBox(height: 24),
                for (var i = 0; i < entries.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                        radius: 8,
                        backgroundColor: _colors[i % _colors.length]),
                    title: Text(entries[i].key,
                        style: TextStyle(color: ColorUtil.kTextColor)),
                    trailing: Text(
                        'Rs. ${entries[i].value.toStringAsFixed(0)}  '
                        '(${(entries[i].value / total * 100).toStringAsFixed(1)}%)',
                        style: TextStyle(color: ColorUtil.kTextColor)),
                  ),
              ],
            ),
    );
  }
}
