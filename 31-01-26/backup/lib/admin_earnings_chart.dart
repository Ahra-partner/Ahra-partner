import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminEarningsChart extends StatelessWidget {
  const AdminEarningsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings Chart (Last 7 Days)'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('daily_stats')
            .orderBy('createdAt', descending: false)
            .limit(7)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No earnings data'));
          }

          final List<FlSpot> spots = [];

          for (int i = 0; i < docs.length; i++) {
            final data = docs[i].data() as Map<String, dynamic>;
            final double amount =
                (data['totalEarnings'] ?? 0).toDouble();
            spots.add(FlSpot(i.toDouble(), amount));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= docs.length) {
                          return const SizedBox.shrink();
                        }

                        final ts =
                            docs[index]['createdAt'] as Timestamp;
                        final label = DateFormat('dd MMM')
                            .format(ts.toDate());

                        return Text(
                          label,
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.green,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
