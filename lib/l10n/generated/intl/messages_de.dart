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

  static String m1(habitName) =>
      "Möchtest du die Gewohnheit \"${habitName}\" wirklich löschen?";

  static String m2(entryTitle) =>
      "Möchtest du den Eintrag \"${entryTitle}\" wirklich löschen?";

  static String m3(date) => "Fällig am ${date}";

  static String m4(error) => "Ein Fehler ist aufgetreten: ${error}";

  static String m5(currentFlow, totalFlows) =>
      "Flow ${currentFlow} / ${totalFlows}";

  static String m6(usedPrompts) =>
      "Kostenlose Prompts genutzt: ${usedPrompts} / 5";

  static String m7(date) => "Keine Aufgaben für ${date}";

  static String m8(error) => "Fehler beim Kauf: ${error}";

  static String m9(error) => "Fehler beim Wiederherstellen: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accountTitle": MessageLookupByLibrary.simpleMessage("ACCOUNT"),
    "addTask": MessageLookupByLibrary.simpleMessage("Add"),
    "addTodo": MessageLookupByLibrary.simpleMessage("Add"),
    "appBarTitle": MessageLookupByLibrary.simpleMessage("Daimonion Chat"),
    "autoStartBreak": MessageLookupByLibrary.simpleMessage(
      "Automatisch Pause starten",
    ),
    "autoStartNextFlow": MessageLookupByLibrary.simpleMessage(
      "Automatisch nächsten Flow starten",
    ),
    "buyPremium": MessageLookupByLibrary.simpleMessage("Premium kaufen"),
    "calendarViewTitle": MessageLookupByLibrary.simpleMessage(
      "Kalender-Übersicht",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "changeDeadline": MessageLookupByLibrary.simpleMessage("Deadline ändern"),
    "chatbotModeBrutal": MessageLookupByLibrary.simpleMessage("Brutal Ehrlich"),
    "chatbotModeHard": MessageLookupByLibrary.simpleMessage("Hart"),
    "chatbotModeNormal": MessageLookupByLibrary.simpleMessage("Normal"),
    "chatbotWarning": MessageLookupByLibrary.simpleMessage(
      "Achtung: Im Modus \"Brutal Ehrlich\" wirst du beleidigt und extrem herausgefordert.",
    ),
    "cheerAlmost": MessageLookupByLibrary.simpleMessage(
      "Noch nicht fertig, aber du packst das. Nur weitermachen!",
    ),
    "cheerHalf": MessageLookupByLibrary.simpleMessage(
      "Schon über die Hälfte deiner Gewohnheiten geschafft – stark!",
    ),
    "cheerPerfect": MessageLookupByLibrary.simpleMessage(
      "Perfekt! Du hast heute alle Gewohnheiten erledigt. Keep pushing!",
    ),
    "cheerStart": MessageLookupByLibrary.simpleMessage(
      "Pack an! Zeit, etwas zu tun!",
    ),
    "chooseDay": m0,
    "confirmDelete": MessageLookupByLibrary.simpleMessage("Ja, löschen"),
    "confirmDeleteHabit": MessageLookupByLibrary.simpleMessage("Ja, löschen"),
    "continueButton": MessageLookupByLibrary.simpleMessage("Weiter"),
    "dailyReminderActivated": MessageLookupByLibrary.simpleMessage(
      "Täglicher Reminder um 20:00 aktiviert!",
    ),
    "dailyReminderDeactivated": MessageLookupByLibrary.simpleMessage(
      "Täglicher Reminder wurde deaktiviert.",
    ),
    "dashboardTitle": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "deleteHabitMessage": m1,
    "deleteHabitTitle": MessageLookupByLibrary.simpleMessage("Löschen?"),
    "deleteJournalEntryMessage": m2,
    "deleteJournalEntryTitle": MessageLookupByLibrary.simpleMessage("Löschen?"),
    "deleteTask": MessageLookupByLibrary.simpleMessage("Löschen"),
    "dueOn": m3,
    "editJournalEntry": MessageLookupByLibrary.simpleMessage(
      "Eintrag bearbeiten",
    ),
    "editProfile": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
    "editProfileHint": MessageLookupByLibrary.simpleMessage("Dein Name"),
    "editProfileTitle": MessageLookupByLibrary.simpleMessage("Name bearbeiten"),
    "editTask": MessageLookupByLibrary.simpleMessage("Aufgabe bearbeiten"),
    "editTaskDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Aufgabe bearbeiten",
    ),
    "errorContent": MessageLookupByLibrary.simpleMessage(
      "Es ist ein Fehler aufgetreten. Bitte versuche es später erneut.",
    ),
    "errorOccurred": m4,
    "errorTitle": MessageLookupByLibrary.simpleMessage("Fehler"),
    "filterMonth": MessageLookupByLibrary.simpleMessage("Monat"),
    "filterWeek": MessageLookupByLibrary.simpleMessage("Woche"),
    "filterYear": MessageLookupByLibrary.simpleMessage("Jahr"),
    "firstTimeButtonText": MessageLookupByLibrary.simpleMessage(
      "ICH BIN BEREIT",
    ),
    "firstTimeHeadline": MessageLookupByLibrary.simpleMessage(
      "WILLST DU JEMAND SEIN, DER KONTROLLE HAT,\nODER WILLST DU EIN SKLAVE DEINER IMPULSE BLEIBEN?",
    ),
    "flowCounter": m5,
    "flowStatsTitle": MessageLookupByLibrary.simpleMessage("Flow Stats"),
    "flowTimer": MessageLookupByLibrary.simpleMessage("Flow Timer"),
    "flowTimerBreakLabel": MessageLookupByLibrary.simpleMessage("Pause"),
    "flowTimerSetFlowsHint": MessageLookupByLibrary.simpleMessage(
      "Anzahl der Flows",
    ),
    "flowTimerSetFlowsTitle": MessageLookupByLibrary.simpleMessage(
      "Flow-Einstellungen",
    ),
    "flowTimerSetTimeHint": MessageLookupByLibrary.simpleMessage(
      "Minuten eingeben...",
    ),
    "flowTimerSetTimeTitle": MessageLookupByLibrary.simpleMessage(
      "Flow-Zeit einstellen",
    ),
    "flowTimerTitle": MessageLookupByLibrary.simpleMessage("Flow-Timer"),
    "flowTimerToolTitle": MessageLookupByLibrary.simpleMessage("Flow Timer"),
    "freePromptsCounter": m6,
    "goalBetterRelationships": MessageLookupByLibrary.simpleMessage(
      "Bessere Beziehungen aufbauen",
    ),
    "goalCareer": MessageLookupByLibrary.simpleMessage("Karriere vorantreiben"),
    "goalFit": MessageLookupByLibrary.simpleMessage("Fitter werden"),
    "goalMentalHealth": MessageLookupByLibrary.simpleMessage(
      "Mentale Gesundheit stärken",
    ),
    "goalProductivity": MessageLookupByLibrary.simpleMessage(
      "Produktiver sein",
    ),
    "goalSaveMoney": MessageLookupByLibrary.simpleMessage("Mehr Geld sparen"),
    "habitHeader": MessageLookupByLibrary.simpleMessage("Habit"),
    "habitTrackerTitle": MessageLookupByLibrary.simpleMessage("Habit Tracker"),
    "habitTrackerToolTitle": MessageLookupByLibrary.simpleMessage(
      "Gewohnheitstracker",
    ),
    "habits": MessageLookupByLibrary.simpleMessage("Habits"),
    "hardnessBrutal": MessageLookupByLibrary.simpleMessage("Brutal ehrlich"),
    "hardnessHard": MessageLookupByLibrary.simpleMessage("Hart"),
    "hardnessNormal": MessageLookupByLibrary.simpleMessage("Normal"),
    "hardnessQuestion": MessageLookupByLibrary.simpleMessage(
      "WIE HART SOLL ICH ZU DIR SEIN?",
    ),
    "hardnessTitle": MessageLookupByLibrary.simpleMessage("Härtegrad"),
    "hideDone": MessageLookupByLibrary.simpleMessage("Hide done"),
    "hintText": MessageLookupByLibrary.simpleMessage(
      "Frag Daimonion was du willst...",
    ),
    "journalContentLabel": MessageLookupByLibrary.simpleMessage("Inhalt"),
    "journalMoodLabel": MessageLookupByLibrary.simpleMessage("Stimmung:"),
    "journalTitle": MessageLookupByLibrary.simpleMessage("Journal"),
    "journalTitleLabel": MessageLookupByLibrary.simpleMessage("Titel"),
    "journalToolTitle": MessageLookupByLibrary.simpleMessage("Journal"),
    "keepScreenOn": MessageLookupByLibrary.simpleMessage("Bildschirm anlassen"),
    "legalAndAppInfoTitle": MessageLookupByLibrary.simpleMessage(
      "RECHTLICHES & APP-INFOS",
    ),
    "motivationQuotes": MessageLookupByLibrary.simpleMessage(
      "Du bist nicht hier, um Durchschnitt zu sein!||Keine Ausreden – geh weiter!||Wenn du aufgibst, hast du es nie ernst gemeint.||Jeder Tag eine neue Chance, nutze sie!||Your future self will thank you for your grind today.||Disziplin schlägt Talent – jeden Tag.||Was du heute tust, entscheidet über morgen.||Träume groß, arbeite härter.||Du bist stärker, als du denkst.||Kein Wachstum ohne Anstrengung.||Die härtesten Kämpfe kommen vor den größten Siegen.||Du musst die Person werden, die du dir wünschst zu sein – Schritt für Schritt.||Egal, wie langsam du gehst, du schlägst jeden, der auf der Couch bleibt.||Fehler sind der Beweis, dass du es versuchst.||Man wächst nicht in seiner Komfortzone – wage den Schritt hinaus.||Harte Arbeit wird nicht immer belohnt, aber sie baut Charakter.||Es sind die kleinen täglichen Siege, die die großen Erfolge formen.||Du hast 24 Stunden wie jeder andere – nutze sie mit Intention.||Deine Ziele interessieren sich nicht für deine Ausreden.||Wenn der Weg einfach ist, bist du auf dem falschen Pfad.||Hör auf zu reden, fang an zu machen.||Jeder Erfolg beginnt mit dem Mut, es zu versuchen.||Stärke wächst, wo Komfort endet.||Deine einzige Grenze ist die, die du dir selbst setzt.||Dein Potenzial wartet auf deinen Einsatz.||Jedes Nein bringt dich näher an ein Ja.||Konzentriere dich auf das, was du kontrollieren kannst.||Das Gestern ist vergangen. Heute ist dein Tag.||Die besten Entscheidungen sind oft die schwersten.||Ein kleiner Fortschritt ist immer noch Fortschritt.||Die schwierigste Entscheidung deines Lebens könnte die sein, die alles verändert.||Jede großartige Reise beginnt mit dem ersten Schritt.||Menschen, die dich unterschätzen, geben dir das größte Geschenk: den Ansporn, zu beweisen, dass sie falsch liegen.||Erfolg ist kein Ziel, sondern eine Reise – bleib dran.||Du kannst nichts kontrollieren außer deiner Reaktion auf die Welt.||Die schwierigsten Momente sind oft die, die dich am meisten formen.||Was du heute pflanzt, wirst du morgen ernten.||Wenn du versagst, versuche es erneut, aber versage diesmal besser.||Erfolg bedeutet nicht Perfektion, sondern Fortschritt.||Das Leben gibt dir, was du bereit bist, dir selbst zu nehmen.||Der Schmerz vergeht, der Stolz bleibt.||Fokus schlägt Chaos.||Tu, was getan werden muss.||Du bist ein Krieger, keine Ausrede zählt.||Hass treibt dich an, Liebe macht dich unaufhaltsam.||Ziele hoch – immer.||Disziplin ist Freiheit.||Entweder du machst es oder jemand anderes tut es.||Verliere nie deinen Glauben an dich selbst.||Angst ist dein Kompass – folge ihr.",
    ),
    "nameEmptyWarning": MessageLookupByLibrary.simpleMessage(
      "Bitte gib deinen Namen ein.",
    ),
    "nameHint": MessageLookupByLibrary.simpleMessage("Dein Name"),
    "newHabitNameHint": MessageLookupByLibrary.simpleMessage("Name"),
    "newHabitTitle": MessageLookupByLibrary.simpleMessage("Neue Gewohnheit"),
    "newJournalEntry": MessageLookupByLibrary.simpleMessage("Neuer Eintrag"),
    "newTaskHint": MessageLookupByLibrary.simpleMessage("Neue Aufgabe..."),
    "newTodoHint": MessageLookupByLibrary.simpleMessage("Neue Aufgabe..."),
    "noActivePurchases": MessageLookupByLibrary.simpleMessage(
      "Keine aktiven Käufe gefunden.",
    ),
    "noDataMessage": MessageLookupByLibrary.simpleMessage(
      "Keine Daten für diesen Zeitraum",
    ),
    "noHabitsMessage": MessageLookupByLibrary.simpleMessage(
      "Noch keine Gewohnheiten",
    ),
    "noJournalEntries": MessageLookupByLibrary.simpleMessage(
      "Noch keine Einträge im Journal",
    ),
    "noMatchingTasks": MessageLookupByLibrary.simpleMessage(
      "Keine passenden Aufgaben",
    ),
    "noOffersAvailable": MessageLookupByLibrary.simpleMessage(
      "Keine Angebote verfügbar",
    ),
    "noReminder": MessageLookupByLibrary.simpleMessage("Keine"),
    "noTasks": MessageLookupByLibrary.simpleMessage("Keine Aufgaben"),
    "noTasksForDay": m7,
    "noTasksToday": MessageLookupByLibrary.simpleMessage(
      "Keine Aufgaben für heute",
    ),
    "noTodosAdded": MessageLookupByLibrary.simpleMessage(
      "Noch keine To-Dos hinzugefügt.",
    ),
    "notificationActiveMessage": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen sind jetzt aktiv! Lass uns loslegen.",
    ),
    "notificationDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen wurden abgelehnt. Du kannst sie später in den Einstellungen aktivieren.",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "onboardingAgeQuestion": MessageLookupByLibrary.simpleMessage(
      "Wie alt bist du?",
    ),
    "onboardingChatbotTitle": MessageLookupByLibrary.simpleMessage(
      "Chatbot Härtegrad",
    ),
    "onboardingFinishButtonText": MessageLookupByLibrary.simpleMessage(
      "LET’S GO ZUM DASHBOARD!",
    ),
    "onboardingFinishHeadline": MessageLookupByLibrary.simpleMessage(
      "DU HAST ES GESCHAFFT!",
    ),
    "onboardingFinishSubheadline": MessageLookupByLibrary.simpleMessage(
      "Jetzt beginnt der wahre Grind. Du bist bereit, die Kontrolle zu übernehmen.",
    ),
    "onboardingGoalsQuestion": MessageLookupByLibrary.simpleMessage(
      "Was sind deine Ziele?",
    ),
    "onboardingNameQuestion": MessageLookupByLibrary.simpleMessage(
      "Wie heißt du?",
    ),
    "onboardingNotificationButtonText": MessageLookupByLibrary.simpleMessage(
      "Push mich!",
    ),
    "onboardingNotificationDescription": MessageLookupByLibrary.simpleMessage(
      "Stell dir vor, du wirst jeden Tag daran erinnert, besser zu sein als gestern. Deine Ziele, deine To-Dos, deine Disziplin – alles wird stärker, weil du es wirst. Schalte jetzt Benachrichtigungen ein und lass dich von deinem inneren Daimonion pushen.",
    ),
    "onboardingNotificationHeadline": MessageLookupByLibrary.simpleMessage(
      "Mach den ersten Schritt",
    ),
    "onboardingNotificationNextChallenge": MessageLookupByLibrary.simpleMessage(
      "Weiter zur nächsten Challenge",
    ),
    "onboardingTodosSubheadline": MessageLookupByLibrary.simpleMessage(
      "Leg jetzt deine ersten Aufgaben an. Diese To-Dos landen direkt in deiner Hauptliste.",
    ),
    "onboardingTodosTitle": MessageLookupByLibrary.simpleMessage(
      "Deine ersten To-Dos",
    ),
    "paywallContent": MessageLookupByLibrary.simpleMessage(
      "Dieses Tool ist nur für Premium-Mitglieder verfügbar.",
    ),
    "paywallTitle": MessageLookupByLibrary.simpleMessage("Premium benötigt"),
    "premiumPackageNotFound": MessageLookupByLibrary.simpleMessage(
      "Premium-Paket nicht gefunden",
    ),
    "premiumRequired": MessageLookupByLibrary.simpleMessage("Premium benötigt"),
    "premiumRestored": MessageLookupByLibrary.simpleMessage(
      "Premium wiederhergestellt!",
    ),
    "premiumSectionUnavailable": MessageLookupByLibrary.simpleMessage(
      "Dieser Bereich ist nur für Premium-Nutzer verfügbar.",
    ),
    "premiumUpgradeSuccess": MessageLookupByLibrary.simpleMessage(
      "Herzlichen Glückwunsch! Du bist Premium.",
    ),
    "privacyAndTerms": MessageLookupByLibrary.simpleMessage(
      "Datenschutz & Nutzungsbedingungen",
    ),
    "privacyAndTermsContent": MessageLookupByLibrary.simpleMessage(
      "Datenschutz und Nutzungsbedingungen\n\nDatenschutz\nWir nehmen den Schutz deiner Daten ernst. Aktuell speichert unsere App keine Daten in externen Datenbanken. Alle Informationen, die du in der App eingibst, werden lokal auf deinem Gerät gespeichert. Es erfolgt keine Weitergabe deiner Daten an Dritte.\n\nIn Zukunft könnten zusätzliche Funktionen wie ein Login oder Online-Dienste integriert werden. Falls dies geschieht, werden wir diese Datenschutzerklärung entsprechend aktualisieren, um dich transparent über Änderungen zu informieren.\n\nNutzungsbedingungen\nUnsere App ist darauf ausgelegt, dir zu helfen, produktiver zu werden und deine Ziele zu erreichen. Die Nutzung der App erfolgt auf eigene Verantwortung. Wir übernehmen keine Haftung für direkte oder indirekte Schäden, die aus der Nutzung der App entstehen könnten.\n\nBitte benutze die App verantwortungsbewusst und halte dich an die Gesetze deines Landes.\n\nKontakt\nFalls du Fragen oder Anliegen zu unseren Datenschutzrichtlinien oder Nutzungsbedingungen hast, kontaktiere uns unter kontakt@dineswipe.de.",
    ),
    "privacyAndTermsTitle": MessageLookupByLibrary.simpleMessage(
      "Datenschutz & Nutzungsbedingungen",
    ),
    "productiveTimeWeek": MessageLookupByLibrary.simpleMessage(
      "Produktive Zeit (Woche)",
    ),
    "profileHeader": MessageLookupByLibrary.simpleMessage("WHO COULD YOU BE?"),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profil"),
    "purchaseError": m8,
    "reminderLabel": MessageLookupByLibrary.simpleMessage(
      "Reminder (optional):",
    ),
    "restoreError": m9,
    "restorePurchases": MessageLookupByLibrary.simpleMessage(
      "Restore Purchases",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "selectHardness": MessageLookupByLibrary.simpleMessage("Härtegrad wählen"),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("EINSTELLUNGEN"),
    "statAverageFlow": MessageLookupByLibrary.simpleMessage(
      "Ø Zeit pro Flow (Min)",
    ),
    "statAverageWeeklyFlow": MessageLookupByLibrary.simpleMessage(
      "Ø Zeit pro Woche (Min)",
    ),
    "statFlows": MessageLookupByLibrary.simpleMessage("Flows"),
    "statTotalMinutes": MessageLookupByLibrary.simpleMessage("Minuten gesamt"),
    "streak": MessageLookupByLibrary.simpleMessage("Streak"),
    "successContent": MessageLookupByLibrary.simpleMessage(
      "Du hast erfolgreich Premium freigeschaltet!",
    ),
    "successTitle": MessageLookupByLibrary.simpleMessage("Erfolg"),
    "suggestion1": MessageLookupByLibrary.simpleMessage(
      "Ich fühle mich heute faul und unmotiviert.",
    ),
    "suggestion2": MessageLookupByLibrary.simpleMessage(
      "Ich weiß nicht, was ich mit meinem Tag anfangen soll.",
    ),
    "suggestion3": MessageLookupByLibrary.simpleMessage(
      "Ich möchte neue Gewohnheiten aufbauen, aber wie?",
    ),
    "suggestion4": MessageLookupByLibrary.simpleMessage(
      "Ich habe keine Lust zu trainieren. Überzeug mich!",
    ),
    "suggestion5": MessageLookupByLibrary.simpleMessage(
      "Womit kann ich heute anfangen, produktiver zu sein?",
    ),
    "suggestion6": MessageLookupByLibrary.simpleMessage(
      "Gib mir einen Tritt in den Hintern!",
    ),
    "taskTitleLabel": MessageLookupByLibrary.simpleMessage("Titel"),
    "tasks": MessageLookupByLibrary.simpleMessage("Tasks"),
    "tasksToolTitle": MessageLookupByLibrary.simpleMessage("Tasks"),
    "todayLabel": MessageLookupByLibrary.simpleMessage("Heute:"),
    "todaysTasks": MessageLookupByLibrary.simpleMessage("HEUTIGE TASKS"),
    "todoListTitle": MessageLookupByLibrary.simpleMessage("To-Do-Liste"),
    "toolsPageTitle": MessageLookupByLibrary.simpleMessage(
      "Deine Werkzeuge zum Sieg",
    ),
    "unknownUser": MessageLookupByLibrary.simpleMessage("Unbekannter Nutzer"),
    "untitled": MessageLookupByLibrary.simpleMessage("(Ohne Titel)"),
    "upgradeContent": MessageLookupByLibrary.simpleMessage(
      "Du hast deine 5 kostenlosen Prompts verbraucht.\n\nHol dir jetzt die Premium-Version für unbegrenzte Chats!",
    ),
    "upgradeTitle": MessageLookupByLibrary.simpleMessage("Upgrade nötig"),
    "upgradeToPremium": MessageLookupByLibrary.simpleMessage(
      "Upgrade zu Premium",
    ),
    "version": MessageLookupByLibrary.simpleMessage("Version"),
    "weeklyProgress": MessageLookupByLibrary.simpleMessage("WOCHENFORTSCHRITT"),
  };
}
