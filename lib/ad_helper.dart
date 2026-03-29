import 'dart:io';

class AdHelper {
  // ★ ここを false にすると本番用IDに切り替わります
  static const bool useTestAd = false;

  // ---------------------------------------------------------------------------
  // 本番用広告ユニットID (AdMob管理画面で発行したIDをここに貼り付けてください)
  // ---------------------------------------------------------------------------

  // ネイティブ広告用
  static const String _homeNativeAndroidRes =
      'ca-app-pub-9410375406721754/9855915771';
  static const String _homeNativeIOSRes = 'ca-app-pub-XXXXX/XXXXX';

  static const String _recordNativeAndroidRes =
      'ca-app-pub-9410375406721754/2037871599';
  static const String _recordNativeIOSRes = 'ca-app-pub-XXXXX/XXXXX';

  static const String _searchNativeAndroidRes =
      'ca-app-pub-9410375406721754/5690176143';
  static const String _searchNativeIOSRes = 'ca-app-pub-XXXXX/XXXXX';

  static const String _missionNativeAndroidRes =
      'ca-app-pub-9410375406721754/7909846077';
  static const String _missionNativeIOSRes = 'ca-app-pub-XXXXX/XXXXX';

  static const String _settingsNativeAndroidRes =
      'ca-app-pub-9410375406721754/1476299667';
  static const String _settingsNativeIOSRes = 'ca-app-pub-XXXXX/XXXXX';

  // ---------------------------------------------------------------------------
  // 各画面用のゲッター
  // ---------------------------------------------------------------------------

  static String get homeNativeAdUnitId => _getNativeId(
    prodAndroid: _homeNativeAndroidRes,
    prodIOS: _homeNativeIOSRes,
  );

  static String get recordNativeAdUnitId => _getNativeId(
    prodAndroid: _recordNativeAndroidRes,
    prodIOS: _recordNativeIOSRes,
  );

  static String get logSearchNativeAdUnitId => _getNativeId(
    prodAndroid: _searchNativeAndroidRes,
    prodIOS: _searchNativeIOSRes,
  );

  static String get missionNativeAdUnitId => _getNativeId(
    prodAndroid: _missionNativeAndroidRes,
    prodIOS: _missionNativeIOSRes,
  );

  static String get settingsNativeAdUnitId => _getNativeId(
    prodAndroid: _settingsNativeAndroidRes,
    prodIOS: _settingsNativeIOSRes,
  );

  // ---------------------------------------------------------------------------
  // 判定ロジック（共通）
  // ---------------------------------------------------------------------------

  static String _getNativeId({
    required String prodAndroid,
    required String prodIOS,
  }) {
    if (useTestAd) {
      // テスト用ユニットID
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-3940256099942544/3986624511';
    } else {
      // 本番用ユニットID
      if (Platform.isAndroid) return prodAndroid;
      if (Platform.isIOS) return prodIOS;
      throw UnsupportedError('Unsupported platform');
    }
  }
}
