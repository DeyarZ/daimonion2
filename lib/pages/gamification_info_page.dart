import 'package:flutter/material.dart';
import 'package:daimonion_app/l10n/generated/l10n.dart';

class GamificationInfoPage extends StatelessWidget {
  const GamificationInfoPage({Key? key}) : super(key: key);

  // Kleiner Helper für den Table-Container:
  Widget _buildTableContainer(Widget table) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 44, 44, 44), const Color.fromARGB(255, 48, 48, 48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: table,
    );
  }

  // Um den Rang-String in einen Dateinamen zu konvertieren:
  String _badgePathForRank(String rank) {
    final filename = rank.toLowerCase().replaceAll(" ", "_");
    return 'assets/badges/$filename.png';
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.levels_and_rankings),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  loc.how_to_earn_xp,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: const Color.fromARGB(255, 223, 27, 27),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTableContainer(
                DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.grey.shade800,
                  ),
                  columns: [
                    DataColumn(
                      label: Text(loc.action,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: Text(loc.xp,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: Text(loc.max_per_day,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  rows: [
                    _buildXpRow(loc.complete_todo, '1', '5'),
                    _buildXpRow(loc.complete_habit, '1', '5'),
                    _buildXpRow(loc.journal_entry, '2', '2'),
                    _buildXpRow(loc.ten_min_flow, '1', '-'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  loc.levels_and_ranks,
                  style: TextStyle(
                    fontSize: 22,
                    color: const Color.fromARGB(255, 223, 27, 27),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTableContainer(
                DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.grey.shade800,
                  ),
                  columns: [
                    DataColumn(
                      label: Text(loc.level,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: Text(loc.rank,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    DataColumn(
                      label: Text(loc.badge,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  rows: [
                    _buildLevelRow('1', loc.recruit),
                    _buildLevelRow('5', loc.soldier),
                    _buildLevelRow('8', loc.elite_soldier),
                    _buildLevelRow('11', loc.veteran),
                    _buildLevelRow('16', loc.sergeant),
                    _buildLevelRow('21', loc.lieutenant),
                    _buildLevelRow('26', loc.captain),
                    _buildLevelRow('31', loc.major),
                    _buildLevelRow('36', loc.colonel),
                    _buildLevelRow('41', loc.general),
                    _buildLevelRow('46', loc.warlord),
                    _buildLevelRow('51', loc.daimonion_warlord),
                    _buildLevelRow('56', loc.legend),
                    _buildLevelRow('61', loc.immortal),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                loc.keep_grinding,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color.fromARGB(255, 223, 27, 27),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 24),
                label: Text(
                  loc.back,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildXpRow(String action, String xp, String maxPerDay) {
    return DataRow(
      cells: [
        DataCell(Text(action, style: const TextStyle(color: Colors.white70))),
        DataCell(Text(xp, style: const TextStyle(color: Colors.white70))),
        DataCell(Text(maxPerDay, style: const TextStyle(color: Colors.white70))),
      ],
    );
  }

  DataRow _buildLevelRow(String level, String rank) {
    return DataRow(
      cells: [
        DataCell(Text(level, style: const TextStyle(color: Colors.white70))),
        DataCell(Text(rank, style: const TextStyle(color: Colors.white70))),
        DataCell(_buildBadgeCell(rank)),
      ],
    );
  }

  Widget _buildBadgeCell(String rank) {
    final path = _badgePathForRank(rank);
    return Image.asset(
      path,
      width: 32,
      height: 32,
    );
  }
}
