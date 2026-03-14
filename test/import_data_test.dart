import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shirolog/models.dart';

void main() {
  // このテストはエミュレータや実機上で「データのインポート」を実行するためのものです。
  // 通常のユニットテストではなく、便宜上テストフレームワークを利用しています。
  testWidgets('Import seed data to Firestore', (WidgetTester tester) async {
    print('--- データインポート開始 ---');

    // Firebaseの初期化（実機/エミュレータ環境が必要）
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      print('Firebaseの初期化に成功しました。');

      // 1. お城マスター（Spot）のインポート
      print('お城マスターを登録中...');
      await importSpots(seedSpots);

      // 2. ミッション（Mission）のインポート
      print('ミッションデータを登録中...');
      await importMissions([seedMission]);

      print('--- すべてのインポートが完了しました ---');
    } catch (e) {
      print('エラーが発生しました: $e');
      // エラーの詳細を表示
      fail('Import failed: $e');
    }
  });
}
