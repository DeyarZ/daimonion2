import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appBarTitle => 'Daimonion Chat';

  @override
  String freePromptsCounter(Object usedPrompts) {
    return 'Free prompts used: $usedPrompts / 5';
  }

  @override
  String get upgradeTitle => 'Upgrade Needed';

  @override
  String get upgradeContent => 'You have used your 5 free prompts.\n\nGet the premium version for unlimited chats now!';

  @override
  String get cancel => 'Cancel';

  @override
  String get buyPremium => 'Buy Premium';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorContent => 'An error occurred. Please try again later.';

  @override
  String get ok => 'OK';

  @override
  String get successTitle => 'Success';

  @override
  String get successContent => 'You have successfully unlocked premium!';

  @override
  String get hintText => 'Ask Daimonion whatever you want...';

  @override
  String get suggestion1 => 'I\'m feeling lazy and unmotivated today.';

  @override
  String get suggestion2 => 'I don\'t know what to do with my day.';

  @override
  String get suggestion3 => 'I want to build new habits, but how?';

  @override
  String get suggestion4 => 'I don\'t feel like working out. Convince me!';

  @override
  String get suggestion5 => 'What can I start with today to be more productive?';

  @override
  String get suggestion6 => 'Give me a kick in the butt!';

  @override
  String errorOccurred(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get productiveTimeWeek => 'Productive Time (Week)';

  @override
  String get streak => 'Streak';

  @override
  String get flowTimer => 'Flow Timer';

  @override
  String get todaysTasks => 'Today\'s Tasks';

  @override
  String get noTasksToday => 'No tasks for today. Stay disciplined and productive!';

  @override
  String get tasks => 'Tasks';

  @override
  String get habits => 'Habits';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String get premiumRequired => 'Premium required';

  @override
  String get premiumSectionUnavailable => 'This section is available for premium users only.';

  @override
  String get cheerPerfect => 'Perfect! You completed all your habits today. Keep pushing!';

  @override
  String get cheerHalf => 'You\'ve already completed more than half of your habits – strong!';

  @override
  String get cheerAlmost => 'Not done yet, but you got this. Keep going!';

  @override
  String get cheerStart => 'Get to it! Time to do something!';

  @override
  String get motivationQuotes => 'You’re not here to be average!||No excuses – keep moving!||If you quit, you never meant it anyway.||Every day is a new chance – seize it!||Your future self will thank you for today’s grind.||Discipline beats talent – every day.||What you do today decides tomorrow.||Dream big, work harder.||You’re stronger than you think.||No growth without effort.||The toughest battles come before the greatest victories.||You must become the person you want to be – step by step.||No matter how slow you go, you’re beating everyone sitting on the couch.||Mistakes prove that you’re trying.||You don’t grow in your comfort zone – dare to step out.||Hard work isn’t always rewarded, but it builds character.||It’s the small daily victories that form great successes.||You have 24 hours like everyone else – use them with intention.||Your goals don’t care about your excuses.||If the path is easy, you’re on the wrong track.||Stop talking and start doing.||Every success begins with the courage to try.||Strength grows where comfort ends.||Your only limit is the one you set for yourself.||Your potential is waiting for you to act.||Every no brings you closer to a yes.||Focus on what you can control.||Yesterday is gone. Today is your day.||The best decisions are often the hardest.||A small progress is still progress.||The hardest decision of your life might be the one that changes everything.||Every great journey begins with a single step.||Those who underestimate you give you the greatest gift: the drive to prove them wrong.||Success is not a destination, but a journey – keep at it.||You can’t control anything except your reaction to the world.||The toughest moments often shape you the most.||What you plant today, you will harvest tomorrow.||If you fail, try again – but fail better next time.||Success means progress, not perfection.||Pain is temporary, pride lasts forever.||Focus beats chaos.||Do what needs to be done.||You’re a warrior – no excuse counts.||Hate fuels you, love makes you unstoppable.||Aim high – always.||Discipline is freedom.||Either you do it or someone else will.||Never lose faith in yourself.||Fear is your compass – follow it.';

  @override
  String get firstTimeHeadline => 'DO YOU WANT TO BE SOMEONE WHO HAS CONTROL,\nOR DO YOU WANT TO REMAIN A SLAVE TO YOUR IMPULSES?';

  @override
  String get firstTimeButtonText => 'I\'M READY';

  @override
  String get flowStatsTitle => 'Flow Statistics';

  @override
  String get filterWeek => 'Week';

  @override
  String get filterMonth => 'Month';

  @override
  String get filterYear => 'Year';

  @override
  String get noDataMessage => 'No data available.';

  @override
  String get statFlows => 'Sessions';

  @override
  String get statTotalMinutes => 'Total Minutes';

  @override
  String get statAverageFlow => 'Avg Flow Duration';

  @override
  String get statAverageWeeklyFlow => 'Avg Weekly Flow';

  @override
  String get flowTimerTitle => 'Flow Timer';

  @override
  String flowCounter(Object currentFlow, Object totalFlows) {
    return 'Flow $currentFlow / $totalFlows';
  }

  @override
  String get flowTimerSetTimeTitle => 'Set Flow Time';

  @override
  String get flowTimerSetTimeHint => 'Enter minutes...';

  @override
  String get flowTimerSetFlowsTitle => 'Flow Settings';

  @override
  String get flowTimerSetFlowsHint => 'Number of flows';

  @override
  String get habitTrackerTitle => 'Habit Tracker';

  @override
  String get todayLabel => 'Today';

  @override
  String get noHabitsMessage => 'No habits added yet.';

  @override
  String get habitHeader => 'Habit';

  @override
  String get newHabitTitle => 'Create New Habit';

  @override
  String get newHabitNameHint => 'Name';

  @override
  String get reminderLabel => 'Set Reminder';

  @override
  String get noReminder => 'None';

  @override
  String get deleteHabitTitle => 'Delete Habit';

  @override
  String deleteHabitMessage(Object habitName) {
    return 'Do you really want to delete the habit \"$habitName\"?';
  }

  @override
  String get confirmDeleteHabit => 'Yes, delete';

  @override
  String get journalTitle => 'Journal';

  @override
  String get noJournalEntries => 'No journal entries yet';

  @override
  String get untitled => '(Untitled)';

  @override
  String get newJournalEntry => 'New Entry';

  @override
  String get editJournalEntry => 'Edit Entry';

  @override
  String get journalTitleLabel => 'Title';

  @override
  String get journalContentLabel => 'Content';

  @override
  String get journalMoodLabel => 'Mood:';

  @override
  String get deleteJournalEntryTitle => 'Delete?';

  @override
  String deleteJournalEntryMessage(Object entryTitle) {
    return 'Do you really want to delete the entry \"$entryTitle\"?';
  }

  @override
  String get confirmDelete => 'Yes, delete';

  @override
  String get privacyAndTermsTitle => 'Privacy & Terms of Use';

  @override
  String get privacyAndTermsContent => 'Privacy and Terms of Use\n\nPrivacy\nWe take the protection of your data seriously. Currently, our app does not store any data in external databases. All information you enter into the app is stored locally on your device. Your data is not shared with third parties.\n\nIn the future, additional features such as login or online services might be integrated. If that happens, we will update this privacy policy accordingly to keep you informed transparently about any changes.\n\nTerms of Use\nOur app is designed to help you become more productive and achieve your goals. Use of the app is at your own risk. We do not assume liability for any direct or indirect damages that may result from using the app.\n\nPlease use the app responsibly and adhere to the laws of your country.\n\nContact\nIf you have any questions or concerns about our privacy policy or terms of use, contact us at kontakt@dineswipe.de.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileHeader => 'Your Profile';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileHint => 'Enter your name...';

  @override
  String get save => 'Save';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get hardnessTitle => 'Feedback Style';

  @override
  String get hardnessNormal => 'Normal';

  @override
  String get hardnessHard => 'Hard';

  @override
  String get hardnessBrutal => 'Brutal';

  @override
  String get legalAndAppInfoTitle => 'Legal & App Info';

  @override
  String get privacyAndTerms => 'Privacy & Terms';

  @override
  String get version => 'Version';

  @override
  String get accountTitle => 'Account';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get premiumPackageNotFound => 'Premium package not found';

  @override
  String get noOffersAvailable => 'No offers available';

  @override
  String get premiumUpgradeSuccess => 'Congratulations! You are now Premium.';

  @override
  String purchaseError(Object error) {
    return 'Purchase error: $error';
  }

  @override
  String get premiumRestored => 'Premium subscription restored successfully.';

  @override
  String get noActivePurchases => 'No active purchases found.';

  @override
  String restoreError(Object error) {
    return 'Error restoring purchases: $error';
  }

  @override
  String get selectHardness => 'Select Feedback Style';

  @override
  String get hardnessQuestion => 'How tough do you want your Daimonion to be?';

  @override
  String get todoListTitle => 'To-Do List';

  @override
  String get newTaskHint => 'New Task...';

  @override
  String get addTask => 'Add';

  @override
  String get noTasks => 'No tasks';

  @override
  String get noMatchingTasks => 'No matching tasks';

  @override
  String dueOn(Object date) {
    return 'Due on $date';
  }

  @override
  String get editTask => 'Edit Task';

  @override
  String get deleteTask => 'Delete';

  @override
  String get editTaskDialogTitle => 'Edit Task';

  @override
  String get taskTitleLabel => 'Title';

  @override
  String get changeDeadline => 'Change Deadline';

  @override
  String get dailyReminderActivated => 'Daily reminder at 20:00 activated!';

  @override
  String get dailyReminderDeactivated => 'Daily reminder deactivated.';

  @override
  String get hideDone => 'Hide done';

  @override
  String get calendarViewTitle => 'Calendar Overview';

  @override
  String chooseDay(Object date) {
    return 'Choose day: $date';
  }

  @override
  String noTasksForDay(Object date) {
    return 'No tasks for $date';
  }

  @override
  String get toolsPageTitle => 'Tools';

  @override
  String get flowTimerToolTitle => 'Flow Timer';

  @override
  String get tasksToolTitle => 'To-Do List';

  @override
  String get journalToolTitle => 'Journal';

  @override
  String get habitTrackerToolTitle => 'Habit Tracker';

  @override
  String get paywallTitle => 'Unlock Premium Tools';

  @override
  String get paywallContent => 'Get access to all premium features and tools to maximize your productivity and growth.';

  @override
  String get flowTimerBreakLabel => 'Break';

  @override
  String get autoStartBreak => 'Auto-Start Break';

  @override
  String get autoStartNextFlow => 'Auto-Start Next Flow';

  @override
  String get keepScreenOn => 'Keep screen on';

  @override
  String get onboardingAgeQuestion => 'How old are you?';

  @override
  String get continueButton => 'Continue';

  @override
  String get onboardingChatbotTitle => 'Chatbot Hardness Level';

  @override
  String get chatbotModeNormal => 'Normal';

  @override
  String get chatbotModeHard => 'Hard';

  @override
  String get chatbotModeBrutal => 'Brutally Honest';

  @override
  String get chatbotWarning => 'Warning: In the \"Brutally Honest\" mode, you will be insulted and challenged intensely.';

  @override
  String get onboardingFinishHeadline => 'YOU DID IT!';

  @override
  String get onboardingFinishSubheadline => 'Now the real grind begins. You’re ready to take control.';

  @override
  String get onboardingFinishButtonText => 'LET’S GO TO THE DASHBOARD!';

  @override
  String get onboardingGoalsQuestion => 'What are your goals?';

  @override
  String get goalFit => 'Get fitter';

  @override
  String get goalProductivity => 'Be more productive';

  @override
  String get goalSaveMoney => 'Save more money';

  @override
  String get goalBetterRelationships => 'Build better relationships';

  @override
  String get goalMentalHealth => 'Strengthen mental health';

  @override
  String get goalCareer => 'Advance your career';

  @override
  String get onboardingNameQuestion => 'What\'s your name?';

  @override
  String get nameHint => 'Your Name';

  @override
  String get nameEmptyWarning => 'Please enter your name.';

  @override
  String get onboardingNotificationHeadline => 'Take the first step';

  @override
  String get onboardingNotificationDescription => 'Imagine being reminded every day to be better than yesterday. Your goals, your tasks, your discipline – everything gets stronger because you do. Enable notifications now and let your inner Daimonion push you.';

  @override
  String get onboardingNotificationButtonText => 'Push me!';

  @override
  String get notificationActiveMessage => 'Notifications are now active! Let\'s get started.';

  @override
  String get notificationDeniedMessage => 'Notifications were denied. You can enable them later in settings.';

  @override
  String get onboardingNotificationNextChallenge => 'Continue to the next challenge';

  @override
  String get onboardingTodosTitle => 'Your First To-Dos';

  @override
  String get onboardingTodosSubheadline => 'Set up your first tasks. These to-dos will go directly into your main list.';

  @override
  String get newTodoHint => 'New Task...';

  @override
  String get addTodo => 'Add';

  @override
  String get noTodosAdded => 'No to-dos added yet.';

  @override
  String get dailyFundamentalsTitle => 'FUNDAMENTALS';

  @override
  String get shortCheckGym => 'Body';

  @override
  String get shortCheckMental => 'Mental';

  @override
  String get shortCheckNoPorn => 'No Porn';

  @override
  String get shortCheckHealthyEating => 'Healthy';

  @override
  String get shortCheckHelpOthers => 'Help';

  @override
  String get shortCheckNature => 'Nature';

  @override
  String get fullCheckGym => 'Did you do something for your body?';

  @override
  String get fullCheckMental => 'Did you do something mentally productive?';

  @override
  String get fullCheckNoPorn => 'Did you stay away from porn?';

  @override
  String get fullCheckHealthyEating => 'Did you eat healthy?';

  @override
  String get fullCheckHelpOthers => 'Did you do something good for others?';

  @override
  String get fullCheckNature => 'Did you spend time in nature today?';

  @override
  String get dailyInsultTitle => 'You messed up!';

  @override
  String get dailyInsultAllMissed => 'You ignored ALL fundamentals!';

  @override
  String dailyInsultSomeMissed(Object count) {
    return 'You missed $count fundamentals. That won\'t lead you anywhere!';
  }

  @override
  String get loadOffers => 'Load Offers';

  @override
  String get trainingPlanToolTitle => 'Training Plan';

  @override
  String get appTitle => 'Training Plan';

  @override
  String get workoutNameLabel => 'Workout Name';

  @override
  String get noExercisesMessage => 'No exercises added yet.';

  @override
  String get newExerciseHint => 'Enter new exercise';

  @override
  String get addExerciseSnackbar => 'Enter an exercise!';

  @override
  String get editExerciseTitle => 'Edit Exercise Details';

  @override
  String get setsLabel => 'Sets';

  @override
  String get repsLabel => 'Reps';

  @override
  String get weightLabel => 'Weight';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get getPremiumButton => 'Get Premium';

  @override
  String get title_progress => 'Your Progress';

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
    return '$percent% to Level $nextLevel';
  }

  @override
  String xp_text(Object xpProgress, Object xpToNextLevel) {
    return '$xpProgress / $xpToNextLevel XP';
  }

  @override
  String get motivation_text => 'Come on! Stop whining and show them what you\'re made of!';

  @override
  String get streak_info_title => 'Streak Info';

  @override
  String streak_days(Object streak) {
    return '$streak Days Streak';
  }

  @override
  String xp_bonus(Object bonusPercent) {
    return 'XP Bonus: $bonusPercent%';
  }

  @override
  String get streak_description => 'The longer you stay active daily, the more XP you earn! Your streak rewards consistency and helps you level up faster.';

  @override
  String get streak_rewards => '- 7+ days: +5% XP\\n- 14+ days: +10% XP\\n- 30+ days: +15% XP\\n';

  @override
  String get back_button => 'Back';

  @override
  String get levels_and_rankings => 'Levels and Rankings';

  @override
  String get how_to_earn_xp => 'How to earn XP and level up!';

  @override
  String get action => 'Action';

  @override
  String get xp => 'XP';

  @override
  String get max_per_day => 'Max/Day';

  @override
  String get complete_todo => 'Complete a To-Do';

  @override
  String get complete_habit => 'Complete a Habit';

  @override
  String get journal_entry => 'Write a Journal Entry';

  @override
  String get ten_min_flow => '10 min Flow';

  @override
  String get levels_and_ranks => 'Levels & Ranks';

  @override
  String get level => 'Level';

  @override
  String get rank => 'Rank';

  @override
  String get badge => 'Badge';

  @override
  String get recruit => 'Recruit';

  @override
  String get soldier => 'Soldier';

  @override
  String get elite_soldier => 'Elite Soldier';

  @override
  String get veteran => 'Veteran';

  @override
  String get sergeant => 'Sergeant';

  @override
  String get lieutenant => 'Lieutenant';

  @override
  String get captain => 'Captain';

  @override
  String get major => 'Major';

  @override
  String get colonel => 'Colonel';

  @override
  String get general => 'General';

  @override
  String get warlord => 'Warlord';

  @override
  String get daimonion_warlord => 'Daimonion Warlord';

  @override
  String get legend => 'Legend';

  @override
  String get immortal => 'Immortal';

  @override
  String get keep_grinding => 'Keep grinding!';

  @override
  String get back => 'Back';

  @override
  String get unlock_premium => 'Unlock Premium';

  @override
  String get premium_description => 'Subscribe to get full access to premium features';

  @override
  String get access_journal => 'Access to Journal Tool';

  @override
  String get access_habit_tracker => 'Access to Habit Tracker';

  @override
  String get unlimited_chat_prompts => 'Unlimited Chat Prompts';

  @override
  String get more_to_come => 'More to come!';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get weekly_price => '\$1.99/week';

  @override
  String get monthly_price => '\$3.99/month';

  @override
  String get yearly_price => '\$29.99/year';

  @override
  String get auto_renewal => 'Auto Renewal';

  @override
  String get subscription_disclaimer => 'Cancel anytime | Privacy Policy\nYour subscription will automatically renew. Cancel at least 24 hours before renewal on Google Play.';

  @override
  String get coming_soon => 'Coming Soon';

  @override
  String get coming_soon_description => 'This option will be available soon!';

  @override
  String get thank_you => 'Thank you!';

  @override
  String get premium_activated => 'Your premium subscription has been activated!';

  @override
  String get subscription_failed => 'Subscription could not be activated.';

  @override
  String get premium_not_available => 'Premium package not available.';

  @override
  String get feedbackButtonLabel => 'Feedback';

  @override
  String get noEmailClientFound => 'No email client found on this device.';

  @override
  String get habitReminderTitle => 'Habit Reminder';

  @override
  String get habitReminderChannelName => 'Habit Reminders';

  @override
  String get habitReminderChannelDescription => 'Reminds you about your habit daily.';

  @override
  String get dailyTodoChannelName => 'Daily Todo Reminder';

  @override
  String get dailyTodoChannelDesc => 'Reminds you to check your tasks daily at 20:00';

  @override
  String get todoReminderTitleNormal => 'Check your tasks!';

  @override
  String get todoReminderBodyNormal => 'Small steps lead you to your goal. Start now!';

  @override
  String get todoReminderTitleHard => 'Time to tackle your tasks!';

  @override
  String get todoReminderBodyHard => 'Show discipline and work on your vision. No excuses!';

  @override
  String get todoReminderTitleBrutal => 'What the hell are you doing?!';

  @override
  String get todoReminderBodyBrutal => 'Your tasks are waiting! Time to grind!';

  @override
  String get tasksForDay => 'Test';

  @override
  String get trainingPlan => 'Training Plan';

  @override
  String get workoutNameHint => 'Workout Name';

  @override
  String get kg => 'kg';

  @override
  String get sets => 'sets';

  @override
  String get reps => 'reps';

  @override
  String get tapToAddExercises => 'Tap to add exercises';

  @override
  String get exerciseName => 'Exercise Name';

  @override
  String get exerciseDetails => 'Exercise Details';

  @override
  String get notes => 'Notes';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get quickAdd => 'Quick Add';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get tapToAddDetails => 'Tap to add details';

  @override
  String get chooseWorkoutColor => 'Choose Workout Color';

  @override
  String get editWorkoutName => 'Edit Workout Name';

  @override
  String get exercises => 'exercises';

  @override
  String get upgradeForMoreFeatures => 'Upgrade for more features';

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get editDayTitle => 'Edit Day';

  @override
  String get newDayNameHint => 'New day name';

  @override
  String get noWorkoutName => 'No Workout Name';

  @override
  String get atLeastOneWorkoutDay => 'You need at least one workout day. Do something for your body!';

  @override
  String get newDay => 'New Day';

  @override
  String day(Object number) {
    return 'Day $number';
  }

  @override
  String get premium_label => 'PREMIUM';

  @override
  String get features_label => 'What\'s included:';

  @override
  String get weekly_label => 'Weekly';

  @override
  String get weekly_description => 'Try it out cheaply';

  @override
  String get monthly_label => 'Monthly';

  @override
  String get monthly_description => 'Save over 30%';

  @override
  String get yearly_label => 'Yearly';

  @override
  String get yearly_description => 'Save over 40%';

  @override
  String get most_popular_label => 'Popular';

  @override
  String get start_free_week_label => 'Start free week';

  @override
  String get error_title => 'Error';

  @override
  String get nameLabel => 'Name';

  @override
  String get restoringPurchases => 'Restoring purchases...';

  @override
  String get purchasesRestoredSuccess => 'Purchases restored successfully!';

  @override
  String get noPurchasesToRestore => 'No purchases to restore';

  @override
  String get purchasesRestoredError => 'Error restoring purchases';

  @override
  String get emailAppNotFound => 'No email app found';

  @override
  String get couldNotSendFeedback => 'Could not send feedback';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get comingSoonDescription => 'This feature will be available soon!';

  @override
  String get productivityCategory => 'Productivity';

  @override
  String get wellnessCategory => 'Wellness & Growth';

  @override
  String get flowTimerDescription => 'Stay focused with deep work sessions.';

  @override
  String get flowTimerHelp => 'Use the Flow Timer to break tasks into deep focus periods.';

  @override
  String get tasksDescription => 'Manage your tasks effectively.';

  @override
  String get tasksHelp => 'Plan your day with a simple and effective task list.';

  @override
  String get journalDescription => 'Track your thoughts and progress.';

  @override
  String get journalHelp => 'Write daily reflections and structure your thoughts in the journal.';

  @override
  String get habitTrackerDescription => 'Build and maintain strong habits.';

  @override
  String get habitTrackerHelp => 'Stay consistent with habit tracking for long-term success.';

  @override
  String get trainingPlanDescription => 'Optimize your workouts and track progress.';

  @override
  String get trainingPlanHelp => 'Use the Training Plan to follow a structured fitness routine.';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get helpDialogTitle => 'How to Use These Tools';

  @override
  String get gotIt => 'Got it';

  @override
  String get allHabits => 'All Habits';

  @override
  String get byCategory => 'By Category';

  @override
  String get addNewHabit => 'Add a New Habit';

  @override
  String get habitDeleted => 'Habit deleted';

  @override
  String get edit => 'Edit';

  @override
  String get undo => 'Undo';

  @override
  String get editHabitTitle => 'Edit Habit';

  @override
  String get habitNameLabel => 'Habit Name';

  @override
  String get repeatLabel => 'Repeat On';

  @override
  String get categoryLabel => 'Category';

  @override
  String get colorLabel => 'Choose a Color';

  @override
  String get setTime => 'Set Time';

  @override
  String get noReminderSet => 'No reminder set';

  @override
  String get update => 'Update';

  @override
  String get deleteHabitConfirmation => 'Are you sure you want to delete';

  @override
  String get emptyNameError => 'Please enter a habit name.';

  @override
  String get noDaysSelectedError => 'Please select at least one day.';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get health => 'Health';

  @override
  String get productivity => 'Productivity';

  @override
  String get learning => 'Learning';

  @override
  String get personal => 'Personal';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get mondayShort => 'Mo';

  @override
  String get tuesdayShort => 'Tu';

  @override
  String get wednesdayShort => 'We';

  @override
  String get thursdayShort => 'Th';

  @override
  String get fridayShort => 'Fr';

  @override
  String get saturdayShort => 'Sa';

  @override
  String get sundayShort => 'Su';

  @override
  String get highPriority => 'High';

  @override
  String get mediumPriority => 'Medium';

  @override
  String get lowPriority => 'Low';

  @override
  String get noPriority => 'No Priority';

  @override
  String get viewAll => 'View all';

  @override
  String get addNewTask => 'Add New Task';

  @override
  String get moreTasks => 'more tasks...';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get upgradeToUnlock => 'Upgrade to unlock this feature and boost your growth.';

  @override
  String get notNow => 'Not now';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get motivationalInsults => 'Why are you slacking, soldier? Get back on track!||No excuses, get your work done!||You want to be great? Then act like it!||Losers procrastinate. Winners execute. Which one are you?';

  @override
  String get iWillDoIt => 'I\'ll do it!';

  @override
  String get tapToRefresh => 'Tap to refresh';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String get goPremium => 'Go Premium';

  @override
  String get dailyProgress => 'Daily Progress';

  @override
  String get viewStats => 'View Stats';

  @override
  String get understood => 'Got it';

  @override
  String get typeMessage => 'Type a message ...';

  @override
  String get you => 'You';

  @override
  String get userStats => 'Your Statistics';

  @override
  String get detailedUserStats => 'Detailed statistics about your productivity, streaks, and progress will be displayed here.';

  @override
  String get pauseTimer => 'Pause';

  @override
  String get startTimer => 'Start';

  @override
  String get allTasksCompleted => 'Great job! You\'ve completed all your tasks!';

  @override
  String get aboutStatistics => 'About Statistics';

  @override
  String get aboutStatisticsContent => 'This page shows your task completion statistics. The calendar view displays daily completion rates, while the analytics tab provides weekly progress and monthly summaries.';

  @override
  String get calendarTab => 'Calendar';

  @override
  String get analyticsTab => 'Analytics';

  @override
  String get totalTasks => 'Total Tasks';

  @override
  String get completed => 'Completed';

  @override
  String get pending => 'Pending';

  @override
  String get taskCompletionTrends => 'Task Completion Trends';

  @override
  String get monthlyOverview => 'Monthly Overview';

  @override
  String get productivityScore => 'Productivity Score';

  @override
  String get newLabel => 'NEW';

  @override
  String completedTasksPercentage(Object percentage) {
    return 'You\'ve completed $percentage% of your tasks this month!';
  }

  @override
  String get noTasksScheduled => 'No tasks scheduled for this month yet.';

  @override
  String completeMoreTasks(Object pending) {
    return 'Complete $pending more tasks to reach 100%';
  }

  @override
  String get startAddingTasks => 'Start adding tasks to track your productivity.';

  @override
  String taskLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tasks',
      one: 'task',
    );
    return '$_temp0';
  }

  @override
  String get totalTime => 'Total Time';

  @override
  String get avgDuration => 'Avg Duration';

  @override
  String get flowConsistency => 'Flow Consistency';

  @override
  String get dailyFlowMinutes => 'Daily Flow Minutes';

  @override
  String get weeklyFlowMinutes => 'Weekly Flow Minutes';

  @override
  String get monthlyFlowMinutes => 'Monthly Flow Minutes';

  @override
  String get flowMinutes => 'Flow Minutes';

  @override
  String get improving => 'Improving';

  @override
  String get declining => 'Declining';

  @override
  String get stable => 'Stable';

  @override
  String get infoTitle => 'Flow Statistics Help';

  @override
  String get infoContent => 'This screen shows analytics for your flow sessions. Here you can track your progress and see your performance over time.';

  @override
  String get helpTimeFiltersTitle => 'Time Filters';

  @override
  String get helpTimeFiltersDescription => 'Switch between week, month, and year views to see different time periods.';

  @override
  String get helpBarChartTitle => 'Bar Chart';

  @override
  String get helpBarChartDescription => 'Each bar represents the flow minutes for a day, week, or month based on your selected filter.';

  @override
  String get helpWeeklyGoalTitle => 'Weekly Goal';

  @override
  String get helpWeeklyGoalDescription => 'Track your progress toward your weekly flow goal of 300 minutes.';

  @override
  String get helpTrendIndicatorTitle => 'Trend Indicator';

  @override
  String get helpTrendIndicatorDescription => 'Shows whether your flow time is improving, declining, or stable compared to the previous period.';

  @override
  String get dailyReminderTitle => 'Daily Reminder';

  @override
  String get dailyReminderBody => 'Don\'t forget to complete your tasks for today!';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get addPoints => 'You earned 2 XP for completing the task!';

  @override
  String get taskAdded => 'Task added';

  @override
  String get changeDate => 'Change date';

  @override
  String get taskNotesLabel => 'Task notes';

  @override
  String get emptyTitleError => 'The title cannot be empty!';

  @override
  String get taskCompletedMessage => 'Task successfully completed!';

  @override
  String get updateTask => 'Update task';

  @override
  String get taskUpdatedMessage => 'Task has been updated';

  @override
  String get taskDetails => 'Task details';

  @override
  String get description => 'Description';

  @override
  String get deadline => 'Deadline';

  @override
  String get priority => 'Priority';

  @override
  String get notCompleted => 'Not completed';

  @override
  String get tags => 'Tags';

  @override
  String get quoteShared => 'Quote shared!';

  @override
  String get favoriteTooltip => 'Mark as favorite';

  @override
  String get shareTooltip => 'Share';

  @override
  String get doubleTapToFavorite => 'Double tap to favorite';

  @override
  String get currency_symbol => '\$';

  @override
  String get view_all_premium_benefits => 'View all premium benefits';

  @override
  String get premium_benefit_unlimited_chat => 'Unlimited chat requests for your Daimonion';

  @override
  String get premium_benefit_no_ads => 'No advertisements';

  @override
  String get premium_benefit_journal_access => 'Access to journal';

  @override
  String get premium_benefit_habit_tracker_access => 'Access to habit tracker';

  @override
  String get premium_benefit_todo_advanced => 'Access to advanced features in to-do list';

  @override
  String get premium_benefit_training_advanced => 'Access to advanced features in training plan';

  @override
  String get premium_benefit_flow_stats => 'Detailed statistics for flow timer';

  @override
  String get premium_benefit_tags_stats => 'Detailed statistics for tasks';

  @override
  String get hardnessSubtitle => 'Choose how direct the feedback should be';

  @override
  String get hardnessNormalDesc => 'Normal feedback with constructive suggestions';

  @override
  String get hardnessHardDesc => 'Challenging feedback that pushes your limits';

  @override
  String get hardnessBrutalDesc => 'No-nonsense, raw and unfiltered truth';

  @override
  String get stats => 'Stats';

  @override
  String get feedback => 'Feedback';

  @override
  String get levelAndXp => 'Level & XP';

  @override
  String get levelAndXpSubtitle => 'View your progress statistics';

  @override
  String get helpImproveDaimonion => 'Help us improve Daimonion';

  @override
  String get privacyAndTermsSubtitle => 'Privacy policy and terms of service';

  @override
  String get currentAppVersion => 'Current App Version';

  @override
  String get upgradeToPremiumSubtitle => 'Get access to all premium features';

  @override
  String get restorePurchasesSubtitle => 'Restore your previous purchases';

  @override
  String get imageSelectError => 'Could not select image';

  @override
  String levelNumber(Object level) {
    return 'Lvl $level';
  }

  @override
  String progressToNextLevel(Object progress) {
    return '$progress% to next level';
  }

  @override
  String get feedbackEmailSubject => 'Feedback for Daimonion';

  @override
  String get feedbackEmailBody => 'I would like to provide the following feedback:';

  @override
  String get motivationalMessage0 => 'Start your daily habits! Take the first step today.';

  @override
  String get motivationalMessageLessThan3 => 'You\'ve made a good start! Keep going!';

  @override
  String get motivationalMessageLessThan5 => 'Almost there! Just a few more to complete today\'s goals.';

  @override
  String get motivationalMessageAllCompleted => 'Amazing job! You\'ve completed all your daily habits!';
}
