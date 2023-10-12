import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'model/TransactionData.dart';

class TransactionFlowChart extends StatelessWidget {
  final List<TransactionData> transactions;

  const TransactionFlowChart({Key? key, required this.transactions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ChartSampleData> transformData(List<TransactionData> transactions) {
      return transactions.map((transaction) {
        final amount = transaction.amount;
        final date = transaction.tranDate;

        return ChartSampleData(date, amount);
      }).toList();
    }

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context); // This will navigate back to the previous screen
          },
        ),
        title: const Text(
          'Total Incomes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24, // Update this value to change the title size
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: 400,
                height: 450,
                child: Container(
                  child: SfCartesianChart(
                    title: ChartTitle(text: 'Total Transaction Chart'),
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelIntersectAction: AxisLabelIntersectAction.rotate90,
                    ),
                    series: <ChartSeries>[
                      StackedLineSeries<ChartSampleData, String>(
                        dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            showCumulativeValues: true,
                            useSeriesColor: true,
                            color: Colors.red),
                        dataSource: transformData(transactions),
                        markerSettings: const MarkerSettings(isVisible: true),
                        xValueMapper: (ChartSampleData data, _) => data.x,
                        // Convert DateTime to formatted string
                        yValueMapper: (ChartSampleData data, _) {
                          return data.y;
                        },
                        animationDuration: 1000,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: const Text(
                      'Total Transaction amount : ',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(1.0),
                    child: const Text(
                      '\u{20B9}18,342 L',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Add spacing between chart and description

              const SizedBox(height: 10.0),
              const Text(
                'Note: This chart illustrates the latest total transaction according to date. ',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ],
          )),
    ));
  }
}

class ChartSampleData {
  final String x;
  final double y;

  ChartSampleData(this.x, this.y);
}
