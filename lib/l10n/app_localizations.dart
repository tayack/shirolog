import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

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
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ShiroLog'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Log Search'**
  String get search;

  /// No description provided for @mission.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get mission;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'ShiroLog'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Castle Visit Log App'**
  String get loginSubtitle;

  /// No description provided for @googleLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleLogin;

  /// No description provided for @appleLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get appleLogin;

  /// No description provided for @guestLogin.
  ///
  /// In en, this message translates to:
  /// **'Start as Guest'**
  String get guestLogin;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @recentSummary.
  ///
  /// In en, this message translates to:
  /// **'Recent Visit Summary'**
  String get recentSummary;

  /// No description provided for @visitDate.
  ///
  /// In en, this message translates to:
  /// **'Visit Date'**
  String get visitDate;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Record'**
  String get edit;

  /// No description provided for @searchCastle.
  ///
  /// In en, this message translates to:
  /// **'Search Castle Name'**
  String get searchCastle;

  /// No description provided for @alreadyVisited.
  ///
  /// In en, this message translates to:
  /// **'Already visited. If you want to edit, please do so from Log Search.'**
  String get alreadyVisited;

  /// No description provided for @achieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get achieved;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @guestModeWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Guest Mode: Link your account in Settings to keep data when changing devices'**
  String get guestModeWarning;

  /// No description provided for @linkGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Google Account'**
  String get linkGoogleAccount;

  /// No description provided for @linkSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account linked successfully!'**
  String get linkSuccess;

  /// No description provided for @logoutWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get logoutWarningTitle;

  /// No description provided for @logoutWarningContent.
  ///
  /// In en, this message translates to:
  /// **'If you logout as a guest, your data will be permanently lost. Link account to backup data?'**
  String get logoutWarningContent;

  /// No description provided for @favoriteMissions.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoriteMissions;

  /// No description provided for @inProgressMissions.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressMissions;

  /// No description provided for @unstartedMissions.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get unstartedMissions;

  /// No description provided for @completedMissions.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedMissions;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit record saved!'**
  String get shareTitle;

  /// No description provided for @shareContent.
  ///
  /// In en, this message translates to:
  /// **'Would you like to share your memory on SNS?'**
  String get shareContent;

  /// No description provided for @shareLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get shareLater;

  /// No description provided for @shareNow.
  ///
  /// In en, this message translates to:
  /// **'Share Now'**
  String get shareNow;

  /// No description provided for @shareTwitter.
  ///
  /// In en, this message translates to:
  /// **'X (Twitter)'**
  String get shareTwitter;

  /// No description provided for @shareOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get shareOthers;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'【Visit Log】I visited {castleName}! ({date})\n\n{comment}\n\n#ShiroLog #CastleTour #100FineCastlesOfJapan'**
  String shareText(Object castleName, Object date, Object comment);

  /// No description provided for @supportDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Support the Developer'**
  String get supportDeveloper;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using ShiroLog!\nIf you\'d like, you can support the developer with a small donation (Buy Me a Coffee). It really helps keep the app running!'**
  String get supportMessage;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @supportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportConfirm;

  /// No description provided for @errorFetchingData.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch data'**
  String get errorFetchingData;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @totalVisits.
  ///
  /// In en, this message translates to:
  /// **'Total Castles'**
  String get totalVisits;

  /// No description provided for @castleUnit.
  ///
  /// In en, this message translates to:
  /// **' castles'**
  String get castleUnit;

  /// No description provided for @yearUnit.
  ///
  /// In en, this message translates to:
  /// **''**
  String get yearUnit;

  /// No description provided for @supportApp.
  ///
  /// In en, this message translates to:
  /// **'Support ShiroLog'**
  String get supportApp;

  /// No description provided for @recentVisits.
  ///
  /// In en, this message translates to:
  /// **'Recent Visits'**
  String get recentVisits;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records yet.\nLet\'s go explore some castles!'**
  String get noRecords;

  /// No description provided for @recommendedContent.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendedContent;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @newRecord.
  ///
  /// In en, this message translates to:
  /// **'New Record'**
  String get newRecord;

  /// No description provided for @editRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Record'**
  String get editRecord;

  /// No description provided for @selectPrefecture.
  ///
  /// In en, this message translates to:
  /// **'Select Prefecture'**
  String get selectPrefecture;

  /// No description provided for @viewRecord.
  ///
  /// In en, this message translates to:
  /// **'View/Edit Record'**
  String get viewRecord;

  /// No description provided for @cancelEdit.
  ///
  /// In en, this message translates to:
  /// **'Cancel Edit'**
  String get cancelEdit;

  /// No description provided for @deleteLog.
  ///
  /// In en, this message translates to:
  /// **'Delete Log'**
  String get deleteLog;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this log?'**
  String get deleteConfirm;

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

  /// No description provided for @searchCriteria.
  ///
  /// In en, this message translates to:
  /// **'Search Criteria'**
  String get searchCriteria;

  /// No description provided for @applying.
  ///
  /// In en, this message translates to:
  /// **'Applying'**
  String get applying;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @searchByCastleName.
  ///
  /// In en, this message translates to:
  /// **'Search by Castle Name'**
  String get searchByCastleName;

  /// No description provided for @exampleCastle.
  ///
  /// In en, this message translates to:
  /// **'e.g. Himeji Castle'**
  String get exampleCastle;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get notSpecified;

  /// No description provided for @clearCriteria.
  ///
  /// In en, this message translates to:
  /// **'Clear Criteria'**
  String get clearCriteria;

  /// No description provided for @noMatchingRecords.
  ///
  /// In en, this message translates to:
  /// **'No matching records found.'**
  String get noMatchingRecords;

  /// No description provided for @missionAccomplished.
  ///
  /// In en, this message translates to:
  /// **'Mission Accomplished'**
  String get missionAccomplished;

  /// No description provided for @missionCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **' accomplished!'**
  String get missionCompletedMessage;

  /// No description provided for @bravo.
  ///
  /// In en, this message translates to:
  /// **'Bravo!'**
  String get bravo;

  /// No description provided for @missionAccomplishedSharePrefix.
  ///
  /// In en, this message translates to:
  /// **'【Mission Accomplished!】\n'**
  String get missionAccomplishedSharePrefix;

  /// No description provided for @missionCompletedShareSuffix.
  ///
  /// In en, this message translates to:
  /// **' has been conquered!\n\n'**
  String get missionCompletedShareSuffix;

  /// No description provided for @supporterIntro.
  ///
  /// In en, this message translates to:
  /// **'These are the supporters who have helped develop the app.'**
  String get supporterIntro;

  /// No description provided for @existingAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Existing Account Found'**
  String get existingAccountTitle;

  /// No description provided for @existingAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This Google account is already linked to another user. Would you like to switch to the existing account?\n(*Current guest data will be lost)'**
  String get existingAccountMessage;

  /// No description provided for @switchToExisting.
  ///
  /// In en, this message translates to:
  /// **'Switch Account'**
  String get switchToExisting;

  /// No description provided for @stayAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Stay as Guest'**
  String get stayAsGuest;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data, including visit logs, will be permanently deleted.'**
  String get deleteAccountConfirmation;

  /// No description provided for @accountDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Account and associated data have been deleted.'**
  String get accountDeletedMessage;

  /// No description provided for @reauthenticationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-authentication Required'**
  String get reauthenticationRequiredTitle;

  /// No description provided for @reauthenticationRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'For security reasons, please log out and sign in again before deleting your account.'**
  String get reauthenticationRequiredMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;
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
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
