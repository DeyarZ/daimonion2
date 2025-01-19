import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class FlowStatsPage extends StatefulWidget {
  const FlowStatsPage({Key? key}) : super(key: key);

  @override
  _FlowStatsPageState createState() => _FlowStatsPageState();
}

class _FlowStatsPageState extends State<FlowStatsPage> {
  // Filter: 'week', 'month', 'year'
  String _currentFilter = 'week'; 

  // Die aufbereiteten (aggregierten) Daten, z.B. 7 Balken (für 7 Tage) bei week
  List<double> _barValues = [];

  // x-Achse Labels, z.B. ['Mo','Di','Mi','Do','Fr','Sa','So'] für week
  List<String> _barLabels = [];

  double _averageFlowMinutes = 0.0; // Durchschnittliche Flow-Zeit

  @override
  void initState() {
    super.initState();
    // Beim ersten Mal: Daten laden
    _loadDataForFilter(_currentFilter);
  }

  Future<void> _loadDataForFilter(String filter) async {
    final box = await Hive.openBox<Map>('flow_sessions');
    final allSessions = _boxToFlowSessions(box);

    // Filtern wir die Sessions nach dem Zeitraum
    final now = DateTime.now();

    List<FlowSession> filtered;
    if (filter == 'week') {
      // Letzte 7 Tage
      final from = now.subtract(const Duration(days: 6)); 
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from)) ).toList();
      _setupWeekData(filtered);
    } 
    else if (filter == 'month') {
      // Letzte 4 Wochen
      final from = now.subtract(const Duration(days: 27)); 
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from)) ).toList();
      _setupMonthData(filtered);
    } 
    else {
      // 'year' => letzte 12 Monate
      final from = DateTime(now.year - 1, now.month, now.day);
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from)) ).toList();
      _setupYearData(filtered);
    }

    // Durchschnitt berechnen
    if (filtered.isNotEmpty) {
      final total = filtered.fold<int>(0, (sum, fs) => sum + fs.minutes);
      _averageFlowMinutes = total / filtered.length;
    } else {
      _averageFlowMinutes = 0;
    }

    setState(() {});
  }

  // ------------------------------------------------
  // WEEK-DATEN => 7 Balken (Mo..So)
  // ------------------------------------------------
  void _setupWeekData(List<FlowSession> sessions) {
    // Wir gehen von Mo..So (7 Tage), sortieren danach
    // In Flutter: (Mo=1, So=7) => dayOfWeek
    // 1) Erstelle 7 Einträge (je Tag) => 0
    final List<double> dayTotals = List.filled(7, 0.0);

    // Summiere die Flow-Minuten pro Wochentag
    for (var fs in sessions) {
      final wd = fs.date.weekday; // 1..7
      dayTotals[wd - 1] += fs.minutes; // add the minutes
    }

    _barValues = dayTotals;
    _barLabels = ['MO','DI','MI','DO','FR','SA','SO'];
  }

  // ------------------------------------------------
  // MONTH-DATEN => 4 Balken (je Woche) 
  // ------------------------------------------------
  void _setupMonthData(List<FlowSession> sessions) {
    // Du könntest auch 30 Balken machen, aber das wird unübersichtlich.
    // Ich gehe hier von 4 Balken (jede Woche).
    final now = DateTime.now();
    final firstDay = now.subtract(const Duration(days: 27)); // 4 Wochen = 28 Tage
    // Woche0 => firstDay..firstDay+6
    // Woche1 => firstDay+7..+13
    // ...
    final List<double> weekTotals = List.filled(4, 0.0);

    for (var fs in sessions) {
      final diffDays = fs.date.difference(firstDay).inDays;
      final index = diffDays ~/ 7; 
      if (index >= 0 && index < 4) {
        weekTotals[index] += fs.minutes;
      }
    }

    _barValues = weekTotals;
    _barLabels = ['W1','W2','W3','W4']; 
  }

  // ------------------------------------------------
  // YEAR-DATEN => 12 Balken (Monate)
  // ------------------------------------------------
  void _setupYearData(List<FlowSession> sessions) {
    // Letzte 12 Monate => jeder Monat 1 Balken
    // Wir erstellen ein Array [0..11], das die Summe der Flow-Minuten hält.
    final now = DateTime.now();
    final baseYear = now.year;
    final baseMonth = now.month; // z.B. 1..12

    final List<double> monthTotals = List.filled(12, 0.0);

    for (var fs in sessions) {
      // Wir wollen die Differenz in Monaten rauskriegen
      // z.B. wenn fs.date = 2024-12, und now = 2025-01 => das war 1 Monat her
      final monthsDiff = _monthDiff(fs.date, now);
      // monthsDiff=0 => gleicher Monat wie "now"
      // monthsDiff=11 => 11 Monate her => ganz am Anfang des Jahres

      if (monthsDiff >= 0 && monthsDiff < 12) {
        // monthTotals[0] => der aktuelle Monat
        // monthTotals[1] => letzter Monat, etc.
        // Manchmal will man es umgekehrt. Ich mach’s mal so:
        final index = 11 - monthsDiff; 
        monthTotals[index] += fs.minutes;
      }
    }

    _barValues = monthTotals;
    // z.B. ['-11M','-10M','...','NOW'] => bisschen kryptisch, machen wir’s netter:
    // Du könntest aber dynamisch echte Monatsnamen generieren.
    _barLabels = _generateLast12MonthLabels(now);
  }

  // ------------------------------------------------
  // UI
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Stats'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter-Auswahl
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

            // Chart
            Expanded(child: _buildBarChart()),

            // Info: Durchschnitt
            Text(
              'Ø Flow-Zeit: ${_averageFlowMinutes.toStringAsFixed(1)} Min',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
          ],
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

    final maxVal = _barValues.reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal < 10) ? 10.0 : (maxVal * 1.2);

    return BarChart(
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
              // Je nach Step
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
        // Daten neu laden
        await _loadDataForFilter(value);
      },
      child: Text(label),
    );
  }

  // ------------------------------------------------
  // Parsing + Helper
  // ------------------------------------------------
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

  DateTime _startOfDay(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  // months difference between two dates
  int _monthDiff(DateTime a, DateTime b) {
    // ungefähre Formel, die nur Jahr/Monat beachtet, Tag ignorieren wir 
    final yearDiff = b.year - a.year;
    final monthDiff = b.month - a.month;
    return yearDiff * 12 + monthDiff;
  }

  List<String> _generateLast12MonthLabels(DateTime now) {
    // z.B. wenn now = Jan 2025:
    //   monthDiff=0 => Jan 2025
    //   monthDiff=1 => Dez 2024
    //   ...
    // wir erstellen die label in Reihenfolge 0..11
    // index=0 => -11 months, index=11 => 0 months
    // => wir kehren es um => index=0 => 12 months ago ?

    final List<String> labels = [];
    // wir gehen hier mal = 12 step
    for (int i = 11; i >= 0; i--) {
      final thatMonth = DateTime(now.year, now.month - i, 1);
      final mm = thatMonth.month;
      final yy = thatMonth.year.toString().substring(2); // 2-stellig
      labels.add('${_monthName(mm)} $yy');
    }
    return labels;
  }

  String _monthName(int m) {
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

// ------------------------------------------------------------
// FLOWSESSION - unsere Datenklasse
// ------------------------------------------------------------
class FlowSession {
  final DateTime date;
  final int minutes;

  FlowSession({required this.date, required this.minutes});
}
