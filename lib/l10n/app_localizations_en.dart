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
  String get todaysTasks => 'TODAY\'S TASKS';

  @override
  String get noTasksToday => 'No tasks for today';

  @override
  String get tasks => 'Tasks';

  @override
  String get habits => 'Habits';

  @override
  String get weeklyProgress => 'WEEKLY PROGRESS';

  @override
  String get premiumRequired => 'Premium Required';

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
  String get flowStatsTitle => 'Flow Stats';

  @override
  String get filterWeek => 'Week';

  @override
  String get filterMonth => 'Month';

  @override
  String get filterYear => 'Year';

  @override
  String get noDataMessage => 'No data for this period';

  @override
  String get statFlows => 'Flows';

  @override
  String get statTotalMinutes => 'Total Minutes';

  @override
  String get statAverageFlow => 'Avg Time per Flow (Min)';

  @override
  String get statAverageWeeklyFlow => 'Avg Time per Week (Min)';

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
  String get todayLabel => 'Today:';

  @override
  String get noHabitsMessage => 'No habits yet';

  @override
  String get habitHeader => 'Habit';

  @override
  String get newHabitTitle => 'New Habit';

  @override
  String get newHabitNameHint => 'Name';

  @override
  String get reminderLabel => 'Reminder (optional):';

  @override
  String get noReminder => 'None';

  @override
  String get deleteHabitTitle => 'Delete?';

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
  String get profileHeader => 'WHO COULD YOU BE?';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get editProfile => 'Edit';

  @override
  String get editProfileTitle => 'Edit Name';

  @override
  String get editProfileHint => 'Your Name';

  @override
  String get save => 'Save';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get hardnessTitle => 'Hardness';

  @override
  String get hardnessNormal => 'Normal';

  @override
  String get hardnessHard => 'Hard';

  @override
  String get hardnessBrutal => 'Brutally Honest';

  @override
  String get legalAndAppInfoTitle => 'LEGAL & APP INFO';

  @override
  String get privacyAndTerms => 'Privacy & Terms of Use';

  @override
  String get version => 'Version';

  @override
  String get accountTitle => 'ACCOUNT';

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
  String get premiumRestored => 'Premium restored!';

  @override
  String get noActivePurchases => 'No active purchases found.';

  @override
  String restoreError(Object error) {
    return 'Restore error: $error';
  }

  @override
  String get selectHardness => 'Select Hardness';

  @override
  String get hardnessQuestion => 'HOW HARD SHOULD I BE TO YOU?';

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
  String get toolsPageTitle => 'Your Tools for Victory';

  @override
  String get flowTimerToolTitle => 'Flow Timer';

  @override
  String get tasksToolTitle => 'Tasks';

  @override
  String get journalToolTitle => 'Journal';

  @override
  String get habitTrackerToolTitle => 'Habit Tracker';

  @override
  String get paywallTitle => 'Premium Required';

  @override
  String get paywallContent => 'This tool is only available for premium members.';

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
  String get noExercisesMessage => 'No exercises added.\nStart building your workout!';

  @override
  String get newExerciseHint => 'Enter new exercise...';

  @override
  String get addExerciseSnackbar => 'Enter an exercise!';

  @override
  String get editExerciseTitle => 'Edit Exercise Details';

  @override
  String get setsLabel => 'Sets';

  @override
  String get repsLabel => 'Reps';

  @override
  String get weightLabel => 'Weight (kg)';

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
  String get feedbackButtonLabel => 'Send Feedback';

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
}
