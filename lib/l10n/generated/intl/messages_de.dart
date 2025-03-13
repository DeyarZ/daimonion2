// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static String m0(date) => "Tag wählen: ${date}";

  static String m1(pending) =>
      "Erledige noch ${pending} Aufgaben, um 100% zu erreichen";

  static String m2(percentage) =>
      "Du hast diesen Monat ${percentage}% deiner Aufgaben abgeschlossen!";

  static String m3(count) => "Du hast ${count} Grundlagen verkackt.";

  static String m4(number) => "Tag ${number}";

  static String m5(habitName) =>
      "Möchtest du die Gewohnheit \"${habitName}\" wirklich löschen?";

  static String m6(entryTitle) =>
      "Möchtest du den Eintrag \"${entryTitle}\" wirklich löschen?";

  static String m7(date) => "Fällig am ${date}";

  static String m8(error) => "Ein Fehler ist aufgetreten: ${error}";

  static String m9(currentFlow, totalFlows) =>
      "Flow ${currentFlow} / ${totalFlows}";

  static String m10(usedPrompts) =>
      "Kostenlose Prompts genutzt: ${usedPrompts} / 5";

  static String m11(level) => "Stufe ${level}";

  static String m12(level) => "Level ${level}";

  static String m13(date) => "Keine Aufgaben für ${date}";

  static String m14(progress) => "${progress}% zum nächsten Level";

  static String m15(percent, nextLevel) => "${percent}% bis Level ${nextLevel}";

  static String m16(error) => "Fehler beim Kauf: ${error}";

  static String m17(error) =>
      "Fehler beim Wiederherstellen der Käufe: ${error}";

  static String m18(status) => "Status: ${status}";

  static String m19(streak) => "${streak} Tage Streak";

  static String m20(count) =>
      "${Intl.plural(count, one: 'Aufgabe', other: 'Aufgaben')}";

  static String m21(bonusPercent) => "XP Bonus: ${bonusPercent}%";

  static String m22(xpProgress, xpToNextLevel) =>
      "${xpProgress} / ${xpToNextLevel} XP";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "aboutStatistics":
            MessageLookupByLibrary.simpleMessage("Über Statistiken"),
        "aboutStatisticsContent": MessageLookupByLibrary.simpleMessage(
            "Diese Seite zeigt deine Aufgabenabschlussstatistiken. Die Kalenderansicht zeigt tägliche Abschlussraten, während der Analyse-Tab wöchentliche Fortschritte und monatliche Zusammenfassungen bietet."),
        "access_habit_tracker": MessageLookupByLibrary.simpleMessage(
            "Zugriff auf den Gewohnheitstracker"),
        "access_journal": MessageLookupByLibrary.simpleMessage(
            "Zugriff auf das Journal-Tool"),
        "accountTitle": MessageLookupByLibrary.simpleMessage("Konto"),
        "action": MessageLookupByLibrary.simpleMessage("Aktion"),
        "addExercise": MessageLookupByLibrary.simpleMessage("Übung hinzufügen"),
        "addExerciseSnackbar":
            MessageLookupByLibrary.simpleMessage("Gib eine Übung ein!"),
        "addNewHabit":
            MessageLookupByLibrary.simpleMessage("Neue Gewohnheit hinzufügen"),
        "addNewTask":
            MessageLookupByLibrary.simpleMessage("Neue Aufgabe hinzufügen"),
        "addPoints": MessageLookupByLibrary.simpleMessage(
            "Du hast 2 XP für die abgeschlossene Aufgabe erhalten!"),
        "addTask": MessageLookupByLibrary.simpleMessage("Add"),
        "addTodo": MessageLookupByLibrary.simpleMessage("Add"),
        "allHabits": MessageLookupByLibrary.simpleMessage("Alle Gewohnheiten"),
        "allTasksCompleted": MessageLookupByLibrary.simpleMessage(
            "Klasse, du hast alle Aufgaben abgeschlossen!"),
        "analyticsTab": MessageLookupByLibrary.simpleMessage("Analyse"),
        "appBarTitle": MessageLookupByLibrary.simpleMessage("Daimonion Chat"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Trainingsplan"),
        "atLeastOneWorkoutDay": MessageLookupByLibrary.simpleMessage(
            "Du brauchst mindestens einen verdammten Trainingstag! Tu was für deinen Körper!"),
        "autoStartBreak":
            MessageLookupByLibrary.simpleMessage("Automatisch Pause starten"),
        "autoStartNextFlow": MessageLookupByLibrary.simpleMessage(
            "Automatisch nächsten Flow starten"),
        "auto_renewal":
            MessageLookupByLibrary.simpleMessage("Automatische Verlängerung"),
        "back": MessageLookupByLibrary.simpleMessage("Zurück"),
        "back_button": MessageLookupByLibrary.simpleMessage("Zurück"),
        "badge": MessageLookupByLibrary.simpleMessage("Abzeichen"),
        "buyPremium": MessageLookupByLibrary.simpleMessage("Premium kaufen"),
        "byCategory": MessageLookupByLibrary.simpleMessage("Nach Kategorie"),
        "calendarTab": MessageLookupByLibrary.simpleMessage("Kalender"),
        "calendarViewTitle":
            MessageLookupByLibrary.simpleMessage("Kalender-Übersicht"),
        "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "cancelButton": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "captain": MessageLookupByLibrary.simpleMessage("Captain"),
        "categoryLabel": MessageLookupByLibrary.simpleMessage("Kategorie"),
        "changeDate": MessageLookupByLibrary.simpleMessage("Datum ändern"),
        "changeDeadline":
            MessageLookupByLibrary.simpleMessage("Deadline ändern"),
        "chatbotModeBrutal":
            MessageLookupByLibrary.simpleMessage("Brutal Ehrlich"),
        "chatbotModeHard": MessageLookupByLibrary.simpleMessage("Hart"),
        "chatbotModeNormal": MessageLookupByLibrary.simpleMessage("Normal"),
        "chatbotWarning": MessageLookupByLibrary.simpleMessage(
            "Achtung: Im Modus \"Brutal Ehrlich\" wirst du beleidigt und extrem herausgefordert."),
        "cheerAlmost": MessageLookupByLibrary.simpleMessage(
            "Noch nicht fertig, aber du packst das. Nur weitermachen!"),
        "cheerHalf": MessageLookupByLibrary.simpleMessage(
            "Schon über die Hälfte deiner Gewohnheiten geschafft – stark!"),
        "cheerPerfect": MessageLookupByLibrary.simpleMessage(
            "Perfekt! Du hast heute alle Gewohnheiten erledigt. Keep pushing!"),
        "cheerStart": MessageLookupByLibrary.simpleMessage(
            "Pack an! Zeit, etwas zu tun!"),
        "chooseDay": m0,
        "chooseWorkoutColor":
            MessageLookupByLibrary.simpleMessage("Wähle Trainingsfarbe"),
        "close": MessageLookupByLibrary.simpleMessage("Schließen"),
        "colonel": MessageLookupByLibrary.simpleMessage("Colonel"),
        "colorLabel": MessageLookupByLibrary.simpleMessage("Farbe wählen"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("Bald verfügbar"),
        "comingSoonDescription": MessageLookupByLibrary.simpleMessage(
            "Diese Funktion wird bald verfügbar sein!"),
        "coming_soon": MessageLookupByLibrary.simpleMessage("Bald verfügbar"),
        "coming_soon_description": MessageLookupByLibrary.simpleMessage(
            "Diese Option wird bald verfügbar sein!"),
        "completeMoreTasks": m1,
        "complete_habit":
            MessageLookupByLibrary.simpleMessage("Gewohnheit abschließen"),
        "complete_todo":
            MessageLookupByLibrary.simpleMessage("To-Do erledigen"),
        "completed": MessageLookupByLibrary.simpleMessage("Erledigt"),
        "completedTasksPercentage": m2,
        "confirmDelete": MessageLookupByLibrary.simpleMessage("Ja, löschen"),
        "confirmDeleteHabit":
            MessageLookupByLibrary.simpleMessage("Ja, löschen"),
        "continueButton": MessageLookupByLibrary.simpleMessage("Weiter"),
        "couldNotSendFeedback": MessageLookupByLibrary.simpleMessage(
            "Feedback konnte nicht gesendet werden"),
        "currency_symbol": MessageLookupByLibrary.simpleMessage("€"),
        "currentAppVersion":
            MessageLookupByLibrary.simpleMessage("Aktuelle App-Version"),
        "dailyFundamentalsTitle":
            MessageLookupByLibrary.simpleMessage("GRUNDLAGEN"),
        "dailyInsultAllMissed": MessageLookupByLibrary.simpleMessage(
            "Du hast ALLE Grundlagen ignoriert!"),
        "dailyInsultSomeMissed": m3,
        "dailyInsultTitle":
            MessageLookupByLibrary.simpleMessage("Du hast verkackt!"),
        "dailyProgress":
            MessageLookupByLibrary.simpleMessage("Täglicher Fortschritt"),
        "dailyReminderActivated": MessageLookupByLibrary.simpleMessage(
            "Täglicher Reminder um 20:00 aktiviert!"),
        "dailyReminderBody": MessageLookupByLibrary.simpleMessage(
            "Vergiss nicht, deine Aufgaben für heute zu erledigen!"),
        "dailyReminderDeactivated": MessageLookupByLibrary.simpleMessage(
            "Täglicher Reminder wurde deaktiviert."),
        "dailyReminderTitle":
            MessageLookupByLibrary.simpleMessage("Tägliche Erinnerung"),
        "dailyTodoChannelDesc": MessageLookupByLibrary.simpleMessage(
            "Erinnert dich jeden Tag um 20:00 an deine Aufgaben."),
        "dailyTodoChannelName":
            MessageLookupByLibrary.simpleMessage("Täglicher To-Do Reminder"),
        "daimonion_warlord":
            MessageLookupByLibrary.simpleMessage("Daimonion-Warlord"),
        "dashboardTitle": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "day": m4,
        "deadline": MessageLookupByLibrary.simpleMessage("Fälligkeitsdatum"),
        "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
        "deleteHabitConfirmation": MessageLookupByLibrary.simpleMessage(
            "Bist du sicher, dass du die Gewohnheit löschen möchtest?"),
        "deleteHabitMessage": m5,
        "deleteHabitTitle":
            MessageLookupByLibrary.simpleMessage("Gewohnheit löschen"),
        "deleteJournalEntryMessage": m6,
        "deleteJournalEntryTitle":
            MessageLookupByLibrary.simpleMessage("Löschen?"),
        "deleteTask": MessageLookupByLibrary.simpleMessage("Löschen"),
        "description": MessageLookupByLibrary.simpleMessage("Beschreibung"),
        "detailedUserStats": MessageLookupByLibrary.simpleMessage(
            "Hier werden detaillierte Statistiken über deine Produktivität, Streaks und Fortschritte angezeigt."),
        "doubleTapToFavorite": MessageLookupByLibrary.simpleMessage(
            "Doppelt tippen, um als Favorit zu markieren"),
        "dueOn": m7,
        "edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "editDayTitle": MessageLookupByLibrary.simpleMessage("Tag bearbeiten"),
        "editExerciseTitle":
            MessageLookupByLibrary.simpleMessage("Übungsdetails bearbeiten"),
        "editHabitTitle":
            MessageLookupByLibrary.simpleMessage("Gewohnheit bearbeiten"),
        "editJournalEntry":
            MessageLookupByLibrary.simpleMessage("Eintrag bearbeiten"),
        "editProfile":
            MessageLookupByLibrary.simpleMessage("Profil bearbeiten"),
        "editProfileHint":
            MessageLookupByLibrary.simpleMessage("Gib deinen Namen ein..."),
        "editProfileTitle":
            MessageLookupByLibrary.simpleMessage("Profil bearbeiten"),
        "editTask": MessageLookupByLibrary.simpleMessage("Aufgabe bearbeiten"),
        "editTaskDialogTitle":
            MessageLookupByLibrary.simpleMessage("Aufgabe bearbeiten"),
        "editWorkoutName":
            MessageLookupByLibrary.simpleMessage("Workout-Namen bearbeiten"),
        "elite_soldier": MessageLookupByLibrary.simpleMessage("Elite-Soldat"),
        "emailAppNotFound":
            MessageLookupByLibrary.simpleMessage("Keine E-Mail-App gefunden"),
        "emptyNameError": MessageLookupByLibrary.simpleMessage(
            "Bitte gib einen Namen für die Gewohnheit ein."),
        "emptyTitleError": MessageLookupByLibrary.simpleMessage(
            "Der Titel darf nicht leer sein!"),
        "errorContent": MessageLookupByLibrary.simpleMessage(
            "Es ist ein Fehler aufgetreten. Bitte versuche es später erneut."),
        "errorOccurred": m8,
        "errorTitle": MessageLookupByLibrary.simpleMessage("Fehler"),
        "error_title": MessageLookupByLibrary.simpleMessage("Fehler"),
        "exerciseDetails":
            MessageLookupByLibrary.simpleMessage("Übungsdetails"),
        "exerciseName": MessageLookupByLibrary.simpleMessage("Übungsname"),
        "exercises": MessageLookupByLibrary.simpleMessage("Übungen"),
        "favoriteTooltip":
            MessageLookupByLibrary.simpleMessage("Als Favorit markieren"),
        "features_label":
            MessageLookupByLibrary.simpleMessage("Was ist enthalten:"),
        "feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
        "feedbackButtonLabel": MessageLookupByLibrary.simpleMessage("Feedback"),
        "feedbackEmailBody": MessageLookupByLibrary.simpleMessage(
            "Ich möchte folgendes Feedback geben:"),
        "feedbackEmailSubject":
            MessageLookupByLibrary.simpleMessage("Feedback für Daimonion"),
        "filterMonth": MessageLookupByLibrary.simpleMessage("Monat"),
        "filterWeek": MessageLookupByLibrary.simpleMessage("Woche"),
        "filterYear": MessageLookupByLibrary.simpleMessage("Jahr"),
        "firstTimeButtonText":
            MessageLookupByLibrary.simpleMessage("ICH BIN BEREIT"),
        "firstTimeHeadline": MessageLookupByLibrary.simpleMessage(
            "WILLST DU JEMAND SEIN, DER KONTROLLE HAT,\nODER WILLST DU EIN SKLAVE DEINER IMPULSE BLEIBEN?"),
        "flowCounter": m9,
        "flowStatsTitle": MessageLookupByLibrary.simpleMessage("Flow Stats"),
        "flowTimer": MessageLookupByLibrary.simpleMessage("Flow Timer"),
        "flowTimerBreakLabel": MessageLookupByLibrary.simpleMessage("Pause"),
        "flowTimerDescription": MessageLookupByLibrary.simpleMessage(
            "Bleibe fokussiert mit Deep-Work-Sessions."),
        "flowTimerHelp": MessageLookupByLibrary.simpleMessage(
            "Nutze den Flow-Timer, um Aufgaben in fokussierte Arbeitseinheiten zu unterteilen."),
        "flowTimerSetFlowsHint":
            MessageLookupByLibrary.simpleMessage("Anzahl der Flows"),
        "flowTimerSetFlowsTitle":
            MessageLookupByLibrary.simpleMessage("Flow-Einstellungen"),
        "flowTimerSetTimeHint":
            MessageLookupByLibrary.simpleMessage("Minuten eingeben..."),
        "flowTimerSetTimeTitle":
            MessageLookupByLibrary.simpleMessage("Flow-Zeit einstellen"),
        "flowTimerTitle": MessageLookupByLibrary.simpleMessage("Flow-Timer"),
        "flowTimerToolTitle":
            MessageLookupByLibrary.simpleMessage("Flow-Timer"),
        "freePromptsCounter": m10,
        "friday": MessageLookupByLibrary.simpleMessage("Freitag"),
        "fridayShort": MessageLookupByLibrary.simpleMessage("Fr"),
        "fullCheckGym": MessageLookupByLibrary.simpleMessage(
            "Hast du heute was für dein Körper getan?"),
        "fullCheckHealthyEating": MessageLookupByLibrary.simpleMessage(
            "Hast du heute gesund gegessen?"),
        "fullCheckHelpOthers": MessageLookupByLibrary.simpleMessage(
            "Hast du heute etwas Gutes für andere getan?"),
        "fullCheckMental": MessageLookupByLibrary.simpleMessage(
            "Hast du heute etwas Produktives für deinen Kopf getan?"),
        "fullCheckNoPorn": MessageLookupByLibrary.simpleMessage(
            "Bist du heute von Pornos weggeblieben?"),
        "general": MessageLookupByLibrary.simpleMessage("General"),
        "getPremiumButton": MessageLookupByLibrary.simpleMessage("Get Premium"),
        "goPremium":
            MessageLookupByLibrary.simpleMessage("Upgrade auf Premium"),
        "goalBetterRelationships": MessageLookupByLibrary.simpleMessage(
            "Bessere Beziehungen aufbauen"),
        "goalCareer":
            MessageLookupByLibrary.simpleMessage("Karriere vorantreiben"),
        "goalFit": MessageLookupByLibrary.simpleMessage("Fitter werden"),
        "goalMentalHealth":
            MessageLookupByLibrary.simpleMessage("Mentale Gesundheit stärken"),
        "goalProductivity":
            MessageLookupByLibrary.simpleMessage("Produktiver sein"),
        "goalSaveMoney":
            MessageLookupByLibrary.simpleMessage("Mehr Geld sparen"),
        "gotIt": MessageLookupByLibrary.simpleMessage("Verstanden"),
        "habitDeleted":
            MessageLookupByLibrary.simpleMessage("Gewohnheit gelöscht"),
        "habitHeader": MessageLookupByLibrary.simpleMessage("Habit"),
        "habitNameLabel":
            MessageLookupByLibrary.simpleMessage("Name der Gewohnheit"),
        "habitReminderChannelDescription": MessageLookupByLibrary.simpleMessage(
            "Erinnert dich täglich an deine Gewohnheit."),
        "habitReminderChannelName":
            MessageLookupByLibrary.simpleMessage("Gewohnheits-Reminder"),
        "habitReminderTitle":
            MessageLookupByLibrary.simpleMessage("Gewohnheits-Erinnerung"),
        "habitTrackerDescription": MessageLookupByLibrary.simpleMessage(
            "Baue starke Gewohnheiten auf und halte sie durch."),
        "habitTrackerHelp": MessageLookupByLibrary.simpleMessage(
            "Bleibe konsequent, indem du deine Gewohnheiten regelmäßig nachverfolgst."),
        "habitTrackerTitle":
            MessageLookupByLibrary.simpleMessage("Gewohnheitstracker"),
        "habitTrackerToolTitle":
            MessageLookupByLibrary.simpleMessage("Gewohnheitstracker"),
        "habits": MessageLookupByLibrary.simpleMessage("Gewohnheiten"),
        "hardnessBrutal": MessageLookupByLibrary.simpleMessage("Brutal"),
        "hardnessBrutalDesc": MessageLookupByLibrary.simpleMessage(
            "Unverblümte, rohe und ungefilterte Wahrheit"),
        "hardnessHard": MessageLookupByLibrary.simpleMessage("Hart"),
        "hardnessHardDesc": MessageLookupByLibrary.simpleMessage(
            "Herausforderndes Feedback, das deine Grenzen testet"),
        "hardnessNormal": MessageLookupByLibrary.simpleMessage("Normal"),
        "hardnessNormalDesc": MessageLookupByLibrary.simpleMessage(
            "Normales Feedback mit konstruktiven Vorschlägen"),
        "hardnessQuestion": MessageLookupByLibrary.simpleMessage(
            "Wie hart soll dein Daimonion sein?"),
        "hardnessSubtitle": MessageLookupByLibrary.simpleMessage(
            "Wähle, wie direkt das Feedback sein soll"),
        "hardnessTitle": MessageLookupByLibrary.simpleMessage("Feedback-Stil"),
        "health": MessageLookupByLibrary.simpleMessage("Gesundheit"),
        "helpDialogTitle":
            MessageLookupByLibrary.simpleMessage("So nutzt du die Tools"),
        "helpImproveDaimonion": MessageLookupByLibrary.simpleMessage(
            "Hilf uns, Daimonion zu verbessern"),
        "hideDone": MessageLookupByLibrary.simpleMessage("Hide done"),
        "highPriority": MessageLookupByLibrary.simpleMessage("Hoch"),
        "hintText": MessageLookupByLibrary.simpleMessage(
            "Frag Daimonion was du willst..."),
        "how_to_earn_xp": MessageLookupByLibrary.simpleMessage(
            "Wie du XP kassierst & Level aufsteigst!"),
        "iWillDoIt": MessageLookupByLibrary.simpleMessage("Ich mach’s!"),
        "imageSelectError": MessageLookupByLibrary.simpleMessage(
            "Bild konnte nicht ausgewählt werden"),
        "immortal": MessageLookupByLibrary.simpleMessage("Unsterblicher"),
        "journalContentLabel": MessageLookupByLibrary.simpleMessage("Inhalt"),
        "journalDescription": MessageLookupByLibrary.simpleMessage(
            "Verfolge deine Gedanken und Fortschritte."),
        "journalHelp": MessageLookupByLibrary.simpleMessage(
            "Schreibe tägliche Reflexionen und strukturiere deine Gedanken im Tagebuch."),
        "journalMoodLabel": MessageLookupByLibrary.simpleMessage("Stimmung:"),
        "journalTitle": MessageLookupByLibrary.simpleMessage("Journal"),
        "journalTitleLabel": MessageLookupByLibrary.simpleMessage("Titel"),
        "journalToolTitle": MessageLookupByLibrary.simpleMessage("Tagebuch"),
        "journal_entry":
            MessageLookupByLibrary.simpleMessage("Journal-Eintrag"),
        "keepScreenOn":
            MessageLookupByLibrary.simpleMessage("Bildschirm anlassen"),
        "keep_grinding": MessageLookupByLibrary.simpleMessage("Bleib dran!"),
        "kg": MessageLookupByLibrary.simpleMessage("kg"),
        "learning": MessageLookupByLibrary.simpleMessage("Lernen"),
        "legalAndAppInfoTitle":
            MessageLookupByLibrary.simpleMessage("Rechtliches & App-Info"),
        "legend": MessageLookupByLibrary.simpleMessage("Legende"),
        "level": MessageLookupByLibrary.simpleMessage("Level"),
        "levelAndXp": MessageLookupByLibrary.simpleMessage("Level & XP"),
        "levelAndXpSubtitle": MessageLookupByLibrary.simpleMessage(
            "Zeige deinen Fortschritt und Statistiken"),
        "levelNumber": m11,
        "level_text": m12,
        "levels_and_rankings":
            MessageLookupByLibrary.simpleMessage("Level und Ränge"),
        "levels_and_ranks":
            MessageLookupByLibrary.simpleMessage("Level & Ränge"),
        "lieutenant": MessageLookupByLibrary.simpleMessage("Leutnant"),
        "loadOffers": MessageLookupByLibrary.simpleMessage("Angebote laden"),
        "lowPriority": MessageLookupByLibrary.simpleMessage("Niedrig"),
        "major": MessageLookupByLibrary.simpleMessage("Major"),
        "max_per_day": MessageLookupByLibrary.simpleMessage("Max/Tag"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Vielleicht später"),
        "mediumPriority": MessageLookupByLibrary.simpleMessage("Mittel"),
        "monday": MessageLookupByLibrary.simpleMessage("Montag"),
        "mondayShort": MessageLookupByLibrary.simpleMessage("Mo"),
        "monthly": MessageLookupByLibrary.simpleMessage("Monatlich"),
        "monthlyOverview":
            MessageLookupByLibrary.simpleMessage("Monatliche Übersicht"),
        "monthly_description":
            MessageLookupByLibrary.simpleMessage("Spare über 30%"),
        "monthly_label": MessageLookupByLibrary.simpleMessage("Monatlich"),
        "monthly_price": MessageLookupByLibrary.simpleMessage("3,99 €/Monat"),
        "moreTasks":
            MessageLookupByLibrary.simpleMessage("weitere Aufgaben..."),
        "more_to_come":
            MessageLookupByLibrary.simpleMessage("Mehr kommt noch!"),
        "most_popular_label": MessageLookupByLibrary.simpleMessage("Beliebt"),
        "motivationQuotes": MessageLookupByLibrary.simpleMessage(
            "Du bist nicht hier, um Durchschnitt zu sein!||Keine Ausreden – geh weiter!||Wenn du aufgibst, hast du es nie ernst gemeint.||Jeder Tag eine neue Chance, nutze sie!||Your future self will thank you for your grind today.||Disziplin schlägt Talent – jeden Tag.||Was du heute tust, entscheidet über morgen.||Träume groß, arbeite härter.||Du bist stärker, als du denkst.||Kein Wachstum ohne Anstrengung.||Die härtesten Kämpfe kommen vor den größten Siegen.||Du musst die Person werden, die du dir wünschst zu sein – Schritt für Schritt.||Egal, wie langsam du gehst, du schlägst jeden, der auf der Couch bleibt.||Fehler sind der Beweis, dass du es versuchst.||Man wächst nicht in seiner Komfortzone – wage den Schritt hinaus.||Harte Arbeit wird nicht immer belohnt, aber sie baut Charakter.||Es sind die kleinen täglichen Siege, die die großen Erfolge formen.||Du hast 24 Stunden wie jeder andere – nutze sie mit Intention.||Deine Ziele interessieren sich nicht für deine Ausreden.||Wenn der Weg einfach ist, bist du auf dem falschen Pfad.||Hör auf zu reden, fang an zu machen.||Jeder Erfolg beginnt mit dem Mut, es zu versuchen.||Stärke wächst, wo Komfort endet.||Deine einzige Grenze ist die, die du dir selbst setzt.||Dein Potenzial wartet auf deinen Einsatz.||Jedes Nein bringt dich näher an ein Ja.||Konzentriere dich auf das, was du kontrollieren kannst.||Das Gestern ist vergangen. Heute ist dein Tag.||Die besten Entscheidungen sind oft die schwersten.||Ein kleiner Fortschritt ist immer noch Fortschritt.||Die schwierigste Entscheidung deines Lebens könnte die sein, die alles verändert.||Jede großartige Reise beginnt mit dem ersten Schritt.||Menschen, die dich unterschätzen, geben dir das größte Geschenk: den Ansporn, zu beweisen, dass sie falsch liegen.||Erfolg ist kein Ziel, sondern eine Reise – bleib dran.||Du kannst nichts kontrollieren außer deiner Reaktion auf die Welt.||Die schwierigsten Momente sind oft die, die dich am meisten formen.||Was du heute pflanzt, wirst du morgen ernten.||Wenn du versagst, versuche es erneut, aber versage diesmal besser.||Erfolg bedeutet nicht Perfektion, sondern Fortschritt.||Das Leben gibt dir, was du bereit bist, dir selbst zu nehmen.||Der Schmerz vergeht, der Stolz bleibt.||Fokus schlägt Chaos.||Tu, was getan werden muss.||Du bist ein Krieger, keine Ausrede zählt.||Hass treibt dich an, Liebe macht dich unaufhaltsam.||Ziele hoch – immer.||Disziplin ist Freiheit.||Entweder du machst es oder jemand anderes tut es.||Verliere nie deinen Glauben an dich selbst.||Angst ist dein Kompass – folge ihr."),
        "motivation_text": MessageLookupByLibrary.simpleMessage(
            "Let\'s go! Hör auf zu jammern und zeig, was in dir steckt!"),
        "motivationalInsults": MessageLookupByLibrary.simpleMessage(
            "Warum hängst du rum, Soldat? Zurück an die Arbeit!||Keine Ausreden, erledige deine Aufgaben!||Du willst großartig sein? Dann benimm dich auch so!||Verlierer prokrastinieren. Gewinner handeln. Welcher bist du?"),
        "motivationalMessage0": MessageLookupByLibrary.simpleMessage(
            "Starte mit deinen täglichen Gewohnheiten! Mach heute den ersten Schritt."),
        "motivationalMessageAllCompleted": MessageLookupByLibrary.simpleMessage(
            "Fantastische Arbeit! Du hast alle deine täglichen Gewohnheiten erfüllt!"),
        "motivationalMessageLessThan3": MessageLookupByLibrary.simpleMessage(
            "Ein guter Anfang! Mach weiter so!"),
        "motivationalMessageLessThan5": MessageLookupByLibrary.simpleMessage(
            "Fast geschafft! Nur noch ein paar mehr, um deine Ziele zu erreichen."),
        "nameEmptyWarning":
            MessageLookupByLibrary.simpleMessage("Bitte gib deinen Namen ein."),
        "nameHint": MessageLookupByLibrary.simpleMessage("Dein Name"),
        "nameLabel": MessageLookupByLibrary.simpleMessage("Name"),
        "newDay": MessageLookupByLibrary.simpleMessage("Neuer Tag"),
        "newDayNameHint": MessageLookupByLibrary.simpleMessage("Neuer Tagname"),
        "newExerciseHint":
            MessageLookupByLibrary.simpleMessage("Neue Übung eingeben"),
        "newHabitNameHint": MessageLookupByLibrary.simpleMessage("Name"),
        "newHabitTitle":
            MessageLookupByLibrary.simpleMessage("Neue Gewohnheit erstellen"),
        "newJournalEntry":
            MessageLookupByLibrary.simpleMessage("Neuer Eintrag"),
        "newLabel": MessageLookupByLibrary.simpleMessage("NEU"),
        "newTaskHint": MessageLookupByLibrary.simpleMessage("Neue Aufgabe..."),
        "newTodoHint": MessageLookupByLibrary.simpleMessage("Neue Aufgabe..."),
        "noActivePurchases": MessageLookupByLibrary.simpleMessage(
            "Keine aktiven Käufe gefunden."),
        "noDataMessage": MessageLookupByLibrary.simpleMessage(
            "Keine Daten für diesen Zeitraum"),
        "noDaysSelectedError": MessageLookupByLibrary.simpleMessage(
            "Bitte wähle mindestens einen Tag aus."),
        "noEmailClientFound": MessageLookupByLibrary.simpleMessage(
            "Kein E-Mail-Client auf diesem Gerät gefunden."),
        "noExercisesMessage": MessageLookupByLibrary.simpleMessage(
            "Noch keine Übungen hinzugefügt."),
        "noHabitsMessage": MessageLookupByLibrary.simpleMessage(
            "Noch keine Gewohnheiten hinzugefügt."),
        "noJournalEntries": MessageLookupByLibrary.simpleMessage(
            "Noch keine Einträge im Journal"),
        "noMatchingTasks":
            MessageLookupByLibrary.simpleMessage("Keine passenden Aufgaben"),
        "noOffersAvailable":
            MessageLookupByLibrary.simpleMessage("Keine Angebote verfügbar"),
        "noPriority": MessageLookupByLibrary.simpleMessage("Keine Priorität"),
        "noPurchasesToRestore": MessageLookupByLibrary.simpleMessage(
            "Keine Käufe zum Wiederherstellen gefunden"),
        "noReminder": MessageLookupByLibrary.simpleMessage("Keine"),
        "noReminderSet":
            MessageLookupByLibrary.simpleMessage("Keine Erinnerung gesetzt"),
        "noTasks": MessageLookupByLibrary.simpleMessage("Keine Aufgaben"),
        "noTasksForDay": m13,
        "noTasksScheduled": MessageLookupByLibrary.simpleMessage(
            "Für diesen Monat sind noch keine Aufgaben geplant."),
        "noTasksToday": MessageLookupByLibrary.simpleMessage(
            "Keine Aufgaben für heute. Bleib diszipliniert und produktiv!"),
        "noTodosAdded": MessageLookupByLibrary.simpleMessage(
            "Noch keine To-Dos hinzugefügt."),
        "noWorkoutName":
            MessageLookupByLibrary.simpleMessage("Kein Trainingsname"),
        "notCompleted":
            MessageLookupByLibrary.simpleMessage("Nicht abgeschlossen"),
        "notNow": MessageLookupByLibrary.simpleMessage("Nicht jetzt"),
        "notes": MessageLookupByLibrary.simpleMessage("Notizen"),
        "notificationActiveMessage": MessageLookupByLibrary.simpleMessage(
            "Benachrichtigungen sind jetzt aktiv! Lass uns loslegen."),
        "notificationDeniedMessage": MessageLookupByLibrary.simpleMessage(
            "Benachrichtigungen wurden abgelehnt. Du kannst sie später in den Einstellungen aktivieren."),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "onboardingAgeQuestion":
            MessageLookupByLibrary.simpleMessage("Wie alt bist du?"),
        "onboardingChatbotTitle":
            MessageLookupByLibrary.simpleMessage("Chatbot Härtegrad"),
        "onboardingFinishButtonText":
            MessageLookupByLibrary.simpleMessage("LET’S GO ZUM DASHBOARD!"),
        "onboardingFinishHeadline":
            MessageLookupByLibrary.simpleMessage("DU HAST ES GESCHAFFT!"),
        "onboardingFinishSubheadline": MessageLookupByLibrary.simpleMessage(
            "Jetzt beginnt der wahre Grind. Du bist bereit, die Kontrolle zu übernehmen."),
        "onboardingGoalsQuestion":
            MessageLookupByLibrary.simpleMessage("Was sind deine Ziele?"),
        "onboardingNameQuestion":
            MessageLookupByLibrary.simpleMessage("Wie heißt du?"),
        "onboardingNotificationButtonText":
            MessageLookupByLibrary.simpleMessage("Push mich!"),
        "onboardingNotificationDescription": MessageLookupByLibrary.simpleMessage(
            "Stell dir vor, du wirst jeden Tag daran erinnert, besser zu sein als gestern. Deine Ziele, deine To-Dos, deine Disziplin – alles wird stärker, weil du es wirst. Schalte jetzt Benachrichtigungen ein und lass dich von deinem inneren Daimonion pushen."),
        "onboardingNotificationHeadline":
            MessageLookupByLibrary.simpleMessage("Mach den ersten Schritt"),
        "onboardingNotificationNextChallenge":
            MessageLookupByLibrary.simpleMessage(
                "Weiter zur nächsten Challenge"),
        "onboardingTodosSubheadline": MessageLookupByLibrary.simpleMessage(
            "Leg jetzt deine ersten Aufgaben an. Diese To-Dos landen direkt in deiner Hauptliste."),
        "onboardingTodosTitle":
            MessageLookupByLibrary.simpleMessage("Deine ersten To-Dos"),
        "pauseTimer": MessageLookupByLibrary.simpleMessage("Pause"),
        "paywallContent": MessageLookupByLibrary.simpleMessage(
            "Erhalte Zugriff auf alle Premium-Features und Tools, um deine Produktivität und dein Wachstum zu maximieren."),
        "paywallTitle":
            MessageLookupByLibrary.simpleMessage("Premium-Tools freischalten"),
        "pending": MessageLookupByLibrary.simpleMessage("Ausstehend"),
        "personal": MessageLookupByLibrary.simpleMessage("Persönlich"),
        "premiumFeature":
            MessageLookupByLibrary.simpleMessage("Premium-Funktion"),
        "premiumPackageNotFound": MessageLookupByLibrary.simpleMessage(
            "Premium-Paket nicht gefunden"),
        "premiumRequired":
            MessageLookupByLibrary.simpleMessage("Premium erforderlich"),
        "premiumRestored": MessageLookupByLibrary.simpleMessage(
            "Premium-Abonnement erfolgreich wiederhergestellt."),
        "premiumSectionUnavailable": MessageLookupByLibrary.simpleMessage(
            "Dieser Bereich ist nur für Premium-Nutzer verfügbar."),
        "premiumUpgradeSuccess": MessageLookupByLibrary.simpleMessage(
            "Herzlichen Glückwunsch! Du bist Premium."),
        "premium_activated": MessageLookupByLibrary.simpleMessage(
            "Dein Premium-Abo wurde aktiviert!"),
        "premium_benefit_flow_stats": MessageLookupByLibrary.simpleMessage(
            "Detaillierte Statistiken für Flow-Timer"),
        "premium_benefit_habit_tracker_access":
            MessageLookupByLibrary.simpleMessage(
                "Zugriff auf Gewohnheitstracker"),
        "premium_benefit_journal_access":
            MessageLookupByLibrary.simpleMessage("Zugriff auf Journal"),
        "premium_benefit_no_ads":
            MessageLookupByLibrary.simpleMessage("Keine Werbung"),
        "premium_benefit_tags_stats": MessageLookupByLibrary.simpleMessage(
            "Detaillierte Statistiken für Tasks"),
        "premium_benefit_todo_advanced": MessageLookupByLibrary.simpleMessage(
            "Zugriff auf erweiterte Funktionen in To-Do-Liste"),
        "premium_benefit_training_advanced":
            MessageLookupByLibrary.simpleMessage(
                "Zugriff auf erweiterte Funktionen in Trainingsplan"),
        "premium_benefit_unlimited_chat": MessageLookupByLibrary.simpleMessage(
            "Unbegrenzte Chat-Anfragen für deinen Daimonion"),
        "premium_description": MessageLookupByLibrary.simpleMessage(
            "Abonniere, um vollen Zugriff auf Premium-Funktionen zu erhalten"),
        "premium_label": MessageLookupByLibrary.simpleMessage("PREMIUM"),
        "premium_not_available": MessageLookupByLibrary.simpleMessage(
            "Premium-Paket nicht verfügbar."),
        "priority": MessageLookupByLibrary.simpleMessage("Priorität"),
        "privacyAndTerms":
            MessageLookupByLibrary.simpleMessage("Datenschutz & AGB"),
        "privacyAndTermsContent": MessageLookupByLibrary.simpleMessage(
            "Datenschutz und Nutzungsbedingungen\n\nDatenschutz\nWir nehmen den Schutz deiner Daten ernst. Aktuell speichert unsere App keine Daten in externen Datenbanken. Alle Informationen, die du in der App eingibst, werden lokal auf deinem Gerät gespeichert. Es erfolgt keine Weitergabe deiner Daten an Dritte.\n\nIn Zukunft könnten zusätzliche Funktionen wie ein Login oder Online-Dienste integriert werden. Falls dies geschieht, werden wir diese Datenschutzerklärung entsprechend aktualisieren, um dich transparent über Änderungen zu informieren.\n\nNutzungsbedingungen\nUnsere App ist darauf ausgelegt, dir zu helfen, produktiver zu werden und deine Ziele zu erreichen. Die Nutzung der App erfolgt auf eigene Verantwortung. Wir übernehmen keine Haftung für direkte oder indirekte Schäden, die aus der Nutzung der App entstehen könnten.\n\nBitte benutze die App verantwortungsbewusst und halte dich an die Gesetze deines Landes.\n\nKontakt\nFalls du Fragen oder Anliegen zu unseren Datenschutzrichtlinien oder Nutzungsbedingungen hast, kontaktiere uns unter kontakt@dineswipe.de."),
        "privacyAndTermsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Datenschutzrichtlinie und Nutzungsbedingungen"),
        "privacyAndTermsTitle": MessageLookupByLibrary.simpleMessage(
            "Datenschutz & Nutzungsbedingungen"),
        "productiveTimeWeek":
            MessageLookupByLibrary.simpleMessage("Produktive Zeit (Woche)"),
        "productivity": MessageLookupByLibrary.simpleMessage("Produktivität"),
        "productivityCategory":
            MessageLookupByLibrary.simpleMessage("Produktivität"),
        "productivityScore":
            MessageLookupByLibrary.simpleMessage("Produktivitätswert"),
        "profileHeader": MessageLookupByLibrary.simpleMessage("Dein Profil"),
        "profileTitle": MessageLookupByLibrary.simpleMessage("Profil"),
        "progressToNextLevel": m14,
        "progress_text": m15,
        "purchaseError": m16,
        "purchasesRestoredError": MessageLookupByLibrary.simpleMessage(
            "Fehler beim Wiederherstellen der Käufe"),
        "purchasesRestoredSuccess": MessageLookupByLibrary.simpleMessage(
            "Käufe erfolgreich wiederhergestellt!"),
        "quickAdd": MessageLookupByLibrary.simpleMessage("Schnell hinzufügen"),
        "quoteShared":
            MessageLookupByLibrary.simpleMessage("Zitat wurde geteilt!"),
        "rank": MessageLookupByLibrary.simpleMessage("Rang"),
        "recruit": MessageLookupByLibrary.simpleMessage("Rekrut"),
        "reminderLabel":
            MessageLookupByLibrary.simpleMessage("Erinnerung setzen"),
        "removeAds": MessageLookupByLibrary.simpleMessage("Werbung entfernen"),
        "repeatLabel": MessageLookupByLibrary.simpleMessage("Wiederholen am"),
        "reps": MessageLookupByLibrary.simpleMessage("Wdh."),
        "repsLabel": MessageLookupByLibrary.simpleMessage("Wiederholungen"),
        "restoreError": m17,
        "restorePurchases":
            MessageLookupByLibrary.simpleMessage("Käufe wiederherstellen"),
        "restorePurchasesSubtitle": MessageLookupByLibrary.simpleMessage(
            "Stelle deine bisherigen Käufe wieder her"),
        "restoringPurchases": MessageLookupByLibrary.simpleMessage(
            "Käufe werden wiederhergestellt..."),
        "saturday": MessageLookupByLibrary.simpleMessage("Samstag"),
        "saturdayShort": MessageLookupByLibrary.simpleMessage("Sa"),
        "save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "saveButton": MessageLookupByLibrary.simpleMessage("Speichern"),
        "saveChanges":
            MessageLookupByLibrary.simpleMessage("Änderungen speichern"),
        "selectCategory":
            MessageLookupByLibrary.simpleMessage("Kategorie auswählen"),
        "selectHardness":
            MessageLookupByLibrary.simpleMessage("Feedback-Stil auswählen"),
        "sergeant": MessageLookupByLibrary.simpleMessage("Sergeant"),
        "setTime": MessageLookupByLibrary.simpleMessage("Zeit festlegen"),
        "sets": MessageLookupByLibrary.simpleMessage("Sätze"),
        "setsLabel": MessageLookupByLibrary.simpleMessage("Sätze"),
        "settingsTitle": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "shareTooltip": MessageLookupByLibrary.simpleMessage("Teilen"),
        "shortCheckGym": MessageLookupByLibrary.simpleMessage("Körper"),
        "shortCheckHealthyEating":
            MessageLookupByLibrary.simpleMessage("Gesund"),
        "shortCheckHelpOthers": MessageLookupByLibrary.simpleMessage("Helfen"),
        "shortCheckMental": MessageLookupByLibrary.simpleMessage("Mental"),
        "shortCheckNature": MessageLookupByLibrary.simpleMessage("Natur"),
        "shortCheckNoPorn": MessageLookupByLibrary.simpleMessage("No Porn"),
        "soldier": MessageLookupByLibrary.simpleMessage("Soldat"),
        "startAddingTasks": MessageLookupByLibrary.simpleMessage(
            "Fang an, Aufgaben hinzuzufügen, um deine Produktivität zu verfolgen."),
        "startTimer": MessageLookupByLibrary.simpleMessage("Start"),
        "start_free_week_label":
            MessageLookupByLibrary.simpleMessage("Kostenlose Woche starten"),
        "statAverageFlow":
            MessageLookupByLibrary.simpleMessage("Ø Zeit pro Flow (Min)"),
        "statAverageWeeklyFlow":
            MessageLookupByLibrary.simpleMessage("Ø Zeit pro Woche (Min)"),
        "statFlows": MessageLookupByLibrary.simpleMessage("Flows"),
        "statTotalMinutes":
            MessageLookupByLibrary.simpleMessage("Minuten gesamt"),
        "stats": MessageLookupByLibrary.simpleMessage("Statistiken"),
        "status_text": m18,
        "streak": MessageLookupByLibrary.simpleMessage("Streak"),
        "streak_days": m19,
        "streak_description": MessageLookupByLibrary.simpleMessage(
            "Je länger du täglich aktiv bist, desto mehr XP bekommst du! Deine Streak belohnt dich für Konsistenz und sorgt dafür, dass du schneller im Level aufsteigst."),
        "streak_info_title":
            MessageLookupByLibrary.simpleMessage("Streak-Info"),
        "streak_rewards": MessageLookupByLibrary.simpleMessage(
            "- 7+ Tage: +5% XP\\n- 14+ Tage: +10% XP\\n- 30+ Tage: +15% XP\\n"),
        "subscription_disclaimer": MessageLookupByLibrary.simpleMessage(
            "Jederzeit kündbar | Datenschutzrichtlinie\nDein Abo verlängert sich automatisch. Kündige es mindestens 24 Stunden vor der Erneuerung im Google Play Store."),
        "subscription_failed": MessageLookupByLibrary.simpleMessage(
            "Abo konnte nicht aktiviert werden."),
        "successContent": MessageLookupByLibrary.simpleMessage(
            "Du hast erfolgreich Premium freigeschaltet!"),
        "successTitle": MessageLookupByLibrary.simpleMessage("Erfolg"),
        "suggestion1": MessageLookupByLibrary.simpleMessage(
            "Ich fühle mich heute faul und unmotiviert."),
        "suggestion2": MessageLookupByLibrary.simpleMessage(
            "Was soll ich mit meinem Tag anfangen?"),
        "suggestion3": MessageLookupByLibrary.simpleMessage(
            "Ich möchte neue Gewohnheiten aufbauen."),
        "suggestion4": MessageLookupByLibrary.simpleMessage(
            "Ich habe keine Lust zu trainieren."),
        "suggestion5": MessageLookupByLibrary.simpleMessage(
            "Was kann ich tun, um produktiver zu sein?"),
        "suggestion6": MessageLookupByLibrary.simpleMessage(
            "Gib mir einen Tritt in den Hintern!"),
        "sunday": MessageLookupByLibrary.simpleMessage("Sonntag"),
        "sundayShort": MessageLookupByLibrary.simpleMessage("So"),
        "tags": MessageLookupByLibrary.simpleMessage("Tags"),
        "tapToAddDetails": MessageLookupByLibrary.simpleMessage(
            "Tippe, um Details hinzuzufügen"),
        "tapToAddExercises": MessageLookupByLibrary.simpleMessage(
            "Tippe, um Übungen hinzuzufügen"),
        "tapToRefresh":
            MessageLookupByLibrary.simpleMessage("Zum Aktualisieren tippen"),
        "taskAdded":
            MessageLookupByLibrary.simpleMessage("Aufgabe hinzugefügt"),
        "taskCompletedMessage": MessageLookupByLibrary.simpleMessage(
            "Aufgabe erfolgreich abgeschlossen!"),
        "taskCompletionTrends":
            MessageLookupByLibrary.simpleMessage("Aufgabenabschluss-Trends"),
        "taskDeleted": MessageLookupByLibrary.simpleMessage("Aufgabe gelöscht"),
        "taskDetails": MessageLookupByLibrary.simpleMessage("Aufgabendetails"),
        "taskLabel": m20,
        "taskNotesLabel":
            MessageLookupByLibrary.simpleMessage("Notizen zur Aufgabe"),
        "taskTitleLabel": MessageLookupByLibrary.simpleMessage("Titel"),
        "taskUpdatedMessage":
            MessageLookupByLibrary.simpleMessage("Aufgabe wurde aktualisiert"),
        "tasks": MessageLookupByLibrary.simpleMessage("Tasks"),
        "tasksDescription": MessageLookupByLibrary.simpleMessage(
            "Organisiere deine Aufgaben effizient."),
        "tasksForDay": MessageLookupByLibrary.simpleMessage("Test"),
        "tasksHelp": MessageLookupByLibrary.simpleMessage(
            "Plane deinen Tag mit einer einfachen und effektiven Aufgabenliste."),
        "tasksToolTitle": MessageLookupByLibrary.simpleMessage("To-Do-Liste"),
        "ten_min_flow": MessageLookupByLibrary.simpleMessage("10 min Flow"),
        "thank_you": MessageLookupByLibrary.simpleMessage("Vielen Dank!"),
        "thursday": MessageLookupByLibrary.simpleMessage("Donnerstag"),
        "thursdayShort": MessageLookupByLibrary.simpleMessage("Do"),
        "title_progress":
            MessageLookupByLibrary.simpleMessage("Dein Fortschritt"),
        "todayLabel": MessageLookupByLibrary.simpleMessage("Heute"),
        "todaysTasks": MessageLookupByLibrary.simpleMessage("Heutige Aufgaben"),
        "todoListTitle": MessageLookupByLibrary.simpleMessage("To-Do-Liste"),
        "todoReminderBodyBrutal": MessageLookupByLibrary.simpleMessage(
            "Deine Aufgaben warten! Zeit zu liefern!"),
        "todoReminderBodyHard": MessageLookupByLibrary.simpleMessage(
            "Zeig Disziplin und arbeite an deiner Vision. Keine Ausreden!"),
        "todoReminderBodyNormal": MessageLookupByLibrary.simpleMessage(
            "Kleine Schritte bringen dich ans Ziel. Fang jetzt an!"),
        "todoReminderTitleBrutal":
            MessageLookupByLibrary.simpleMessage("Was machst du eigentlich?!"),
        "todoReminderTitleHard": MessageLookupByLibrary.simpleMessage(
            "Zeit, deine To-Dos anzugehen!"),
        "todoReminderTitleNormal":
            MessageLookupByLibrary.simpleMessage("Check deine Aufgaben!"),
        "toolsPageTitle": MessageLookupByLibrary.simpleMessage("Tools"),
        "totalTasks": MessageLookupByLibrary.simpleMessage("Gesamtaufgaben"),
        "trainingPlan": MessageLookupByLibrary.simpleMessage("Trainingsplan"),
        "trainingPlanDescription": MessageLookupByLibrary.simpleMessage(
            "Optimiere deine Workouts und verfolge deine Fortschritte."),
        "trainingPlanHelp": MessageLookupByLibrary.simpleMessage(
            "Nutze den Trainingsplan, um eine strukturierte Fitnessroutine zu verfolgen."),
        "trainingPlanToolTitle":
            MessageLookupByLibrary.simpleMessage("Trainingsplan"),
        "tuesday": MessageLookupByLibrary.simpleMessage("Dienstag"),
        "tuesdayShort": MessageLookupByLibrary.simpleMessage("Di"),
        "typeMessage":
            MessageLookupByLibrary.simpleMessage("Schreibe eine Nachricht ..."),
        "uncategorized":
            MessageLookupByLibrary.simpleMessage("Unkategorisiert"),
        "understood": MessageLookupByLibrary.simpleMessage("Verstanden"),
        "undo": MessageLookupByLibrary.simpleMessage("Rückgängig"),
        "unknownUser":
            MessageLookupByLibrary.simpleMessage("Unbekannter Benutzer"),
        "unlimited_chat_prompts":
            MessageLookupByLibrary.simpleMessage("Unbegrenzte Chat-Prompts"),
        "unlock_premium":
            MessageLookupByLibrary.simpleMessage("Premium freischalten"),
        "untitled": MessageLookupByLibrary.simpleMessage("(Ohne Titel)"),
        "update": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
        "updateTask":
            MessageLookupByLibrary.simpleMessage("Aufgabe aktualisieren"),
        "upgrade": MessageLookupByLibrary.simpleMessage("Premium"),
        "upgradeContent": MessageLookupByLibrary.simpleMessage(
            "Du hast deine 5 kostenlosen Prompts verbraucht.\n\nHol dir jetzt die Premium-Version für unbegrenzte Chats!"),
        "upgradeForMoreFeatures": MessageLookupByLibrary.simpleMessage(
            "Für mehr Funktionen upgraden"),
        "upgradeNow": MessageLookupByLibrary.simpleMessage("Jetzt upgraden"),
        "upgradeTitle": MessageLookupByLibrary.simpleMessage("Upgrade nötig"),
        "upgradeToPremium":
            MessageLookupByLibrary.simpleMessage("Premium freischalten"),
        "upgradeToPremiumSubtitle": MessageLookupByLibrary.simpleMessage(
            "Erhalte Zugriff auf alle Premium-Funktionen"),
        "upgradeToUnlock": MessageLookupByLibrary.simpleMessage(
            "Upgrade erforderlich, um diese Funktion freizuschalten."),
        "userStats": MessageLookupByLibrary.simpleMessage("Deine Statistiken"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "veteran": MessageLookupByLibrary.simpleMessage("Veteran"),
        "viewAll": MessageLookupByLibrary.simpleMessage("Alle anzeigen"),
        "viewStats": MessageLookupByLibrary.simpleMessage("Statistiken"),
        "view_all_premium_benefits": MessageLookupByLibrary.simpleMessage(
            "Alle Premium-Vorteile anzeigen"),
        "warlord": MessageLookupByLibrary.simpleMessage("Kriegsherr"),
        "wednesday": MessageLookupByLibrary.simpleMessage("Mittwoch"),
        "wednesdayShort": MessageLookupByLibrary.simpleMessage("Mi"),
        "weekly": MessageLookupByLibrary.simpleMessage("Wöchentlich"),
        "weeklyProgress":
            MessageLookupByLibrary.simpleMessage("Wöchentlicher Fortschritt"),
        "weekly_description":
            MessageLookupByLibrary.simpleMessage("Probier\'s günstig aus"),
        "weekly_label": MessageLookupByLibrary.simpleMessage("Wöchentlich"),
        "weekly_price": MessageLookupByLibrary.simpleMessage("1,99 €/Woche"),
        "weightLabel": MessageLookupByLibrary.simpleMessage("Gewicht"),
        "wellnessCategory":
            MessageLookupByLibrary.simpleMessage("Wellness & Wachstum"),
        "workoutNameHint":
            MessageLookupByLibrary.simpleMessage("Trainingsname"),
        "workoutNameLabel":
            MessageLookupByLibrary.simpleMessage("Workout-Name"),
        "xp": MessageLookupByLibrary.simpleMessage("XP"),
        "xp_bonus": m21,
        "xp_text": m22,
        "yearly": MessageLookupByLibrary.simpleMessage("Jährlich"),
        "yearly_description":
            MessageLookupByLibrary.simpleMessage("Spare über 40%"),
        "yearly_label": MessageLookupByLibrary.simpleMessage("Jährlich"),
        "yearly_price": MessageLookupByLibrary.simpleMessage("29,99 €/Jahr"),
        "you": MessageLookupByLibrary.simpleMessage("Du")
      };
}
