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

  static String m2(habitName) =>
      "Do you really want to delete the habit \"${habitName}\"?";

  static String m3(entryTitle) =>
      "Do you really want to delete the entry \"${entryTitle}\"?";

  static String m4(date) => "Due on ${date}";

  static String m5(error) => "An error occurred: ${error}";

  static String m6(currentFlow, totalFlows) =>
      "Flow ${currentFlow} / ${totalFlows}";

  static String m7(usedPrompts) => "Free prompts used: ${usedPrompts} / 5";

  static String m8(level) => "Level ${level}";

  static String m9(date) => "No tasks for ${date}";

  static String m10(percent, nextLevel) => "${percent}% to Level ${nextLevel}";

  static String m11(error) => "Purchase error: ${error}";

  static String m12(error) => "Restore error: ${error}";

  static String m13(status) => "Status: ${status}";

  static String m14(streak) => "${streak} Days Streak";

  static String m15(bonusPercent) => "XP Bonus: ${bonusPercent}%";

  static String m16(xpProgress, xpToNextLevel) =>
      "${xpProgress} / ${xpToNextLevel} XP";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "access_habit_tracker":
            MessageLookupByLibrary.simpleMessage("Access to Habit Tracker"),
        "access_journal":
            MessageLookupByLibrary.simpleMessage("Access to Journal Tool"),
        "accountTitle": MessageLookupByLibrary.simpleMessage("ACCOUNT"),
        "action": MessageLookupByLibrary.simpleMessage("Action"),
        "addExerciseSnackbar":
            MessageLookupByLibrary.simpleMessage("Enter an exercise!"),
        "addTask": MessageLookupByLibrary.simpleMessage("Add"),
        "addTodo": MessageLookupByLibrary.simpleMessage("Add"),
        "appBarTitle": MessageLookupByLibrary.simpleMessage("Daimonion Chat"),
        "appTitle": MessageLookupByLibrary.simpleMessage("Training Plan"),
        "autoStartBreak":
            MessageLookupByLibrary.simpleMessage("Auto-Start Break"),
        "autoStartNextFlow":
            MessageLookupByLibrary.simpleMessage("Auto-Start Next Flow"),
        "auto_renewal": MessageLookupByLibrary.simpleMessage("Auto Renewal"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "back_button": MessageLookupByLibrary.simpleMessage("Back"),
        "badge": MessageLookupByLibrary.simpleMessage("Badge"),
        "buyPremium": MessageLookupByLibrary.simpleMessage("Buy Premium"),
        "calendarViewTitle":
            MessageLookupByLibrary.simpleMessage("Calendar Overview"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelButton": MessageLookupByLibrary.simpleMessage("Cancel"),
        "captain": MessageLookupByLibrary.simpleMessage("Captain"),
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
        "colonel": MessageLookupByLibrary.simpleMessage("Colonel"),
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
        "deleteHabitMessage": m2,
        "deleteHabitTitle": MessageLookupByLibrary.simpleMessage("Delete?"),
        "deleteJournalEntryMessage": m3,
        "deleteJournalEntryTitle":
            MessageLookupByLibrary.simpleMessage("Delete?"),
        "deleteTask": MessageLookupByLibrary.simpleMessage("Delete"),
        "dueOn": m4,
        "editExerciseTitle":
            MessageLookupByLibrary.simpleMessage("Edit Exercise Details"),
        "editJournalEntry": MessageLookupByLibrary.simpleMessage("Edit Entry"),
        "editProfile": MessageLookupByLibrary.simpleMessage("Edit"),
        "editProfileHint": MessageLookupByLibrary.simpleMessage("Your Name"),
        "editProfileTitle": MessageLookupByLibrary.simpleMessage("Edit Name"),
        "editTask": MessageLookupByLibrary.simpleMessage("Edit Task"),
        "editTaskDialogTitle":
            MessageLookupByLibrary.simpleMessage("Edit Task"),
        "elite_soldier": MessageLookupByLibrary.simpleMessage("Elite Soldier"),
        "errorContent": MessageLookupByLibrary.simpleMessage(
            "An error occurred. Please try again later."),
        "errorOccurred": m5,
        "errorTitle": MessageLookupByLibrary.simpleMessage("Error"),
        "feedbackButtonLabel":
            MessageLookupByLibrary.simpleMessage("Send Feedback"),
        "filterMonth": MessageLookupByLibrary.simpleMessage("Month"),
        "filterWeek": MessageLookupByLibrary.simpleMessage("Week"),
        "filterYear": MessageLookupByLibrary.simpleMessage("Year"),
        "firstTimeButtonText":
            MessageLookupByLibrary.simpleMessage("I\'M READY"),
        "firstTimeHeadline": MessageLookupByLibrary.simpleMessage(
            "DO YOU WANT TO BE SOMEONE WHO HAS CONTROL,\nOR DO YOU WANT TO REMAIN A SLAVE TO YOUR IMPULSES?"),
        "flowCounter": m6,
        "flowStatsTitle": MessageLookupByLibrary.simpleMessage("Flow Stats"),
        "flowTimer": MessageLookupByLibrary.simpleMessage("Flow Timer"),
        "flowTimerBreakLabel": MessageLookupByLibrary.simpleMessage("Break"),
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
        "freePromptsCounter": m7,
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
        "habitHeader": MessageLookupByLibrary.simpleMessage("Habit"),
        "habitReminderChannelDescription": MessageLookupByLibrary.simpleMessage(
            "Reminds you about your habit daily."),
        "habitReminderChannelName":
            MessageLookupByLibrary.simpleMessage("Habit Reminders"),
        "habitReminderTitle":
            MessageLookupByLibrary.simpleMessage("Habit Reminder"),
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
            "HOW HARD SHOULD I BE TO YOU?"),
        "hardnessTitle": MessageLookupByLibrary.simpleMessage("Hardness"),
        "hideDone": MessageLookupByLibrary.simpleMessage("Hide done"),
        "hintText": MessageLookupByLibrary.simpleMessage(
            "Ask Daimonion whatever you want..."),
        "how_to_earn_xp": MessageLookupByLibrary.simpleMessage(
            "How to earn XP and level up!"),
        "immortal": MessageLookupByLibrary.simpleMessage("Immortal"),
        "journalContentLabel": MessageLookupByLibrary.simpleMessage("Content"),
        "journalMoodLabel": MessageLookupByLibrary.simpleMessage("Mood:"),
        "journalTitle": MessageLookupByLibrary.simpleMessage("Journal"),
        "journalTitleLabel": MessageLookupByLibrary.simpleMessage("Title"),
        "journalToolTitle": MessageLookupByLibrary.simpleMessage("Journal"),
        "journal_entry":
            MessageLookupByLibrary.simpleMessage("Write a Journal Entry"),
        "keepScreenOn": MessageLookupByLibrary.simpleMessage("Keep screen on"),
        "keep_grinding": MessageLookupByLibrary.simpleMessage("Keep grinding!"),
        "legalAndAppInfoTitle":
            MessageLookupByLibrary.simpleMessage("LEGAL & APP INFO"),
        "legend": MessageLookupByLibrary.simpleMessage("Legend"),
        "level": MessageLookupByLibrary.simpleMessage("Level"),
        "level_text": m8,
        "levels_and_rankings":
            MessageLookupByLibrary.simpleMessage("Levels and Rankings"),
        "levels_and_ranks":
            MessageLookupByLibrary.simpleMessage("Levels & Ranks"),
        "lieutenant": MessageLookupByLibrary.simpleMessage("Lieutenant"),
        "loadOffers": MessageLookupByLibrary.simpleMessage("Load Offers"),
        "major": MessageLookupByLibrary.simpleMessage("Major"),
        "max_per_day": MessageLookupByLibrary.simpleMessage("Max/Day"),
        "monthly": MessageLookupByLibrary.simpleMessage("Monthly"),
        "monthly_price": MessageLookupByLibrary.simpleMessage("\$3.99/month"),
        "more_to_come": MessageLookupByLibrary.simpleMessage("More to come!"),
        "motivationQuotes": MessageLookupByLibrary.simpleMessage(
            "You’re not here to be average!||No excuses – keep moving!||If you quit, you never meant it anyway.||Every day is a new chance – seize it!||Your future self will thank you for today’s grind.||Discipline beats talent – every day.||What you do today decides tomorrow.||Dream big, work harder.||You’re stronger than you think.||No growth without effort.||The toughest battles come before the greatest victories.||You must become the person you want to be – step by step.||No matter how slow you go, you’re beating everyone sitting on the couch.||Mistakes prove that you’re trying.||You don’t grow in your comfort zone – dare to step out.||Hard work isn’t always rewarded, but it builds character.||It’s the small daily victories that form great successes.||You have 24 hours like everyone else – use them with intention.||Your goals don’t care about your excuses.||If the path is easy, you’re on the wrong track.||Stop talking and start doing.||Every success begins with the courage to try.||Strength grows where comfort ends.||Your only limit is the one you set for yourself.||Your potential is waiting for you to act.||Every no brings you closer to a yes.||Focus on what you can control.||Yesterday is gone. Today is your day.||The best decisions are often the hardest.||A small progress is still progress.||The hardest decision of your life might be the one that changes everything.||Every great journey begins with a single step.||Those who underestimate you give you the greatest gift: the drive to prove them wrong.||Success is not a destination, but a journey – keep at it.||You can’t control anything except your reaction to the world.||The toughest moments often shape you the most.||What you plant today, you will harvest tomorrow.||If you fail, try again – but fail better next time.||Success means progress, not perfection.||Pain is temporary, pride lasts forever.||Focus beats chaos.||Do what needs to be done.||You’re a warrior – no excuse counts.||Hate fuels you, love makes you unstoppable.||Aim high – always.||Discipline is freedom.||Either you do it or someone else will.||Never lose faith in yourself.||Fear is your compass – follow it."),
        "motivation_text": MessageLookupByLibrary.simpleMessage(
            "Come on! Stop whining and show them what you\'re made of!"),
        "nameEmptyWarning":
            MessageLookupByLibrary.simpleMessage("Please enter your name."),
        "nameHint": MessageLookupByLibrary.simpleMessage("Your Name"),
        "newExerciseHint":
            MessageLookupByLibrary.simpleMessage("Enter new exercise..."),
        "newHabitNameHint": MessageLookupByLibrary.simpleMessage("Name"),
        "newHabitTitle": MessageLookupByLibrary.simpleMessage("New Habit"),
        "newJournalEntry": MessageLookupByLibrary.simpleMessage("New Entry"),
        "newTaskHint": MessageLookupByLibrary.simpleMessage("New Task..."),
        "newTodoHint": MessageLookupByLibrary.simpleMessage("New Task..."),
        "noActivePurchases":
            MessageLookupByLibrary.simpleMessage("No active purchases found."),
        "noDataMessage":
            MessageLookupByLibrary.simpleMessage("No data for this period"),
        "noEmailClientFound": MessageLookupByLibrary.simpleMessage(
            "No email client found on this device."),
        "noExercisesMessage": MessageLookupByLibrary.simpleMessage(
            "No exercises added.\nStart building your workout!"),
        "noHabitsMessage":
            MessageLookupByLibrary.simpleMessage("No habits yet"),
        "noJournalEntries":
            MessageLookupByLibrary.simpleMessage("No journal entries yet"),
        "noMatchingTasks":
            MessageLookupByLibrary.simpleMessage("No matching tasks"),
        "noOffersAvailable":
            MessageLookupByLibrary.simpleMessage("No offers available"),
        "noReminder": MessageLookupByLibrary.simpleMessage("None"),
        "noTasks": MessageLookupByLibrary.simpleMessage("No tasks"),
        "noTasksForDay": m9,
        "noTasksToday":
            MessageLookupByLibrary.simpleMessage("No tasks for today"),
        "noTodosAdded":
            MessageLookupByLibrary.simpleMessage("No to-dos added yet."),
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
            "This tool is only available for premium members."),
        "paywallTitle":
            MessageLookupByLibrary.simpleMessage("Premium Required"),
        "premiumPackageNotFound":
            MessageLookupByLibrary.simpleMessage("Premium package not found"),
        "premiumRequired":
            MessageLookupByLibrary.simpleMessage("Premium Required"),
        "premiumRestored":
            MessageLookupByLibrary.simpleMessage("Premium restored!"),
        "premiumSectionUnavailable": MessageLookupByLibrary.simpleMessage(
            "This section is available for premium users only."),
        "premiumUpgradeSuccess": MessageLookupByLibrary.simpleMessage(
            "Congratulations! You are now Premium."),
        "premium_activated": MessageLookupByLibrary.simpleMessage(
            "Your premium subscription has been activated!"),
        "premium_description": MessageLookupByLibrary.simpleMessage(
            "Subscribe to get full access to premium features"),
        "premium_not_available": MessageLookupByLibrary.simpleMessage(
            "Premium package not available."),
        "privacyAndTerms":
            MessageLookupByLibrary.simpleMessage("Privacy & Terms of Use"),
        "privacyAndTermsContent": MessageLookupByLibrary.simpleMessage(
            "Privacy and Terms of Use\n\nPrivacy\nWe take the protection of your data seriously. Currently, our app does not store any data in external databases. All information you enter into the app is stored locally on your device. Your data is not shared with third parties.\n\nIn the future, additional features such as login or online services might be integrated. If that happens, we will update this privacy policy accordingly to keep you informed transparently about any changes.\n\nTerms of Use\nOur app is designed to help you become more productive and achieve your goals. Use of the app is at your own risk. We do not assume liability for any direct or indirect damages that may result from using the app.\n\nPlease use the app responsibly and adhere to the laws of your country.\n\nContact\nIf you have any questions or concerns about our privacy policy or terms of use, contact us at kontakt@dineswipe.de."),
        "privacyAndTermsTitle":
            MessageLookupByLibrary.simpleMessage("Privacy & Terms of Use"),
        "productiveTimeWeek":
            MessageLookupByLibrary.simpleMessage("Productive Time (Week)"),
        "profileHeader":
            MessageLookupByLibrary.simpleMessage("WHO COULD YOU BE?"),
        "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
        "progress_text": m10,
        "purchaseError": m11,
        "rank": MessageLookupByLibrary.simpleMessage("Rank"),
        "recruit": MessageLookupByLibrary.simpleMessage("Recruit"),
        "reminderLabel":
            MessageLookupByLibrary.simpleMessage("Reminder (optional):"),
        "repsLabel": MessageLookupByLibrary.simpleMessage("Reps"),
        "restoreError": m12,
        "restorePurchases":
            MessageLookupByLibrary.simpleMessage("Restore Purchases"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveButton": MessageLookupByLibrary.simpleMessage("Save"),
        "selectHardness":
            MessageLookupByLibrary.simpleMessage("Select Hardness"),
        "sergeant": MessageLookupByLibrary.simpleMessage("Sergeant"),
        "setsLabel": MessageLookupByLibrary.simpleMessage("Sets"),
        "settingsTitle": MessageLookupByLibrary.simpleMessage("SETTINGS"),
        "shortCheckGym": MessageLookupByLibrary.simpleMessage("Body"),
        "shortCheckHealthyEating":
            MessageLookupByLibrary.simpleMessage("Healthy"),
        "shortCheckHelpOthers": MessageLookupByLibrary.simpleMessage("Help"),
        "shortCheckMental": MessageLookupByLibrary.simpleMessage("Mental"),
        "shortCheckNature": MessageLookupByLibrary.simpleMessage("Nature"),
        "shortCheckNoPorn": MessageLookupByLibrary.simpleMessage("No Porn"),
        "soldier": MessageLookupByLibrary.simpleMessage("Soldier"),
        "statAverageFlow":
            MessageLookupByLibrary.simpleMessage("Avg Time per Flow (Min)"),
        "statAverageWeeklyFlow":
            MessageLookupByLibrary.simpleMessage("Avg Time per Week (Min)"),
        "statFlows": MessageLookupByLibrary.simpleMessage("Flows"),
        "statTotalMinutes":
            MessageLookupByLibrary.simpleMessage("Total Minutes"),
        "status_text": m13,
        "streak": MessageLookupByLibrary.simpleMessage("Streak"),
        "streak_days": m14,
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
        "taskTitleLabel": MessageLookupByLibrary.simpleMessage("Title"),
        "tasks": MessageLookupByLibrary.simpleMessage("Tasks"),
        "tasksToolTitle": MessageLookupByLibrary.simpleMessage("Tasks"),
        "ten_min_flow": MessageLookupByLibrary.simpleMessage("10 min Flow"),
        "thank_you": MessageLookupByLibrary.simpleMessage("Thank you!"),
        "title_progress": MessageLookupByLibrary.simpleMessage("Your Progress"),
        "todayLabel": MessageLookupByLibrary.simpleMessage("Today:"),
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
        "toolsPageTitle":
            MessageLookupByLibrary.simpleMessage("Your Tools for Victory"),
        "trainingPlanToolTitle":
            MessageLookupByLibrary.simpleMessage("Training Plan"),
        "unknownUser": MessageLookupByLibrary.simpleMessage("Unknown User"),
        "unlimited_chat_prompts":
            MessageLookupByLibrary.simpleMessage("Unlimited Chat Prompts"),
        "unlock_premium":
            MessageLookupByLibrary.simpleMessage("Unlock Premium"),
        "untitled": MessageLookupByLibrary.simpleMessage("(Untitled)"),
        "upgradeContent": MessageLookupByLibrary.simpleMessage(
            "You have used your 5 free prompts.\n\nGet the premium version for unlimited chats now!"),
        "upgradeTitle": MessageLookupByLibrary.simpleMessage("Upgrade Needed"),
        "upgradeToPremium":
            MessageLookupByLibrary.simpleMessage("Upgrade to Premium"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "veteran": MessageLookupByLibrary.simpleMessage("Veteran"),
        "warlord": MessageLookupByLibrary.simpleMessage("Warlord"),
        "weekly": MessageLookupByLibrary.simpleMessage("Weekly"),
        "weeklyProgress":
            MessageLookupByLibrary.simpleMessage("WEEKLY PROGRESS"),
        "weekly_price": MessageLookupByLibrary.simpleMessage("\$1.99/week"),
        "weightLabel": MessageLookupByLibrary.simpleMessage("Weight (kg)"),
        "workoutNameLabel":
            MessageLookupByLibrary.simpleMessage("Workout Name"),
        "xp": MessageLookupByLibrary.simpleMessage("XP"),
        "xp_bonus": m15,
        "xp_text": m16,
        "yearly": MessageLookupByLibrary.simpleMessage("Yearly"),
        "yearly_price": MessageLookupByLibrary.simpleMessage("\$29.99/year")
      };
}
