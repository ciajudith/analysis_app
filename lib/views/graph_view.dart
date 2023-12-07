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
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.03,
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.4,
                    child: _buildLineChart(
                      widget.scannedData,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.1,
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
      AppColors.teaGreenColor,
      AppColors.verdigrisColor,
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(
          show: true,
        ),
        titlesData: FlTitlesData(
          show: false,
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _generateChartData(data),
            isCurved: true,
            color: AppColors.eggshellColor,
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
    Set<String> allHeaders = data.expand((entry) => entry.keys).toSet();

    String xHeader = allHeaders.elementAt(0);
    List<String> yHeaders = allHeaders.skip(1).toList();

    Map<String, List<FlSpot>> chartData = {};

    for (var header in yHeaders) {
      chartData[header] = [];
    }

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

    List<double> xValues = chartData[yHeaders.first]!
        .map((flSpot) => flSpot.x)
        .toSet()
        .toList()
      ..sort();

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

    for (var i = 0; i < result.length; i++) {
      result[i] = FlSpot(i.toDouble(), result[i].y);
    }

    return result;
  }

  double _getNumericValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return _getNextStringXValue();
    } else {
      return 13.0;
    }
  }

  int _stringXCounter = 0;

  double _getNextStringXValue() {
    _stringXCounter++;
    return _stringXCounter.toDouble();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    List<String> xValuesStrings = widget.scannedData.map((entry) {
      return _extractXAxisData(entry);
    }).toList();
    Widget text;
    int index = value.toInt();

    if (index >= 0 && index < xValuesStrings.length) {
      text = Text(xValuesStrings[index], style: style);
    } else {
      text = const Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  String _extractXAxisData(Map<String, dynamic> entry) {
    Set<String> allHeaders =
        widget.scannedData.expand((entry) => entry.keys).toSet();
    String xHeader = allHeaders.elementAt(0);
    return entry[xHeader].toString();
  }
}
