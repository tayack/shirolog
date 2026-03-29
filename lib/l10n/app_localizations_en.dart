// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShiroLog';

  @override
  String get home => 'Home';

  @override
  String get record => 'Record';

  @override
  String get search => 'Log Search';

  @override
  String get mission => 'Missions';

  @override
  String get settings => 'Settings';

  @override
  String get loginTitle => 'ShiroLog';

  @override
  String get loginSubtitle => 'Castle Visit Log App';

  @override
  String get googleLogin => 'Sign in with Google';

  @override
  String get appleLogin => 'Sign in with Apple';

  @override
  String get guestLogin => 'Start as Guest';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get japanese => 'Japanese';

  @override
  String get english => 'English';

  @override
  String get recentSummary => 'Recent Visit Summary';

  @override
  String get visitDate => 'Visit Date';

  @override
  String get memo => 'Memo';

  @override
  String get save => 'Save Record';

  @override
  String get edit => 'Edit Record';

  @override
  String get searchCastle => 'Search Castle Name';

  @override
  String get alreadyVisited =>
      'Already visited. If you want to edit, please do so from Log Search.';

  @override
  String get achieved => 'Achieved';

  @override
  String get points => 'points';

  @override
  String get guestModeWarning =>
      '⚠️ Guest Mode: Link your account in Settings to keep data when changing devices';

  @override
  String get linkGoogleAccount => 'Link Google Account';

  @override
  String get linkSuccess => 'Account linked successfully!';

  @override
  String get logoutWarningTitle => 'Confirm Logout';

  @override
  String get logoutWarningContent =>
      'If you logout as a guest, your data will be permanently lost. Link account to backup data?';

  @override
  String get favoriteMissions => 'Favorites';

  @override
  String get inProgressMissions => 'In Progress';

  @override
  String get unstartedMissions => 'Not Started';

  @override
  String get completedMissions => 'Completed';

  @override
  String get shareTitle => 'Visit record saved!';

  @override
  String get shareContent => 'Would you like to share your memory on SNS?';

  @override
  String get shareLater => 'Later';

  @override
  String get shareNow => 'Share Now';

  @override
  String get shareTwitter => 'X (Twitter)';

  @override
  String get shareOthers => 'Others';

  @override
  String shareText(Object castleName, Object date, Object comment) {
    return '【Visit Log】I visited $castleName! ($date)\n\n$comment\n\n#ShiroLog #CastleTour #100FineCastlesOfJapan';
  }

  @override
  String get supportDeveloper => 'Support the Developer';

  @override
  String get supportMessage =>
      'Thank you for using ShiroLog!\nIf you\'d like, you can support the developer with a small donation (Buy Me a Coffee). It really helps keep the app running!';

  @override
  String get close => 'Close';

  @override
  String get supportConfirm => 'Support';

  @override
  String get errorFetchingData => 'Failed to fetch data';

  @override
  String get retry => 'Retry';

  @override
  String get totalVisits => 'Total Castles';

  @override
  String get castleUnit => ' castles';

  @override
  String get yearUnit => '';

  @override
  String get supportApp => 'Support ShiroLog';

  @override
  String get recentVisits => 'Recent Visits';

  @override
  String get seeAll => 'See All';

  @override
  String get noRecords => 'No records yet.\nLet\'s go explore some castles!';

  @override
  String get recommendedContent => 'Recommended';

  @override
  String get loading => 'Loading...';

  @override
  String get newRecord => 'New Record';

  @override
  String get editRecord => 'Edit Record';

  @override
  String get selectPrefecture => 'Select Prefecture';

  @override
  String get viewRecord => 'View/Edit Record';

  @override
  String get cancelEdit => 'Cancel Edit';

  @override
  String get deleteLog => 'Delete Log';

  @override
  String get deleteConfirm => 'Are you sure you want to delete this log?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get searchCriteria => 'Search Criteria';

  @override
  String get applying => 'Applying';

  @override
  String get all => 'All';

  @override
  String get searchByCastleName => 'Search by Castle Name';

  @override
  String get exampleCastle => 'e.g. Himeji Castle';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get notSpecified => 'Not Specified';

  @override
  String get clearCriteria => 'Clear Criteria';

  @override
  String get noMatchingRecords => 'No matching records found.';

  @override
  String get missionAccomplished => 'Mission Accomplished';

  @override
  String get missionCompletedMessage => ' accomplished!';

  @override
  String get bravo => 'Bravo!';

  @override
  String get missionAccomplishedSharePrefix => '【Mission Accomplished!】\n';

  @override
  String get missionCompletedShareSuffix => ' has been conquered!\n\n';

  @override
  String get supporterIntro =>
      'These are the supporters who have helped develop the app.';

  @override
  String get existingAccountTitle => 'Existing Account Found';

  @override
  String get existingAccountMessage =>
      'This Google account is already linked to another user. Would you like to switch to the existing account?\n(*Current guest data will be lost)';

  @override
  String get switchToExisting => 'Switch Account';

  @override
  String get stayAsGuest => 'Stay as Guest';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountTitle => 'Permanently delete account?';

  @override
  String get deleteAccountConfirmation =>
      'This action cannot be undone. All your data, including visit logs, will be permanently deleted.';

  @override
  String get accountDeletedMessage =>
      'Account and associated data have been deleted.';

  @override
  String get reauthenticationRequiredTitle => 'Re-authentication Required';

  @override
  String get reauthenticationRequiredMessage =>
      'For security reasons, please log out and sign in again before deleting your account.';

  @override
  String get ok => 'OK';
}
