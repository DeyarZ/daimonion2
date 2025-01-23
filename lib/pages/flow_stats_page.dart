import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class FlowStatsPage extends StatefulWidget {
  const FlowStatsPage({Key? key}) : super(key: key);

  @override
  _FlowStatsPageState createState() => _FlowStatsPageState();
}

class _FlowStatsPageState extends State<FlowStatsPage> {
  String _currentFilter = 'week'; 
  List<double> _barValues = [];
  List<String> _barLabels = [];

  double _averageFlowMinutes = 0.0;
  int _totalFlowCount = 0;
  int _totalFlowMinutes = 0;

  @override
  void initState() {
    super.initState();
    _loadDataForFilter(_currentFilter);
  }

  Future<void> _loadDataForFilter(String filter) async {
    final box = await Hive.openBox<Map>('flow_sessions');
    final allSessions = _boxToFlowSessions(box);
    final now = DateTime.now();

    List<FlowSession> filtered;
    if (filter == 'week') {
      final from = now.subtract(const Duration(days: 6));
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from))).toList();
      _setupWeekData(filtered);
    } else if (filter == 'month') {
      final from = now.subtract(const Duration(days: 27)); 
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from))).toList();
      _setupMonthData(filtered);
    } else {
      final from = DateTime(now.year - 1, now.month, now.day);
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from))).toList();
      _setupYearData(filtered);
    }

    _totalFlowCount = filtered.length;
    if (_totalFlowCount > 0) {
      _totalFlowMinutes = filtered.fold<int>(0, (sum, fs) => sum + fs.minutes);
      _averageFlowMinutes = _totalFlowMinutes / _totalFlowCount;
    } else {
      _totalFlowMinutes = 0;
      _averageFlowMinutes = 0;
    }

    setState(() {});
  }

  void _setupWeekData(List<FlowSession> sessions) {
    final List<double> dayTotals = List.filled(7, 0.0);
    for (var fs in sessions) {
      dayTotals[fs.date.weekday - 1] += fs.minutes;
    }
    _barValues = dayTotals;
    _barLabels = ['MO', 'DI', 'MI', 'DO', 'FR', 'SA', 'SO'];
  }

  void _setupMonthData(List<FlowSession> sessions) {
    final now = DateTime.now();
    final firstDay = now.subtract(const Duration(days: 27));
    final List<double> weekTotals = List.filled(4, 0.0);

    for (var fs in sessions) {
      final diffDays = fs.date.difference(_startOfDay(firstDay)).inDays;
      final index = diffDays ~/ 7; 
      if (index >= 0 && index < 4) {
        weekTotals[index] += fs.minutes;
      }
    }
    _barValues = weekTotals;
    _barLabels = _generateWeekLabels(firstDay, 4);
  }

  void _setupYearData(List<FlowSession> sessions) {
    final now = DateTime.now();
    final List<double> monthTotals = List.filled(12, 0.0);

    for (var fs in sessions) {
      final monthsDiff = _monthDiff(fs.date, now);
      if (monthsDiff >= 0 && monthsDiff < 12) {
        final index = 11 - monthsDiff; 
        monthTotals[index] += fs.minutes;
      }
    }
    _barValues = monthTotals;
    _barLabels = _generateLast12MonthLabels(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Stats'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton('week', 'Woche'),
                const SizedBox(width: 8),
                _buildFilterButton('month', 'Monat'),
                const SizedBox(width: 8),
                _buildFilterButton('year', 'Jahr'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              child: _buildBarChart(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem(
                  title: 'Flows', 
                  value: _totalFlowCount.toString(),
                ),
                _statItem(
                  title: 'Minuten', 
                  value: _totalFlowMinutes.toString(),
                ),
                _statItem(
                  title: 'Ø Zeit (Min)', 
                  value: _averageFlowMinutes.toStringAsFixed(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String value, String label) {
    final isSelected = (value == _currentFilter);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.redAccent : Colors.grey[800],
      ),
      onPressed: () async {
        setState(() {
          _currentFilter = value;
        });
        await _loadDataForFilter(value);
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (_barValues.isEmpty) {
      return Center(
        child: Text(
          'Keine Daten für diesen Zeitraum',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      );
    }

    final maxVal = _barValues.reduce(max);
    final maxY = (maxVal < 10) ? 10.0 : (maxVal * 1.2);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: _calculateChartWidth(),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            minY: 0,
            barTouchData: BarTouchData(enabled: true),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white24,
                strokeWidth: 1,
              ),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxY / 5,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < _barLabels.length) {
                      return Text(
                        _barLabels[idx],
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            barGroups: List.generate(_barValues.length, (index) {
              final val = _barValues[index];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: val,
                    color: Colors.redAccent,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _statItem({required String title, required String value}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  double _calculateChartWidth() {
    const barWidth = 40.0;
    return max(_barValues.length * barWidth, 300); 
  }

  List<FlowSession> _boxToFlowSessions(Box<Map> box) {
    final List<FlowSession> result = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data == null) continue;
      final dateMs = data['date'] as int?;
      final mins = data['minutes'] as int?;
      if (dateMs == null || mins == null) continue;
      final dt = DateTime.fromMillisecondsSinceEpoch(dateMs);
      result.add(FlowSession(date: dt, minutes: mins));
    }
    return result;
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  int _monthDiff(DateTime a, DateTime b) {
    final yearDiff = b.year - a.year;
    final monthDiff = b.month - a.month;
    return yearDiff * 12 + monthDiff;
  }

  List<String> _generateWeekLabels(DateTime startDay, int numberOfWeeks) {
    final List<String> labels = [];
    for (int i = 0; i < numberOfWeeks; i++) {
      final weekStart = startDay.add(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final startLabel = '${weekStart.day}.${_monthToShort(weekStart.month)}';
      final endLabel   = '${weekEnd.day}.${_monthToShort(weekEnd.month)}';

      labels.add('$startLabel–$endLabel');
    }
    return labels;
  }

  List<String> _generateLast12MonthLabels(DateTime now) {
    final List<String> labels = [];
    for (int i = 11; i >= 0; i--) {
      final thatMonth = DateTime(now.year, now.month - i, 1);
      final mm = thatMonth.month;
      final yy = thatMonth.year.toString().substring(2);
      labels.add('${_monthToShort(mm)} $yy');
    }
    return labels;
  }

  String _monthToShort(int m) {
    switch (m) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mär';
      case 4: return 'Apr';
      case 5: return 'Mai';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Okt';
      case 11: return 'Nov';
      case 12: return 'Dez';
      default: return '?';
    }
  }
}

class FlowSession {
  final DateTime date;
  final int minutes;
  FlowSession({required this.date, required this.minutes});
}
