// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(date) => "Choose day: ${date}";

  static String m1(count) =>
      "You missed ${count} fundamentals. That won\'t lead you anywhere!";

  static String m2(number) => "Day ${number}";

  static String m3(habitName) =>
      "Do you really want to delete the habit \"${habitName}\"?";

  static String m4(entryTitle) =>
      "Do you really want to delete the entry \"${entryTitle}\"?";

  static String m5(date) => "Due on ${date}";

  static String m6(error) => "An error occurred: ${error}";

  static String m7(currentFlow, totalFlows) =>
      "Flow ${currentFlow} / ${totalFlows}";

  static String m8(usedPrompts) => "Free prompts used: ${usedPrompts} / 5";

  static String m9(level) => "Level ${level}";

  static String m10(date) => "No tasks for ${date}";

  static String m11(percent, nextLevel) => "${percent}% to Level ${nextLevel}";

  static String m12(error) => "Purchase error: ${error}";

  static String m13(error) => "Error restoring purchases: ${error}";

  static String m14(status) => "Status: ${status}";

  static String m15(streak) => "${streak} Days Streak";

  static String m16(bonusPercent) => "XP Bonus: ${bonusPercent}%";

  static String m17(xpProgress, xpToNextLevel) =>
      "${xpProgress} / ${xpToNextLevel} XP";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "access_habit_tracker":
            MessageLookupByLibrary.simpleMessage("Access to Habit Tracker"),
        "access_journal":
            MessageLookupByLibrary.simpleMessage("Access to Journal Tool"),
        "accountTitle": MessageLookupByLibrary.simpleMessage("Account"),
        "action": MessageLookupByLibrary.simpleMessage("Action"),
        "addExercise": MessageLookupByLibrary.simpleMessage("Add Exercise"),
        "addExerciseSnackbar":
            MessageLookupByLibrary.simpleMessage("Enter an exercise!"),
        "addNewHabit": MessageLookupByLibrary.simpleMessage("Add a New Habit"),
        "addTask": MessageLookupByLibrary.simpleMessage("Add"),
        "addTodo": MessageLookupByLibrary.simpleMessage("Add"),
        "allHabits": MessageLookupByLibrary.simpleMessage("All Habits"),
        "appBarTitle": MessageLookupByLibrary.simpleMessage("Daimonion Chat"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Training Plan"),
        "atLeastOneWorkoutDay": MessageLookupByLibrary.simpleMessage(
            "You need at least one workout day. Do something for your body!"),
        "autoStartBreak":
            MessageLookupByLibrary.simpleMessage("Auto-Start Break"),
        "autoStartNextFlow":
            MessageLookupByLibrary.simpleMessage("Auto-Start Next Flow"),
        "auto_renewal": MessageLookupByLibrary.simpleMessage("Auto Renewal"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "back_button": MessageLookupByLibrary.simpleMessage("Back"),
        "badge": MessageLookupByLibrary.simpleMessage("Badge"),
        "buyPremium": MessageLookupByLibrary.simpleMessage("Buy Premium"),
        "byCategory": MessageLookupByLibrary.simpleMessage("By Category"),
        "calendarViewTitle":
            MessageLookupByLibrary.simpleMessage("Calendar Overview"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelButton": MessageLookupByLibrary.simpleMessage("Cancel"),
        "captain": MessageLookupByLibrary.simpleMessage("Captain"),
        "categoryLabel": MessageLookupByLibrary.simpleMessage("Category"),
        "changeDeadline":
            MessageLookupByLibrary.simpleMessage("Change Deadline"),
        "chatbotModeBrutal":
            MessageLookupByLibrary.simpleMessage("Brutally Honest"),
        "chatbotModeHard": MessageLookupByLibrary.simpleMessage("Hard"),
        "chatbotModeNormal": MessageLookupByLibrary.simpleMessage("Normal"),
        "chatbotWarning": MessageLookupByLibrary.simpleMessage(
            "Warning: In the \"Brutally Honest\" mode, you will be insulted and challenged intensely."),
        "cheerAlmost": MessageLookupByLibrary.simpleMessage(
            "Not done yet, but you got this. Keep going!"),
        "cheerHalf": MessageLookupByLibrary.simpleMessage(
            "You\'ve already completed more than half of your habits – strong!"),
        "cheerPerfect": MessageLookupByLibrary.simpleMessage(
            "Perfect! You completed all your habits today. Keep pushing!"),
        "cheerStart": MessageLookupByLibrary.simpleMessage(
            "Get to it! Time to do something!"),
        "chooseDay": m0,
        "chooseWorkoutColor":
            MessageLookupByLibrary.simpleMessage("Choose Workout Color"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "colonel": MessageLookupByLibrary.simpleMessage("Colonel"),
        "colorLabel": MessageLookupByLibrary.simpleMessage("Choose a Color"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("Coming Soon"),
        "comingSoonDescription": MessageLookupByLibrary.simpleMessage(
            "This feature will be available soon!"),
        "coming_soon": MessageLookupByLibrary.simpleMessage("Coming Soon"),
        "coming_soon_description": MessageLookupByLibrary.simpleMessage(
            "This option will be available soon!"),
        "complete_habit":
            MessageLookupByLibrary.simpleMessage("Complete a Habit"),
        "complete_todo":
            MessageLookupByLibrary.simpleMessage("Complete a To-Do"),
        "confirmDelete": MessageLookupByLibrary.simpleMessage("Yes, delete"),
        "confirmDeleteHabit":
            MessageLookupByLibrary.simpleMessage("Yes, delete"),
        "continueButton": MessageLookupByLibrary.simpleMessage("Continue"),
        "couldNotSendFeedback":
            MessageLookupByLibrary.simpleMessage("Could not send feedback."),
        "dailyFundamentalsTitle":
            MessageLookupByLibrary.simpleMessage("FUNDAMENTALS"),
        "dailyInsultAllMissed": MessageLookupByLibrary.simpleMessage(
            "You ignored ALL fundamentals!"),
        "dailyInsultSomeMissed": m1,
        "dailyInsultTitle":
            MessageLookupByLibrary.simpleMessage("You messed up!"),
        "dailyReminderActivated": MessageLookupByLibrary.simpleMessage(
            "Daily reminder at 20:00 activated!"),
        "dailyReminderDeactivated":
            MessageLookupByLibrary.simpleMessage("Daily reminder deactivated."),
        "dailyTodoChannelDesc": MessageLookupByLibrary.simpleMessage(
            "Reminds you to check your tasks daily at 20:00"),
        "dailyTodoChannelName":
            MessageLookupByLibrary.simpleMessage("Daily Todo Reminder"),
        "daimonion_warlord":
            MessageLookupByLibrary.simpleMessage("Daimonion Warlord"),
        "dashboardTitle": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "day": m2,
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteHabitConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete"),
        "deleteHabitMessage": m3,
        "deleteHabitTitle":
            MessageLookupByLibrary.simpleMessage("Delete Habit"),
        "deleteJournalEntryMessage": m4,
        "deleteJournalEntryTitle":
            MessageLookupByLibrary.simpleMessage("Delete?"),
        "deleteTask": MessageLookupByLibrary.simpleMessage("Delete"),
        "dueOn": m5,
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editDayTitle": MessageLookupByLibrary.simpleMessage("Edit Day"),
        "editExerciseTitle":
            MessageLookupByLibrary.simpleMessage("Edit Exercise Details"),
        "editHabitTitle": MessageLookupByLibrary.simpleMessage("Edit Habit"),
        "editJournalEntry": MessageLookupByLibrary.simpleMessage("Edit Entry"),
        "editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
        "editProfileHint":
            MessageLookupByLibrary.simpleMessage("Enter your name..."),
        "editProfileTitle":
            MessageLookupByLibrary.simpleMessage("Edit Your Name"),
        "editTask": MessageLookupByLibrary.simpleMessage("Edit Task"),
        "editTaskDialogTitle":
            MessageLookupByLibrary.simpleMessage("Edit Task"),
        "editWorkoutName":
            MessageLookupByLibrary.simpleMessage("Edit Workout Name"),
        "elite_soldier": MessageLookupByLibrary.simpleMessage("Elite Soldier"),
        "emailAppNotFound": MessageLookupByLibrary.simpleMessage(
            "No email client found on this device."),
        "emptyNameError":
            MessageLookupByLibrary.simpleMessage("Please enter a habit name."),
        "errorContent": MessageLookupByLibrary.simpleMessage(
            "An error occurred. Please try again later."),
        "errorOccurred": m6,
        "errorTitle": MessageLookupByLibrary.simpleMessage("Error"),
        "error_title": MessageLookupByLibrary.simpleMessage("Error"),
        "exerciseDetails":
            MessageLookupByLibrary.simpleMessage("Exercise Details"),
        "exerciseName": MessageLookupByLibrary.simpleMessage("Exercise Name"),
        "exercises": MessageLookupByLibrary.simpleMessage("exercises"),
        "features_label":
            MessageLookupByLibrary.simpleMessage("What\'s included:"),
        "feedbackButtonLabel":
            MessageLookupByLibrary.simpleMessage("Send Feedback"),
        "filterMonth": MessageLookupByLibrary.simpleMessage("Month"),
        "filterWeek": MessageLookupByLibrary.simpleMessage("Week"),
        "filterYear": MessageLookupByLibrary.simpleMessage("Year"),
        "firstTimeButtonText":
            MessageLookupByLibrary.simpleMessage("I\'M READY"),
        "firstTimeHeadline": MessageLookupByLibrary.simpleMessage(
            "DO YOU WANT TO BE SOMEONE WHO HAS CONTROL,\nOR DO YOU WANT TO REMAIN A SLAVE TO YOUR IMPULSES?"),
        "flowCounter": m7,
        "flowStatsTitle": MessageLookupByLibrary.simpleMessage("Flow Stats"),
        "flowTimer": MessageLookupByLibrary.simpleMessage("Flow Timer"),
        "flowTimerBreakLabel": MessageLookupByLibrary.simpleMessage("Break"),
        "flowTimerDescription": MessageLookupByLibrary.simpleMessage(
            "Stay focused with deep work sessions."),
        "flowTimerHelp": MessageLookupByLibrary.simpleMessage(
            "Use the Flow Timer to break tasks into deep focus periods."),
        "flowTimerSetFlowsHint":
            MessageLookupByLibrary.simpleMessage("Number of flows"),
        "flowTimerSetFlowsTitle":
            MessageLookupByLibrary.simpleMessage("Flow Settings"),
        "flowTimerSetTimeHint":
            MessageLookupByLibrary.simpleMessage("Enter minutes..."),
        "flowTimerSetTimeTitle":
            MessageLookupByLibrary.simpleMessage("Set Flow Time"),
        "flowTimerTitle": MessageLookupByLibrary.simpleMessage("Flow Timer"),
        "flowTimerToolTitle":
            MessageLookupByLibrary.simpleMessage("Flow Timer"),
        "freePromptsCounter": m8,
        "friday": MessageLookupByLibrary.simpleMessage("Friday"),
        "fridayShort": MessageLookupByLibrary.simpleMessage("F"),
        "fullCheckGym": MessageLookupByLibrary.simpleMessage(
            "Did you do something for your body?"),
        "fullCheckHealthyEating":
            MessageLookupByLibrary.simpleMessage("Did you eat healthy?"),
        "fullCheckHelpOthers": MessageLookupByLibrary.simpleMessage(
            "Did you do something good for others?"),
        "fullCheckMental": MessageLookupByLibrary.simpleMessage(
            "Did you do something mentally productive?"),
        "fullCheckNature": MessageLookupByLibrary.simpleMessage(
            "Did you spend time in nature today?"),
        "fullCheckNoPorn": MessageLookupByLibrary.simpleMessage(
            "Did you stay away from porn?"),
        "general": MessageLookupByLibrary.simpleMessage("General"),
        "getPremiumButton": MessageLookupByLibrary.simpleMessage("Get Premium"),
        "goalBetterRelationships":
            MessageLookupByLibrary.simpleMessage("Build better relationships"),
        "goalCareer":
            MessageLookupByLibrary.simpleMessage("Advance your career"),
        "goalFit": MessageLookupByLibrary.simpleMessage("Get fitter"),
        "goalMentalHealth":
            MessageLookupByLibrary.simpleMessage("Strengthen mental health"),
        "goalProductivity":
            MessageLookupByLibrary.simpleMessage("Be more productive"),
        "goalSaveMoney":
            MessageLookupByLibrary.simpleMessage("Save more money"),
        "gotIt": MessageLookupByLibrary.simpleMessage("Got it!"),
        "habitDeleted": MessageLookupByLibrary.simpleMessage("Habit deleted"),
        "habitHeader": MessageLookupByLibrary.simpleMessage("Habit"),
        "habitNameLabel": MessageLookupByLibrary.simpleMessage("Habit Name"),
        "habitReminderChannelDescription": MessageLookupByLibrary.simpleMessage(
            "Reminds you about your habit daily."),
        "habitReminderChannelName":
            MessageLookupByLibrary.simpleMessage("Habit Reminders"),
        "habitReminderTitle":
            MessageLookupByLibrary.simpleMessage("Habit Reminder"),
        "habitTrackerDescription": MessageLookupByLibrary.simpleMessage(
            "Build and maintain strong habits."),
        "habitTrackerHelp": MessageLookupByLibrary.simpleMessage(
            "Stay consistent with habit tracking for long-term success."),
        "habitTrackerTitle":
            MessageLookupByLibrary.simpleMessage("Habit Tracker"),
        "habitTrackerToolTitle":
            MessageLookupByLibrary.simpleMessage("Habit Tracker"),
        "habits": MessageLookupByLibrary.simpleMessage("Habits"),
        "hardnessBrutal":
            MessageLookupByLibrary.simpleMessage("Brutally Honest"),
        "hardnessHard": MessageLookupByLibrary.simpleMessage("Hard"),
        "hardnessNormal": MessageLookupByLibrary.simpleMessage("Normal"),
        "hardnessQuestion": MessageLookupByLibrary.simpleMessage(
            "How tough do you want your Daimonion to be?"),
        "hardnessTitle": MessageLookupByLibrary.simpleMessage("Hardness Level"),
        "health": MessageLookupByLibrary.simpleMessage("Health"),
        "helpDialogTitle":
            MessageLookupByLibrary.simpleMessage("How to Use These Tools"),
        "hideDone": MessageLookupByLibrary.simpleMessage("Hide done"),
        "hintText": MessageLookupByLibrary.simpleMessage(
            "Ask Daimonion whatever you want..."),
        "how_to_earn_xp": MessageLookupByLibrary.simpleMessage(
            "How to earn XP and level up!"),
        "immortal": MessageLookupByLibrary.simpleMessage("Immortal"),
        "journalContentLabel": MessageLookupByLibrary.simpleMessage("Content"),
        "journalDescription": MessageLookupByLibrary.simpleMessage(
            "Track your thoughts and progress."),
        "journalHelp": MessageLookupByLibrary.simpleMessage(
            "Write daily reflections and structure your thoughts in the journal."),
        "journalMoodLabel": MessageLookupByLibrary.simpleMessage("Mood:"),
        "journalTitle": MessageLookupByLibrary.simpleMessage("Journal"),
        "journalTitleLabel": MessageLookupByLibrary.simpleMessage("Title"),
        "journalToolTitle": MessageLookupByLibrary.simpleMessage("Journal"),
        "journal_entry":
            MessageLookupByLibrary.simpleMessage("Write a Journal Entry"),
        "keepScreenOn": MessageLookupByLibrary.simpleMessage("Keep screen on"),
        "keep_grinding": MessageLookupByLibrary.simpleMessage("Keep grinding!"),
        "kg": MessageLookupByLibrary.simpleMessage("kg"),
        "learning": MessageLookupByLibrary.simpleMessage("Learning"),
        "legalAndAppInfoTitle":
            MessageLookupByLibrary.simpleMessage("Legal & App Info"),
        "legend": MessageLookupByLibrary.simpleMessage("Legend"),
        "level": MessageLookupByLibrary.simpleMessage("Level"),
        "level_text": m9,
        "levels_and_rankings":
            MessageLookupByLibrary.simpleMessage("Levels and Rankings"),
        "levels_and_ranks":
            MessageLookupByLibrary.simpleMessage("Levels & Ranks"),
        "lieutenant": MessageLookupByLibrary.simpleMessage("Lieutenant"),
        "loadOffers": MessageLookupByLibrary.simpleMessage("Load Offers"),
        "major": MessageLookupByLibrary.simpleMessage("Major"),
        "max_per_day": MessageLookupByLibrary.simpleMessage("Max/Day"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe later"),
        "monday": MessageLookupByLibrary.simpleMessage("Monday"),
        "mondayShort": MessageLookupByLibrary.simpleMessage("M"),
        "monthly": MessageLookupByLibrary.simpleMessage("Monthly"),
        "monthly_description":
            MessageLookupByLibrary.simpleMessage("Save over 30%"),
        "monthly_label": MessageLookupByLibrary.simpleMessage("Monthly"),
        "monthly_price": MessageLookupByLibrary.simpleMessage("\$3.99/month"),
        "more_to_come": MessageLookupByLibrary.simpleMessage("More to come!"),
        "most_popular_label": MessageLookupByLibrary.simpleMessage("Popular"),
        "motivationQuotes": MessageLookupByLibrary.simpleMessage(
            "You’re not here to be average!||No excuses – keep moving!||If you quit, you never meant it anyway.||Every day is a new chance – seize it!||Your future self will thank you for today’s grind.||Discipline beats talent – every day.||What you do today decides tomorrow.||Dream big, work harder.||You’re stronger than you think.||No growth without effort.||The toughest battles come before the greatest victories.||You must become the person you want to be – step by step.||No matter how slow you go, you’re beating everyone sitting on the couch.||Mistakes prove that you’re trying.||You don’t grow in your comfort zone – dare to step out.||Hard work isn’t always rewarded, but it builds character.||It’s the small daily victories that form great successes.||You have 24 hours like everyone else – use them with intention.||Your goals don’t care about your excuses.||If the path is easy, you’re on the wrong track.||Stop talking and start doing.||Every success begins with the courage to try.||Strength grows where comfort ends.||Your only limit is the one you set for yourself.||Your potential is waiting for you to act.||Every no brings you closer to a yes.||Focus on what you can control.||Yesterday is gone. Today is your day.||The best decisions are often the hardest.||A small progress is still progress.||The hardest decision of your life might be the one that changes everything.||Every great journey begins with a single step.||Those who underestimate you give you the greatest gift: the drive to prove them wrong.||Success is not a destination, but a journey – keep at it.||You can’t control anything except your reaction to the world.||The toughest moments often shape you the most.||What you plant today, you will harvest tomorrow.||If you fail, try again – but fail better next time.||Success means progress, not perfection.||Pain is temporary, pride lasts forever.||Focus beats chaos.||Do what needs to be done.||You’re a warrior – no excuse counts.||Hate fuels you, love makes you unstoppable.||Aim high – always.||Discipline is freedom.||Either you do it or someone else will.||Never lose faith in yourself.||Fear is your compass – follow it."),
        "motivation_text": MessageLookupByLibrary.simpleMessage(
            "Come on! Stop whining and show them what you\'re made of!"),
        "nameEmptyWarning":
            MessageLookupByLibrary.simpleMessage("Please enter your name."),
        "nameHint": MessageLookupByLibrary.simpleMessage("Your Name"),
        "nameLabel": MessageLookupByLibrary.simpleMessage("Your Name"),
        "newDay": MessageLookupByLibrary.simpleMessage("New Day"),
        "newDayNameHint": MessageLookupByLibrary.simpleMessage("New day name"),
        "newExerciseHint":
            MessageLookupByLibrary.simpleMessage("Enter new exercise"),
        "newHabitNameHint": MessageLookupByLibrary.simpleMessage("Name"),
        "newHabitTitle":
            MessageLookupByLibrary.simpleMessage("Create New Habit"),
        "newJournalEntry": MessageLookupByLibrary.simpleMessage("New Entry"),
        "newTaskHint": MessageLookupByLibrary.simpleMessage("New Task..."),
        "newTodoHint": MessageLookupByLibrary.simpleMessage("New Task..."),
        "noActivePurchases":
            MessageLookupByLibrary.simpleMessage("No active purchases found."),
        "noDataMessage":
            MessageLookupByLibrary.simpleMessage("No data for this period"),
        "noDaysSelectedError": MessageLookupByLibrary.simpleMessage(
            "Please select at least one day."),
        "noEmailClientFound": MessageLookupByLibrary.simpleMessage(
            "No email client found on this device."),
        "noExercisesMessage":
            MessageLookupByLibrary.simpleMessage("No exercises added yet."),
        "noHabitsMessage":
            MessageLookupByLibrary.simpleMessage("No habits added yet."),
        "noJournalEntries":
            MessageLookupByLibrary.simpleMessage("No journal entries yet"),
        "noMatchingTasks":
            MessageLookupByLibrary.simpleMessage("No matching tasks"),
        "noOffersAvailable":
            MessageLookupByLibrary.simpleMessage("No offers available"),
        "noPurchasesToRestore": MessageLookupByLibrary.simpleMessage(
            "No previous purchases found to restore."),
        "noReminder": MessageLookupByLibrary.simpleMessage("None"),
        "noReminderSet":
            MessageLookupByLibrary.simpleMessage("No reminder set"),
        "noTasks": MessageLookupByLibrary.simpleMessage("No tasks"),
        "noTasksForDay": m10,
        "noTasksToday":
            MessageLookupByLibrary.simpleMessage("No tasks for today"),
        "noTodosAdded":
            MessageLookupByLibrary.simpleMessage("No to-dos added yet."),
        "noWorkoutName":
            MessageLookupByLibrary.simpleMessage("No Workout Name"),
        "notes": MessageLookupByLibrary.simpleMessage("Notes"),
        "notificationActiveMessage": MessageLookupByLibrary.simpleMessage(
            "Notifications are now active! Let\'s get started."),
        "notificationDeniedMessage": MessageLookupByLibrary.simpleMessage(
            "Notifications were denied. You can enable them later in settings."),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "onboardingAgeQuestion":
            MessageLookupByLibrary.simpleMessage("How old are you?"),
        "onboardingChatbotTitle":
            MessageLookupByLibrary.simpleMessage("Chatbot Hardness Level"),
        "onboardingFinishButtonText":
            MessageLookupByLibrary.simpleMessage("LET’S GO TO THE DASHBOARD!"),
        "onboardingFinishHeadline":
            MessageLookupByLibrary.simpleMessage("YOU DID IT!"),
        "onboardingFinishSubheadline": MessageLookupByLibrary.simpleMessage(
            "Now the real grind begins. You’re ready to take control."),
        "onboardingGoalsQuestion":
            MessageLookupByLibrary.simpleMessage("What are your goals?"),
        "onboardingNameQuestion":
            MessageLookupByLibrary.simpleMessage("What\'s your name?"),
        "onboardingNotificationButtonText":
            MessageLookupByLibrary.simpleMessage("Push me!"),
        "onboardingNotificationDescription": MessageLookupByLibrary.simpleMessage(
            "Imagine being reminded every day to be better than yesterday. Your goals, your tasks, your discipline – everything gets stronger because you do. Enable notifications now and let your inner Daimonion push you."),
        "onboardingNotificationHeadline":
            MessageLookupByLibrary.simpleMessage("Take the first step"),
        "onboardingNotificationNextChallenge":
            MessageLookupByLibrary.simpleMessage(
                "Continue to the next challenge"),
        "onboardingTodosSubheadline": MessageLookupByLibrary.simpleMessage(
            "Set up your first tasks. These to-dos will go directly into your main list."),
        "onboardingTodosTitle":
            MessageLookupByLibrary.simpleMessage("Your First To-Dos"),
        "paywallContent": MessageLookupByLibrary.simpleMessage(
            "Get access to all premium features and tools to maximize your productivity and growth."),
        "paywallTitle":
            MessageLookupByLibrary.simpleMessage("Unlock Premium Tools"),
        "personal": MessageLookupByLibrary.simpleMessage("Personal"),
        "premiumPackageNotFound":
            MessageLookupByLibrary.simpleMessage("Premium package not found"),
        "premiumRequired":
            MessageLookupByLibrary.simpleMessage("Premium required"),
        "premiumRestored": MessageLookupByLibrary.simpleMessage(
            "Premium subscription restored successfully."),
        "premiumSectionUnavailable": MessageLookupByLibrary.simpleMessage(
            "This section is available for premium users only."),
        "premiumUpgradeSuccess": MessageLookupByLibrary.simpleMessage(
            "Congratulations! You are now Premium."),
        "premium_activated": MessageLookupByLibrary.simpleMessage(
            "Your premium subscription has been activated!"),
        "premium_description": MessageLookupByLibrary.simpleMessage(
            "Subscribe to get full access to premium features"),
        "premium_label": MessageLookupByLibrary.simpleMessage("PREMIUM"),
        "premium_not_available": MessageLookupByLibrary.simpleMessage(
            "Premium package not available."),
        "privacyAndTerms":
            MessageLookupByLibrary.simpleMessage("Privacy & Terms"),
        "privacyAndTermsContent": MessageLookupByLibrary.simpleMessage(
            "Privacy and Terms of Use\n\nPrivacy\nWe take the protection of your data seriously. Currently, our app does not store any data in external databases. All information you enter into the app is stored locally on your device. Your data is not shared with third parties.\n\nIn the future, additional features such as login or online services might be integrated. If that happens, we will update this privacy policy accordingly to keep you informed transparently about any changes.\n\nTerms of Use\nOur app is designed to help you become more productive and achieve your goals. Use of the app is at your own risk. We do not assume liability for any direct or indirect damages that may result from using the app.\n\nPlease use the app responsibly and adhere to the laws of your country.\n\nContact\nIf you have any questions or concerns about our privacy policy or terms of use, contact us at kontakt@dineswipe.de."),
        "privacyAndTermsTitle":
            MessageLookupByLibrary.simpleMessage("Privacy & Terms of Use"),
        "productiveTimeWeek":
            MessageLookupByLibrary.simpleMessage("Productive Time (Week)"),
        "productivity": MessageLookupByLibrary.simpleMessage("Productivity"),
        "productivityCategory":
            MessageLookupByLibrary.simpleMessage("Productivity"),
        "profileHeader": MessageLookupByLibrary.simpleMessage("Your Profile"),
        "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
        "progress_text": m11,
        "purchaseError": m12,
        "purchasesRestoredError": MessageLookupByLibrary.simpleMessage(
            "Could not restore purchases."),
        "purchasesRestoredSuccess": MessageLookupByLibrary.simpleMessage(
            "Your purchases have been restored successfully!"),
        "quickAdd": MessageLookupByLibrary.simpleMessage("Quick Add"),
        "rank": MessageLookupByLibrary.simpleMessage("Rank"),
        "recruit": MessageLookupByLibrary.simpleMessage("Recruit"),
        "reminderLabel": MessageLookupByLibrary.simpleMessage("Set Reminder"),
        "repeatLabel": MessageLookupByLibrary.simpleMessage("Repeat On"),
        "reps": MessageLookupByLibrary.simpleMessage("reps"),
        "repsLabel": MessageLookupByLibrary.simpleMessage("Reps"),
        "restoreError": m13,
        "restorePurchases":
            MessageLookupByLibrary.simpleMessage("Restore Purchases"),
        "restoringPurchases":
            MessageLookupByLibrary.simpleMessage("Restoring purchases..."),
        "saturday": MessageLookupByLibrary.simpleMessage("Saturday"),
        "saturdayShort": MessageLookupByLibrary.simpleMessage("S"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveButton": MessageLookupByLibrary.simpleMessage("Save"),
        "selectCategory":
            MessageLookupByLibrary.simpleMessage("Select a category"),
        "selectHardness":
            MessageLookupByLibrary.simpleMessage("Select Hardness Level"),
        "sergeant": MessageLookupByLibrary.simpleMessage("Sergeant"),
        "setTime": MessageLookupByLibrary.simpleMessage("Set Time"),
        "sets": MessageLookupByLibrary.simpleMessage("sets"),
        "setsLabel": MessageLookupByLibrary.simpleMessage("Sets"),
        "settingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
        "shortCheckGym": MessageLookupByLibrary.simpleMessage("Body"),
        "shortCheckHealthyEating":
            MessageLookupByLibrary.simpleMessage("Healthy"),
        "shortCheckHelpOthers": MessageLookupByLibrary.simpleMessage("Help"),
        "shortCheckMental": MessageLookupByLibrary.simpleMessage("Mental"),
        "shortCheckNature": MessageLookupByLibrary.simpleMessage("Nature"),
        "shortCheckNoPorn": MessageLookupByLibrary.simpleMessage("No Porn"),
        "soldier": MessageLookupByLibrary.simpleMessage("Soldier"),
        "start_free_week_label":
            MessageLookupByLibrary.simpleMessage("Start free week"),
        "statAverageFlow":
            MessageLookupByLibrary.simpleMessage("Avg Time per Flow (Min)"),
        "statAverageWeeklyFlow":
            MessageLookupByLibrary.simpleMessage("Avg Time per Week (Min)"),
        "statFlows": MessageLookupByLibrary.simpleMessage("Flows"),
        "statTotalMinutes":
            MessageLookupByLibrary.simpleMessage("Total Minutes"),
        "status_text": m14,
        "streak": MessageLookupByLibrary.simpleMessage("Streak"),
        "streak_days": m15,
        "streak_description": MessageLookupByLibrary.simpleMessage(
            "The longer you stay active daily, the more XP you earn! Your streak rewards consistency and helps you level up faster."),
        "streak_info_title":
            MessageLookupByLibrary.simpleMessage("Streak Info"),
        "streak_rewards": MessageLookupByLibrary.simpleMessage(
            "- 7+ days: +5% XP\\n- 14+ days: +10% XP\\n- 30+ days: +15% XP\\n"),
        "subscription_disclaimer": MessageLookupByLibrary.simpleMessage(
            "Cancel anytime | Privacy Policy\nYour subscription will automatically renew. Cancel at least 24 hours before renewal on Google Play."),
        "subscription_failed": MessageLookupByLibrary.simpleMessage(
            "Subscription could not be activated."),
        "successContent": MessageLookupByLibrary.simpleMessage(
            "You have successfully unlocked premium!"),
        "successTitle": MessageLookupByLibrary.simpleMessage("Success"),
        "suggestion1": MessageLookupByLibrary.simpleMessage(
            "I\'m feeling lazy and unmotivated today."),
        "suggestion2": MessageLookupByLibrary.simpleMessage(
            "I don\'t know what to do with my day."),
        "suggestion3": MessageLookupByLibrary.simpleMessage(
            "I want to build new habits, but how?"),
        "suggestion4": MessageLookupByLibrary.simpleMessage(
            "I don\'t feel like working out. Convince me!"),
        "suggestion5": MessageLookupByLibrary.simpleMessage(
            "What can I start with today to be more productive?"),
        "suggestion6":
            MessageLookupByLibrary.simpleMessage("Give me a kick in the butt!"),
        "sunday": MessageLookupByLibrary.simpleMessage("Sunday"),
        "sundayShort": MessageLookupByLibrary.simpleMessage("S"),
        "tapToAddDetails":
            MessageLookupByLibrary.simpleMessage("Tap to add details"),
        "tapToAddExercises":
            MessageLookupByLibrary.simpleMessage("Tap to add exercises"),
        "taskTitleLabel": MessageLookupByLibrary.simpleMessage("Title"),
        "tasks": MessageLookupByLibrary.simpleMessage("Tasks"),
        "tasksDescription": MessageLookupByLibrary.simpleMessage(
            "Manage your tasks effectively."),
        "tasksForDay": MessageLookupByLibrary.simpleMessage("Test"),
        "tasksHelp": MessageLookupByLibrary.simpleMessage(
            "Plan your day with a simple and effective task list."),
        "tasksToolTitle": MessageLookupByLibrary.simpleMessage("To-Do List"),
        "ten_min_flow": MessageLookupByLibrary.simpleMessage("10 min Flow"),
        "thank_you": MessageLookupByLibrary.simpleMessage("Thank you!"),
        "thursday": MessageLookupByLibrary.simpleMessage("Thursday"),
        "thursdayShort": MessageLookupByLibrary.simpleMessage("T"),
        "title_progress": MessageLookupByLibrary.simpleMessage("Your Progress"),
        "todayLabel": MessageLookupByLibrary.simpleMessage("Today"),
        "todaysTasks": MessageLookupByLibrary.simpleMessage("TODAY\'S TASKS"),
        "todoListTitle": MessageLookupByLibrary.simpleMessage("To-Do List"),
        "todoReminderBodyBrutal": MessageLookupByLibrary.simpleMessage(
            "Your tasks are waiting! Time to grind!"),
        "todoReminderBodyHard": MessageLookupByLibrary.simpleMessage(
            "Show discipline and work on your vision. No excuses!"),
        "todoReminderBodyNormal": MessageLookupByLibrary.simpleMessage(
            "Small steps lead you to your goal. Start now!"),
        "todoReminderTitleBrutal": MessageLookupByLibrary.simpleMessage(
            "What the hell are you doing?!"),
        "todoReminderTitleHard":
            MessageLookupByLibrary.simpleMessage("Time to tackle your tasks!"),
        "todoReminderTitleNormal":
            MessageLookupByLibrary.simpleMessage("Check your tasks!"),
        "toolsPageTitle": MessageLookupByLibrary.simpleMessage("Tools"),
        "trainingPlan": MessageLookupByLibrary.simpleMessage("Training Plan"),
        "trainingPlanDescription": MessageLookupByLibrary.simpleMessage(
            "Optimize your workouts and track progress."),
        "trainingPlanHelp": MessageLookupByLibrary.simpleMessage(
            "Use the Training Plan to follow a structured fitness routine."),
        "trainingPlanToolTitle":
            MessageLookupByLibrary.simpleMessage("Training Plan"),
        "tuesday": MessageLookupByLibrary.simpleMessage("Tuesday"),
        "tuesdayShort": MessageLookupByLibrary.simpleMessage("T"),
        "uncategorized": MessageLookupByLibrary.simpleMessage("Uncategorized"),
        "undo": MessageLookupByLibrary.simpleMessage("Undo"),
        "unknownUser": MessageLookupByLibrary.simpleMessage("Unknown User"),
        "unlimited_chat_prompts":
            MessageLookupByLibrary.simpleMessage("Unlimited Chat Prompts"),
        "unlock_premium":
            MessageLookupByLibrary.simpleMessage("Unlock Premium"),
        "untitled": MessageLookupByLibrary.simpleMessage("(Untitled)"),
        "update": MessageLookupByLibrary.simpleMessage("Update"),
        "upgradeContent": MessageLookupByLibrary.simpleMessage(
            "You have used your 5 free prompts.\n\nGet the premium version for unlimited chats now!"),
        "upgradeForMoreFeatures":
            MessageLookupByLibrary.simpleMessage("Upgrade for more features"),
        "upgradeNow": MessageLookupByLibrary.simpleMessage("Upgrade Now"),
        "upgradeTitle": MessageLookupByLibrary.simpleMessage("Upgrade Needed"),
        "upgradeToPremium":
            MessageLookupByLibrary.simpleMessage("Upgrade to Premium"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "veteran": MessageLookupByLibrary.simpleMessage("Veteran"),
        "warlord": MessageLookupByLibrary.simpleMessage("Warlord"),
        "wednesday": MessageLookupByLibrary.simpleMessage("Wednesday"),
        "wednesdayShort": MessageLookupByLibrary.simpleMessage("W"),
        "weekly": MessageLookupByLibrary.simpleMessage("Weekly"),
        "weeklyProgress":
            MessageLookupByLibrary.simpleMessage("WEEKLY PROGRESS"),
        "weekly_description":
            MessageLookupByLibrary.simpleMessage("Try it out cheaply"),
        "weekly_label": MessageLookupByLibrary.simpleMessage("Weekly"),
        "weekly_price": MessageLookupByLibrary.simpleMessage("\$1.99/week"),
        "weightLabel": MessageLookupByLibrary.simpleMessage("Weight"),
        "wellnessCategory":
            MessageLookupByLibrary.simpleMessage("Wellness & Growth"),
        "workoutNameHint": MessageLookupByLibrary.simpleMessage("Workout Name"),
        "workoutNameLabel":
            MessageLookupByLibrary.simpleMessage("Workout Name"),
        "xp": MessageLookupByLibrary.simpleMessage("XP"),
        "xp_bonus": m16,
        "xp_text": m17,
        "yearly": MessageLookupByLibrary.simpleMessage("Yearly"),
        "yearly_description":
            MessageLookupByLibrary.simpleMessage("Save over 40%"),
        "yearly_label": MessageLookupByLibrary.simpleMessage("Yearly"),
        "yearly_price": MessageLookupByLibrary.simpleMessage("\$29.99/year")
      };
}
