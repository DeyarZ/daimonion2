import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appBarTitle => 'Daimonion Chat';

  @override
  String freePromptsCounter(Object usedPrompts) {
    return 'Kostenlose Prompts genutzt: $usedPrompts / 5';
  }

  @override
  String get upgradeTitle => 'Upgrade nötig';

  @override
  String get upgradeContent => 'Du hast deine 5 kostenlosen Prompts verbraucht.\n\nHol dir jetzt die Premium-Version für unbegrenzte Chats!';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get buyPremium => 'Premium kaufen';

  @override
  String get errorTitle => 'Fehler';

  @override
  String get errorContent => 'Es ist ein Fehler aufgetreten. Bitte versuche es später erneut.';

  @override
  String get ok => 'OK';

  @override
  String get successTitle => 'Erfolg';

  @override
  String get successContent => 'Du hast erfolgreich Premium freigeschaltet!';

  @override
  String get hintText => 'Frag Daimonion was du willst...';

  @override
  String get suggestion1 => 'Ich fühle mich heute faul und unmotiviert.';

  @override
  String get suggestion2 => 'Ich weiß nicht, was ich mit meinem Tag anfangen soll.';

  @override
  String get suggestion3 => 'Ich möchte neue Gewohnheiten aufbauen, aber wie?';

  @override
  String get suggestion4 => 'Ich habe keine Lust zu trainieren. Überzeug mich!';

  @override
  String get suggestion5 => 'Womit kann ich heute anfangen, produktiver zu sein?';

  @override
  String get suggestion6 => 'Gib mir einen Tritt in den Hintern!';

  @override
  String errorOccurred(Object error) {
    return 'Ein Fehler ist aufgetreten: $error';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get productiveTimeWeek => 'Produktive Zeit (Woche)';

  @override
  String get streak => 'Streak';

  @override
  String get flowTimer => 'Flow Timer';

  @override
  String get todaysTasks => 'HEUTIGE TASKS';

  @override
  String get noTasksToday => 'Keine Aufgaben für heute';

  @override
  String get tasks => 'Tasks';

  @override
  String get habits => 'Habits';

  @override
  String get weeklyProgress => 'WOCHENFORTSCHRITT';

  @override
  String get premiumRequired => 'Premium benötigt';

  @override
  String get premiumSectionUnavailable => 'Dieser Bereich ist nur für Premium-Nutzer verfügbar.';

  @override
  String get cheerPerfect => 'Perfekt! Du hast heute alle Gewohnheiten erledigt. Keep pushing!';

  @override
  String get cheerHalf => 'Schon über die Hälfte deiner Gewohnheiten geschafft – stark!';

  @override
  String get cheerAlmost => 'Noch nicht fertig, aber du packst das. Nur weitermachen!';

  @override
  String get cheerStart => 'Pack an! Zeit, etwas zu tun!';

  @override
  String get motivationQuotes => 'Du bist nicht hier, um Durchschnitt zu sein!||Keine Ausreden – geh weiter!||Wenn du aufgibst, hast du es nie ernst gemeint.||Jeder Tag eine neue Chance, nutze sie!||Your future self will thank you for your grind today.||Disziplin schlägt Talent – jeden Tag.||Was du heute tust, entscheidet über morgen.||Träume groß, arbeite härter.||Du bist stärker, als du denkst.||Kein Wachstum ohne Anstrengung.||Die härtesten Kämpfe kommen vor den größten Siegen.||Du musst die Person werden, die du dir wünschst zu sein – Schritt für Schritt.||Egal, wie langsam du gehst, du schlägst jeden, der auf der Couch bleibt.||Fehler sind der Beweis, dass du es versuchst.||Man wächst nicht in seiner Komfortzone – wage den Schritt hinaus.||Harte Arbeit wird nicht immer belohnt, aber sie baut Charakter.||Es sind die kleinen täglichen Siege, die die großen Erfolge formen.||Du hast 24 Stunden wie jeder andere – nutze sie mit Intention.||Deine Ziele interessieren sich nicht für deine Ausreden.||Wenn der Weg einfach ist, bist du auf dem falschen Pfad.||Hör auf zu reden, fang an zu machen.||Jeder Erfolg beginnt mit dem Mut, es zu versuchen.||Stärke wächst, wo Komfort endet.||Deine einzige Grenze ist die, die du dir selbst setzt.||Dein Potenzial wartet auf deinen Einsatz.||Jedes Nein bringt dich näher an ein Ja.||Konzentriere dich auf das, was du kontrollieren kannst.||Das Gestern ist vergangen. Heute ist dein Tag.||Die besten Entscheidungen sind oft die schwersten.||Ein kleiner Fortschritt ist immer noch Fortschritt.||Die schwierigste Entscheidung deines Lebens könnte die sein, die alles verändert.||Jede großartige Reise beginnt mit dem ersten Schritt.||Menschen, die dich unterschätzen, geben dir das größte Geschenk: den Ansporn, zu beweisen, dass sie falsch liegen.||Erfolg ist kein Ziel, sondern eine Reise – bleib dran.||Du kannst nichts kontrollieren außer deiner Reaktion auf die Welt.||Die schwierigsten Momente sind oft die, die dich am meisten formen.||Was du heute pflanzt, wirst du morgen ernten.||Wenn du versagst, versuche es erneut, aber versage diesmal besser.||Erfolg bedeutet nicht Perfektion, sondern Fortschritt.||Das Leben gibt dir, was du bereit bist, dir selbst zu nehmen.||Der Schmerz vergeht, der Stolz bleibt.||Fokus schlägt Chaos.||Tu, was getan werden muss.||Du bist ein Krieger, keine Ausrede zählt.||Hass treibt dich an, Liebe macht dich unaufhaltsam.||Ziele hoch – immer.||Disziplin ist Freiheit.||Entweder du machst es oder jemand anderes tut es.||Verliere nie deinen Glauben an dich selbst.||Angst ist dein Kompass – folge ihr.';

  @override
  String get firstTimeHeadline => 'WILLST DU JEMAND SEIN, DER KONTROLLE HAT,\nODER WILLST DU EIN SKLAVE DEINER IMPULSE BLEIBEN?';

  @override
  String get firstTimeButtonText => 'ICH BIN BEREIT';

  @override
  String get flowStatsTitle => 'Flow Stats';

  @override
  String get filterWeek => 'Woche';

  @override
  String get filterMonth => 'Monat';

  @override
  String get filterYear => 'Jahr';

  @override
  String get noDataMessage => 'Keine Daten für diesen Zeitraum';

  @override
  String get statFlows => 'Flows';

  @override
  String get statTotalMinutes => 'Minuten gesamt';

  @override
  String get statAverageFlow => 'Ø Zeit pro Flow (Min)';

  @override
  String get statAverageWeeklyFlow => 'Ø Zeit pro Woche (Min)';

  @override
  String get flowTimerTitle => 'Flow-Timer';

  @override
  String flowCounter(Object currentFlow, Object totalFlows) {
    return 'Flow $currentFlow / $totalFlows';
  }

  @override
  String get flowTimerSetTimeTitle => 'Flow-Zeit einstellen';

  @override
  String get flowTimerSetTimeHint => 'Minuten eingeben...';

  @override
  String get flowTimerSetFlowsTitle => 'Flow-Einstellungen';

  @override
  String get flowTimerSetFlowsHint => 'Anzahl der Flows';

  @override
  String get habitTrackerTitle => 'Habit Tracker';

  @override
  String get todayLabel => 'Heute:';

  @override
  String get noHabitsMessage => 'Noch keine Gewohnheiten';

  @override
  String get habitHeader => 'Habit';

  @override
  String get newHabitTitle => 'Neue Gewohnheit';

  @override
  String get newHabitNameHint => 'Name';

  @override
  String get reminderLabel => 'Reminder (optional):';

  @override
  String get noReminder => 'Keine';

  @override
  String get deleteHabitTitle => 'Löschen?';

  @override
  String deleteHabitMessage(Object habitName) {
    return 'Möchtest du die Gewohnheit \"$habitName\" wirklich löschen?';
  }

  @override
  String get confirmDeleteHabit => 'Ja, löschen';

  @override
  String get journalTitle => 'Journal';

  @override
  String get noJournalEntries => 'Noch keine Einträge im Journal';

  @override
  String get untitled => '(Ohne Titel)';

  @override
  String get newJournalEntry => 'Neuer Eintrag';

  @override
  String get editJournalEntry => 'Eintrag bearbeiten';

  @override
  String get journalTitleLabel => 'Titel';

  @override
  String get journalContentLabel => 'Inhalt';

  @override
  String get journalMoodLabel => 'Stimmung:';

  @override
  String get deleteJournalEntryTitle => 'Löschen?';

  @override
  String deleteJournalEntryMessage(Object entryTitle) {
    return 'Möchtest du den Eintrag \"$entryTitle\" wirklich löschen?';
  }

  @override
  String get confirmDelete => 'Ja, löschen';

  @override
  String get privacyAndTermsTitle => 'Datenschutz & Nutzungsbedingungen';

  @override
  String get privacyAndTermsContent => 'Datenschutz und Nutzungsbedingungen\n\nDatenschutz\nWir nehmen den Schutz deiner Daten ernst. Aktuell speichert unsere App keine Daten in externen Datenbanken. Alle Informationen, die du in der App eingibst, werden lokal auf deinem Gerät gespeichert. Es erfolgt keine Weitergabe deiner Daten an Dritte.\n\nIn Zukunft könnten zusätzliche Funktionen wie ein Login oder Online-Dienste integriert werden. Falls dies geschieht, werden wir diese Datenschutzerklärung entsprechend aktualisieren, um dich transparent über Änderungen zu informieren.\n\nNutzungsbedingungen\nUnsere App ist darauf ausgelegt, dir zu helfen, produktiver zu werden und deine Ziele zu erreichen. Die Nutzung der App erfolgt auf eigene Verantwortung. Wir übernehmen keine Haftung für direkte oder indirekte Schäden, die aus der Nutzung der App entstehen könnten.\n\nBitte benutze die App verantwortungsbewusst und halte dich an die Gesetze deines Landes.\n\nKontakt\nFalls du Fragen oder Anliegen zu unseren Datenschutzrichtlinien oder Nutzungsbedingungen hast, kontaktiere uns unter kontakt@dineswipe.de.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileHeader => 'WHO COULD YOU BE?';

  @override
  String get unknownUser => 'Unbekannter Nutzer';

  @override
  String get editProfile => 'Bearbeiten';

  @override
  String get editProfileTitle => 'Name bearbeiten';

  @override
  String get editProfileHint => 'Dein Name';

  @override
  String get save => 'Speichern';

  @override
  String get settingsTitle => 'EINSTELLUNGEN';

  @override
  String get hardnessTitle => 'Härtegrad';

  @override
  String get hardnessNormal => 'Normal';

  @override
  String get hardnessHard => 'Hart';

  @override
  String get hardnessBrutal => 'Brutal ehrlich';

  @override
  String get legalAndAppInfoTitle => 'RECHTLICHES & APP-INFOS';

  @override
  String get privacyAndTerms => 'Datenschutz & Nutzungsbedingungen';

  @override
  String get version => 'Version';

  @override
  String get accountTitle => 'ACCOUNT';

  @override
  String get upgradeToPremium => 'Upgrade zu Premium';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get premiumPackageNotFound => 'Premium-Paket nicht gefunden';

  @override
  String get noOffersAvailable => 'Keine Angebote verfügbar';

  @override
  String get premiumUpgradeSuccess => 'Herzlichen Glückwunsch! Du bist Premium.';

  @override
  String purchaseError(Object error) {
    return 'Fehler beim Kauf: $error';
  }

  @override
  String get premiumRestored => 'Premium wiederhergestellt!';

  @override
  String get noActivePurchases => 'Keine aktiven Käufe gefunden.';

  @override
  String restoreError(Object error) {
    return 'Fehler beim Wiederherstellen: $error';
  }

  @override
  String get selectHardness => 'Härtegrad wählen';

  @override
  String get hardnessQuestion => 'WIE HART SOLL ICH ZU DIR SEIN?';

  @override
  String get todoListTitle => 'To-Do-Liste';

  @override
  String get newTaskHint => 'Neue Aufgabe...';

  @override
  String get addTask => 'Add';

  @override
  String get noTasks => 'Keine Aufgaben';

  @override
  String get noMatchingTasks => 'Keine passenden Aufgaben';

  @override
  String dueOn(Object date) {
    return 'Fällig am $date';
  }

  @override
  String get editTask => 'Aufgabe bearbeiten';

  @override
  String get deleteTask => 'Löschen';

  @override
  String get editTaskDialogTitle => 'Aufgabe bearbeiten';

  @override
  String get taskTitleLabel => 'Titel';

  @override
  String get changeDeadline => 'Deadline ändern';

  @override
  String get dailyReminderActivated => 'Täglicher Reminder um 20:00 aktiviert!';

  @override
  String get dailyReminderDeactivated => 'Täglicher Reminder wurde deaktiviert.';

  @override
  String get hideDone => 'Hide done';

  @override
  String get calendarViewTitle => 'Kalender-Übersicht';

  @override
  String chooseDay(Object date) {
    return 'Tag wählen: $date';
  }

  @override
  String noTasksForDay(Object date) {
    return 'Keine Aufgaben für $date';
  }

  @override
  String get toolsPageTitle => 'Deine Werkzeuge zum Sieg';

  @override
  String get flowTimerToolTitle => 'Flow Timer';

  @override
  String get tasksToolTitle => 'Tasks';

  @override
  String get journalToolTitle => 'Journal';

  @override
  String get habitTrackerToolTitle => 'Gewohnheitstracker';

  @override
  String get paywallTitle => 'Premium benötigt';

  @override
  String get paywallContent => 'Dieses Tool ist nur für Premium-Mitglieder verfügbar.';

  @override
  String get flowTimerBreakLabel => 'Pause';

  @override
  String get autoStartBreak => 'Automatisch Pause starten';

  @override
  String get autoStartNextFlow => 'Automatisch nächsten Flow starten';

  @override
  String get keepScreenOn => 'Bildschirm anlassen';

  @override
  String get onboardingAgeQuestion => 'Wie alt bist du?';

  @override
  String get continueButton => 'Weiter';

  @override
  String get onboardingChatbotTitle => 'Chatbot Härtegrad';

  @override
  String get chatbotModeNormal => 'Normal';

  @override
  String get chatbotModeHard => 'Hart';

  @override
  String get chatbotModeBrutal => 'Brutal Ehrlich';

  @override
  String get chatbotWarning => 'Achtung: Im Modus \"Brutal Ehrlich\" wirst du beleidigt und extrem herausgefordert.';

  @override
  String get onboardingFinishHeadline => 'DU HAST ES GESCHAFFT!';

  @override
  String get onboardingFinishSubheadline => 'Jetzt beginnt der wahre Grind. Du bist bereit, die Kontrolle zu übernehmen.';

  @override
  String get onboardingFinishButtonText => 'LET’S GO ZUM DASHBOARD!';

  @override
  String get onboardingGoalsQuestion => 'Was sind deine Ziele?';

  @override
  String get goalFit => 'Fitter werden';

  @override
  String get goalProductivity => 'Produktiver sein';

  @override
  String get goalSaveMoney => 'Mehr Geld sparen';

  @override
  String get goalBetterRelationships => 'Bessere Beziehungen aufbauen';

  @override
  String get goalMentalHealth => 'Mentale Gesundheit stärken';

  @override
  String get goalCareer => 'Karriere vorantreiben';

  @override
  String get onboardingNameQuestion => 'Wie heißt du?';

  @override
  String get nameHint => 'Dein Name';

  @override
  String get nameEmptyWarning => 'Bitte gib deinen Namen ein.';

  @override
  String get onboardingNotificationHeadline => 'Mach den ersten Schritt';

  @override
  String get onboardingNotificationDescription => 'Stell dir vor, du wirst jeden Tag daran erinnert, besser zu sein als gestern. Deine Ziele, deine To-Dos, deine Disziplin – alles wird stärker, weil du es wirst. Schalte jetzt Benachrichtigungen ein und lass dich von deinem inneren Daimonion pushen.';

  @override
  String get onboardingNotificationButtonText => 'Push mich!';

  @override
  String get notificationActiveMessage => 'Benachrichtigungen sind jetzt aktiv! Lass uns loslegen.';

  @override
  String get notificationDeniedMessage => 'Benachrichtigungen wurden abgelehnt. Du kannst sie später in den Einstellungen aktivieren.';

  @override
  String get onboardingNotificationNextChallenge => 'Weiter zur nächsten Challenge';

  @override
  String get onboardingTodosTitle => 'Deine ersten To-Dos';

  @override
  String get onboardingTodosSubheadline => 'Leg jetzt deine ersten Aufgaben an. Diese To-Dos landen direkt in deiner Hauptliste.';

  @override
  String get newTodoHint => 'Neue Aufgabe...';

  @override
  String get addTodo => 'Add';

  @override
  String get noTodosAdded => 'Noch keine To-Dos hinzugefügt.';

  @override
  String get dailyFundamentalsTitle => 'GRUNDLAGEN';

  @override
  String get shortCheckGym => 'Körper';

  @override
  String get shortCheckMental => 'Mental';

  @override
  String get shortCheckNoPorn => 'Kein Porn';

  @override
  String get shortCheckHealthyEating => 'Gesund';

  @override
  String get shortCheckHelpOthers => 'Helfen';

  @override
  String get shortCheckNature => 'Natur';

  @override
  String get fullCheckGym => 'Hast du heute was für dein Körper getan?';

  @override
  String get fullCheckMental => 'Hast du heute etwas Produktives für deinen Kopf getan?';

  @override
  String get fullCheckNoPorn => 'Bist du heute von Pornos weggeblieben?';

  @override
  String get fullCheckHealthyEating => 'Hast du heute gesund gegessen?';

  @override
  String get fullCheckHelpOthers => 'Hast du heute etwas Gutes für andere getan?';

  @override
  String get fullCheckNature => 'Did you spend time in nature today?';

  @override
  String get dailyInsultTitle => 'Du hast verkackt!';

  @override
  String get dailyInsultAllMissed => 'Du hast ALLE Grundlagen ignoriert!';

  @override
  String dailyInsultSomeMissed(Object count) {
    return 'Du hast $count Grundlagen verkackt.';
  }

  @override
  String get loadOffers => 'Angebote laden';

  @override
  String get trainingPlanToolTitle => 'Trainingsplan';

  @override
  String get appTitle => 'Trainingsplan';

  @override
  String get workoutNameLabel => 'Workout-Name';

  @override
  String get noExercisesMessage => 'Keine Übungen hinzugefügt.\nFang an, dein Workout zu erstellen!';

  @override
  String get newExerciseHint => 'Neue Übung eingeben...';

  @override
  String get addExerciseSnackbar => 'Gib eine Übung ein!';

  @override
  String get editExerciseTitle => 'Übungsdetails bearbeiten';

  @override
  String get setsLabel => 'Sätze';

  @override
  String get repsLabel => 'Wiederholungen';

  @override
  String get weightLabel => 'Gewicht (kg)';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get saveButton => 'Speichern';

  @override
  String get getPremiumButton => 'Get Premium';

  @override
  String get title_progress => 'Dein Fortschritt';

  @override
  String level_text(Object level) {
    return 'Level $level';
  }

  @override
  String status_text(Object status) {
    return 'Status: $status';
  }

  @override
  String progress_text(Object nextLevel, Object percent) {
    return '$percent% bis Level $nextLevel';
  }

  @override
  String xp_text(Object xpProgress, Object xpToNextLevel) {
    return '$xpProgress / $xpToNextLevel XP';
  }

  @override
  String get motivation_text => 'Let\'s go! Hör auf zu jammern und zeig, was in dir steckt!';

  @override
  String get streak_info_title => 'Streak-Info';

  @override
  String streak_days(Object streak) {
    return '$streak Tage Streak';
  }

  @override
  String xp_bonus(Object bonusPercent) {
    return 'XP Bonus: $bonusPercent%';
  }

  @override
  String get streak_description => 'Je länger du täglich aktiv bist, desto mehr XP bekommst du! Deine Streak belohnt dich für Konsistenz und sorgt dafür, dass du schneller im Level aufsteigst.';

  @override
  String get streak_rewards => '- 7+ Tage: +5% XP\\n- 14+ Tage: +10% XP\\n- 30+ Tage: +15% XP\\n';

  @override
  String get back_button => 'Zurück';

  @override
  String get levels_and_rankings => 'Level und Ränge';

  @override
  String get how_to_earn_xp => 'Wie du XP kassierst & Level aufsteigst!';

  @override
  String get action => 'Aktion';

  @override
  String get xp => 'XP';

  @override
  String get max_per_day => 'Max/Tag';

  @override
  String get complete_todo => 'To-Do erledigen';

  @override
  String get complete_habit => 'Gewohnheit abschließen';

  @override
  String get journal_entry => 'Journal-Eintrag';

  @override
  String get ten_min_flow => '10 min Flow';

  @override
  String get levels_and_ranks => 'Level & Ränge';

  @override
  String get level => 'Level';

  @override
  String get rank => 'Rang';

  @override
  String get badge => 'Abzeichen';

  @override
  String get recruit => 'Rekrut';

  @override
  String get soldier => 'Soldat';

  @override
  String get elite_soldier => 'Elite-Soldat';

  @override
  String get veteran => 'Veteran';

  @override
  String get sergeant => 'Sergeant';

  @override
  String get lieutenant => 'Leutnant';

  @override
  String get captain => 'Captain';

  @override
  String get major => 'Major';

  @override
  String get colonel => 'Colonel';

  @override
  String get general => 'General';

  @override
  String get warlord => 'Kriegsherr';

  @override
  String get daimonion_warlord => 'Daimonion-Warlord';

  @override
  String get legend => 'Legende';

  @override
  String get immortal => 'Unsterblicher';

  @override
  String get keep_grinding => 'Bleib dran!';

  @override
  String get back => 'Zurück';

  @override
  String get unlock_premium => 'Premium freischalten';

  @override
  String get premium_description => 'Abonniere, um vollen Zugriff auf Premium-Funktionen zu erhalten';

  @override
  String get access_journal => 'Zugriff auf das Journal-Tool';

  @override
  String get access_habit_tracker => 'Zugriff auf den Gewohnheitstracker';

  @override
  String get unlimited_chat_prompts => 'Unbegrenzte Chat-Prompts';

  @override
  String get more_to_come => 'Mehr kommt noch!';

  @override
  String get weekly => 'Wöchentlich';

  @override
  String get monthly => 'Monatlich';

  @override
  String get yearly => 'Jährlich';

  @override
  String get weekly_price => '1,99 €/Woche';

  @override
  String get monthly_price => '3,99 €/Monat';

  @override
  String get yearly_price => '29,99 €/Jahr';

  @override
  String get auto_renewal => 'Automatische Verlängerung';

  @override
  String get subscription_disclaimer => 'Jederzeit kündbar | Datenschutzrichtlinie\nDein Abo verlängert sich automatisch. Kündige es mindestens 24 Stunden vor der Erneuerung im Google Play Store.';

  @override
  String get coming_soon => 'Bald verfügbar';

  @override
  String get coming_soon_description => 'Diese Option wird bald verfügbar sein!';

  @override
  String get thank_you => 'Vielen Dank!';

  @override
  String get premium_activated => 'Dein Premium-Abo wurde aktiviert!';

  @override
  String get subscription_failed => 'Abo konnte nicht aktiviert werden.';

  @override
  String get premium_not_available => 'Premium-Paket nicht verfügbar.';

  @override
  String get feedbackButtonLabel => 'Feedback senden';

  @override
  String get noEmailClientFound => 'Kein E-Mail-Client auf diesem Gerät gefunden.';
}
