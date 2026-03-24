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
  String get mission => 'Mission';

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
  String get memo => 'Personal Note';

  @override
  String get save => 'Save Record';

  @override
  String get edit => 'Edit Content';

  @override
  String get searchCastle => 'Search Castle Name';

  @override
  String get alreadyVisited =>
      'You have already visited this site. To edit, please go to Log Search.';

  @override
  String get achieved => 'Achieved';

  @override
  String get points => 'Points';

  @override
  String get guestModeWarning =>
      '⚠️ Guest Mode: Link your account in Settings to keep data when changing devices.';

  @override
  String get linkGoogleAccount => 'Link Google Account';

  @override
  String get linkSuccess => 'Account linked successfully!';

  @override
  String get logoutWarningTitle => 'Logout Confirmation';

  @override
  String get logoutWarningContent =>
      'Data will be lost if you logout as a guest. Would you like to link your account first?';

  @override
  String get favoriteMissions => 'Favorites';

  @override
  String get inProgressMissions => 'In Progress';

  @override
  String get unstartedMissions => 'Not Started';

  @override
  String get completedMissions => 'Completed';

  @override
  String get shareTitle => 'Visit Record Saved!';

  @override
  String get shareContent => 'Would you like to share your memory on SNS?';

  @override
  String get shareLater => 'Later';

  @override
  String get shareNow => 'Share';

  @override
  String get shareTwitter => 'X (Twitter)';

  @override
  String get shareOthers => 'Others';

  @override
  String shareText(Object castleName, Object date, Object comment) {
    return '[Castle Log] I visited $castleName! ($date)\n\n$comment\n\n#ShiroLog #CastleTour #Japan100Castles';
  }
}
