import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsTitleWithIcon.
  ///
  /// In en, this message translates to:
  /// **'⚙️ Settings'**
  String get settingsTitleWithIcon;

  /// No description provided for @errorLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings'**
  String get errorLoadingSettings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred theme'**
  String get themeSubtitle;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @appLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get appLanguageSubtitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about test results'**
  String get pushNotificationsSubtitle;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on notifications and interactions'**
  String get vibrationSubtitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @developers.
  ///
  /// In en, this message translates to:
  /// **'Developers'**
  String get developers;

  /// No description provided for @developersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Meet the team behind this app'**
  String get developersSubtitle;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'🚧 Coming Soon'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonContent.
  ///
  /// In en, this message translates to:
  /// **'{feature} functionality will be implemented soon!'**
  String comingSoonContent(Object feature);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @developersDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Developers'**
  String get developersDialogTitle;

  /// No description provided for @reagentTestingApp.
  ///
  /// In en, this message translates to:
  /// **'Reagent Testing App'**
  String get reagentTestingApp;

  /// No description provided for @theDevelopers.
  ///
  /// In en, this message translates to:
  /// **'👨‍💻 The Developers'**
  String get theDevelopers;

  /// No description provided for @developerOneName.
  ///
  /// In en, this message translates to:
  /// **'Yousef Mesir Al-Enezi'**
  String get developerOneName;

  /// No description provided for @developerTwoName.
  ///
  /// In en, this message translates to:
  /// **'Mohammed Nafa Al-Ruwayli'**
  String get developerTwoName;

  /// No description provided for @aboutTheApp.
  ///
  /// In en, this message translates to:
  /// **'🧪 About the App:'**
  String get aboutTheApp;

  /// No description provided for @aboutTheAppContent.
  ///
  /// In en, this message translates to:
  /// **'This app helps users safely test substances using chemical reagents.'**
  String get aboutTheAppContent;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'📧 Contact: '**
  String get contact;

  /// No description provided for @reagentTesting.
  ///
  /// In en, this message translates to:
  /// **'Reagent Testing'**
  String get reagentTesting;

  /// No description provided for @searchReagents.
  ///
  /// In en, this message translates to:
  /// **'Search reagents...'**
  String get searchReagents;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @initializingReagentData.
  ///
  /// In en, this message translates to:
  /// **'Initializing reagent data...'**
  String get initializingReagentData;

  /// No description provided for @loadingReagents.
  ///
  /// In en, this message translates to:
  /// **'Loading reagents...'**
  String get loadingReagents;

  /// No description provided for @errorLoadingReagents.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Reagents'**
  String get errorLoadingReagents;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noReagentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Reagents Available'**
  String get noReagentsAvailable;

  /// No description provided for @unableToLoadReagentData.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reagent data from assets.\nPlease check your internet connection and try again.'**
  String get unableToLoadReagentData;

  /// No description provided for @retryLoading.
  ///
  /// In en, this message translates to:
  /// **'Retry Loading'**
  String get retryLoading;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing {reagentName}'**
  String testing(Object reagentName);

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration} min'**
  String duration(Object duration);

  /// No description provided for @safetyLevel.
  ///
  /// In en, this message translates to:
  /// **'Safety Level'**
  String get safetyLevel;

  /// No description provided for @readyToStart.
  ///
  /// In en, this message translates to:
  /// **'Ready to Start Testing'**
  String get readyToStart;

  /// No description provided for @readyToStartDescription.
  ///
  /// In en, this message translates to:
  /// **'Please ensure you have read and understood all safety instructions before proceeding with the test.'**
  String get readyToStartDescription;

  /// No description provided for @testProcedure.
  ///
  /// In en, this message translates to:
  /// **'Test Procedure'**
  String get testProcedure;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step {stepNumber}'**
  String step(Object stepNumber);

  /// No description provided for @reactionTimer.
  ///
  /// In en, this message translates to:
  /// **'Reaction Timer'**
  String get reactionTimer;

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start Timer'**
  String get startTimer;

  /// No description provided for @stopTimer.
  ///
  /// In en, this message translates to:
  /// **'Stop Timer'**
  String get stopTimer;

  /// No description provided for @resetTimer.
  ///
  /// In en, this message translates to:
  /// **'Reset Timer'**
  String get resetTimer;

  /// No description provided for @timerRunning.
  ///
  /// In en, this message translates to:
  /// **'Timer Running'**
  String get timerRunning;

  /// No description provided for @observedColor.
  ///
  /// In en, this message translates to:
  /// **'Observed Color'**
  String get observedColor;

  /// No description provided for @observedColorDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the color you observed after adding the reagent'**
  String get observedColorDescription;

  /// No description provided for @tapColorInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the color that best matches what you observed'**
  String get tapColorInstruction;

  /// No description provided for @testNotes.
  ///
  /// In en, this message translates to:
  /// **'Test Notes'**
  String get testNotes;

  /// No description provided for @testNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add any additional observations or notes about the test...'**
  String get testNotesPlaceholder;

  /// No description provided for @completeTest.
  ///
  /// In en, this message translates to:
  /// **'Complete Test'**
  String get completeTest;

  /// No description provided for @completeTestDescription.
  ///
  /// In en, this message translates to:
  /// **'Review your observations and complete the test'**
  String get completeTestDescription;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @unknownState.
  ///
  /// In en, this message translates to:
  /// **'Unknown state'**
  String get unknownState;

  /// No description provided for @safetyInformation.
  ///
  /// In en, this message translates to:
  /// **'Safety Information'**
  String get safetyInformation;

  /// No description provided for @chemicalComponents.
  ///
  /// In en, this message translates to:
  /// **'Chemical Components'**
  String get chemicalComponents;

  /// No description provided for @testInstructions.
  ///
  /// In en, this message translates to:
  /// **'Test Instructions'**
  String get testInstructions;

  /// No description provided for @safetyAcknowledgment.
  ///
  /// In en, this message translates to:
  /// **'Safety Acknowledgment'**
  String get safetyAcknowledgment;

  /// No description provided for @safetyAcknowledgmentText.
  ///
  /// In en, this message translates to:
  /// **'I have read and understand all safety instructions and will follow proper safety procedures during testing.'**
  String get safetyAcknowledgmentText;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start Test'**
  String get startTest;

  /// No description provided for @safetyAcknowledgmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Safety Acknowledgment Required'**
  String get safetyAcknowledgmentRequired;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Required Equipment'**
  String get equipment;

  /// No description provided for @handlingProcedures.
  ///
  /// In en, this message translates to:
  /// **'Handling Procedures'**
  String get handlingProcedures;

  /// No description provided for @specificHazards.
  ///
  /// In en, this message translates to:
  /// **'Specific Hazards'**
  String get specificHazards;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage Requirements'**
  String get storage;

  /// No description provided for @testResults.
  ///
  /// In en, this message translates to:
  /// **'Test Results'**
  String get testResults;

  /// No description provided for @testHistory.
  ///
  /// In en, this message translates to:
  /// **'Test History'**
  String get testHistory;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(Object message);

  /// No description provided for @noTestResultsYet.
  ///
  /// In en, this message translates to:
  /// **'No test results yet'**
  String get noTestResultsYet;

  /// No description provided for @completeTestsToSeeHistory.
  ///
  /// In en, this message translates to:
  /// **'Complete some tests to see your history here'**
  String get completeTestsToSeeHistory;

  /// No description provided for @searchBySubstanceOrNotes.
  ///
  /// In en, this message translates to:
  /// **'Search by substance or notes...'**
  String get searchBySubstanceOrNotes;

  /// No description provided for @filterByReagent.
  ///
  /// In en, this message translates to:
  /// **'Filter by reagent:'**
  String get filterByReagent;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @totalTests.
  ///
  /// In en, this message translates to:
  /// **'Total Tests'**
  String get totalTests;

  /// No description provided for @testsByReagent.
  ///
  /// In en, this message translates to:
  /// **'Tests by Reagent'**
  String get testsByReagent;

  /// No description provided for @averageConfidence.
  ///
  /// In en, this message translates to:
  /// **'Average Confidence'**
  String get averageConfidence;

  /// No description provided for @mostUsedReagent.
  ///
  /// In en, this message translates to:
  /// **'Most Used Reagent'**
  String get mostUsedReagent;

  /// No description provided for @confidenceWithPercentage.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {confidence}%'**
  String confidenceWithPercentage(Object confidence);

  /// No description provided for @possibleSubstances.
  ///
  /// In en, this message translates to:
  /// **'Possible Substances'**
  String get possibleSubstances;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @testResult.
  ///
  /// In en, this message translates to:
  /// **'Test Result'**
  String get testResult;

  /// No description provided for @reagent.
  ///
  /// In en, this message translates to:
  /// **'Reagent'**
  String get reagent;

  /// No description provided for @observedColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Observed Color'**
  String get observedColorLabel;

  /// No description provided for @testDate.
  ///
  /// In en, this message translates to:
  /// **'Test Date'**
  String get testDate;

  /// No description provided for @deleteTestResult.
  ///
  /// In en, this message translates to:
  /// **'Delete Test Result'**
  String get deleteTestResult;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this {reagentName} test result?'**
  String deleteConfirmation(Object reagentName);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noTestHistory.
  ///
  /// In en, this message translates to:
  /// **'No test results yet'**
  String get noTestHistory;

  /// No description provided for @noTestHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete some tests to see your history here'**
  String get noTestHistoryDescription;

  /// No description provided for @deleteTest.
  ///
  /// In en, this message translates to:
  /// **'Delete Test Result'**
  String get deleteTest;

  /// No description provided for @deleteTestConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this test result?'**
  String get deleteTestConfirmation;

  /// No description provided for @loadingTestHistory.
  ///
  /// In en, this message translates to:
  /// **'Loading test history...'**
  String get loadingTestHistory;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error loading test history'**
  String get errorLoadingHistory;

  /// No description provided for @testSummary.
  ///
  /// In en, this message translates to:
  /// **'Test Summary'**
  String get testSummary;

  /// No description provided for @uniqueReagents.
  ///
  /// In en, this message translates to:
  /// **'Unique Reagents'**
  String get uniqueReagents;

  /// No description provided for @recentTests.
  ///
  /// In en, this message translates to:
  /// **'Recent Tests'**
  String get recentTests;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @syncToCloud.
  ///
  /// In en, this message translates to:
  /// **'Sync to Cloud'**
  String get syncToCloud;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @syncingToCloud.
  ///
  /// In en, this message translates to:
  /// **'Syncing to cloud...'**
  String get syncingToCloud;

  /// No description provided for @clearAllConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all test results? This action cannot be undone.'**
  String get clearAllConfirmation;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @captureImage.
  ///
  /// In en, this message translates to:
  /// **'Capture Image'**
  String get captureImage;

  /// No description provided for @captureImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your test result for AI analysis'**
  String get captureImageDescription;

  /// No description provided for @analyzeWithAI.
  ///
  /// In en, this message translates to:
  /// **'Analyze with AI'**
  String get analyzeWithAI;

  /// No description provided for @aiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysis;

  /// No description provided for @aiAnalysisResult.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Result'**
  String get aiAnalysisResult;

  /// No description provided for @aiAnalysisError.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Error'**
  String get aiAnalysisError;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get retakePhoto;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @aiSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestion'**
  String get aiSuggestion;

  /// No description provided for @confidenceLevel.
  ///
  /// In en, this message translates to:
  /// **'Confidence Level'**
  String get confidenceLevel;

  /// No description provided for @possibleMatches.
  ///
  /// In en, this message translates to:
  /// **'Possible Matches'**
  String get possibleMatches;

  /// No description provided for @analysisNotes.
  ///
  /// In en, this message translates to:
  /// **'Analysis Notes'**
  String get analysisNotes;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @extreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get extreme;

  /// No description provided for @noColorChange.
  ///
  /// In en, this message translates to:
  /// **'No color change'**
  String get noColorChange;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @unknownSubstance.
  ///
  /// In en, this message translates to:
  /// **'Unknown substance or impure sample'**
  String get unknownSubstance;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @primaryTests.
  ///
  /// In en, this message translates to:
  /// **'Primary Tests'**
  String get primaryTests;

  /// No description provided for @secondaryTests.
  ///
  /// In en, this message translates to:
  /// **'Secondary Tests'**
  String get secondaryTests;

  /// No description provided for @specializedTests.
  ///
  /// In en, this message translates to:
  /// **'Specialized Tests'**
  String get specializedTests;

  /// No description provided for @laboratoryProfile.
  ///
  /// In en, this message translates to:
  /// **'Laboratory Profile'**
  String get laboratoryProfile;

  /// No description provided for @labAccess.
  ///
  /// In en, this message translates to:
  /// **'Lab Access'**
  String get labAccess;

  /// No description provided for @joinLaboratory.
  ///
  /// In en, this message translates to:
  /// **'Join Laboratory'**
  String get joinLaboratory;

  /// No description provided for @laboratoryTechnician.
  ///
  /// In en, this message translates to:
  /// **'Laboratory Technician'**
  String get laboratoryTechnician;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @testingStatistics.
  ///
  /// In en, this message translates to:
  /// **'Testing Statistics'**
  String get testingStatistics;

  /// No description provided for @testsPerformed.
  ///
  /// In en, this message translates to:
  /// **'Tests Performed'**
  String get testsPerformed;

  /// No description provided for @reagentsUsed.
  ///
  /// In en, this message translates to:
  /// **'Reagents Used'**
  String get reagentsUsed;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @labHours.
  ///
  /// In en, this message translates to:
  /// **'Lab Hours'**
  String get labHours;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// No description provided for @dayAgo.
  ///
  /// In en, this message translates to:
  /// **'day ago'**
  String get dayAgo;

  /// No description provided for @safetyReminder.
  ///
  /// In en, this message translates to:
  /// **'Safety Reminder'**
  String get safetyReminder;

  /// No description provided for @safetyReminderText.
  ///
  /// In en, this message translates to:
  /// **'Always wear protective equipment when handling reagents. Ensure proper ventilation and follow safety protocols.'**
  String get safetyReminderText;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @joinOurLab.
  ///
  /// In en, this message translates to:
  /// **'Join Our Lab'**
  String get joinOurLab;

  /// No description provided for @accessYourLab.
  ///
  /// In en, this message translates to:
  /// **'Access your reagent testing laboratory'**
  String get accessYourLab;

  /// No description provided for @startYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your journey in substance analysis'**
  String get startYourJourney;

  /// No description provided for @loginMode.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginMode;

  /// No description provided for @registerMode.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerMode;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveLabAccess.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have lab access?'**
  String get dontHaveLabAccess;

  /// No description provided for @alreadyHaveLabAccess.
  ///
  /// In en, this message translates to:
  /// **'Already have lab access?'**
  String get alreadyHaveLabAccess;

  /// No description provided for @joinNow.
  ///
  /// In en, this message translates to:
  /// **'Join Now'**
  String get joinNow;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @accessLaboratory.
  ///
  /// In en, this message translates to:
  /// **'Access Laboratory'**
  String get accessLaboratory;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get signingIn;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating Account...'**
  String get creatingAccount;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterUsername;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @usernameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers, and underscores'**
  String get usernameInvalidChars;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
