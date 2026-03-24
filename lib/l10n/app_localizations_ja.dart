// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '城ログ';

  @override
  String get home => 'ホーム';

  @override
  String get record => '記録';

  @override
  String get search => 'ログ検索';

  @override
  String get mission => 'ミッション';

  @override
  String get settings => '設定';

  @override
  String get loginTitle => '城ログ';

  @override
  String get loginSubtitle => '登城記録アプリ';

  @override
  String get googleLogin => 'Googleでサインイン';

  @override
  String get appleLogin => 'Appleでサインイン';

  @override
  String get guestLogin => 'ゲストとして開始';

  @override
  String get logout => 'ログアウト';

  @override
  String get language => '言語';

  @override
  String get japanese => '日本語';

  @override
  String get english => '英語';

  @override
  String get recentSummary => '最近の登城サマリー';

  @override
  String get visitDate => '訪問日';

  @override
  String get memo => '一言メモ';

  @override
  String get save => '記録を保存する';

  @override
  String get edit => '内容を編集する';

  @override
  String get searchCastle => '城名を検索';

  @override
  String get alreadyVisited => 'すでに訪問済みです。編集を行いたい場合はログ検索から編集を行ってください。';

  @override
  String get achieved => '達成';

  @override
  String get points => '地点';

  @override
  String get guestModeWarning => '⚠️ ゲストモード: 設定からアカウント連携をすることで機種変更してもデータを保てます';

  @override
  String get linkGoogleAccount => 'Googleアカウントを連携する';

  @override
  String get linkSuccess => 'アカウントの連携が完了しました！';

  @override
  String get logoutWarningTitle => 'ログアウトの確認';

  @override
  String get logoutWarningContent =>
      'ゲストアカウントのままログアウトするとデータが完全に失われます。アカウント連携をしてデータを引き継ぎますか？';

  @override
  String get favoriteMissions => 'お気に入り';

  @override
  String get inProgressMissions => '挑戦中';

  @override
  String get unstartedMissions => '未挑戦';

  @override
  String get completedMissions => '達成済み';

  @override
  String get shareTitle => '登城記録を保存しました！';

  @override
  String get shareContent => '思い出をSNSにシェアしませんか？';

  @override
  String get shareLater => 'あとで';

  @override
  String get shareNow => 'シェアする';

  @override
  String get shareTwitter => 'X (Twitter)';

  @override
  String get shareOthers => 'その他';

  @override
  String shareText(Object castleName, Object date, Object comment) {
    return '【登城記録】$castleName に行ってきました！ ($date)\n\n$comment\n\n#城ログ #城巡り #日本100名城';
  }
}
