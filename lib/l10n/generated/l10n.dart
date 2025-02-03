// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Daimonion Chat`
  String get appBarTitle {
    return Intl.message(
      'Daimonion Chat',
      name: 'appBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Free prompts used: {usedPrompts} / 5`
  String freePromptsCounter(Object usedPrompts) {
    return Intl.message(
      'Free prompts used: $usedPrompts / 5',
      name: 'freePromptsCounter',
      desc: '',
      args: [usedPrompts],
    );
  }

  /// `Upgrade Needed`
  String get upgradeTitle {
    return Intl.message(
      'Upgrade Needed',
      name: 'upgradeTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have used your 5 free prompts.\n\nGet the premium version for unlimited chats now!`
  String get upgradeContent {
    return Intl.message(
      'You have used your 5 free prompts.\n\nGet the premium version for unlimited chats now!',
      name: 'upgradeContent',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Buy Premium`
  String get buyPremium {
    return Intl.message('Buy Premium', name: 'buyPremium', desc: '', args: []);
  }

  /// `Error`
  String get errorTitle {
    return Intl.message('Error', name: 'errorTitle', desc: '', args: []);
  }

  /// `An error occurred. Please try again later.`
  String get errorContent {
    return Intl.message(
      'An error occurred. Please try again later.',
      name: 'errorContent',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Success`
  String get successTitle {
    return Intl.message('Success', name: 'successTitle', desc: '', args: []);
  }

  /// `You have successfully unlocked premium!`
  String get successContent {
    return Intl.message(
      'You have successfully unlocked premium!',
      name: 'successContent',
      desc: '',
      args: [],
    );
  }

  /// `Ask Daimonion whatever you want...`
  String get hintText {
    return Intl.message(
      'Ask Daimonion whatever you want...',
      name: 'hintText',
      desc: '',
      args: [],
    );
  }

  /// `I'm feeling lazy and unmotivated today.`
  String get suggestion1 {
    return Intl.message(
      'I\'m feeling lazy and unmotivated today.',
      name: 'suggestion1',
      desc: '',
      args: [],
    );
  }

  /// `I don't know what to do with my day.`
  String get suggestion2 {
    return Intl.message(
      'I don\'t know what to do with my day.',
      name: 'suggestion2',
      desc: '',
      args: [],
    );
  }

  /// `I want to build new habits, but how?`
  String get suggestion3 {
    return Intl.message(
      'I want to build new habits, but how?',
      name: 'suggestion3',
      desc: '',
      args: [],
    );
  }

  /// `I don't feel like working out. Convince me!`
  String get suggestion4 {
    return Intl.message(
      'I don\'t feel like working out. Convince me!',
      name: 'suggestion4',
      desc: '',
      args: [],
    );
  }

  /// `What can I start with today to be more productive?`
  String get suggestion5 {
    return Intl.message(
      'What can I start with today to be more productive?',
      name: 'suggestion5',
      desc: '',
      args: [],
    );
  }

  /// `Give me a kick in the butt!`
  String get suggestion6 {
    return Intl.message(
      'Give me a kick in the butt!',
      name: 'suggestion6',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred: {error}`
  String errorOccurred(Object error) {
    return Intl.message(
      'An error occurred: $error',
      name: 'errorOccurred',
      desc: '',
      args: [error],
    );
  }

  /// `Dashboard`
  String get dashboardTitle {
    return Intl.message(
      'Dashboard',
      name: 'dashboardTitle',
      desc: '',
      args: [],
    );
  }

  /// `Productive Time (Week)`
  String get productiveTimeWeek {
    return Intl.message(
      'Productive Time (Week)',
      name: 'productiveTimeWeek',
      desc: '',
      args: [],
    );
  }

  /// `Streak`
  String get streak {
    return Intl.message('Streak', name: 'streak', desc: '', args: []);
  }

  /// `Flow Timer`
  String get flowTimer {
    return Intl.message('Flow Timer', name: 'flowTimer', desc: '', args: []);
  }

  /// `TODAY'S TASKS`
  String get todaysTasks {
    return Intl.message(
      'TODAY\'S TASKS',
      name: 'todaysTasks',
      desc: '',
      args: [],
    );
  }

  /// `No tasks for today`
  String get noTasksToday {
    return Intl.message(
      'No tasks for today',
      name: 'noTasksToday',
      desc: '',
      args: [],
    );
  }

  /// `Tasks`
  String get tasks {
    return Intl.message('Tasks', name: 'tasks', desc: '', args: []);
  }

  /// `Habits`
  String get habits {
    return Intl.message('Habits', name: 'habits', desc: '', args: []);
  }

  /// `WEEKLY PROGRESS`
  String get weeklyProgress {
    return Intl.message(
      'WEEKLY PROGRESS',
      name: 'weeklyProgress',
      desc: '',
      args: [],
    );
  }

  /// `Premium Required`
  String get premiumRequired {
    return Intl.message(
      'Premium Required',
      name: 'premiumRequired',
      desc: '',
      args: [],
    );
  }

  /// `This section is available for premium users only.`
  String get premiumSectionUnavailable {
    return Intl.message(
      'This section is available for premium users only.',
      name: 'premiumSectionUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Perfect! You completed all your habits today. Keep pushing!`
  String get cheerPerfect {
    return Intl.message(
      'Perfect! You completed all your habits today. Keep pushing!',
      name: 'cheerPerfect',
      desc: '',
      args: [],
    );
  }

  /// `You've already completed more than half of your habits – strong!`
  String get cheerHalf {
    return Intl.message(
      'You\'ve already completed more than half of your habits – strong!',
      name: 'cheerHalf',
      desc: '',
      args: [],
    );
  }

  /// `Not done yet, but you got this. Keep going!`
  String get cheerAlmost {
    return Intl.message(
      'Not done yet, but you got this. Keep going!',
      name: 'cheerAlmost',
      desc: '',
      args: [],
    );
  }

  /// `Get to it! Time to do something!`
  String get cheerStart {
    return Intl.message(
      'Get to it! Time to do something!',
      name: 'cheerStart',
      desc: '',
      args: [],
    );
  }

  /// `You’re not here to be average!||No excuses – keep moving!||If you quit, you never meant it anyway.||Every day is a new chance – seize it!||Your future self will thank you for today’s grind.||Discipline beats talent – every day.||What you do today decides tomorrow.||Dream big, work harder.||You’re stronger than you think.||No growth without effort.||The toughest battles come before the greatest victories.||You must become the person you want to be – step by step.||No matter how slow you go, you’re beating everyone sitting on the couch.||Mistakes prove that you’re trying.||You don’t grow in your comfort zone – dare to step out.||Hard work isn’t always rewarded, but it builds character.||It’s the small daily victories that form great successes.||You have 24 hours like everyone else – use them with intention.||Your goals don’t care about your excuses.||If the path is easy, you’re on the wrong track.||Stop talking and start doing.||Every success begins with the courage to try.||Strength grows where comfort ends.||Your only limit is the one you set for yourself.||Your potential is waiting for you to act.||Every no brings you closer to a yes.||Focus on what you can control.||Yesterday is gone. Today is your day.||The best decisions are often the hardest.||A small progress is still progress.||The hardest decision of your life might be the one that changes everything.||Every great journey begins with a single step.||Those who underestimate you give you the greatest gift: the drive to prove them wrong.||Success is not a destination, but a journey – keep at it.||You can’t control anything except your reaction to the world.||The toughest moments often shape you the most.||What you plant today, you will harvest tomorrow.||If you fail, try again – but fail better next time.||Success means progress, not perfection.||Pain is temporary, pride lasts forever.||Focus beats chaos.||Do what needs to be done.||You’re a warrior – no excuse counts.||Hate fuels you, love makes you unstoppable.||Aim high – always.||Discipline is freedom.||Either you do it or someone else will.||Never lose faith in yourself.||Fear is your compass – follow it.`
  String get motivationQuotes {
    return Intl.message(
      'You’re not here to be average!||No excuses – keep moving!||If you quit, you never meant it anyway.||Every day is a new chance – seize it!||Your future self will thank you for today’s grind.||Discipline beats talent – every day.||What you do today decides tomorrow.||Dream big, work harder.||You’re stronger than you think.||No growth without effort.||The toughest battles come before the greatest victories.||You must become the person you want to be – step by step.||No matter how slow you go, you’re beating everyone sitting on the couch.||Mistakes prove that you’re trying.||You don’t grow in your comfort zone – dare to step out.||Hard work isn’t always rewarded, but it builds character.||It’s the small daily victories that form great successes.||You have 24 hours like everyone else – use them with intention.||Your goals don’t care about your excuses.||If the path is easy, you’re on the wrong track.||Stop talking and start doing.||Every success begins with the courage to try.||Strength grows where comfort ends.||Your only limit is the one you set for yourself.||Your potential is waiting for you to act.||Every no brings you closer to a yes.||Focus on what you can control.||Yesterday is gone. Today is your day.||The best decisions are often the hardest.||A small progress is still progress.||The hardest decision of your life might be the one that changes everything.||Every great journey begins with a single step.||Those who underestimate you give you the greatest gift: the drive to prove them wrong.||Success is not a destination, but a journey – keep at it.||You can’t control anything except your reaction to the world.||The toughest moments often shape you the most.||What you plant today, you will harvest tomorrow.||If you fail, try again – but fail better next time.||Success means progress, not perfection.||Pain is temporary, pride lasts forever.||Focus beats chaos.||Do what needs to be done.||You’re a warrior – no excuse counts.||Hate fuels you, love makes you unstoppable.||Aim high – always.||Discipline is freedom.||Either you do it or someone else will.||Never lose faith in yourself.||Fear is your compass – follow it.',
      name: 'motivationQuotes',
      desc: '',
      args: [],
    );
  }

  /// `DO YOU WANT TO BE SOMEONE WHO HAS CONTROL,\nOR DO YOU WANT TO REMAIN A SLAVE TO YOUR IMPULSES?`
  String get firstTimeHeadline {
    return Intl.message(
      'DO YOU WANT TO BE SOMEONE WHO HAS CONTROL,\nOR DO YOU WANT TO REMAIN A SLAVE TO YOUR IMPULSES?',
      name: 'firstTimeHeadline',
      desc: '',
      args: [],
    );
  }

  /// `I'M READY`
  String get firstTimeButtonText {
    return Intl.message(
      'I\'M READY',
      name: 'firstTimeButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Flow Stats`
  String get flowStatsTitle {
    return Intl.message(
      'Flow Stats',
      name: 'flowStatsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Week`
  String get filterWeek {
    return Intl.message('Week', name: 'filterWeek', desc: '', args: []);
  }

  /// `Month`
  String get filterMonth {
    return Intl.message('Month', name: 'filterMonth', desc: '', args: []);
  }

  /// `Year`
  String get filterYear {
    return Intl.message('Year', name: 'filterYear', desc: '', args: []);
  }

  /// `No data for this period`
  String get noDataMessage {
    return Intl.message(
      'No data for this period',
      name: 'noDataMessage',
      desc: '',
      args: [],
    );
  }

  /// `Flows`
  String get statFlows {
    return Intl.message('Flows', name: 'statFlows', desc: '', args: []);
  }

  /// `Total Minutes`
  String get statTotalMinutes {
    return Intl.message(
      'Total Minutes',
      name: 'statTotalMinutes',
      desc: '',
      args: [],
    );
  }

  /// `Avg Time per Flow (Min)`
  String get statAverageFlow {
    return Intl.message(
      'Avg Time per Flow (Min)',
      name: 'statAverageFlow',
      desc: '',
      args: [],
    );
  }

  /// `Avg Time per Week (Min)`
  String get statAverageWeeklyFlow {
    return Intl.message(
      'Avg Time per Week (Min)',
      name: 'statAverageWeeklyFlow',
      desc: '',
      args: [],
    );
  }

  /// `Flow Timer`
  String get flowTimerTitle {
    return Intl.message(
      'Flow Timer',
      name: 'flowTimerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Flow {currentFlow} / {totalFlows}`
  String flowCounter(Object currentFlow, Object totalFlows) {
    return Intl.message(
      'Flow $currentFlow / $totalFlows',
      name: 'flowCounter',
      desc: '',
      args: [currentFlow, totalFlows],
    );
  }

  /// `Set Flow Time`
  String get flowTimerSetTimeTitle {
    return Intl.message(
      'Set Flow Time',
      name: 'flowTimerSetTimeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter minutes...`
  String get flowTimerSetTimeHint {
    return Intl.message(
      'Enter minutes...',
      name: 'flowTimerSetTimeHint',
      desc: '',
      args: [],
    );
  }

  /// `Flow Settings`
  String get flowTimerSetFlowsTitle {
    return Intl.message(
      'Flow Settings',
      name: 'flowTimerSetFlowsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Number of flows`
  String get flowTimerSetFlowsHint {
    return Intl.message(
      'Number of flows',
      name: 'flowTimerSetFlowsHint',
      desc: '',
      args: [],
    );
  }

  /// `Habit Tracker`
  String get habitTrackerTitle {
    return Intl.message(
      'Habit Tracker',
      name: 'habitTrackerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Today:`
  String get todayLabel {
    return Intl.message('Today:', name: 'todayLabel', desc: '', args: []);
  }

  /// `No habits yet`
  String get noHabitsMessage {
    return Intl.message(
      'No habits yet',
      name: 'noHabitsMessage',
      desc: '',
      args: [],
    );
  }

  /// `Habit`
  String get habitHeader {
    return Intl.message('Habit', name: 'habitHeader', desc: '', args: []);
  }

  /// `New Habit`
  String get newHabitTitle {
    return Intl.message('New Habit', name: 'newHabitTitle', desc: '', args: []);
  }

  /// `Name`
  String get newHabitNameHint {
    return Intl.message('Name', name: 'newHabitNameHint', desc: '', args: []);
  }

  /// `Reminder (optional):`
  String get reminderLabel {
    return Intl.message(
      'Reminder (optional):',
      name: 'reminderLabel',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get noReminder {
    return Intl.message('None', name: 'noReminder', desc: '', args: []);
  }

  /// `Delete?`
  String get deleteHabitTitle {
    return Intl.message(
      'Delete?',
      name: 'deleteHabitTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to delete the habit "{habitName}"?`
  String deleteHabitMessage(Object habitName) {
    return Intl.message(
      'Do you really want to delete the habit "$habitName"?',
      name: 'deleteHabitMessage',
      desc: '',
      args: [habitName],
    );
  }

  /// `Yes, delete`
  String get confirmDeleteHabit {
    return Intl.message(
      'Yes, delete',
      name: 'confirmDeleteHabit',
      desc: '',
      args: [],
    );
  }

  /// `Journal`
  String get journalTitle {
    return Intl.message('Journal', name: 'journalTitle', desc: '', args: []);
  }

  /// `No journal entries yet`
  String get noJournalEntries {
    return Intl.message(
      'No journal entries yet',
      name: 'noJournalEntries',
      desc: '',
      args: [],
    );
  }

  /// `(Untitled)`
  String get untitled {
    return Intl.message('(Untitled)', name: 'untitled', desc: '', args: []);
  }

  /// `New Entry`
  String get newJournalEntry {
    return Intl.message(
      'New Entry',
      name: 'newJournalEntry',
      desc: '',
      args: [],
    );
  }

  /// `Edit Entry`
  String get editJournalEntry {
    return Intl.message(
      'Edit Entry',
      name: 'editJournalEntry',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get journalTitleLabel {
    return Intl.message('Title', name: 'journalTitleLabel', desc: '', args: []);
  }

  /// `Content`
  String get journalContentLabel {
    return Intl.message(
      'Content',
      name: 'journalContentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Mood:`
  String get journalMoodLabel {
    return Intl.message('Mood:', name: 'journalMoodLabel', desc: '', args: []);
  }

  /// `Delete?`
  String get deleteJournalEntryTitle {
    return Intl.message(
      'Delete?',
      name: 'deleteJournalEntryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to delete the entry "{entryTitle}"?`
  String deleteJournalEntryMessage(Object entryTitle) {
    return Intl.message(
      'Do you really want to delete the entry "$entryTitle"?',
      name: 'deleteJournalEntryMessage',
      desc: '',
      args: [entryTitle],
    );
  }

  /// `Yes, delete`
  String get confirmDelete {
    return Intl.message(
      'Yes, delete',
      name: 'confirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `Privacy & Terms of Use`
  String get privacyAndTermsTitle {
    return Intl.message(
      'Privacy & Terms of Use',
      name: 'privacyAndTermsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Privacy and Terms of Use\n\nPrivacy\nWe take the protection of your data seriously. Currently, our app does not store any data in external databases. All information you enter into the app is stored locally on your device. Your data is not shared with third parties.\n\nIn the future, additional features such as login or online services might be integrated. If that happens, we will update this privacy policy accordingly to keep you informed transparently about any changes.\n\nTerms of Use\nOur app is designed to help you become more productive and achieve your goals. Use of the app is at your own risk. We do not assume liability for any direct or indirect damages that may result from using the app.\n\nPlease use the app responsibly and adhere to the laws of your country.\n\nContact\nIf you have any questions or concerns about our privacy policy or terms of use, contact us at kontakt@dineswipe.de.`
  String get privacyAndTermsContent {
    return Intl.message(
      'Privacy and Terms of Use\n\nPrivacy\nWe take the protection of your data seriously. Currently, our app does not store any data in external databases. All information you enter into the app is stored locally on your device. Your data is not shared with third parties.\n\nIn the future, additional features such as login or online services might be integrated. If that happens, we will update this privacy policy accordingly to keep you informed transparently about any changes.\n\nTerms of Use\nOur app is designed to help you become more productive and achieve your goals. Use of the app is at your own risk. We do not assume liability for any direct or indirect damages that may result from using the app.\n\nPlease use the app responsibly and adhere to the laws of your country.\n\nContact\nIf you have any questions or concerns about our privacy policy or terms of use, contact us at kontakt@dineswipe.de.',
      name: 'privacyAndTermsContent',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profileTitle {
    return Intl.message('Profile', name: 'profileTitle', desc: '', args: []);
  }

  /// `WHO COULD YOU BE?`
  String get profileHeader {
    return Intl.message(
      'WHO COULD YOU BE?',
      name: 'profileHeader',
      desc: '',
      args: [],
    );
  }

  /// `Unknown User`
  String get unknownUser {
    return Intl.message(
      'Unknown User',
      name: 'unknownUser',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get editProfile {
    return Intl.message('Edit', name: 'editProfile', desc: '', args: []);
  }

  /// `Edit Name`
  String get editProfileTitle {
    return Intl.message(
      'Edit Name',
      name: 'editProfileTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your Name`
  String get editProfileHint {
    return Intl.message(
      'Your Name',
      name: 'editProfileHint',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `SETTINGS`
  String get settingsTitle {
    return Intl.message('SETTINGS', name: 'settingsTitle', desc: '', args: []);
  }

  /// `Hardness`
  String get hardnessTitle {
    return Intl.message('Hardness', name: 'hardnessTitle', desc: '', args: []);
  }

  /// `Normal`
  String get hardnessNormal {
    return Intl.message('Normal', name: 'hardnessNormal', desc: '', args: []);
  }

  /// `Hard`
  String get hardnessHard {
    return Intl.message('Hard', name: 'hardnessHard', desc: '', args: []);
  }

  /// `Brutally Honest`
  String get hardnessBrutal {
    return Intl.message(
      'Brutally Honest',
      name: 'hardnessBrutal',
      desc: '',
      args: [],
    );
  }

  /// `LEGAL & APP INFO`
  String get legalAndAppInfoTitle {
    return Intl.message(
      'LEGAL & APP INFO',
      name: 'legalAndAppInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Privacy & Terms of Use`
  String get privacyAndTerms {
    return Intl.message(
      'Privacy & Terms of Use',
      name: 'privacyAndTerms',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message('Version', name: 'version', desc: '', args: []);
  }

  /// `ACCOUNT`
  String get accountTitle {
    return Intl.message('ACCOUNT', name: 'accountTitle', desc: '', args: []);
  }

  /// `Upgrade to Premium`
  String get upgradeToPremium {
    return Intl.message(
      'Upgrade to Premium',
      name: 'upgradeToPremium',
      desc: '',
      args: [],
    );
  }

  /// `Restore Purchases`
  String get restorePurchases {
    return Intl.message(
      'Restore Purchases',
      name: 'restorePurchases',
      desc: '',
      args: [],
    );
  }

  /// `Premium package not found`
  String get premiumPackageNotFound {
    return Intl.message(
      'Premium package not found',
      name: 'premiumPackageNotFound',
      desc: '',
      args: [],
    );
  }

  /// `No offers available`
  String get noOffersAvailable {
    return Intl.message(
      'No offers available',
      name: 'noOffersAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations! You are now Premium.`
  String get premiumUpgradeSuccess {
    return Intl.message(
      'Congratulations! You are now Premium.',
      name: 'premiumUpgradeSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Purchase error: {error}`
  String purchaseError(Object error) {
    return Intl.message(
      'Purchase error: $error',
      name: 'purchaseError',
      desc: '',
      args: [error],
    );
  }

  /// `Premium restored!`
  String get premiumRestored {
    return Intl.message(
      'Premium restored!',
      name: 'premiumRestored',
      desc: '',
      args: [],
    );
  }

  /// `No active purchases found.`
  String get noActivePurchases {
    return Intl.message(
      'No active purchases found.',
      name: 'noActivePurchases',
      desc: '',
      args: [],
    );
  }

  /// `Restore error: {error}`
  String restoreError(Object error) {
    return Intl.message(
      'Restore error: $error',
      name: 'restoreError',
      desc: '',
      args: [error],
    );
  }

  /// `Select Hardness`
  String get selectHardness {
    return Intl.message(
      'Select Hardness',
      name: 'selectHardness',
      desc: '',
      args: [],
    );
  }

  /// `HOW HARD SHOULD I BE TO YOU?`
  String get hardnessQuestion {
    return Intl.message(
      'HOW HARD SHOULD I BE TO YOU?',
      name: 'hardnessQuestion',
      desc: '',
      args: [],
    );
  }

  /// `To-Do List`
  String get todoListTitle {
    return Intl.message(
      'To-Do List',
      name: 'todoListTitle',
      desc: '',
      args: [],
    );
  }

  /// `New Task...`
  String get newTaskHint {
    return Intl.message('New Task...', name: 'newTaskHint', desc: '', args: []);
  }

  /// `Add`
  String get addTask {
    return Intl.message('Add', name: 'addTask', desc: '', args: []);
  }

  /// `No tasks`
  String get noTasks {
    return Intl.message('No tasks', name: 'noTasks', desc: '', args: []);
  }

  /// `No matching tasks`
  String get noMatchingTasks {
    return Intl.message(
      'No matching tasks',
      name: 'noMatchingTasks',
      desc: '',
      args: [],
    );
  }

  /// `Due on {date}`
  String dueOn(Object date) {
    return Intl.message('Due on $date', name: 'dueOn', desc: '', args: [date]);
  }

  /// `Edit Task`
  String get editTask {
    return Intl.message('Edit Task', name: 'editTask', desc: '', args: []);
  }

  /// `Delete`
  String get deleteTask {
    return Intl.message('Delete', name: 'deleteTask', desc: '', args: []);
  }

  /// `Edit Task`
  String get editTaskDialogTitle {
    return Intl.message(
      'Edit Task',
      name: 'editTaskDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get taskTitleLabel {
    return Intl.message('Title', name: 'taskTitleLabel', desc: '', args: []);
  }

  /// `Change Deadline`
  String get changeDeadline {
    return Intl.message(
      'Change Deadline',
      name: 'changeDeadline',
      desc: '',
      args: [],
    );
  }

  /// `Daily reminder at 20:00 activated!`
  String get dailyReminderActivated {
    return Intl.message(
      'Daily reminder at 20:00 activated!',
      name: 'dailyReminderActivated',
      desc: '',
      args: [],
    );
  }

  /// `Daily reminder deactivated.`
  String get dailyReminderDeactivated {
    return Intl.message(
      'Daily reminder deactivated.',
      name: 'dailyReminderDeactivated',
      desc: '',
      args: [],
    );
  }

  /// `Hide done`
  String get hideDone {
    return Intl.message('Hide done', name: 'hideDone', desc: '', args: []);
  }

  /// `Calendar Overview`
  String get calendarViewTitle {
    return Intl.message(
      'Calendar Overview',
      name: 'calendarViewTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose day: {date}`
  String chooseDay(Object date) {
    return Intl.message(
      'Choose day: $date',
      name: 'chooseDay',
      desc: '',
      args: [date],
    );
  }

  /// `No tasks for {date}`
  String noTasksForDay(Object date) {
    return Intl.message(
      'No tasks for $date',
      name: 'noTasksForDay',
      desc: '',
      args: [date],
    );
  }

  /// `Your Tools for Victory`
  String get toolsPageTitle {
    return Intl.message(
      'Your Tools for Victory',
      name: 'toolsPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Flow Timer`
  String get flowTimerToolTitle {
    return Intl.message(
      'Flow Timer',
      name: 'flowTimerToolTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tasks`
  String get tasksToolTitle {
    return Intl.message('Tasks', name: 'tasksToolTitle', desc: '', args: []);
  }

  /// `Journal`
  String get journalToolTitle {
    return Intl.message(
      'Journal',
      name: 'journalToolTitle',
      desc: '',
      args: [],
    );
  }

  /// `Habit Tracker`
  String get habitTrackerToolTitle {
    return Intl.message(
      'Habit Tracker',
      name: 'habitTrackerToolTitle',
      desc: '',
      args: [],
    );
  }

  /// `Premium Required`
  String get paywallTitle {
    return Intl.message(
      'Premium Required',
      name: 'paywallTitle',
      desc: '',
      args: [],
    );
  }

  /// `This tool is only available for premium members.`
  String get paywallContent {
    return Intl.message(
      'This tool is only available for premium members.',
      name: 'paywallContent',
      desc: '',
      args: [],
    );
  }

  /// `Break`
  String get flowTimerBreakLabel {
    return Intl.message(
      'Break',
      name: 'flowTimerBreakLabel',
      desc: '',
      args: [],
    );
  }

  /// `Auto-Start Break`
  String get autoStartBreak {
    return Intl.message(
      'Auto-Start Break',
      name: 'autoStartBreak',
      desc: '',
      args: [],
    );
  }

  /// `Auto-Start Next Flow`
  String get autoStartNextFlow {
    return Intl.message(
      'Auto-Start Next Flow',
      name: 'autoStartNextFlow',
      desc: '',
      args: [],
    );
  }

  /// `Keep screen on`
  String get keepScreenOn {
    return Intl.message(
      'Keep screen on',
      name: 'keepScreenOn',
      desc: '',
      args: [],
    );
  }

  /// `How old are you?`
  String get onboardingAgeQuestion {
    return Intl.message(
      'How old are you?',
      name: 'onboardingAgeQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueButton {
    return Intl.message('Continue', name: 'continueButton', desc: '', args: []);
  }

  /// `Chatbot Hardness Level`
  String get onboardingChatbotTitle {
    return Intl.message(
      'Chatbot Hardness Level',
      name: 'onboardingChatbotTitle',
      desc: '',
      args: [],
    );
  }

  /// `Normal`
  String get chatbotModeNormal {
    return Intl.message(
      'Normal',
      name: 'chatbotModeNormal',
      desc: '',
      args: [],
    );
  }

  /// `Hard`
  String get chatbotModeHard {
    return Intl.message('Hard', name: 'chatbotModeHard', desc: '', args: []);
  }

  /// `Brutally Honest`
  String get chatbotModeBrutal {
    return Intl.message(
      'Brutally Honest',
      name: 'chatbotModeBrutal',
      desc: '',
      args: [],
    );
  }

  /// `Warning: In the "Brutally Honest" mode, you will be insulted and challenged intensely.`
  String get chatbotWarning {
    return Intl.message(
      'Warning: In the "Brutally Honest" mode, you will be insulted and challenged intensely.',
      name: 'chatbotWarning',
      desc: '',
      args: [],
    );
  }

  /// `YOU DID IT!`
  String get onboardingFinishHeadline {
    return Intl.message(
      'YOU DID IT!',
      name: 'onboardingFinishHeadline',
      desc: '',
      args: [],
    );
  }

  /// `Now the real grind begins. You’re ready to take control.`
  String get onboardingFinishSubheadline {
    return Intl.message(
      'Now the real grind begins. You’re ready to take control.',
      name: 'onboardingFinishSubheadline',
      desc: '',
      args: [],
    );
  }

  /// `LET’S GO TO THE DASHBOARD!`
  String get onboardingFinishButtonText {
    return Intl.message(
      'LET’S GO TO THE DASHBOARD!',
      name: 'onboardingFinishButtonText',
      desc: '',
      args: [],
    );
  }

  /// `What are your goals?`
  String get onboardingGoalsQuestion {
    return Intl.message(
      'What are your goals?',
      name: 'onboardingGoalsQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Get fitter`
  String get goalFit {
    return Intl.message('Get fitter', name: 'goalFit', desc: '', args: []);
  }

  /// `Be more productive`
  String get goalProductivity {
    return Intl.message(
      'Be more productive',
      name: 'goalProductivity',
      desc: '',
      args: [],
    );
  }

  /// `Save more money`
  String get goalSaveMoney {
    return Intl.message(
      'Save more money',
      name: 'goalSaveMoney',
      desc: '',
      args: [],
    );
  }

  /// `Build better relationships`
  String get goalBetterRelationships {
    return Intl.message(
      'Build better relationships',
      name: 'goalBetterRelationships',
      desc: '',
      args: [],
    );
  }

  /// `Strengthen mental health`
  String get goalMentalHealth {
    return Intl.message(
      'Strengthen mental health',
      name: 'goalMentalHealth',
      desc: '',
      args: [],
    );
  }

  /// `Advance your career`
  String get goalCareer {
    return Intl.message(
      'Advance your career',
      name: 'goalCareer',
      desc: '',
      args: [],
    );
  }

  /// `What's your name?`
  String get onboardingNameQuestion {
    return Intl.message(
      'What\'s your name?',
      name: 'onboardingNameQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Your Name`
  String get nameHint {
    return Intl.message('Your Name', name: 'nameHint', desc: '', args: []);
  }

  /// `Please enter your name.`
  String get nameEmptyWarning {
    return Intl.message(
      'Please enter your name.',
      name: 'nameEmptyWarning',
      desc: '',
      args: [],
    );
  }

  /// `Take the first step`
  String get onboardingNotificationHeadline {
    return Intl.message(
      'Take the first step',
      name: 'onboardingNotificationHeadline',
      desc: '',
      args: [],
    );
  }

  /// `Imagine being reminded every day to be better than yesterday. Your goals, your tasks, your discipline – everything gets stronger because you do. Enable notifications now and let your inner Daimonion push you.`
  String get onboardingNotificationDescription {
    return Intl.message(
      'Imagine being reminded every day to be better than yesterday. Your goals, your tasks, your discipline – everything gets stronger because you do. Enable notifications now and let your inner Daimonion push you.',
      name: 'onboardingNotificationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Push me!`
  String get onboardingNotificationButtonText {
    return Intl.message(
      'Push me!',
      name: 'onboardingNotificationButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Notifications are now active! Let's get started.`
  String get notificationActiveMessage {
    return Intl.message(
      'Notifications are now active! Let\'s get started.',
      name: 'notificationActiveMessage',
      desc: '',
      args: [],
    );
  }

  /// `Notifications were denied. You can enable them later in settings.`
  String get notificationDeniedMessage {
    return Intl.message(
      'Notifications were denied. You can enable them later in settings.',
      name: 'notificationDeniedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Continue to the next challenge`
  String get onboardingNotificationNextChallenge {
    return Intl.message(
      'Continue to the next challenge',
      name: 'onboardingNotificationNextChallenge',
      desc: '',
      args: [],
    );
  }

  /// `Your First To-Dos`
  String get onboardingTodosTitle {
    return Intl.message(
      'Your First To-Dos',
      name: 'onboardingTodosTitle',
      desc: '',
      args: [],
    );
  }

  /// `Set up your first tasks. These to-dos will go directly into your main list.`
  String get onboardingTodosSubheadline {
    return Intl.message(
      'Set up your first tasks. These to-dos will go directly into your main list.',
      name: 'onboardingTodosSubheadline',
      desc: '',
      args: [],
    );
  }

  /// `New Task...`
  String get newTodoHint {
    return Intl.message('New Task...', name: 'newTodoHint', desc: '', args: []);
  }

  /// `Add`
  String get addTodo {
    return Intl.message('Add', name: 'addTodo', desc: '', args: []);
  }

  /// `No to-dos added yet.`
  String get noTodosAdded {
    return Intl.message(
      'No to-dos added yet.',
      name: 'noTodosAdded',
      desc: '',
      args: [],
    );
  }

  /// `FUNDAMENTALS`
  String get dailyFundamentalsTitle {
    return Intl.message(
      'FUNDAMENTALS',
      name: 'dailyFundamentalsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Did you work out today?`
  String get dailyCheckGym {
    return Intl.message(
      'Did you work out today?',
      name: 'dailyCheckGym',
      desc: '',
      args: [],
    );
  }

  /// `Did you do something mentally productive today?`
  String get dailyCheckMental {
    return Intl.message(
      'Did you do something mentally productive today?',
      name: 'dailyCheckMental',
      desc: '',
      args: [],
    );
  }

  /// `Did you stay porn-free today?`
  String get dailyCheckNoPorn {
    return Intl.message(
      'Did you stay porn-free today?',
      name: 'dailyCheckNoPorn',
      desc: '',
      args: [],
    );
  }

  /// `Did you eat healthy today?`
  String get dailyCheckHealthyEating {
    return Intl.message(
      'Did you eat healthy today?',
      name: 'dailyCheckHealthyEating',
      desc: '',
      args: [],
    );
  }

  /// `Did you do something good for others today?`
  String get dailyCheckHelpOthers {
    return Intl.message(
      'Did you do something good for others today?',
      name: 'dailyCheckHelpOthers',
      desc: '',
      args: [],
    );
  }

  /// `Did you spend time in nature today?`
  String get dailyCheckNature {
    return Intl.message(
      'Did you spend time in nature today?',
      name: 'dailyCheckNature',
      desc: '',
      args: [],
    );
  }

  /// `You messed up, motherfucker!`
  String get dailyInsultTitle {
    return Intl.message(
      'You messed up, motherfucker!',
      name: 'dailyInsultTitle',
      desc: '',
      args: [],
    );
  }

  /// `You ignored ALL fundamentals, worthless scum!`
  String get dailyInsultAllMissed {
    return Intl.message(
      'You ignored ALL fundamentals, worthless scum!',
      name: 'dailyInsultAllMissed',
      desc: '',
      args: [],
    );
  }

  /// `You missed {count} fundamentals, bitch. That won't lead you anywhere!`
  String dailyInsultSomeMissed(Object count) {
    return Intl.message(
      'You missed $count fundamentals, bitch. That won\'t lead you anywhere!',
      name: 'dailyInsultSomeMissed',
      desc: '',
      args: [count],
    );
  }

  /// `Sport`
  String get shortCheckGym {
    return Intl.message('Sport', name: 'shortCheckGym', desc: '', args: []);
  }

  /// `Mental`
  String get shortCheckMental {
    return Intl.message('Mental', name: 'shortCheckMental', desc: '', args: []);
  }

  /// `No Porn`
  String get shortCheckNoPorn {
    return Intl.message(
      'No Porn',
      name: 'shortCheckNoPorn',
      desc: '',
      args: [],
    );
  }

  /// `Healthy`
  String get shortCheckHealthyEating {
    return Intl.message(
      'Healthy',
      name: 'shortCheckHealthyEating',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get shortCheckHelpOthers {
    return Intl.message(
      'Help',
      name: 'shortCheckHelpOthers',
      desc: '',
      args: [],
    );
  }

  /// `Nature`
  String get shortCheckNature {
    return Intl.message('Nature', name: 'shortCheckNature', desc: '', args: []);
  }

  /// `Did you work out today, motherfucker?`
  String get fullCheckGym {
    return Intl.message(
      'Did you work out today, motherfucker?',
      name: 'fullCheckGym',
      desc: '',
      args: [],
    );
  }

  /// `Did you do something mentally productive?`
  String get fullCheckMental {
    return Intl.message(
      'Did you do something mentally productive?',
      name: 'fullCheckMental',
      desc: '',
      args: [],
    );
  }

  /// `Did you stay away from porn, you nasty fuck?`
  String get fullCheckNoPorn {
    return Intl.message(
      'Did you stay away from porn, you nasty fuck?',
      name: 'fullCheckNoPorn',
      desc: '',
      args: [],
    );
  }

  /// `Did you eat healthy, you donut junkie?`
  String get fullCheckHealthyEating {
    return Intl.message(
      'Did you eat healthy, you donut junkie?',
      name: 'fullCheckHealthyEating',
      desc: '',
      args: [],
    );
  }

  /// `Did you do something good for others?`
  String get fullCheckHelpOthers {
    return Intl.message(
      'Did you do something good for others?',
      name: 'fullCheckHelpOthers',
      desc: '',
      args: [],
    );
  }

  /// `Did you spend time in nature today?`
  String get fullCheckNature {
    return Intl.message(
      'Did you spend time in nature today?',
      name: 'fullCheckNature',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
