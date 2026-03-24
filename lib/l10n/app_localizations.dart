import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

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
  /// **'Mission'**
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
  /// **'Personal Note'**
  String get memo;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Content'**
  String get edit;

  /// No description provided for @searchCastle.
  ///
  /// In en, this message translates to:
  /// **'Search Castle Name'**
  String get searchCastle;

  /// No description provided for @alreadyVisited.
  ///
  /// In en, this message translates to:
  /// **'You have already visited this site. To edit, please go to Log Search.'**
  String get alreadyVisited;

  /// No description provided for @achieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get achieved;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @guestModeWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Guest Mode: Link your account in Settings to keep data when changing devices.'**
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
  /// **'Logout Confirmation'**
  String get logoutWarningTitle;

  /// No description provided for @logoutWarningContent.
  ///
  /// In en, this message translates to:
  /// **'Data will be lost if you logout as a guest. Would you like to link your account first?'**
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
  /// **'Visit Record Saved!'**
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
  /// **'Share'**
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
  /// **'[Castle Log] I visited {castleName}! ({date})\n\n{comment}\n\n#ShiroLog #CastleTour #Japan100Castles'**
  String shareText(Object castleName, Object date, Object comment);
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
      <String>['en', 'ja'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
