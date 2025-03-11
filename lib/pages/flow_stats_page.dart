// lib/pages/flow_stats_page.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../l10n/generated/l10n.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Für SVG-Icons
import 'package:intl/intl.dart'; // Für bessere Datumsformatierung

// MODELDATEN
class FlowSession {
  final DateTime date;
  final int minutes;
  FlowSession({required this.date, required this.minutes});
}

// FLOWSTATS-PAGE
class FlowStatsPage extends StatefulWidget {
  const FlowStatsPage({Key? key}) : super(key: key);

  @override
  _FlowStatsPageState createState() => _FlowStatsPageState();
}

class _FlowStatsPageState extends State<FlowStatsPage>
    with SingleTickerProviderStateMixin {
  // Getter für S.of(context)
  S get loc => S.of(context);

  String _currentFilter = 'week';
  List<double> _barValues = [];
  List<String> _barLabels = [];

  double _averageFlowMinutes = 0.0;
  int _totalFlowCount = 0;
  int _totalFlowMinutes = 0;
  double _averageWeeklyFlowMinutes = 0.0;
  int _rangeDays = 7;
  
  // Animation und visuelle Effekte
  late AnimationController _animationController;
  bool _isLoading = true;
  String _trend = "neutral"; // "up", "down" oder "neutral"
  double _progressPercentage = 0.0; // Für Goal-Tracking
  
  // Weekly Goal (in Minuten)
  final int _weeklyFlowGoal = 300;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    
    _loadDataForFilter(_currentFilter);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDataForFilter(String filter) async {
    setState(() {
      _isLoading = true;
    });
    
    final box = await Hive.openBox<Map>('flow_sessions');
    final allSessions = _boxToFlowSessions(box);
    final now = DateTime.now();

    List<FlowSession> filtered;
    List<FlowSession> previousPeriodSessions;

    if (filter == 'week') {
      _rangeDays = 7;
      final from = now.subtract(const Duration(days: 6));
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from))).toList();
      
      // Vorherige Woche für Trendanalyse
      final previousFrom = from.subtract(const Duration(days: 7));
      previousPeriodSessions = allSessions.where((fs) => 
        fs.date.isAfter(_startOfDay(previousFrom)) && 
        fs.date.isBefore(_startOfDay(from))
      ).toList();
      
      _setupWeekData(filtered);
    } else if (filter == 'month') {
      _rangeDays = 28;
      final from = now.subtract(const Duration(days: 27));
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from))).toList();
      
      // Vorheriger Monat
      final previousFrom = from.subtract(const Duration(days: 28));
      previousPeriodSessions = allSessions.where((fs) => 
        fs.date.isAfter(_startOfDay(previousFrom)) && 
        fs.date.isBefore(_startOfDay(from))
      ).toList();
      
      _setupMonthData(filtered);
    } else {
      _rangeDays = 365;
      final from = DateTime(now.year - 1, now.month, now.day);
      filtered = allSessions.where((fs) => fs.date.isAfter(_startOfDay(from))).toList();
      
      // Vorheriges Jahr
      final previousFrom = DateTime(now.year - 2, now.month, now.day);
      previousPeriodSessions = allSessions.where((fs) => 
        fs.date.isAfter(_startOfDay(previousFrom)) && 
        fs.date.isBefore(_startOfDay(from))
      ).toList();
      
      _setupYearData(filtered);
    }

    _totalFlowCount = filtered.length;
    _totalFlowMinutes = filtered.fold<int>(0, (sum, fs) => sum + fs.minutes);
    _averageFlowMinutes = _totalFlowCount > 0 ? _totalFlowMinutes / _totalFlowCount : 0.0;

    if (_rangeDays > 0) {
      final weeks = _rangeDays / 7.0;
      _averageWeeklyFlowMinutes = weeks > 0 ? _totalFlowMinutes / weeks : 0.0;
    } else {
      _averageWeeklyFlowMinutes = 0.0;
    }
    
    // Trendberechnung
    int previousTotalMinutes = previousPeriodSessions.fold<int>(0, (sum, fs) => sum + fs.minutes);
    if (previousTotalMinutes > 0) {
      double change = (_totalFlowMinutes - previousTotalMinutes) / previousTotalMinutes;
      if (change > 0.05) {
        _trend = "up";
      } else if (change < -0.05) {
        _trend = "down";
      } else {
        _trend = "neutral";
      }
    } else {
      _trend = "neutral";
    }
    
    // Fortschrittsberechnung für das Wochenziel
    if (_currentFilter == 'week') {
      _progressPercentage = _totalFlowMinutes / _weeklyFlowGoal;
      _progressPercentage = _progressPercentage.clamp(0.0, 1.0);
    } else {
      _progressPercentage = 0;
    }

    setState(() {
      _isLoading = false;
    });
  }

  // DATENAUFBEREITUNG
  void _setupWeekData(List<FlowSession> sessions) {
    final List<double> dayTotals = List.filled(7, 0.0);
    for (var fs in sessions) {
      final day = (fs.date.weekday - 1) % 7;
      dayTotals[day] += fs.minutes;
    }
    _barValues = dayTotals;
    
    final now = DateTime.now();
    final List<String> labels = [];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      labels.add('${_getDayInitial(day.weekday)}\n${day.day}');
    }
    _barLabels = labels.reversed.toList();
  }

  String _getDayInitial(int weekday) {
    switch (weekday) {
      case 1: return 'M';
      case 2: return 'T';
      case 3: return 'W';
      case 4: return 'T';
      case 5: return 'F';
      case 6: return 'S';
      case 7: return 'S';
      default: return '?';
    }
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

  // UI-Bau
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          loc.flowStatsTitle,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.6),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, size: 22),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF121212),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFDF1B1B),
              ),
            )
          : Stack(
              children: [
                // Hintergrundgradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.red.shade900.withOpacity(0.4),
                        Colors.black,
                        Colors.black,
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Zeitfilter
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                                color: Colors.grey.shade800, width: 1.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildFilterButton('week', loc.filterWeek),
                              const SizedBox(width: 8),
                              _buildFilterButton('month', loc.filterMonth),
                              const SizedBox(width: 8),
                              _buildFilterButton('year', loc.filterYear),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Key metrics cards
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _animationController.value,
                              child: child,
                            );
                          },
                          child: _buildKeyMetricsRow(),
                        ),
                        const SizedBox(height: 24),
                        // Goal Tracking (nur für Woche)
                        if (_currentFilter == 'week') _buildGoalTracker(),
                        // Chart title
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 8.0, bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getChartTitle(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              _buildTrendIndicator(),
                            ],
                          ),
                        ),
                        // Chart card
                        Container(
                          height: 280,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                                color: Colors.grey.shade800, width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.shade900.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _animationController.value,
                                child: child,
                              );
                            },
                            child: _buildBarChart(context),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stats Liste
                        _buildStatsList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // FILTER-BUTTON
  Widget _buildFilterButton(String filterKey, String label) {
    final isSelected = _currentFilter == filterKey;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          _animationController.reset();
          _animationController.forward();
          setState(() {
            _currentFilter = filterKey;
            _loadDataForFilter(filterKey);
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDF1B1B) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFDF1B1B).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // Key metrics cards
  Widget _buildKeyMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.timer,
            title: loc.totalTime,
            value: '$_totalFlowMinutes min',
            iconColor: const Color(0xFFDF1B1B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.insights,
            title: loc.statFlows,
            value: '$_totalFlowCount',
            iconColor: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.auto_graph,
            title: loc.avgDuration,
            value: '${_averageFlowMinutes.toStringAsFixed(1)} min',
            iconColor: Colors.teal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade800, width: 1.0),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 28.0,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  // Goal tracking progress bar (nur für Weekly View)
  Widget _buildGoalTracker() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade800, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Goal Progress', // Kann auch lokalisiert werden
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$_totalFlowMinutes / $_weeklyFlowGoal min',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: _progressPercentage),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey.shade800,
                      color: _getProgressColor(value),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(value * 100).toInt()}% Complete',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  Color _getProgressColor(double value) {
    if (value < 0.3) return Colors.red;
    if (value < 0.7) return Colors.orange;
    return Colors.green;
  }
  
  Widget _buildTrendIndicator() {
    IconData icon;
    Color color;
    String text;
    
    switch (_trend) {
      case "up":
        icon = Icons.trending_up;
        color = Colors.green;
        text = loc.improving;
        break;
      case "down":
        icon = Icons.trending_down;
        color = Colors.red;
        text = loc.declining;
        break;
      default:
        icon = Icons.trending_flat;
        color = Colors.amber;
        text = loc.stable;
    }
    
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  String _getChartTitle() {
    switch(_currentFilter) {
      case 'week':
        return loc.dailyFlowMinutes;
      case 'month':
        return loc.weeklyFlowMinutes;
      case 'year':
        return loc.monthlyFlowMinutes;
      default:
        return loc.flowMinutes;
    }
  }
  
  // BARCHART
  Widget _buildBarChart(BuildContext context) {
    if (_barValues.isEmpty) {
      return Center(
        child: Text(
          loc.noDataMessage,
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      );
    }
    
    final maxVal = _barValues.reduce(max);
    final maxY = (maxVal < 10) ? 10.0 : (maxVal * 1.2);
    
    double barWidth = 30;
    if (_barValues.length >= 12) {
      barWidth = 20;
    } else if (_barValues.length <= 4) {
      barWidth = 40;
    }
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${_barValues[groupIndex].toInt()} min',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white10,
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
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _barLabels[idx],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        barGroups: List.generate(_barValues.length, (index) {
          final val = _barValues[index];
          const gradient = LinearGradient(
            colors: [Color(0xFFDF1B1B), Color(0xFFFF4A4A)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          );
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: val,
                gradient: gradient,
                width: barWidth,
                borderRadius: BorderRadius.circular(8),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  // STATS-LISTE
  Widget _buildStatsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade800, width: 1.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _statItem(title: loc.statFlows, value: _totalFlowCount.toString(), icon: Icons.checklist_rtl),
          const SizedBox(height: 12),
          _statItem(title: loc.statTotalMinutes, value: _totalFlowMinutes.toString(), icon: Icons.timer),
          const SizedBox(height: 12),
          _statItem(
            title: loc.statAverageFlow,
            value: _averageFlowMinutes.toStringAsFixed(1),
            icon: Icons.equalizer,
          ),
          const SizedBox(height: 12),
          _statItem(
            title: loc.statAverageWeeklyFlow,
            value: _averageWeeklyFlowMinutes.isNaN ? '0.0' : _averageWeeklyFlowMinutes.toStringAsFixed(1),
            icon: Icons.calendar_view_week,
          ),
          const SizedBox(height: 12),
          _statItem(
            title: loc.flowConsistency,
            value: _calculateConsistency().toStringAsFixed(1) + '%',
            icon: Icons.repeat,
          ),
        ],
      ),
    );
  }
  
  Widget _statItem({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFDF1B1B).withOpacity(0.8),
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
  
  // Berechnet Flow-Konsistenz (Prozentsatz der Tage mit Sessions)
  double _calculateConsistency() {
    if (_currentFilter == 'week') {
      Set<int> daysWithSessions = {};
      for (int i = 0; i < _barValues.length; i++) {
        if (_barValues[i] > 0) {
          daysWithSessions.add(i);
        }
      }
      return (daysWithSessions.length / 7) * 100;
    } else if (_currentFilter == 'month') {
      int weeksWithSessions = 0;
      for (int i = 0; i < _barValues.length; i++) {
        if (_barValues[i] > 0) {
          weeksWithSessions++;
        }
      }
      return (weeksWithSessions / 4) * 100;
    } else {
      int monthsWithSessions = 0;
      for (int i = 0; i < _barValues.length; i++) {
        if (_barValues[i] > 0) {
          monthsWithSessions++;
        }
      }
      return (monthsWithSessions / 12) * 100;
    }
  }
  
  // Info-Dialog
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFDF1B1B),
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      loc.infoTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  loc.infoContent,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                _buildHelpItem(
                  icon: Icons.filter_list,
                  title: loc.helpTimeFiltersTitle,
                  description: loc.helpTimeFiltersDescription,
                ),
                const SizedBox(height: 12),
                _buildHelpItem(
                  icon: Icons.bar_chart,
                  title: loc.helpBarChartTitle,
                  description: loc.helpBarChartDescription,
                ),
                const SizedBox(height: 12),
                _buildHelpItem(
                  icon: Icons.track_changes,
                  title: loc.helpWeeklyGoalTitle,
                  description: loc.helpWeeklyGoalDescription,
                ),
                const SizedBox(height: 12),
                _buildHelpItem(
                  icon: Icons.trending_up,
                  title: loc.helpTrendIndicatorTitle,
                  description: loc.helpTrendIndicatorDescription,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDF1B1B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    loc.gotIt,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
    final dateFormatter = DateFormat('d MMM');
    
    for (int i = 0; i < numberOfWeeks; i++) {
      final weekStart = startDay.add(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final startLabel = dateFormatter.format(weekStart).substring(0, 5);
      final endLabel = dateFormatter.format(weekEnd).substring(0, 5);
      labels.add('$startLabel-$endLabel');
    }
    return labels;
  }

  List<String> _generateLast12MonthLabels(DateTime now) {
    final List<String> labels = [];
    final dateFormatter = DateFormat('MMM yy');
    
    for (int i = 11; i >= 0; i--) {
      final thatMonth = DateTime(now.year, now.month - i, 1);
      labels.add(dateFormatter.format(thatMonth));
    }
    return labels;
  }

  String _monthToShort(int m) {
    switch (m) {
      case 1:  return 'Jan';
      case 2:  return 'Feb';
      case 3:  return 'Mar';
      case 4:  return 'Apr';
      case 5:  return 'May';
      case 6:  return 'Jun';
      case 7:  return 'Jul';
      case 8:  return 'Aug';
      case 9:  return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '?';
    }
  }
}
