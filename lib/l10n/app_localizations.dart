import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FitTrack'**
  String get appTitle;

  /// No description provided for @workoutDashboard.
  ///
  /// In en, this message translates to:
  /// **'Workout Dashboard'**
  String get workoutDashboard;

  /// No description provided for @currentDate.
  ///
  /// In en, this message translates to:
  /// **'Tuesday, June 24th, 2025'**
  String get currentDate;

  /// No description provided for @todaysWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get todaysWorkout;

  /// No description provided for @keepMomentum.
  ///
  /// In en, this message translates to:
  /// **'Keep the momentum'**
  String get keepMomentum;

  /// No description provided for @totalSessions.
  ///
  /// In en, this message translates to:
  /// **'Total Sessions'**
  String get totalSessions;

  /// No description provided for @consistencyMatters.
  ///
  /// In en, this message translates to:
  /// **'Consistency matters'**
  String get consistencyMatters;

  /// No description provided for @timeInvested.
  ///
  /// In en, this message translates to:
  /// **'Time Invested'**
  String get timeInvested;

  /// No description provided for @yourDedication.
  ///
  /// In en, this message translates to:
  /// **'Your dedication'**
  String get yourDedication;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories Burned'**
  String get caloriesBurned;

  /// No description provided for @energyTransformed.
  ///
  /// In en, this message translates to:
  /// **'Energy transformed'**
  String get energyTransformed;

  /// No description provided for @todaysIntake.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Intake'**
  String get todaysIntake;

  /// No description provided for @caloriesConsumed.
  ///
  /// In en, this message translates to:
  /// **'Calories consumed'**
  String get caloriesConsumed;

  /// No description provided for @weeklyWorkoutDuration.
  ///
  /// In en, this message translates to:
  /// **'Weekly Workout Duration'**
  String get weeklyWorkoutDuration;

  /// No description provided for @weeklyNutritionIntake.
  ///
  /// In en, this message translates to:
  /// **'Weekly Nutrition Intake'**
  String get weeklyNutritionIntake;

  /// No description provided for @recentWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Recent Workouts'**
  String get recentWorkouts;

  /// No description provided for @squat.
  ///
  /// In en, this message translates to:
  /// **'Squat'**
  String get squat;

  /// No description provided for @benchPress.
  ///
  /// In en, this message translates to:
  /// **'Bench Press'**
  String get benchPress;

  /// No description provided for @deadlift.
  ///
  /// In en, this message translates to:
  /// **'Deadlift'**
  String get deadlift;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// No description provided for @aiFeaturePreparing.
  ///
  /// In en, this message translates to:
  /// **'AI feature is under preparation'**
  String get aiFeaturePreparing;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fat;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @workoutManager.
  ///
  /// In en, this message translates to:
  /// **'Workout Manager'**
  String get workoutManager;

  /// No description provided for @trackFitnessJourney.
  ///
  /// In en, this message translates to:
  /// **'Track your fitness journey and build consistency'**
  String get trackFitnessJourney;

  /// No description provided for @thisWeekStatistics.
  ///
  /// In en, this message translates to:
  /// **'This Week Statistics'**
  String get thisWeekStatistics;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @avgDuration.
  ///
  /// In en, this message translates to:
  /// **'Avg Duration'**
  String get avgDuration;

  /// No description provided for @exerciseProgress.
  ///
  /// In en, this message translates to:
  /// **'Exercise Progress'**
  String get exerciseProgress;

  /// No description provided for @selectExercise.
  ///
  /// In en, this message translates to:
  /// **'Select exercise'**
  String get selectExercise;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume (kg × sets × reps)'**
  String get totalVolume;

  /// No description provided for @workoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistory;

  /// No description provided for @selectExerciseToViewProgress.
  ///
  /// In en, this message translates to:
  /// **'Please select an exercise to view progress'**
  String get selectExerciseToViewProgress;

  /// No description provided for @cardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// No description provided for @flexibility.
  ///
  /// In en, this message translates to:
  /// **'Flexibility'**
  String get flexibility;

  /// No description provided for @pushUp.
  ///
  /// In en, this message translates to:
  /// **'Push Up'**
  String get pushUp;

  /// No description provided for @pullUp.
  ///
  /// In en, this message translates to:
  /// **'Pull Up'**
  String get pullUp;

  /// No description provided for @plank.
  ///
  /// In en, this message translates to:
  /// **'Plank'**
  String get plank;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @cycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get cycling;

  /// No description provided for @swimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get swimming;

  /// No description provided for @yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// No description provided for @stretching.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get stretching;

  /// No description provided for @workoutPrograms.
  ///
  /// In en, this message translates to:
  /// **'Workout Programs'**
  String get workoutPrograms;

  /// No description provided for @workoutProgramsDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover proven workout routines from top trainers and bodybuilders. Find the perfect program to achieve your fitness goals.'**
  String get workoutProgramsDesc;

  /// No description provided for @totalPrograms.
  ///
  /// In en, this message translates to:
  /// **'Total Programs'**
  String get totalPrograms;

  /// No description provided for @popularPrograms.
  ///
  /// In en, this message translates to:
  /// **'Popular Programs'**
  String get popularPrograms;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @avgWeeks.
  ///
  /// In en, this message translates to:
  /// **'Avg Weeks'**
  String get avgWeeks;

  /// No description provided for @searchProgramsHint.
  ///
  /// In en, this message translates to:
  /// **'Search programs, creators, or keywords...'**
  String get searchProgramsHint;

  /// No description provided for @allLevels.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get allLevels;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// No description provided for @allDurations.
  ///
  /// In en, this message translates to:
  /// **'All Durations'**
  String get allDurations;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @powerlifting.
  ///
  /// In en, this message translates to:
  /// **'Powerlifting'**
  String get powerlifting;

  /// No description provided for @bodybuilding.
  ///
  /// In en, this message translates to:
  /// **'Bodybuilding'**
  String get bodybuilding;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @equipmentNeeded.
  ///
  /// In en, this message translates to:
  /// **'Equipment needed:'**
  String get equipmentNeeded;

  /// No description provided for @viewProgram.
  ///
  /// In en, this message translates to:
  /// **'View Program'**
  String get viewProgram;

  /// No description provided for @noProgramsFound.
  ///
  /// In en, this message translates to:
  /// **'No programs found.'**
  String get noProgramsFound;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get by;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @startProgram.
  ///
  /// In en, this message translates to:
  /// **'Start Program'**
  String get startProgram;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get weeklySchedule;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @routine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routine;

  /// No description provided for @diet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get diet;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get reps;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @exerciseAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get exerciseAdd;

  /// No description provided for @exerciseSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get exerciseSearchHint;

  /// No description provided for @exerciseQuickFilters.
  ///
  /// In en, this message translates to:
  /// **'Quick Filters'**
  String get exerciseQuickFilters;

  /// No description provided for @exerciseAdvancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get exerciseAdvancedFilters;

  /// No description provided for @exercisePopular.
  ///
  /// In en, this message translates to:
  /// **'Popular Exercises'**
  String get exercisePopular;

  /// No description provided for @exerciseList.
  ///
  /// In en, this message translates to:
  /// **'Exercise List'**
  String get exerciseList;

  /// No description provided for @exerciseFound.
  ///
  /// In en, this message translates to:
  /// **'found'**
  String get exerciseFound;

  /// No description provided for @exerciseCreateCustom.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Exercise'**
  String get exerciseCreateCustom;

  /// No description provided for @exerciseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter exercise name...'**
  String get exerciseEnterName;

  /// No description provided for @remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get remember_me;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password;

  /// No description provided for @sign_up_with_email.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Email'**
  String get sign_up_with_email;

  /// No description provided for @login_with_email.
  ///
  /// In en, this message translates to:
  /// **'Login with Email'**
  String get login_with_email;

  /// No description provided for @or_continue_with.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get or_continue_with;

  /// No description provided for @terms_agreement.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our Terms and Privacy Policy.'**
  String get terms_agreement;

  /// No description provided for @registration_successful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registration_successful;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups'**
  String get myGroups;

  /// No description provided for @publicGroups.
  ///
  /// In en, this message translates to:
  /// **'Public Groups'**
  String get publicGroups;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get joinGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @groupDescription.
  ///
  /// In en, this message translates to:
  /// **'Group Description'**
  String get groupDescription;

  /// No description provided for @groupPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Group Privacy'**
  String get groupPrivacy;

  /// No description provided for @publicGroup.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicGroup;

  /// No description provided for @privateGroup.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateGroup;

  /// No description provided for @maxMembers.
  ///
  /// In en, this message translates to:
  /// **'Max Members'**
  String get maxMembers;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get inviteCode;

  /// No description provided for @groupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group created successfully!'**
  String get groupCreated;

  /// No description provided for @groupJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined group successfully!'**
  String get groupJoined;

  /// No description provided for @groupLeft.
  ///
  /// In en, this message translates to:
  /// **'Left group successfully!'**
  String get groupLeft;

  /// No description provided for @groupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Group deleted successfully!'**
  String get groupDeleted;

  /// No description provided for @groupNotFound.
  ///
  /// In en, this message translates to:
  /// **'Group not found'**
  String get groupNotFound;

  /// No description provided for @groupFull.
  ///
  /// In en, this message translates to:
  /// **'Group is full'**
  String get groupFull;

  /// No description provided for @invalidInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired invite code'**
  String get invalidInviteCode;

  /// No description provided for @insufficientPermissions.
  ///
  /// In en, this message translates to:
  /// **'Insufficient permissions'**
  String get insufficientPermissions;

  /// No description provided for @groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Group Members'**
  String get groupMembers;

  /// No description provided for @groupAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get groupAdmin;

  /// No description provided for @groupModerator.
  ///
  /// In en, this message translates to:
  /// **'Moderator'**
  String get groupModerator;

  /// No description provided for @groupMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupMember;

  /// No description provided for @removeFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove from Group'**
  String get removeFromGroup;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get deleteGroup;

  /// No description provided for @groupSettings.
  ///
  /// In en, this message translates to:
  /// **'Group Settings'**
  String get groupSettings;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get editGroup;

  /// No description provided for @shareGroup.
  ///
  /// In en, this message translates to:
  /// **'Share Group'**
  String get shareGroup;

  /// No description provided for @copyInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Invite Link'**
  String get copyInviteLink;

  /// No description provided for @inviteLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied to clipboard!'**
  String get inviteLinkCopied;

  /// No description provided for @groupActivity.
  ///
  /// In en, this message translates to:
  /// **'Group Activity'**
  String get groupActivity;

  /// No description provided for @activityFeed.
  ///
  /// In en, this message translates to:
  /// **'Activity Feed'**
  String get activityFeed;

  /// No description provided for @shareRoutine.
  ///
  /// In en, this message translates to:
  /// **'Share Routine'**
  String get shareRoutine;

  /// No description provided for @sharedRoutine.
  ///
  /// In en, this message translates to:
  /// **'Shared Routine'**
  String get sharedRoutine;

  /// No description provided for @routineShared.
  ///
  /// In en, this message translates to:
  /// **'Routine shared successfully!'**
  String get routineShared;

  /// No description provided for @copyRoutine.
  ///
  /// In en, this message translates to:
  /// **'Copy Routine'**
  String get copyRoutine;

  /// No description provided for @routineCopied.
  ///
  /// In en, this message translates to:
  /// **'Routine copied successfully!'**
  String get routineCopied;

  /// No description provided for @workoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workout Completed'**
  String get workoutCompleted;

  /// No description provided for @encourageMembers.
  ///
  /// In en, this message translates to:
  /// **'Encourage Members'**
  String get encourageMembers;

  /// No description provided for @sendEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Send Encouragement'**
  String get sendEncouragement;

  /// No description provided for @encouragementSent.
  ///
  /// In en, this message translates to:
  /// **'Encouragement sent!'**
  String get encouragementSent;

  /// No description provided for @workoutSession.
  ///
  /// In en, this message translates to:
  /// **'Workout Session'**
  String get workoutSession;

  /// No description provided for @completedWorkout.
  ///
  /// In en, this message translates to:
  /// **'completed a workout'**
  String get completedWorkout;

  /// No description provided for @sharedARoutine.
  ///
  /// In en, this message translates to:
  /// **'shared a routine'**
  String get sharedARoutine;

  /// No description provided for @joinedGroup.
  ///
  /// In en, this message translates to:
  /// **'joined the group'**
  String get joinedGroup;

  /// No description provided for @leftGroup.
  ///
  /// In en, this message translates to:
  /// **'left the group'**
  String get leftGroup;

  /// No description provided for @noActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities yet'**
  String get noActivities;

  /// No description provided for @loadMoreActivities.
  ///
  /// In en, this message translates to:
  /// **'Load More Activities'**
  String get loadMoreActivities;

  /// No description provided for @groupChat.
  ///
  /// In en, this message translates to:
  /// **'Group Chat'**
  String get groupChat;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @messageReactions.
  ///
  /// In en, this message translates to:
  /// **'Message Reactions'**
  String get messageReactions;

  /// No description provided for @replyToMessage.
  ///
  /// In en, this message translates to:
  /// **'Reply to Message'**
  String get replyToMessage;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessage;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// No description provided for @typingIndicator.
  ///
  /// In en, this message translates to:
  /// **'is typing...'**
  String get typingIndicator;

  /// No description provided for @onlineMembers.
  ///
  /// In en, this message translates to:
  /// **'Online Members'**
  String get onlineMembers;

  /// No description provided for @offlineMembers.
  ///
  /// In en, this message translates to:
  /// **'Offline Members'**
  String get offlineMembers;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @messageDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get messageDelivered;

  /// No description provided for @messageRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get messageRead;

  /// No description provided for @communityBoard.
  ///
  /// In en, this message translates to:
  /// **'Community Board'**
  String get communityBoard;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Title'**
  String get postTitle;

  /// No description provided for @postContent.
  ///
  /// In en, this message translates to:
  /// **'Post Content'**
  String get postContent;

  /// No description provided for @postCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get postCategory;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @postTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get postTags;

  /// No description provided for @addTags.
  ///
  /// In en, this message translates to:
  /// **'Add Tags'**
  String get addTags;

  /// No description provided for @uploadMedia.
  ///
  /// In en, this message translates to:
  /// **'Upload Media'**
  String get uploadMedia;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @uploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload Video'**
  String get uploadVideo;

  /// No description provided for @postCreated.
  ///
  /// In en, this message translates to:
  /// **'Post created successfully!'**
  String get postCreated;

  /// No description provided for @postUpdated.
  ///
  /// In en, this message translates to:
  /// **'Post updated successfully!'**
  String get postUpdated;

  /// No description provided for @postDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted successfully!'**
  String get postDeleted;

  /// No description provided for @likePost.
  ///
  /// In en, this message translates to:
  /// **'Like Post'**
  String get likePost;

  /// No description provided for @dislikePost.
  ///
  /// In en, this message translates to:
  /// **'Dislike Post'**
  String get dislikePost;

  /// No description provided for @commentOnPost.
  ///
  /// In en, this message translates to:
  /// **'Comment on Post'**
  String get commentOnPost;

  /// No description provided for @sharePost.
  ///
  /// In en, this message translates to:
  /// **'Share Post'**
  String get sharePost;

  /// No description provided for @bookmarkPost.
  ///
  /// In en, this message translates to:
  /// **'Bookmark Post'**
  String get bookmarkPost;

  /// No description provided for @reportPost.
  ///
  /// In en, this message translates to:
  /// **'Report Post'**
  String get reportPost;

  /// No description provided for @postReported.
  ///
  /// In en, this message translates to:
  /// **'Post reported successfully'**
  String get postReported;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get addComment;

  /// No description provided for @replyToComment.
  ///
  /// In en, this message translates to:
  /// **'Reply to Comment'**
  String get replyToComment;

  /// No description provided for @editComment.
  ///
  /// In en, this message translates to:
  /// **'Edit Comment'**
  String get editComment;

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteComment;

  /// No description provided for @commentAdded.
  ///
  /// In en, this message translates to:
  /// **'Comment added successfully!'**
  String get commentAdded;

  /// No description provided for @commentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Comment updated successfully!'**
  String get commentUpdated;

  /// No description provided for @commentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Comment deleted successfully!'**
  String get commentDeleted;

  /// No description provided for @viewComments.
  ///
  /// In en, this message translates to:
  /// **'View Comments'**
  String get viewComments;

  /// No description provided for @hideComments.
  ///
  /// In en, this message translates to:
  /// **'Hide Comments'**
  String get hideComments;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// No description provided for @loadMoreComments.
  ///
  /// In en, this message translates to:
  /// **'Load More Comments'**
  String get loadMoreComments;

  /// No description provided for @searchPosts.
  ///
  /// In en, this message translates to:
  /// **'Search Posts'**
  String get searchPosts;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// No description provided for @sortByLatest.
  ///
  /// In en, this message translates to:
  /// **'Sort by Latest'**
  String get sortByLatest;

  /// No description provided for @sortByPopular.
  ///
  /// In en, this message translates to:
  /// **'Sort by Popular'**
  String get sortByPopular;

  /// No description provided for @sortByMostLiked.
  ///
  /// In en, this message translates to:
  /// **'Sort by Most Liked'**
  String get sortByMostLiked;

  /// No description provided for @noPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get noPosts;

  /// No description provided for @loadMorePosts.
  ///
  /// In en, this message translates to:
  /// **'Load More Posts'**
  String get loadMorePosts;

  /// No description provided for @ranking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get ranking;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @myScore.
  ///
  /// In en, this message translates to:
  /// **'My Score'**
  String get myScore;

  /// No description provided for @groupRanking.
  ///
  /// In en, this message translates to:
  /// **'Group Ranking'**
  String get groupRanking;

  /// No description provided for @userScore.
  ///
  /// In en, this message translates to:
  /// **'User Score'**
  String get userScore;

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get totalScore;

  /// No description provided for @bodyBalanceScore.
  ///
  /// In en, this message translates to:
  /// **'Body Balance Score'**
  String get bodyBalanceScore;

  /// No description provided for @volumeScore.
  ///
  /// In en, this message translates to:
  /// **'Volume Score'**
  String get volumeScore;

  /// No description provided for @progressScore.
  ///
  /// In en, this message translates to:
  /// **'Progress Score'**
  String get progressScore;

  /// No description provided for @consistencyScore.
  ///
  /// In en, this message translates to:
  /// **'Consistency Score'**
  String get consistencyScore;

  /// No description provided for @bodyPartScores.
  ///
  /// In en, this message translates to:
  /// **'Body Part Scores'**
  String get bodyPartScores;

  /// No description provided for @chestScore.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chestScore;

  /// No description provided for @backScore.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backScore;

  /// No description provided for @legsScore.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legsScore;

  /// No description provided for @shouldersScore.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shouldersScore;

  /// No description provided for @armsScore.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get armsScore;

  /// No description provided for @coreScore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get coreScore;

  /// No description provided for @weeklyRanking.
  ///
  /// In en, this message translates to:
  /// **'Weekly Ranking'**
  String get weeklyRanking;

  /// No description provided for @monthlyRanking.
  ///
  /// In en, this message translates to:
  /// **'Monthly Ranking'**
  String get monthlyRanking;

  /// No description provided for @dailyRanking.
  ///
  /// In en, this message translates to:
  /// **'Daily Ranking'**
  String get dailyRanking;

  /// No description provided for @rankingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Ranking Period'**
  String get rankingPeriod;

  /// No description provided for @currentRank.
  ///
  /// In en, this message translates to:
  /// **'Current Rank'**
  String get currentRank;

  /// No description provided for @previousRank.
  ///
  /// In en, this message translates to:
  /// **'Previous Rank'**
  String get previousRank;

  /// No description provided for @rankImproved.
  ///
  /// In en, this message translates to:
  /// **'Rank Improved!'**
  String get rankImproved;

  /// No description provided for @rankDeclined.
  ///
  /// In en, this message translates to:
  /// **'Rank Declined'**
  String get rankDeclined;

  /// No description provided for @scoreAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Score Analysis'**
  String get scoreAnalysis;

  /// No description provided for @detailedAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Detailed Analysis'**
  String get detailedAnalysis;

  /// No description provided for @scoreBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Score Breakdown'**
  String get scoreBreakdown;

  /// No description provided for @performanceTrends.
  ///
  /// In en, this message translates to:
  /// **'Performance Trends'**
  String get performanceTrends;

  /// No description provided for @memberComparison.
  ///
  /// In en, this message translates to:
  /// **'Member Comparison'**
  String get memberComparison;

  /// No description provided for @groupStats.
  ///
  /// In en, this message translates to:
  /// **'Group Stats'**
  String get groupStats;

  /// No description provided for @averageGroupScore.
  ///
  /// In en, this message translates to:
  /// **'Average Group Score'**
  String get averageGroupScore;

  /// No description provided for @topPerformer.
  ///
  /// In en, this message translates to:
  /// **'Top Performer'**
  String get topPerformer;

  /// No description provided for @mostImproved.
  ///
  /// In en, this message translates to:
  /// **'Most Improved'**
  String get mostImproved;

  /// No description provided for @mostConsistent.
  ///
  /// In en, this message translates to:
  /// **'Most Consistent'**
  String get mostConsistent;

  /// No description provided for @ptDietDashboard.
  ///
  /// In en, this message translates to:
  /// **'PT Diet Dashboard'**
  String get ptDietDashboard;

  /// No description provided for @memberDiets.
  ///
  /// In en, this message translates to:
  /// **'Member Diets'**
  String get memberDiets;

  /// No description provided for @dietSummary.
  ///
  /// In en, this message translates to:
  /// **'Diet Summary'**
  String get dietSummary;

  /// No description provided for @dailyCalories.
  ///
  /// In en, this message translates to:
  /// **'Daily Calories'**
  String get dailyCalories;

  /// No description provided for @calorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Calorie Goal'**
  String get calorieGoal;

  /// No description provided for @proteinIntake.
  ///
  /// In en, this message translates to:
  /// **'Protein Intake'**
  String get proteinIntake;

  /// No description provided for @carbIntake.
  ///
  /// In en, this message translates to:
  /// **'Carb Intake'**
  String get carbIntake;

  /// No description provided for @fatIntake.
  ///
  /// In en, this message translates to:
  /// **'Fat Intake'**
  String get fatIntake;

  /// No description provided for @mealCount.
  ///
  /// In en, this message translates to:
  /// **'Meal Count'**
  String get mealCount;

  /// No description provided for @lastMealTime.
  ///
  /// In en, this message translates to:
  /// **'Last Meal Time'**
  String get lastMealTime;

  /// No description provided for @dietFeedback.
  ///
  /// In en, this message translates to:
  /// **'Diet Feedback'**
  String get dietFeedback;

  /// No description provided for @addFeedback.
  ///
  /// In en, this message translates to:
  /// **'Add Feedback'**
  String get addFeedback;

  /// No description provided for @feedbackType.
  ///
  /// In en, this message translates to:
  /// **'Feedback Type'**
  String get feedbackType;

  /// No description provided for @positiveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get positiveFeedback;

  /// No description provided for @suggestionFeedback.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestionFeedback;

  /// No description provided for @concernFeedback.
  ///
  /// In en, this message translates to:
  /// **'Concern'**
  String get concernFeedback;

  /// No description provided for @feedbackText.
  ///
  /// In en, this message translates to:
  /// **'Feedback Text'**
  String get feedbackText;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent successfully!'**
  String get feedbackSent;

  /// No description provided for @dietAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Diet Analysis'**
  String get dietAnalysis;

  /// No description provided for @weeklyTrends.
  ///
  /// In en, this message translates to:
  /// **'Weekly Trends'**
  String get weeklyTrends;

  /// No description provided for @monthlyTrends.
  ///
  /// In en, this message translates to:
  /// **'Monthly Trends'**
  String get monthlyTrends;

  /// No description provided for @goalAchievement.
  ///
  /// In en, this message translates to:
  /// **'Goal Achievement'**
  String get goalAchievement;

  /// No description provided for @nutritionBalance.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Balance'**
  String get nutritionBalance;

  /// No description provided for @dietPermissions.
  ///
  /// In en, this message translates to:
  /// **'Diet Permissions'**
  String get dietPermissions;

  /// No description provided for @viewMeals.
  ///
  /// In en, this message translates to:
  /// **'View Meals'**
  String get viewMeals;

  /// No description provided for @viewPhotos.
  ///
  /// In en, this message translates to:
  /// **'View Photos'**
  String get viewPhotos;

  /// No description provided for @viewNutrition.
  ///
  /// In en, this message translates to:
  /// **'View Nutrition'**
  String get viewNutrition;

  /// No description provided for @permissionsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Permissions updated successfully!'**
  String get permissionsUpdated;

  /// No description provided for @accessibilityGroupList.
  ///
  /// In en, this message translates to:
  /// **'List of workout groups'**
  String get accessibilityGroupList;

  /// No description provided for @accessibilityGroupCard.
  ///
  /// In en, this message translates to:
  /// **'Group card for {groupName}'**
  String accessibilityGroupCard(Object groupName);

  /// No description provided for @accessibilityJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join group {groupName}'**
  String accessibilityJoinGroup(Object groupName);

  /// No description provided for @accessibilityLeaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave group {groupName}'**
  String accessibilityLeaveGroup(Object groupName);

  /// No description provided for @accessibilityGroupMembers.
  ///
  /// In en, this message translates to:
  /// **'{memberCount} members'**
  String accessibilityGroupMembers(Object memberCount);

  /// No description provided for @accessibilityGroupAdmin.
  ///
  /// In en, this message translates to:
  /// **'Group administrator'**
  String get accessibilityGroupAdmin;

  /// No description provided for @accessibilityGroupModerator.
  ///
  /// In en, this message translates to:
  /// **'Group moderator'**
  String get accessibilityGroupModerator;

  /// No description provided for @accessibilityGroupMember.
  ///
  /// In en, this message translates to:
  /// **'Group member'**
  String get accessibilityGroupMember;

  /// No description provided for @accessibilityActivityFeed.
  ///
  /// In en, this message translates to:
  /// **'Group activity feed'**
  String get accessibilityActivityFeed;

  /// No description provided for @accessibilityActivityItem.
  ///
  /// In en, this message translates to:
  /// **'Activity by {userName}'**
  String accessibilityActivityItem(Object userName);

  /// No description provided for @accessibilityPostCard.
  ///
  /// In en, this message translates to:
  /// **'Post by {authorName}'**
  String accessibilityPostCard(Object authorName);

  /// No description provided for @accessibilityLikeButton.
  ///
  /// In en, this message translates to:
  /// **'Like this post'**
  String get accessibilityLikeButton;

  /// No description provided for @accessibilityDislikeButton.
  ///
  /// In en, this message translates to:
  /// **'Dislike this post'**
  String get accessibilityDislikeButton;

  /// No description provided for @accessibilityCommentButton.
  ///
  /// In en, this message translates to:
  /// **'Comment on this post'**
  String get accessibilityCommentButton;

  /// No description provided for @accessibilityShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share this post'**
  String get accessibilityShareButton;

  /// No description provided for @accessibilityBookmarkButton.
  ///
  /// In en, this message translates to:
  /// **'Bookmark this post'**
  String get accessibilityBookmarkButton;

  /// No description provided for @accessibilityRankingItem.
  ///
  /// In en, this message translates to:
  /// **'Ranking position {rank} for {groupName}'**
  String accessibilityRankingItem(Object groupName, Object rank);

  /// No description provided for @accessibilityScoreCard.
  ///
  /// In en, this message translates to:
  /// **'Score card showing {score} points'**
  String accessibilityScoreCard(Object score);

  /// No description provided for @accessibilityNavigateBack.
  ///
  /// In en, this message translates to:
  /// **'Navigate back'**
  String get accessibilityNavigateBack;

  /// No description provided for @accessibilityOpenMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get accessibilityOpenMenu;

  /// No description provided for @accessibilityCloseMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get accessibilityCloseMenu;

  /// No description provided for @accessibilitySearchField.
  ///
  /// In en, this message translates to:
  /// **'Search field'**
  String get accessibilitySearchField;

  /// No description provided for @accessibilityFilterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter options'**
  String get accessibilityFilterButton;

  /// No description provided for @accessibilitySortButton.
  ///
  /// In en, this message translates to:
  /// **'Sort options'**
  String get accessibilitySortButton;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection error'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get serverError;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @dislike.
  ///
  /// In en, this message translates to:
  /// **'Dislike'**
  String get dislike;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @viewLess.
  ///
  /// In en, this message translates to:
  /// **'View Less'**
  String get viewLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @insufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient'**
  String get insufficient;

  /// No description provided for @excessive.
  ///
  /// In en, this message translates to:
  /// **'Excessive'**
  String get excessive;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @permissionsSaved.
  ///
  /// In en, this message translates to:
  /// **'Permissions saved successfully'**
  String get permissionsSaved;

  /// No description provided for @permissionsError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while saving permissions'**
  String get permissionsError;

  /// No description provided for @revokePermissions.
  ///
  /// In en, this message translates to:
  /// **'Revoke Permissions'**
  String get revokePermissions;

  /// No description provided for @revokePermissionsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to revoke all permissions?'**
  String get revokePermissionsConfirm;

  /// No description provided for @revoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revoke;

  /// No description provided for @viewMealsDesc.
  ///
  /// In en, this message translates to:
  /// **'Trainer can view your meal records'**
  String get viewMealsDesc;

  /// No description provided for @viewPhotosDesc.
  ///
  /// In en, this message translates to:
  /// **'Trainer can view your meal photos'**
  String get viewPhotosDesc;

  /// No description provided for @viewNutritionDesc.
  ///
  /// In en, this message translates to:
  /// **'Trainer can view your nutrition intake information'**
  String get viewNutritionDesc;

  /// No description provided for @allowAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Allow Data Analysis'**
  String get allowAnalysis;

  /// No description provided for @allowAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Analyze diet data to identify trends and patterns'**
  String get allowAnalysisDesc;

  /// No description provided for @allowRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Allow Recommendations'**
  String get allowRecommendations;

  /// No description provided for @allowRecommendationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive AI-based diet recommendations'**
  String get allowRecommendationsDesc;

  /// No description provided for @allowComparison.
  ///
  /// In en, this message translates to:
  /// **'Allow Group Comparison'**
  String get allowComparison;

  /// No description provided for @allowComparisonDesc.
  ///
  /// In en, this message translates to:
  /// **'Compare anonymously with other group members'**
  String get allowComparisonDesc;

  /// No description provided for @savePermissions.
  ///
  /// In en, this message translates to:
  /// **'Save Permissions'**
  String get savePermissions;

  /// No description provided for @revokeAllPermissions.
  ///
  /// In en, this message translates to:
  /// **'Revoke All Permissions'**
  String get revokeAllPermissions;

  /// No description provided for @permissionsNote.
  ///
  /// In en, this message translates to:
  /// **'Permission settings can be changed at any time. Your data is securely protected.'**
  String get permissionsNote;

  /// No description provided for @groupDietAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Group Diet Analysis'**
  String get groupDietAnalysis;

  /// No description provided for @memberDietAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Member Diet Analysis'**
  String get memberDietAnalysis;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @distribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get distribution;

  /// No description provided for @timing.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get timing;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @shareStarted.
  ///
  /// In en, this message translates to:
  /// **'Sharing started'**
  String get shareStarted;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// No description provided for @analysisReport.
  ///
  /// In en, this message translates to:
  /// **'Analysis Report'**
  String get analysisReport;

  /// No description provided for @feedbackError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while sending feedback'**
  String get feedbackError;

  /// No description provided for @createFeedback.
  ///
  /// In en, this message translates to:
  /// **'Create Feedback'**
  String get createFeedback;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @feedbackTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get feedbackTemplates;

  /// No description provided for @mealReference.
  ///
  /// In en, this message translates to:
  /// **'Meal Reference'**
  String get mealReference;

  /// No description provided for @feedbackRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter feedback content'**
  String get feedbackRequired;

  /// No description provided for @positiveHint.
  ///
  /// In en, this message translates to:
  /// **'Specifically praise what they\'re doing well'**
  String get positiveHint;

  /// No description provided for @suggestionHint.
  ///
  /// In en, this message translates to:
  /// **'Suggest ways to improve'**
  String get suggestionHint;

  /// No description provided for @concernHint.
  ///
  /// In en, this message translates to:
  /// **'Specifically describe your concerns'**
  String get concernHint;

  /// No description provided for @positive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get positive;

  /// No description provided for @suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestion;

  /// No description provided for @concern.
  ///
  /// In en, this message translates to:
  /// **'Concern'**
  String get concern;

  /// No description provided for @memberDietDetail.
  ///
  /// In en, this message translates to:
  /// **'Member Diet Detail'**
  String get memberDietDetail;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @exportStarted.
  ///
  /// In en, this message translates to:
  /// **'Export started'**
  String get exportStarted;

  /// No description provided for @dietTrends.
  ///
  /// In en, this message translates to:
  /// **'Diet Trends'**
  String get dietTrends;

  /// No description provided for @mealPhotos.
  ///
  /// In en, this message translates to:
  /// **'Meal Photos'**
  String get mealPhotos;

  /// No description provided for @nutritionBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Breakdown'**
  String get nutritionBreakdown;

  /// No description provided for @mealTimeline.
  ///
  /// In en, this message translates to:
  /// **'Meal Timeline'**
  String get mealTimeline;

  /// No description provided for @dailyNutrition.
  ///
  /// In en, this message translates to:
  /// **'Daily Nutrition'**
  String get dailyNutrition;

  /// No description provided for @memberDietHeader.
  ///
  /// In en, this message translates to:
  /// **'Member Diet Information'**
  String get memberDietHeader;

  /// No description provided for @memberHeaderPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Loading member information...'**
  String get memberHeaderPlaceholder;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @alertsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Loading alerts...'**
  String get alertsPlaceholder;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @activityPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Loading recent activity...'**
  String get activityPlaceholder;

  /// No description provided for @dietAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Diet Analytics'**
  String get dietAnalytics;

  /// No description provided for @analyticsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Loading analytics data...'**
  String get analyticsPlaceholder;

  /// No description provided for @groupOverview.
  ///
  /// In en, this message translates to:
  /// **'Group Overview'**
  String get groupOverview;

  /// No description provided for @activeMembers.
  ///
  /// In en, this message translates to:
  /// **'Active Members'**
  String get activeMembers;

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// No description provided for @avgCalories.
  ///
  /// In en, this message translates to:
  /// **'Avg Calories'**
  String get avgCalories;

  /// No description provided for @avgProtein.
  ///
  /// In en, this message translates to:
  /// **'Avg Protein'**
  String get avgProtein;

  /// No description provided for @totalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Members'**
  String get totalMembers;

  /// No description provided for @needAttention.
  ///
  /// In en, this message translates to:
  /// **'Need Attention'**
  String get needAttention;

  /// No description provided for @avgCalorieAchievement.
  ///
  /// In en, this message translates to:
  /// **'Avg Calorie Achievement'**
  String get avgCalorieAchievement;

  /// No description provided for @avgProteinAchievement.
  ///
  /// In en, this message translates to:
  /// **'Avg Protein Achievement'**
  String get avgProteinAchievement;

  /// No description provided for @dietDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View group members\' diet status at a glance'**
  String get dietDashboardSubtitle;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous Day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next Day'**
  String get nextDay;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
