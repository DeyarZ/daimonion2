import 'package:hive/hive.dart';

part 'gamification_service.g.dart';

@HiveType(typeId: 1)
class GamificationStats extends HiveObject {
  @HiveField(0)
  int xp;

  GamificationStats({required this.xp});
}

class LevelThreshold {
  final int level;
  final int totalXPNeeded;
  final String status;

  const LevelThreshold({
    required this.level,
    required this.totalXPNeeded,
    required this.status,
  });
}

final List<LevelThreshold> levelTable = [
  LevelThreshold(level: 0, totalXPNeeded: 0, status: 'Rekrut'),
  LevelThreshold(level: 1, totalXPNeeded: 0, status: 'Rekrut'),
  LevelThreshold(level: 2, totalXPNeeded: 100, status: 'Rekrut'),
  LevelThreshold(level: 3, totalXPNeeded: 250, status: 'Rekrut'),
  LevelThreshold(level: 4, totalXPNeeded: 450, status: 'Rekrut'),
  LevelThreshold(level: 5, totalXPNeeded: 700, status: 'Soldat'),
  LevelThreshold(level: 6, totalXPNeeded: 1000, status: 'Soldat'),
  LevelThreshold(level: 7, totalXPNeeded: 1400, status: 'Soldat'),
  LevelThreshold(level: 8, totalXPNeeded: 1900, status: 'Elite-Soldat'),
  LevelThreshold(level: 9, totalXPNeeded: 2500, status: 'Elite-Soldat'),
  LevelThreshold(level: 10, totalXPNeeded: 3500, status: 'Elite-Soldat'),
  LevelThreshold(level: 11, totalXPNeeded: 4800, status: 'Veteran'),
  LevelThreshold(level: 12, totalXPNeeded: 6400, status: 'Veteran'),
  LevelThreshold(level: 13, totalXPNeeded: 8300, status: 'Veteran'),
  LevelThreshold(level: 14, totalXPNeeded: 10500, status: 'Veteran'),
  LevelThreshold(level: 15, totalXPNeeded: 13000, status: 'Veteran'),
  LevelThreshold(level: 16, totalXPNeeded: 16000, status: 'Sergeant'),
  LevelThreshold(level: 17, totalXPNeeded: 19500, status: 'Sergeant'),
  LevelThreshold(level: 18, totalXPNeeded: 23500, status: 'Sergeant'),
  LevelThreshold(level: 19, totalXPNeeded: 28000, status: 'Sergeant'),
  LevelThreshold(level: 20, totalXPNeeded: 33000, status: 'Sergeant'),
  LevelThreshold(level: 21, totalXPNeeded: 38500, status: 'Leutnant'),
  LevelThreshold(level: 22, totalXPNeeded: 44500, status: 'Leutnant'),
  LevelThreshold(level: 23, totalXPNeeded: 51000, status: 'Leutnant'),
  LevelThreshold(level: 24, totalXPNeeded: 58000, status: 'Leutnant'),
  LevelThreshold(level: 25, totalXPNeeded: 65500, status: 'Leutnant'),
  LevelThreshold(level: 26, totalXPNeeded: 73500, status: 'Captain'),
  LevelThreshold(level: 27, totalXPNeeded: 82000, status: 'Captain'),
  LevelThreshold(level: 28, totalXPNeeded: 91000, status: 'Captain'),
  LevelThreshold(level: 29, totalXPNeeded: 100500, status: 'Captain'),
  LevelThreshold(level: 30, totalXPNeeded: 110500, status: 'Captain'),
  LevelThreshold(level: 31, totalXPNeeded: 121500, status: 'Major'),
  LevelThreshold(level: 32, totalXPNeeded: 133500, status: 'Major'),
  LevelThreshold(level: 33, totalXPNeeded: 146500, status: 'Major'),
  LevelThreshold(level: 34, totalXPNeeded: 160500, status: 'Major'),
  LevelThreshold(level: 35, totalXPNeeded: 175500, status: 'Major'),
  LevelThreshold(level: 36, totalXPNeeded: 191500, status: 'Colonel'),
  LevelThreshold(level: 37, totalXPNeeded: 208500, status: 'Colonel'),
  LevelThreshold(level: 38, totalXPNeeded: 226500, status: 'Colonel'),
  LevelThreshold(level: 39, totalXPNeeded: 245500, status: 'Colonel'),
  LevelThreshold(level: 40, totalXPNeeded: 265500, status: 'Colonel'),
  LevelThreshold(level: 41, totalXPNeeded: 287000, status: 'General'),
  LevelThreshold(level: 42, totalXPNeeded: 309500, status: 'General'),
  LevelThreshold(level: 43, totalXPNeeded: 333000, status: 'General'),
  LevelThreshold(level: 44, totalXPNeeded: 357500, status: 'General'),
  LevelThreshold(level: 45, totalXPNeeded: 383000, status: 'General'),
  LevelThreshold(level: 46, totalXPNeeded: 410500, status: 'Kriegsherr'),
  LevelThreshold(level: 47, totalXPNeeded: 439000, status: 'Kriegsherr'),
  LevelThreshold(level: 48, totalXPNeeded: 468500, status: 'Kriegsherr'),
  LevelThreshold(level: 49, totalXPNeeded: 499000, status: 'Kriegsherr'),
  LevelThreshold(level: 50, totalXPNeeded: 530500, status: 'Kriegsherr'),
  LevelThreshold(level: 51, totalXPNeeded: 563500, status: 'Daimonion-Warlord'),
  LevelThreshold(level: 52, totalXPNeeded: 597500, status: 'Daimonion-Warlord'),
  LevelThreshold(level: 53, totalXPNeeded: 632500, status: 'Daimonion-Warlord'),
  LevelThreshold(level: 54, totalXPNeeded: 668500, status: 'Daimonion-Warlord'),
  LevelThreshold(level: 55, totalXPNeeded: 705500, status: 'Daimonion-Warlord'),
  LevelThreshold(level: 56, totalXPNeeded: 743500, status: 'Legende'),
  LevelThreshold(level: 57, totalXPNeeded: 782500, status: 'Legende'),
  LevelThreshold(level: 58, totalXPNeeded: 822500, status: 'Legende'),
  LevelThreshold(level: 59, totalXPNeeded: 863500, status: 'Legende'),
  LevelThreshold(level: 60, totalXPNeeded: 905500, status: 'Legende'),
  LevelThreshold(level: 61, totalXPNeeded: 948500, status: 'Unsterblicher'),
  LevelThreshold(level: 62, totalXPNeeded: 992500, status: 'Unsterblicher'),
  LevelThreshold(level: 63, totalXPNeeded: 1037500, status: 'Unsterblicher'),
  LevelThreshold(level: 64, totalXPNeeded: 1083500, status: 'Unsterblicher'),
  LevelThreshold(level: 65, totalXPNeeded: 1130500, status: 'Unsterblicher'),
  LevelThreshold(level: 66, totalXPNeeded: 1178500, status: 'Unsterblicher'),
  LevelThreshold(level: 67, totalXPNeeded: 1227500, status: 'Unsterblicher'),
  LevelThreshold(level: 68, totalXPNeeded: 1277500, status: 'Unsterblicher'),
  LevelThreshold(level: 69, totalXPNeeded: 1328500, status: 'Unsterblicher'),
  LevelThreshold(level: 70, totalXPNeeded: 1380500, status: 'Unsterblicher'),
  LevelThreshold(level: 80, totalXPNeeded: 1600000, status: 'Unsterblicher'),
  LevelThreshold(level: 90, totalXPNeeded: 1850000, status: 'Unsterblicher'),
  LevelThreshold(level: 100, totalXPNeeded: 2000000, status: 'Unsterblicher'),
];

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;

  GamificationService._internal();

  Box<GamificationStats>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<GamificationStats>('gamificationBox');
    if (_box!.isEmpty) {
      await _box!.add(GamificationStats(xp: 0));
    }
  }

  GamificationStats get _stats => _box!.getAt(0)!;

  int get currentXP => _stats.xp;
  int get currentLevel => _calculateLevelFromXP(_stats.xp);
  String get currentStatus => _calculateStatusFromLevel(currentLevel);

  /// Berechnet den Fortschritt zum nächsten Level (0 bis 1)
  double get levelProgress {
    final level = currentLevel;
    final xpCurrentLevel = getXPNeededForLevel(level);
    final xpNextLevel = getXPNeededForLevel(level + 1);

    if (xpNextLevel <= xpCurrentLevel) return 1.0;

    final xpProgress = currentXP - xpCurrentLevel;
    final xpDelta = xpNextLevel - xpCurrentLevel;

    return xpDelta == 0 ? 0.0 : (xpProgress / xpDelta).clamp(0.0, 1.0);
  }

  /// Fügt eine feste Menge an XP hinzu
  Future<void> addXP(int amount) async {
    _stats.xp += amount;
    await _stats.save();
  }

  /// Fügt XP hinzu basierend auf Streak-Bonus
  Future<void> addXPWithStreak(int baseXP) async {
    final settingsBox = Hive.box('settings');
    final streak = settingsBox.get('streak', defaultValue: 1) as int;

    double multiplier = 1.0;
    if (streak >= 7) multiplier = 1.05;
    if (streak >= 14) multiplier = 1.1;
    if (streak >= 30) multiplier = 1.15;

    final int finalXP = (baseXP * multiplier).round();
    await addXP(finalXP);
  }

  /// Setzt die XP auf einen bestimmten Wert
  Future<void> setXP(int newXP) async {
    _stats.xp = newXP;
    await _stats.save();
  }

  /// Berechnet das Level basierend auf der aktuellen XP
  int _calculateLevelFromXP(int xp) {
    int userLevel = 0;
    for (var threshold in levelTable) {
      if (xp >= threshold.totalXPNeeded) {
        userLevel = threshold.level;
      } else {
        break;
      }
    }
    return userLevel;
  }

  /// Bestimmt den Status basierend auf dem aktuellen Level
  String _calculateStatusFromLevel(int level) {
    final found = levelTable.lastWhere(
      (t) => t.level <= level,
      orElse: () => levelTable.first,
    );
    return found.status;
  }

  /// Gibt die benötigte XP für ein bestimmtes Level zurück
  int getXPNeededForLevel(int level) {
    if (level < 0) return 0;
    final found = levelTable.lastWhere(
      (threshold) => threshold.level == level,
      orElse: () => levelTable.last,
    );
    return found.totalXPNeeded;
  }

  /// Vergibt tägliche XP für Journaling
  Future<void> awardDailyJournalXP() async {
    const int journalXP = 50; // Beispielwert für tägliche XP
    await addXP(journalXP);
  }
}
