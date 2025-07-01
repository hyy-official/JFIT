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
