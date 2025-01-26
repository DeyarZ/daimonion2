import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

// ---------------------------------------
// MODELDATEN
// ---------------------------------------
class FlowSession {
  final DateTime date;
  final int minutes;
  FlowSession({required this.date, required this.minutes});
}

// ---------------------------------------
// FLOWSTATS-PAGE
// ---------------------------------------
class FlowStatsPage extends StatefulWidget {
  const FlowStatsPage({Key? key}) : super(key: key);

  @override
  _FlowStatsPageState createState() => _FlowStatsPageState();
}

class _FlowStatsPageState extends State<FlowStatsPage> {
  String _currentFilter = 'week';
  List<double> _barValues = [];
  List<String> _barLabels = [];

  double _averageFlowMinutes = 0.0; // Ø Zeit pro Flow-Einheit
  int _totalFlowCount = 0;         // Anzahl der Flows
  int _totalFlowMinutes = 0;       // Summe aller Flow-Minuten

  // NEU: Ø Flow-Minuten pro Woche
  double _averageWeeklyFlowMinutes = 0.0;

  // Wieviele Tage fallen in den Zeitraum? (z.B. 7, 28, 365)
  int _rangeDays = 7; // default for "week"

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
      _rangeDays = 7;
      final from = now.subtract(const Duration(days: 6));
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from))).toList();
      _setupWeekData(filtered);
    } else if (filter == 'month') {
      _rangeDays = 28;
      final from = now.subtract(const Duration(days: 27));
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from))).toList();
      _setupMonthData(filtered);
    } else {
      _rangeDays = 365;
      final from = DateTime(now.year - 1, now.month, now.day);
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from))).toList();
      _setupYearData(filtered);
    }

    _totalFlowCount = filtered.length;
    _totalFlowMinutes = filtered.fold<int>(0, (sum, fs) => sum + fs.minutes);
    _averageFlowMinutes =
        _totalFlowCount > 0 ? _totalFlowMinutes / _totalFlowCount : 0.0;

    if (_rangeDays > 0) {
      final weeks = _rangeDays / 7.0;
      _averageWeeklyFlowMinutes = weeks > 0 ? _totalFlowMinutes / weeks : 0.0;
    } else {
      _averageWeeklyFlowMinutes = 0.0;
    }

    setState(() {});
  }

  // ------------------------------------------------------
  // FILTER-BUTTON
  // ------------------------------------------------------
  Widget _buildFilterButton(String filterKey, String label) {
    final isSelected = _currentFilter == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filterKey;
          _loadDataForFilter(filterKey);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.redAccent : Colors.grey[850],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------
  // DATENAUFBEREITUNG
  // ------------------------------------------------------
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

  // ------------------------------------------------------
  // BAU DES UI
  // ------------------------------------------------------
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter-Buttons
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

            // BARCHART
            SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width, // max chart = screen width
              child: _buildBarChart(context),
            ),
            const SizedBox(height: 24),

            // STATS ALS LISTE (vertical)
            _buildStatsList(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------
  // BARCHART
  // ------------------------------------------------------
  Widget _buildBarChart(BuildContext context) {
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

    // Dynamische Balkenbreite, je nach Anzahl
    double barWidth = 30; // default
    if (_barValues.length >= 12) {
      // z.B. bei "year" -> 12 bars -> schmaler
      barWidth = 20;
    } else if (_barValues.length <= 4) {
      // z.B. month -> 4 bars -> bisschen breiter
      barWidth = 40;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
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
                width: barWidth,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ------------------------------------------------------
  // STATS-LISTE
  // ------------------------------------------------------
  Widget _buildStatsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statItem(title: 'Flows', value: _totalFlowCount.toString()),
        const SizedBox(height: 8),
        _statItem(title: 'Minuten gesamt', value: _totalFlowMinutes.toString()),
        const SizedBox(height: 8),
        _statItem(
          title: 'Ø Zeit pro Flow (Min)', 
          value: _averageFlowMinutes.toStringAsFixed(1),
        ),
        const SizedBox(height: 8),
        _statItem(
          title: 'Ø Zeit pro Woche (Min)',
          value: _averageWeeklyFlowMinutes.isNaN
              ? '0.0'
              : _averageWeeklyFlowMinutes.toStringAsFixed(1),
        ),
      ],
    );
  }

  Widget _statItem({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  // HELPER
  // ------------------------------------------------------
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
      case 1:  return 'Jan';
      case 2:  return 'Feb';
      case 3:  return 'Mär';
      case 4:  return 'Apr';
      case 5:  return 'Mai';
      case 6:  return 'Jun';
      case 7:  return 'Jul';
      case 8:  return 'Aug';
      case 9:  return 'Sep';
      case 10: return 'Okt';
      case 11: return 'Nov';
      case 12: return 'Dez';
      default: return '?';
    }
  }
  
}
