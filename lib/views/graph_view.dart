import 'package:analysis_app/constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Data'),
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
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.3,
                  child: _buildLineChart(
                    widget.scannedData,
                  ),
                ),
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
    List<Color> gradientColors = [
      AppColors.primaryColor,
      AppColors.verdigrisColor,
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _generateChartData(data),
            isCurved: true,
            color: AppColors.primaryColor,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors,
              ),
            ),
            gradient: LinearGradient(
              colors: gradientColors,
            ),
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
    for (var header in yHeaders) {
      chartData[header] = [];
    }

    // Populate the chart data
    for (var entry in data) {
      double xValue = entry[xHeader] is String
          ? _getNumericValue(entry[xHeader])
          : entry[xHeader].toDouble();

      for (var header in yHeaders) {
        double yValue = entry[header] is String
            ? _getNumericValue(entry[header])
            : entry[header].toDouble();
        chartData[header]!.add(FlSpot(xValue, yValue));
      }
    }

    // Sort the X-axis values
    List<double> xValues = chartData[yHeaders.first]!
        .map((flSpot) => flSpot.x)
        .toSet()
        .toList()
      ..sort();

    // Create a list of FlSpot with sorted X-axis values
    List<FlSpot> result = [];
    for (var xValue in xValues) {
      for (var header in yHeaders) {
        var spot = chartData[header]!.firstWhere(
          (flSpot) => flSpot.x == xValue,
          orElse: () => FlSpot(xValue, 0.0),
        );
        result.add(spot);
      }
    }

    // Adjust the X-axis values to ensure proper distribution
    for (var i = 0; i < result.length; i++) {
      result[i] = FlSpot(i.toDouble(), result[i].y);
    }

    return result;
  }

  double _getNumericValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      // Increment a counter each time a string is encountered
      // and use the counter as the X-axis value
      return _getNextStringXValue();
    } else {
      return 13.0;
    }
  }

  int _stringXCounter = 0;

  double _getNextStringXValue() {
    // Increment the counter and return it as a double
    _stringXCounter++;
    return _stringXCounter.toDouble();
  }
}
