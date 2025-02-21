import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Daimonion Chat'**
  String get appBarTitle;

  /// No description provided for @freePromptsCounter.
  ///
  /// In en, this message translates to:
  /// **'Free prompts used: {usedPrompts} / 5'**
  String freePromptsCounter(Object usedPrompts);

  /// No description provided for @upgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Needed'**
  String get upgradeTitle;

  /// No description provided for @upgradeContent.
  ///
  /// In en, this message translates to:
  /// **'You have used your 5 free prompts.\n\nGet the premium version for unlimited chats now!'**
  String get upgradeContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @buyPremium.
  ///
  /// In en, this message translates to:
  /// **'Buy Premium'**
  String get buyPremium;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @errorContent.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get errorContent;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// No description provided for @successContent.
  ///
  /// In en, this message translates to:
  /// **'You have successfully unlocked premium!'**
  String get successContent;

  /// No description provided for @hintText.
  ///
  /// In en, this message translates to:
  /// **'Ask Daimonion whatever you want...'**
  String get hintText;

  /// No description provided for @suggestion1.
  ///
  /// In en, this message translates to:
  /// **'I\'m feeling lazy and unmotivated today.'**
  String get suggestion1;

  /// No description provided for @suggestion2.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know what to do with my day.'**
  String get suggestion2;

  /// No description provided for @suggestion3.
  ///
  /// In en, this message translates to:
  /// **'I want to build new habits, but how?'**
  String get suggestion3;

  /// No description provided for @suggestion4.
  ///
  /// In en, this message translates to:
  /// **'I don\'t feel like working out. Convince me!'**
  String get suggestion4;

  /// No description provided for @suggestion5.
  ///
  /// In en, this message translates to:
  /// **'What can I start with today to be more productive?'**
  String get suggestion5;

  /// No description provided for @suggestion6.
  ///
  /// In en, this message translates to:
  /// **'Give me a kick in the butt!'**
  String get suggestion6;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @productiveTimeWeek.
  ///
  /// In en, this message translates to:
  /// **'Productive Time (Week)'**
  String get productiveTimeWeek;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @flowTimer.
  ///
  /// In en, this message translates to:
  /// **'Flow Timer'**
  String get flowTimer;

  /// No description provided for @todaysTasks.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S TASKS'**
  String get todaysTasks;

  /// No description provided for @noTasksToday.
  ///
  /// In en, this message translates to:
  /// **'No tasks for today'**
  String get noTasksToday;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY PROGRESS'**
  String get weeklyProgress;

  /// No description provided for @premiumRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium Required'**
  String get premiumRequired;

  /// No description provided for @premiumSectionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This section is available for premium users only.'**
  String get premiumSectionUnavailable;

  /// No description provided for @cheerPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect! You completed all your habits today. Keep pushing!'**
  String get cheerPerfect;

  /// No description provided for @cheerHalf.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already completed more than half of your habits – strong!'**
  String get cheerHalf;

  /// No description provided for @cheerAlmost.
  ///
  /// In en, this message translates to:
  /// **'Not done yet, but you got this. Keep going!'**
  String get cheerAlmost;

  /// No description provided for @cheerStart.
  ///
  /// In en, this message translates to:
  /// **'Get to it! Time to do something!'**
  String get cheerStart;

  /// No description provided for @motivationQuotes.
  ///
  /// In en, this message translates to:
  /// **'You’re not here to be average!||No excuses – keep moving!||If you quit, you never meant it anyway.||Every day is a new chance – seize it!||Your future self will thank you for today’s grind.||Discipline beats talent – every day.||What you do today decides tomorrow.||Dream big, work harder.||You’re stronger than you think.||No growth without effort.||The toughest battles come before the greatest victories.||You must become the person you want to be – step by step.||No matter how slow you go, you’re beating everyone sitting on the couch.||Mistakes prove that you’re trying.||You don’t grow in your comfort zone – dare to step out.||Hard work isn’t always rewarded, but it builds character.||It’s the small daily victories that form great successes.||You have 24 hours like everyone else – use them with intention.||Your goals don’t care about your excuses.||If the path is easy, you’re on the wrong track.||Stop talking and start doing.||Every success begins with the courage to try.||Strength grows where comfort ends.||Your only limit is the one you set for yourself.||Your potential is waiting for you to act.||Every no brings you closer to a yes.||Focus on what you can control.||Yesterday is gone. Today is your day.||The best decisions are often the hardest.||A small progress is still progress.||The hardest decision of your life might be the one that changes everything.||Every great journey begins with a single step.||Those who underestimate you give you the greatest gift: the drive to prove them wrong.||Success is not a destination, but a journey – keep at it.||You can’t control anything except your reaction to the world.||The toughest moments often shape you the most.||What you plant today, you will harvest tomorrow.||If you fail, try again – but fail better next time.||Success means progress, not perfection.||Pain is temporary, pride lasts forever.||Focus beats chaos.||Do what needs to be done.||You’re a warrior – no excuse counts.||Hate fuels you, love makes you unstoppable.||Aim high – always.||Discipline is freedom.||Either you do it or someone else will.||Never lose faith in yourself.||Fear is your compass – follow it.'**
  String get motivationQuotes;

  /// No description provided for @firstTimeHeadline.
  ///
  /// In en, this message translates to:
  /// **'DO YOU WANT TO BE SOMEONE WHO HAS CONTROL,\nOR DO YOU WANT TO REMAIN A SLAVE TO YOUR IMPULSES?'**
  String get firstTimeHeadline;

  /// No description provided for @firstTimeButtonText.
  ///
  /// In en, this message translates to:
  /// **'I\'M READY'**
  String get firstTimeButtonText;

  /// No description provided for @flowStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flow Stats'**
  String get flowStatsTitle;

  /// No description provided for @filterWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get filterWeek;

  /// No description provided for @filterMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get filterMonth;

  /// No description provided for @filterYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get filterYear;

  /// No description provided for @noDataMessage.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get noDataMessage;

  /// No description provided for @statFlows.
  ///
  /// In en, this message translates to:
  /// **'Flows'**
  String get statFlows;

  /// No description provided for @statTotalMinutes.
  ///
  /// In en, this message translates to:
  /// **'Total Minutes'**
  String get statTotalMinutes;

  /// No description provided for @statAverageFlow.
  ///
  /// In en, this message translates to:
  /// **'Avg Time per Flow (Min)'**
  String get statAverageFlow;

  /// No description provided for @statAverageWeeklyFlow.
  ///
  /// In en, this message translates to:
  /// **'Avg Time per Week (Min)'**
  String get statAverageWeeklyFlow;

  /// No description provided for @flowTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Flow Timer'**
  String get flowTimerTitle;

  /// No description provided for @flowCounter.
  ///
  /// In en, this message translates to:
  /// **'Flow {currentFlow} / {totalFlows}'**
  String flowCounter(Object currentFlow, Object totalFlows);

  /// No description provided for @flowTimerSetTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Flow Time'**
  String get flowTimerSetTimeTitle;

  /// No description provided for @flowTimerSetTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter minutes...'**
  String get flowTimerSetTimeHint;

  /// No description provided for @flowTimerSetFlowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flow Settings'**
  String get flowTimerSetFlowsTitle;

  /// No description provided for @flowTimerSetFlowsHint.
  ///
  /// In en, this message translates to:
  /// **'Number of flows'**
  String get flowTimerSetFlowsHint;

  /// No description provided for @habitTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Tracker'**
  String get habitTrackerTitle;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today:'**
  String get todayLabel;

  /// No description provided for @noHabitsMessage.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get noHabitsMessage;

  /// No description provided for @habitHeader.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get habitHeader;

  /// No description provided for @newHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get newHabitTitle;

  /// No description provided for @newHabitNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get newHabitNameHint;

  /// No description provided for @reminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder (optional):'**
  String get reminderLabel;

  /// No description provided for @noReminder.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noReminder;

  /// No description provided for @deleteHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get deleteHabitTitle;

  /// No description provided for @deleteHabitMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete the habit \"{habitName}\"?'**
  String deleteHabitMessage(Object habitName);

  /// No description provided for @confirmDeleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete'**
  String get confirmDeleteHabit;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @noJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet'**
  String get noJournalEntries;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'(Untitled)'**
  String get untitled;

  /// No description provided for @newJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newJournalEntry;

  /// No description provided for @editJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get editJournalEntry;

  /// No description provided for @journalTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get journalTitleLabel;

  /// No description provided for @journalContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get journalContentLabel;

  /// No description provided for @journalMoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Mood:'**
  String get journalMoodLabel;

  /// No description provided for @deleteJournalEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get deleteJournalEntryTitle;

  /// No description provided for @deleteJournalEntryMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete the entry \"{entryTitle}\"?'**
  String deleteJournalEntryMessage(Object entryTitle);

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete'**
  String get confirmDelete;

  /// No description provided for @privacyAndTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Terms of Use'**
  String get privacyAndTermsTitle;

  /// No description provided for @privacyAndTermsContent.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Terms of Use\n\nPrivacy\nWe take the protection of your data seriously. Currently, our app does not store any data in external databases. All information you enter into the app is stored locally on your device. Your data is not shared with third parties.\n\nIn the future, additional features such as login or online services might be integrated. If that happens, we will update this privacy policy accordingly to keep you informed transparently about any changes.\n\nTerms of Use\nOur app is designed to help you become more productive and achieve your goals. Use of the app is at your own risk. We do not assume liability for any direct or indirect damages that may result from using the app.\n\nPlease use the app responsibly and adhere to the laws of your country.\n\nContact\nIf you have any questions or concerns about our privacy policy or terms of use, contact us at kontakt@dineswipe.de.'**
  String get privacyAndTermsContent;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileHeader.
  ///
  /// In en, this message translates to:
  /// **'WHO COULD YOU BE?'**
  String get profileHeader;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editProfile;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editProfileTitle;

  /// No description provided for @editProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get editProfileHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @hardnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Hardness'**
  String get hardnessTitle;

  /// No description provided for @hardnessNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get hardnessNormal;

  /// No description provided for @hardnessHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hardnessHard;

  /// No description provided for @hardnessBrutal.
  ///
  /// In en, this message translates to:
  /// **'Brutally Honest'**
  String get hardnessBrutal;

  /// No description provided for @legalAndAppInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'LEGAL & APP INFO'**
  String get legalAndAppInfoTitle;

  /// No description provided for @privacyAndTerms.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Terms of Use'**
  String get privacyAndTerms;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountTitle;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @premiumPackageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Premium package not found'**
  String get premiumPackageNotFound;

  /// No description provided for @noOffersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No offers available'**
  String get noOffersAvailable;

  /// No description provided for @premiumUpgradeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You are now Premium.'**
  String get premiumUpgradeSuccess;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'Purchase error: {error}'**
  String purchaseError(Object error);

  /// No description provided for @premiumRestored.
  ///
  /// In en, this message translates to:
  /// **'Premium restored!'**
  String get premiumRestored;

  /// No description provided for @noActivePurchases.
  ///
  /// In en, this message translates to:
  /// **'No active purchases found.'**
  String get noActivePurchases;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Restore error: {error}'**
  String restoreError(Object error);

  /// No description provided for @selectHardness.
  ///
  /// In en, this message translates to:
  /// **'Select Hardness'**
  String get selectHardness;

  /// No description provided for @hardnessQuestion.
  ///
  /// In en, this message translates to:
  /// **'HOW HARD SHOULD I BE TO YOU?'**
  String get hardnessQuestion;

  /// No description provided for @todoListTitle.
  ///
  /// In en, this message translates to:
  /// **'To-Do List'**
  String get todoListTitle;

  /// No description provided for @newTaskHint.
  ///
  /// In en, this message translates to:
  /// **'New Task...'**
  String get newTaskHint;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addTask;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasks;

  /// No description provided for @noMatchingTasks.
  ///
  /// In en, this message translates to:
  /// **'No matching tasks'**
  String get noMatchingTasks;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due on {date}'**
  String dueOn(Object date);

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTask;

  /// No description provided for @editTaskDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTaskDialogTitle;

  /// No description provided for @taskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskTitleLabel;

  /// No description provided for @changeDeadline.
  ///
  /// In en, this message translates to:
  /// **'Change Deadline'**
  String get changeDeadline;

  /// No description provided for @dailyReminderActivated.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder at 20:00 activated!'**
  String get dailyReminderActivated;

  /// No description provided for @dailyReminderDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder deactivated.'**
  String get dailyReminderDeactivated;

  /// No description provided for @hideDone.
  ///
  /// In en, this message translates to:
  /// **'Hide done'**
  String get hideDone;

  /// No description provided for @calendarViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar Overview'**
  String get calendarViewTitle;

  /// No description provided for @chooseDay.
  ///
  /// In en, this message translates to:
  /// **'Choose day: {date}'**
  String chooseDay(Object date);

  /// No description provided for @noTasksForDay.
  ///
  /// In en, this message translates to:
  /// **'No tasks for {date}'**
  String noTasksForDay(Object date);

  /// No description provided for @toolsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Tools for Victory'**
  String get toolsPageTitle;

  /// No description provided for @flowTimerToolTitle.
  ///
  /// In en, this message translates to:
  /// **'Flow Timer'**
  String get flowTimerToolTitle;

  /// No description provided for @tasksToolTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksToolTitle;

  /// No description provided for @journalToolTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalToolTitle;

  /// No description provided for @habitTrackerToolTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Tracker'**
  String get habitTrackerToolTitle;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Required'**
  String get paywallTitle;

  /// No description provided for @paywallContent.
  ///
  /// In en, this message translates to:
  /// **'This tool is only available for premium members.'**
  String get paywallContent;

  /// No description provided for @flowTimerBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get flowTimerBreakLabel;

  /// No description provided for @autoStartBreak.
  ///
  /// In en, this message translates to:
  /// **'Auto-Start Break'**
  String get autoStartBreak;

  /// No description provided for @autoStartNextFlow.
  ///
  /// In en, this message translates to:
  /// **'Auto-Start Next Flow'**
  String get autoStartNextFlow;

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get keepScreenOn;

  /// No description provided for @onboardingAgeQuestion.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get onboardingAgeQuestion;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @onboardingChatbotTitle.
  ///
  /// In en, this message translates to:
  /// **'Chatbot Hardness Level'**
  String get onboardingChatbotTitle;

  /// No description provided for @chatbotModeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get chatbotModeNormal;

  /// No description provided for @chatbotModeHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get chatbotModeHard;

  /// No description provided for @chatbotModeBrutal.
  ///
  /// In en, this message translates to:
  /// **'Brutally Honest'**
  String get chatbotModeBrutal;

  /// No description provided for @chatbotWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: In the \"Brutally Honest\" mode, you will be insulted and challenged intensely.'**
  String get chatbotWarning;

  /// No description provided for @onboardingFinishHeadline.
  ///
  /// In en, this message translates to:
  /// **'YOU DID IT!'**
  String get onboardingFinishHeadline;

  /// No description provided for @onboardingFinishSubheadline.
  ///
  /// In en, this message translates to:
  /// **'Now the real grind begins. You’re ready to take control.'**
  String get onboardingFinishSubheadline;

  /// No description provided for @onboardingFinishButtonText.
  ///
  /// In en, this message translates to:
  /// **'LET’S GO TO THE DASHBOARD!'**
  String get onboardingFinishButtonText;

  /// No description provided for @onboardingGoalsQuestion.
  ///
  /// In en, this message translates to:
  /// **'What are your goals?'**
  String get onboardingGoalsQuestion;

  /// No description provided for @goalFit.
  ///
  /// In en, this message translates to:
  /// **'Get fitter'**
  String get goalFit;

  /// No description provided for @goalProductivity.
  ///
  /// In en, this message translates to:
  /// **'Be more productive'**
  String get goalProductivity;

  /// No description provided for @goalSaveMoney.
  ///
  /// In en, this message translates to:
  /// **'Save more money'**
  String get goalSaveMoney;

  /// No description provided for @goalBetterRelationships.
  ///
  /// In en, this message translates to:
  /// **'Build better relationships'**
  String get goalBetterRelationships;

  /// No description provided for @goalMentalHealth.
  ///
  /// In en, this message translates to:
  /// **'Strengthen mental health'**
  String get goalMentalHealth;

  /// No description provided for @goalCareer.
  ///
  /// In en, this message translates to:
  /// **'Advance your career'**
  String get goalCareer;

  /// No description provided for @onboardingNameQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get onboardingNameQuestion;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get nameHint;

  /// No description provided for @nameEmptyWarning.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get nameEmptyWarning;

  /// No description provided for @onboardingNotificationHeadline.
  ///
  /// In en, this message translates to:
  /// **'Take the first step'**
  String get onboardingNotificationHeadline;

  /// No description provided for @onboardingNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Imagine being reminded every day to be better than yesterday. Your goals, your tasks, your discipline – everything gets stronger because you do. Enable notifications now and let your inner Daimonion push you.'**
  String get onboardingNotificationDescription;

  /// No description provided for @onboardingNotificationButtonText.
  ///
  /// In en, this message translates to:
  /// **'Push me!'**
  String get onboardingNotificationButtonText;

  /// No description provided for @notificationActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications are now active! Let\'s get started.'**
  String get notificationActiveMessage;

  /// No description provided for @notificationDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications were denied. You can enable them later in settings.'**
  String get notificationDeniedMessage;

  /// No description provided for @onboardingNotificationNextChallenge.
  ///
  /// In en, this message translates to:
  /// **'Continue to the next challenge'**
  String get onboardingNotificationNextChallenge;

  /// No description provided for @onboardingTodosTitle.
  ///
  /// In en, this message translates to:
  /// **'Your First To-Dos'**
  String get onboardingTodosTitle;

  /// No description provided for @onboardingTodosSubheadline.
  ///
  /// In en, this message translates to:
  /// **'Set up your first tasks. These to-dos will go directly into your main list.'**
  String get onboardingTodosSubheadline;

  /// No description provided for @newTodoHint.
  ///
  /// In en, this message translates to:
  /// **'New Task...'**
  String get newTodoHint;

  /// No description provided for @addTodo.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addTodo;

  /// No description provided for @noTodosAdded.
  ///
  /// In en, this message translates to:
  /// **'No to-dos added yet.'**
  String get noTodosAdded;

  /// No description provided for @dailyFundamentalsTitle.
  ///
  /// In en, this message translates to:
  /// **'FUNDAMENTALS'**
  String get dailyFundamentalsTitle;

  /// No description provided for @shortCheckGym.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get shortCheckGym;

  /// No description provided for @shortCheckMental.
  ///
  /// In en, this message translates to:
  /// **'Mental'**
  String get shortCheckMental;

  /// No description provided for @shortCheckNoPorn.
  ///
  /// In en, this message translates to:
  /// **'No Porn'**
  String get shortCheckNoPorn;

  /// No description provided for @shortCheckHealthyEating.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get shortCheckHealthyEating;

  /// No description provided for @shortCheckHelpOthers.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get shortCheckHelpOthers;

  /// No description provided for @shortCheckNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get shortCheckNature;

  /// No description provided for @fullCheckGym.
  ///
  /// In en, this message translates to:
  /// **'Did you do something for your body?'**
  String get fullCheckGym;

  /// No description provided for @fullCheckMental.
  ///
  /// In en, this message translates to:
  /// **'Did you do something mentally productive?'**
  String get fullCheckMental;

  /// No description provided for @fullCheckNoPorn.
  ///
  /// In en, this message translates to:
  /// **'Did you stay away from porn?'**
  String get fullCheckNoPorn;

  /// No description provided for @fullCheckHealthyEating.
  ///
  /// In en, this message translates to:
  /// **'Did you eat healthy?'**
  String get fullCheckHealthyEating;

  /// No description provided for @fullCheckHelpOthers.
  ///
  /// In en, this message translates to:
  /// **'Did you do something good for others?'**
  String get fullCheckHelpOthers;

  /// No description provided for @fullCheckNature.
  ///
  /// In en, this message translates to:
  /// **'Did you spend time in nature today?'**
  String get fullCheckNature;

  /// No description provided for @dailyInsultTitle.
  ///
  /// In en, this message translates to:
  /// **'You messed up!'**
  String get dailyInsultTitle;

  /// No description provided for @dailyInsultAllMissed.
  ///
  /// In en, this message translates to:
  /// **'You ignored ALL fundamentals!'**
  String get dailyInsultAllMissed;

  /// No description provided for @dailyInsultSomeMissed.
  ///
  /// In en, this message translates to:
  /// **'You missed {count} fundamentals. That won\'t lead you anywhere!'**
  String dailyInsultSomeMissed(Object count);

  /// No description provided for @loadOffers.
  ///
  /// In en, this message translates to:
  /// **'Load Offers'**
  String get loadOffers;

  /// No description provided for @trainingPlanToolTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Plan'**
  String get trainingPlanToolTitle;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Plan'**
  String get appTitle;

  /// No description provided for @workoutNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout Name'**
  String get workoutNameLabel;

  /// No description provided for @noExercisesMessage.
  ///
  /// In en, this message translates to:
  /// **'No exercises added.\nStart building your workout!'**
  String get noExercisesMessage;

  /// No description provided for @newExerciseHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new exercise...'**
  String get newExerciseHint;

  /// No description provided for @addExerciseSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Enter an exercise!'**
  String get addExerciseSnackbar;

  /// No description provided for @editExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise Details'**
  String get editExerciseTitle;

  /// No description provided for @setsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get setsLabel;

  /// No description provided for @repsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightLabel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @getPremiumButton.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get getPremiumButton;

  /// No description provided for @title_progress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get title_progress;

  /// No description provided for @level_text.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level_text(Object level);

  /// No description provided for @status_text.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String status_text(Object status);

  /// No description provided for @progress_text.
  ///
  /// In en, this message translates to:
  /// **'{percent}% to Level {nextLevel}'**
  String progress_text(Object nextLevel, Object percent);

  /// No description provided for @xp_text.
  ///
  /// In en, this message translates to:
  /// **'{xpProgress} / {xpToNextLevel} XP'**
  String xp_text(Object xpProgress, Object xpToNextLevel);

  /// No description provided for @motivation_text.
  ///
  /// In en, this message translates to:
  /// **'Come on! Stop whining and show them what you\'re made of!'**
  String get motivation_text;

  /// No description provided for @streak_info_title.
  ///
  /// In en, this message translates to:
  /// **'Streak Info'**
  String get streak_info_title;

  /// No description provided for @streak_days.
  ///
  /// In en, this message translates to:
  /// **'{streak} Days Streak'**
  String streak_days(Object streak);

  /// No description provided for @xp_bonus.
  ///
  /// In en, this message translates to:
  /// **'XP Bonus: {bonusPercent}%'**
  String xp_bonus(Object bonusPercent);

  /// No description provided for @streak_description.
  ///
  /// In en, this message translates to:
  /// **'The longer you stay active daily, the more XP you earn! Your streak rewards consistency and helps you level up faster.'**
  String get streak_description;

  /// No description provided for @streak_rewards.
  ///
  /// In en, this message translates to:
  /// **'- 7+ days: +5% XP\\n- 14+ days: +10% XP\\n- 30+ days: +15% XP\\n'**
  String get streak_rewards;

  /// No description provided for @back_button.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back_button;

  /// No description provided for @levels_and_rankings.
  ///
  /// In en, this message translates to:
  /// **'Levels and Rankings'**
  String get levels_and_rankings;

  /// No description provided for @how_to_earn_xp.
  ///
  /// In en, this message translates to:
  /// **'How to earn XP and level up!'**
  String get how_to_earn_xp;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @max_per_day.
  ///
  /// In en, this message translates to:
  /// **'Max/Day'**
  String get max_per_day;

  /// No description provided for @complete_todo.
  ///
  /// In en, this message translates to:
  /// **'Complete a To-Do'**
  String get complete_todo;

  /// No description provided for @complete_habit.
  ///
  /// In en, this message translates to:
  /// **'Complete a Habit'**
  String get complete_habit;

  /// No description provided for @journal_entry.
  ///
  /// In en, this message translates to:
  /// **'Write a Journal Entry'**
  String get journal_entry;

  /// No description provided for @ten_min_flow.
  ///
  /// In en, this message translates to:
  /// **'10 min Flow'**
  String get ten_min_flow;

  /// No description provided for @levels_and_ranks.
  ///
  /// In en, this message translates to:
  /// **'Levels & Ranks'**
  String get levels_and_ranks;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @badge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get badge;

  /// No description provided for @recruit.
  ///
  /// In en, this message translates to:
  /// **'Recruit'**
  String get recruit;

  /// No description provided for @soldier.
  ///
  /// In en, this message translates to:
  /// **'Soldier'**
  String get soldier;

  /// No description provided for @elite_soldier.
  ///
  /// In en, this message translates to:
  /// **'Elite Soldier'**
  String get elite_soldier;

  /// No description provided for @veteran.
  ///
  /// In en, this message translates to:
  /// **'Veteran'**
  String get veteran;

  /// No description provided for @sergeant.
  ///
  /// In en, this message translates to:
  /// **'Sergeant'**
  String get sergeant;

  /// No description provided for @lieutenant.
  ///
  /// In en, this message translates to:
  /// **'Lieutenant'**
  String get lieutenant;

  /// No description provided for @captain.
  ///
  /// In en, this message translates to:
  /// **'Captain'**
  String get captain;

  /// No description provided for @major.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get major;

  /// No description provided for @colonel.
  ///
  /// In en, this message translates to:
  /// **'Colonel'**
  String get colonel;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @warlord.
  ///
  /// In en, this message translates to:
  /// **'Warlord'**
  String get warlord;

  /// No description provided for @daimonion_warlord.
  ///
  /// In en, this message translates to:
  /// **'Daimonion Warlord'**
  String get daimonion_warlord;

  /// No description provided for @legend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legend;

  /// No description provided for @immortal.
  ///
  /// In en, this message translates to:
  /// **'Immortal'**
  String get immortal;

  /// No description provided for @keep_grinding.
  ///
  /// In en, this message translates to:
  /// **'Keep grinding!'**
  String get keep_grinding;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @unlock_premium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get unlock_premium;

  /// No description provided for @premium_description.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to get full access to premium features'**
  String get premium_description;

  /// No description provided for @access_journal.
  ///
  /// In en, this message translates to:
  /// **'Access to Journal Tool'**
  String get access_journal;

  /// No description provided for @access_habit_tracker.
  ///
  /// In en, this message translates to:
  /// **'Access to Habit Tracker'**
  String get access_habit_tracker;

  /// No description provided for @unlimited_chat_prompts.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Chat Prompts'**
  String get unlimited_chat_prompts;

  /// No description provided for @more_to_come.
  ///
  /// In en, this message translates to:
  /// **'More to come!'**
  String get more_to_come;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @weekly_price.
  ///
  /// In en, this message translates to:
  /// **'\$1.99/week'**
  String get weekly_price;

  /// No description provided for @monthly_price.
  ///
  /// In en, this message translates to:
  /// **'\$3.99/month'**
  String get monthly_price;

  /// No description provided for @yearly_price.
  ///
  /// In en, this message translates to:
  /// **'\$29.99/year'**
  String get yearly_price;

  /// No description provided for @auto_renewal.
  ///
  /// In en, this message translates to:
  /// **'Auto Renewal'**
  String get auto_renewal;

  /// No description provided for @subscription_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime | Privacy Policy\nYour subscription will automatically renew. Cancel at least 24 hours before renewal on Google Play.'**
  String get subscription_disclaimer;

  /// No description provided for @coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get coming_soon;

  /// No description provided for @coming_soon_description.
  ///
  /// In en, this message translates to:
  /// **'This option will be available soon!'**
  String get coming_soon_description;

  /// No description provided for @thank_you.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get thank_you;

  /// No description provided for @premium_activated.
  ///
  /// In en, this message translates to:
  /// **'Your premium subscription has been activated!'**
  String get premium_activated;

  /// No description provided for @subscription_failed.
  ///
  /// In en, this message translates to:
  /// **'Subscription could not be activated.'**
  String get subscription_failed;

  /// No description provided for @premium_not_available.
  ///
  /// In en, this message translates to:
  /// **'Premium package not available.'**
  String get premium_not_available;

  /// No description provided for @feedbackButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get feedbackButtonLabel;

  /// No description provided for @noEmailClientFound.
  ///
  /// In en, this message translates to:
  /// **'No email client found on this device.'**
  String get noEmailClientFound;

  /// No description provided for @habitReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Reminder'**
  String get habitReminderTitle;

  /// No description provided for @habitReminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'Habit Reminders'**
  String get habitReminderChannelName;

  /// No description provided for @habitReminderChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminds you about your habit daily.'**
  String get habitReminderChannelDescription;

  /// No description provided for @dailyTodoChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily Todo Reminder'**
  String get dailyTodoChannelName;

  /// No description provided for @dailyTodoChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminds you to check your tasks daily at 20:00'**
  String get dailyTodoChannelDesc;

  /// No description provided for @todoReminderTitleNormal.
  ///
  /// In en, this message translates to:
  /// **'Check your tasks!'**
  String get todoReminderTitleNormal;

  /// No description provided for @todoReminderBodyNormal.
  ///
  /// In en, this message translates to:
  /// **'Small steps lead you to your goal. Start now!'**
  String get todoReminderBodyNormal;

  /// No description provided for @todoReminderTitleHard.
  ///
  /// In en, this message translates to:
  /// **'Time to tackle your tasks!'**
  String get todoReminderTitleHard;

  /// No description provided for @todoReminderBodyHard.
  ///
  /// In en, this message translates to:
  /// **'Show discipline and work on your vision. No excuses!'**
  String get todoReminderBodyHard;

  /// No description provided for @todoReminderTitleBrutal.
  ///
  /// In en, this message translates to:
  /// **'What the hell are you doing?!'**
  String get todoReminderTitleBrutal;

  /// No description provided for @todoReminderBodyBrutal.
  ///
  /// In en, this message translates to:
  /// **'Your tasks are waiting! Time to grind!'**
  String get todoReminderBodyBrutal;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
