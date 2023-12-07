import 'package:analysis_app/constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphView extends StatefulWidget {
  final List<Map<String, dynamic>> scannedData;

  const GraphView({super.key, required this.scannedData});

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanned Data'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: _buildTableColumns(
                      widget.scannedData.first.keys.toList()),
                  rows: _buildTableRows(widget.scannedData),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildLineChart(widget.scannedData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildTableColumns(List<String> headers) {
    return headers.map((header) => DataColumn(label: Text(header))).toList();
  }

  List<DataRow> _buildTableRows(List<Map<String, dynamic>> rows) {
    return rows.map((row) {
      return DataRow(
        cells: row.keys.map((key) => DataCell(Text('${row[key]}'))).toList(),
      );
    }).toList();
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _generateChartData(data),
            isCurved: true,
            color: AppColors.primaryColor,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateChartData(List<Map<String, dynamic>> data) {
    // Extract all unique headers (columns) from the data
    Set<String> allHeaders = data.expand((entry) => entry.keys).toSet();

    // Assuming the first column is the X-axis, and the rest are Y-axis
    String xHeader = allHeaders.elementAt(0);
    List<String> yHeaders = allHeaders.skip(1).toList();

    // Create a map to store Y-axis data for each header
    Map<String, List<FlSpot>> chartData = {};

    // Initialize the map with empty lists
    yHeaders.forEach((header) {
      chartData[header] = [];
    });

    // Populate the chart data
    data.forEach((entry) {
      double xValue = entry[xHeader] is String
          ? _getNumericValue(entry[xHeader])
          : entry[xHeader].toDouble();

      yHeaders.forEach((header) {
        double yValue = entry[header] is String
            ? _getNumericValue(entry[header])
            : entry[header].toDouble();
        chartData[header]!.add(FlSpot(xValue, yValue));
      });
    });

    // Merge all lists into a single list for the chart
    List<FlSpot> result = [];
    yHeaders.forEach((header) {
      result.addAll(chartData[header]!);
    });

    return result;
  }

// Function to handle different types and convert to double
  double _getNumericValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }
}
