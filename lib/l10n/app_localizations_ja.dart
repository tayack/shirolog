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

  @override
  String get supportDeveloper => '開発者を応援';

  @override
  String get supportMessage =>
      '城ログをご利用いただきありがとうございます！\nもしよろしければ、開発者への応援（お茶代の差し入れ）をしていただけると運営の励みになります。';

  @override
  String get close => '閉じる';

  @override
  String get supportConfirm => '応援する';

  @override
  String get errorFetchingData => 'データの取得に失敗しました';

  @override
  String get retry => '再試行';

  @override
  String get totalVisits => '総登城数';

  @override
  String get castleUnit => '城';

  @override
  String get yearUnit => '年';

  @override
  String get supportApp => '城ログを応援する';

  @override
  String get recentVisits => '最新の訪問履歴';

  @override
  String get seeAll => 'すべて見る';

  @override
  String get noRecords => 'まだ記録がありません。\nお城を巡って記録を残しましょう！';

  @override
  String get recommendedContent => 'おすすめコンテンツ';

  @override
  String get loading => '読み込み中...';

  @override
  String get newRecord => '新しい記録';

  @override
  String get editRecord => '記録を編集';

  @override
  String get selectPrefecture => '都道府県を選択';

  @override
  String get viewRecord => '記録を表示・編集する';

  @override
  String get cancelEdit => '編集をキャンセル';

  @override
  String get deleteLog => 'ログの削除';

  @override
  String get deleteConfirm => '削除してもよろしいですか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get searchCriteria => '検索条件';

  @override
  String get applying => '適用中';

  @override
  String get all => 'すべて';

  @override
  String get searchByCastleName => '城名で検索';

  @override
  String get exampleCastle => '例: 姫路城';

  @override
  String get startDate => '開始日';

  @override
  String get endDate => '終了日';

  @override
  String get notSpecified => '指定なし';

  @override
  String get clearCriteria => '検索条件をクリア';

  @override
  String get noMatchingRecords => '該当する記録が見つかりませんでした。';

  @override
  String get missionAccomplished => '任務完了';

  @override
  String get missionCompletedMessage => 'を達成しました！';

  @override
  String get bravo => 'あっぱれ！';

  @override
  String get missionAccomplishedSharePrefix => '【ミッション達成！】\n';

  @override
  String get missionCompletedShareSuffix => ' を制覇しました！\n\n';

  @override
  String get supporterIntro => '※アプリの開発を支援していただいた皆様です';

  @override
  String get existingAccountTitle => '既存アカウントが見つかりました';

  @override
  String get existingAccountMessage =>
      'このGoogleアカウントはすでに他のデータと紐付いています。既存のアカウントに切り替えますか？\n（※現在ゲストとして登録しているデータは失われます）';

  @override
  String get switchToExisting => '切り替える';

  @override
  String get stayAsGuest => '今のまま（ゲスト）';

  @override
  String get deleteAccount => 'アカウントの削除';

  @override
  String get deleteAccountTitle => 'アカウントを完全に削除しますか？';

  @override
  String get deleteAccountConfirmation =>
      'この操作は取り消せません。登城記録などのすべてのデータが完全に削除されます。';

  @override
  String get accountDeletedMessage => 'アカウントと関連データを削除しました。';

  @override
  String get reauthenticationRequiredTitle => '再認証が必要です';

  @override
  String get reauthenticationRequiredMessage =>
      '重要な操作のため、一度ログアウトして再度サインインしてから実行してください。';

  @override
  String get ok => 'OK';
}
