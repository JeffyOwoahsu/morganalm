import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String title;
  final String verticalLabel;
  final Color color;

  const CustomLineChart({
    super.key,
    required this.values,
    required this.labels,
    required this.title,
    required this.verticalLabel,
    this.color = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    double minY = values.reduce((a, b) => a < b ? a : b);
    double maxY = values.reduce((a, b) => a > b ? a : b);

    minY = (minY * 2).floorToDouble() / 2;
    maxY = (maxY * 2).ceilToDouble() / 2;

    double range = maxY - minY;
    double numOfValues = 5;
    double yInterval = range / numOfValues;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,

          // -----------------------------
          // GRID LINES
          // -----------------------------
          gridData: FlGridData(
            show: true,
            horizontalInterval: yInterval,
            verticalInterval: 1,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.grey.shade300, strokeWidth: 1),
            getDrawingVerticalLine: (_) =>
                FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          ),

          // -----------------------------
          // AXIS LABELS
          // -----------------------------
          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              axisNameWidget: Text(title),
              sideTitleAlignment: SideTitleAlignment.outside,
              sideTitles: const SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            // Y-axis (left)
            leftTitles: AxisTitles(
              axisNameWidget: Text(verticalLabel),
              sideTitleAlignment: SideTitleAlignment.outside,
              sideTitles: SideTitles(
                reservedSize: 32,
                showTitles: true,
                interval: yInterval,
                getTitlesWidget: (value, _) {
                  // Only show if value is within valid range
                  if (value < minY - yInterval || value > maxY + yInterval) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),

            // X-axis
            bottomTitles: AxisTitles(
              axisNameWidget: Text("Days"),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1, // This ensures labels align with data points
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();

                  // Prevent out of bounds
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      labels[index],
                      style: const TextStyle(fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),

          // -----------------------------
          // BORDER
          // -----------------------------
          borderData: FlBorderData(show: false),

          // -----------------------------
          // LINE CHART DATA
          // -----------------------------
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              curveSmoothness: 0.32,
              color: color,
              barWidth: 3,
              isStrokeCapRound: true,

              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 3.8,
                      color: color,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),

              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.25),
              ),
            ),
          ],

          lineTouchData: LineTouchData(enabled: false),
        ),
      ),
    );
  }
}