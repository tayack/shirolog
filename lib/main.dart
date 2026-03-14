import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

// --- シロログ配色ガイドライン ---
const kSengokuGold = Color(0xFFC5A059); // 戦国ゴールド
const kUrushiBlack = Color(0xFF1A1A1A); // 漆黒
const kOffWhite = Color(0xFFFDFCF8); // オフホワイト（和紙風）
const kIshigakiGrey = Color(0xFF4A4A4A); // 石垣グレー
const kBannerYellow = Color(0xFFFFD54F); // 警告バナー用
const kUnselectedGrey = Color(0xFFB0B0B0); // 非選択時の視認性を高めたグレー
const kVisitedGreen = Colors.green;
const kUnvisitedRed = Colors.red;

// 記録画面のモード
enum RecordMode { newRecord, edit, view }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Firebase Consoleでプロジェクトを作成し、google-services.jsonを配置した後に有効化してください
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   debugPrint('Firebase initialization failed: $e');
  // }
  runApp(const ShiroLogApp());
}

class ShiroLogApp extends StatelessWidget {
  const ShiroLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '城Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kOffWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kSengokuGold,
          primary: kSengokuGold,
          surface: kOffWhite,
        ),
        fontFamily: 'serif',
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  String _prefilledCastleName = '';
  RecordMode _currentMode = RecordMode.newRecord;

  // 記録画面へモードを指定して遷移する
  void navigateToRecord(String castleName, RecordMode mode) {
    setState(() {
      _prefilledCastleName = castleName;
      _currentMode = mode;
      _selectedIndex = 1; // 記録タブのインデックス
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      RecordScreen(
        initialCastleName: _prefilledCastleName,
        initialMode: _currentMode,
      ),
      const LogSearchScreen(),
      const MissionScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kUrushiBlack,
        elevation: 0,
        centerTitle: true,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '城',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              TextSpan(
                text: 'Log',
                style: TextStyle(
                  color: kSengokuGold,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Container(
            width: double.infinity,
            color: kBannerYellow,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              '⚠️ ゲストモード: ログインしてデータを保護',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: kUrushiBlack,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // タブを直接押したときは常に「新規作成」にする
            if (index == 1) {
              _prefilledCastleName = '';
              _currentMode = RecordMode.newRecord;
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: kUrushiBlack,
        selectedItemColor: kSengokuGold,
        unselectedItemColor: kUnselectedGrey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: WafuIcon(
              assetName: 'home',
              fallbackType: WafuIconType.tenshu,
              color: kUnselectedGrey,
            ),
            activeIcon: WafuIcon(
              assetName: 'home',
              fallbackType: WafuIconType.tenshu,
              color: kSengokuGold,
            ),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: WafuIcon(
              assetName: 'record',
              fallbackType: WafuIconType.record,
              color: kUnselectedGrey,
            ),
            activeIcon: WafuIcon(
              assetName: 'record',
              fallbackType: WafuIconType.record,
              color: kSengokuGold,
            ),
            label: '記録',
          ),
          BottomNavigationBarItem(
            icon: WafuIcon(
              assetName: 'search',
              fallbackType: WafuIconType.logSearch,
              color: kUnselectedGrey,
            ),
            activeIcon: WafuIcon(
              assetName: 'search',
              fallbackType: WafuIconType.logSearch,
              color: kSengokuGold,
            ),
            label: 'ログ検索',
          ),
          BottomNavigationBarItem(
            icon: WafuIcon(
              assetName: 'mission',
              fallbackType: WafuIconType.gunbai,
              color: kUnselectedGrey,
            ),
            activeIcon: WafuIcon(
              assetName: 'mission',
              fallbackType: WafuIconType.gunbai,
              color: kSengokuGold,
            ),
            label: 'ミッション',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 24),
            label: '設定',
          ),
        ],
      ),
    );
  }
}

class ShiroSearchField extends StatelessWidget {
  final String hintText;
  final String tooltip;
  final bool readOnly;
  final TextEditingController? controller;

  const ShiroSearchField({
    super.key,
    required this.hintText,
    required this.tooltip,
    this.readOnly = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: readOnly ? Colors.grey[50] : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kSengokuGold),
          ),
        ),
      ),
    );
  }
}

// --- 1. ホーム画面 ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近の登城サマリー',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kUrushiBlack,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(context, '姫路城', '2024/03/01 訪問', '白鷺城の美しさに感動しました。'),
          _buildSummaryCard(context, '竹田城', '2024/02/15 訪問', '雲海が見事でした。'),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String name,
    String date,
    String comment,
  ) {
    return InkWell(
      onTap: () {
        final navState = context
            .findAncestorStateOfType<MainNavigationScreenState>();
        navState?.navigateToRecord(name, RecordMode.view);
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const WafuIcon(
                    assetName: 'home',
                    fallbackType: WafuIconType.tenshu,
                    color: kSengokuGold,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: kIshigakiGrey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comment,
                style: const TextStyle(fontSize: 14, color: kUrushiBlack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. 記録画面 (新規・編集・参照) ---
class RecordScreen extends StatefulWidget {
  final String initialCastleName;
  final RecordMode initialMode;
  const RecordScreen({
    super.key,
    this.initialCastleName = '',
    this.initialMode = RecordMode.newRecord,
  });

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late TextEditingController _castleController;
  late TextEditingController _commentController;
  late RecordMode _currentMode;

  @override
  void initState() {
    super.initState();
    _castleController = TextEditingController(text: widget.initialCastleName);
    _commentController = TextEditingController(
      text: widget.initialMode == RecordMode.view
          ? '白鷺城の美しさに感動しました。当時のまま残る連立式天守は圧巻でした。'
          : '',
    );
    _currentMode = widget.initialMode;
  }

  @override
  void didUpdateWidget(RecordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCastleName != oldWidget.initialCastleName ||
        widget.initialMode != oldWidget.initialMode) {
      _castleController.text = widget.initialCastleName;
      _currentMode = widget.initialMode;
    }
  }

  @override
  void dispose() {
    _castleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onSharePressed() {
    final castleName = _castleController.text;
    // ここでAIによる解説文を生成する想定
    final aiText = "天下の名城、${castleName}。その白壁は、数多の戦を見つめてきた歴史の証人です。";
    final shareText = "$aiText #城Log #${castleName.replaceAll(' ', '')}";
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    String titleText = "登城を記録する";
    String buttonText = "記録を保存する";
    bool isReadOnly = _currentMode == RecordMode.view;

    if (_currentMode == RecordMode.view) {
      titleText = "登城の記録";
      buttonText = "内容を編集する";
    } else if (_currentMode == RecordMode.edit) {
      titleText = "記録を編集する";
      buttonText = "変更を保存する";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kUrushiBlack,
            ),
          ),
          const SizedBox(height: 24),
          ShiroSearchField(
            hintText: '城名を検索',
            tooltip: 'お城の名前',
            controller: _castleController,
            readOnly: isReadOnly,
          ),
          const SizedBox(height: 16),
          const ShiroSearchField(
            hintText: '訪問日',
            tooltip: '訪問した日付',
            readOnly: true,
          ),
          const SizedBox(height: 16),
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kIshigakiGrey.withOpacity(0.2)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WafuIcon(
                  assetName: 'record',
                  fallbackType: WafuIconType.record,
                  color: kIshigakiGrey,
                  size: 40,
                ),
                SizedBox(height: 8),
                Text('写真を添付', style: TextStyle(color: kIshigakiGrey)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              hintText: '一言メモ（エピソード）',
              filled: true,
              fillColor: isReadOnly ? Colors.grey[50] : Colors.white,
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kSengokuGold,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (_currentMode == RecordMode.view) {
                setState(() => _currentMode = RecordMode.edit);
              } else {
                // 保存処理（モック）
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('投稿が完了しました！'),
                    action: SnackBarAction(
                      label: 'SNSでシェア',
                      textColor: kSengokuGold,
                      onPressed: _onSharePressed,
                    ),
                  ),
                );
                setState(() => _currentMode = RecordMode.view);
              }
            },
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. ログ検索画面 ---
class LogSearchScreen extends StatelessWidget {
  const LogSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: ShiroSearchField(
            hintText: '訪問記録を検索...',
            tooltip: 'キーワードで検索できます',
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 10,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Colors.black12),
            itemBuilder: (context, index) => ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 8,
              ),
              leading: const WafuIcon(
                assetName: 'home',
                fallbackType: WafuIconType.tenshu,
                color: kSengokuGold,
                size: 24,
              ),
              title: Text(
                'お城の名前 #${10 - index}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text(
                '2024/01/01 訪問録',
                style: TextStyle(fontSize: 14),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: kIshigakiGrey,
                size: 20,
              ),
              onTap: () {
                final navState = context
                    .findAncestorStateOfType<MainNavigationScreenState>();
                navState?.navigateToRecord(
                  'お城の名前 #${10 - index}',
                  RecordMode.view,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// --- 4. ミッション画面 ---
class Mission {
  final String id;
  final String leader;
  final String title;
  final String description;
  final List<CastleInMission> castles;
  bool isGoal;
  Mission({
    required this.id,
    required this.leader,
    required this.title,
    required this.description,
    required this.castles,
    this.isGoal = false,
  });
  bool get isCompleted => castles.every((c) => c.visited);
}

class CastleInMission {
  final String name;
  final bool visited;
  CastleInMission({required this.name, required this.visited});
}

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});
  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  final List<Mission> _allMissions = [
    Mission(
      id: '1',
      leader: '伊達政宗',
      title: '独眼竜の野望',
      description: '北の雄、伊達政宗ゆかりの地を巡る軌跡。',
      castles: [
        CastleInMission(name: '青葉城', visited: true),
        CastleInMission(name: '白石城', visited: false),
      ],
      isGoal: true,
    ),
    Mission(
      id: '2',
      leader: '織田信長',
      title: '天下布武への道',
      description: '革新的な城郭を巡るミッション。',
      castles: [
        CastleInMission(name: '安土城', visited: false),
        CastleInMission(name: '岐阜城', visited: true),
      ],
    ),
    Mission(
      id: '3',
      leader: '豊臣秀吉',
      title: '太閤の黄金城',
      description: '豪華絢爛な城郭を巡ります。',
      castles: [
        CastleInMission(name: '大阪城', visited: true),
        CastleInMission(name: '伏見城', visited: true),
      ],
      isGoal: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final goalMissions = _allMissions
        .where((m) => m.isGoal && !m.isCompleted)
        .toList();
    final completedMissions = _allMissions.where((m) => m.isCompleted).toList();
    final unstartedMissions = _allMissions
        .where((m) => !m.isGoal && !m.isCompleted)
        .toList();

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'ミッション',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kUrushiBlack,
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: ShiroSearchField(
            hintText: 'ミッション検索...',
            tooltip: 'キーワードで検索できます',
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              _buildSectionAccordion('選択中の目標', kSengokuGold, goalMissions),
              _buildSectionAccordion('未着手', kUrushiBlack, unstartedMissions),
              _buildSectionAccordion('達成済み', kIshigakiGrey, completedMissions),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionAccordion(
    String title,
    Color color,
    List<Mission> missions,
  ) {
    if (missions.isEmpty) return const SizedBox.shrink();
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        backgroundColor: color.withOpacity(0.05),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: missions
            .map((m) => _buildMissionAccordion(m, color))
            .toList(),
      ),
    );
  }

  Widget _buildMissionAccordion(Mission mission, Color themeColor) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: ExpansionTile(
        key: PageStorageKey(mission.id),
        leading: WafuIcon(
          assetName: 'kabuto',
          fallbackType: WafuIconType.kabuto,
          color: themeColor,
          size: 28,
        ),
        title: Text(
          mission.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeColor,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${mission.leader} - 進捗 ${mission.castles.where((c) => c.visited).length}/${mission.castles.length}',
          style: const TextStyle(fontSize: 11),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.description,
                  style: const TextStyle(fontSize: 13, color: kIshigakiGrey),
                ),
                const SizedBox(height: 12),
                ...mission.castles.map(
                  (castle) => InkWell(
                    onTap: () {
                      final navState = context
                          .findAncestorStateOfType<MainNavigationScreenState>();
                      // 訪問済みなら参照モード、未訪問なら新規モードで遷移
                      navState?.navigateToRecord(
                        castle.name,
                        castle.visited ? RecordMode.view : RecordMode.newRecord,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            castle.visited ? Icons.check_circle : Icons.stars,
                            color: castle.visited
                                ? kVisitedGreen
                                : kUnvisitedRed,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            castle.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: kUrushiBlack,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.edit_note,
                            size: 16,
                            color: kIshigakiGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => mission.isGoal = !mission.isGoal),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeColor,
                      side: BorderSide(color: themeColor),
                    ),
                    child: Text(mission.isGoal ? '目標から解除する' : '目標に設定する'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 5. 設定画面 ---
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            '設定',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kUrushiBlack,
            ),
          ),
        ),
        _buildSectionTitle('SNSアカウント連携'),
        _buildSettingsItem(
          icon: Icons.share,
          title: 'X (旧Twitter) 連携',
          subtitle: '未連携',
        ),
        _buildSettingsItem(
          icon: Icons.camera_alt,
          title: 'Instagram 連携',
          subtitle: '連携済み',
          trailing: const Icon(Icons.check_circle, color: Colors.green),
        ),
        const Divider(height: 32),
        _buildSectionTitle('アプリ情報'),
        _buildSettingsItem(
          icon: Icons.info_outline,
          title: 'バージョン',
          subtitle: '1.0.0',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: kIshigakiGrey,
      ),
    ),
  );
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
    leading: Icon(icon, color: kUrushiBlack),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, color: kUrushiBlack),
    ),
    subtitle: subtitle != null
        ? Text(subtitle, style: const TextStyle(color: kIshigakiGrey))
        : null,
    trailing: trailing,
  );
}

// --- 共通アイコンコンポーネント ---
enum WafuIconType { tenshu, record, logSearch, mission, kabuto, gunbai }

class WafuIcon extends StatelessWidget {
  final String assetName;
  final WafuIconType fallbackType;
  final Color color;
  final double size;
  const WafuIcon({
    super.key,
    required this.assetName,
    required this.fallbackType,
    required this.color,
    this.size = 24,
  });
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/$assetName.png',
      width: size,
      height: size,
      color: color,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => CustomPaint(
        size: Size(size, size),
        painter: _WafuPainter(fallbackType, color),
      ),
    );
  }
}

class _WafuPainter extends CustomPainter {
  final WafuIconType type;
  final Color color;
  _WafuPainter(this.type, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    switch (type) {
      case WafuIconType.tenshu:
        path.moveTo(size.width * 0.5, 0);
        path.lineTo(size.width * 0.1, size.height * 0.4);
        path.lineTo(size.width * 0.9, size.height * 0.4);
        path.close();
        path.addRect(
          Rect.fromLTWH(
            size.width * 0.2,
            size.height * 0.45,
            size.width * 0.6,
            size.height * 0.55,
          ),
        );
        break;
      case WafuIconType.gunbai:
        path.addOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.5, size.height * 0.4),
            width: size.width * 0.7,
            height: size.height * 0.7,
          ),
        );
        path.addRect(
          Rect.fromLTWH(
            size.width * 0.45,
            size.height * 0.7,
            size.width * 0.1,
            size.height * 0.3,
          ),
        );
        break;
      case WafuIconType.kabuto:
        path.moveTo(size.width * 0.2, size.height * 0.8);
        path.quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.1,
          size.width * 0.8,
          size.height * 0.8,
        );
        break;
      case WafuIconType.record:
        path.addRect(
          Rect.fromLTWH(
            size.width * 0.2,
            size.height * 0.1,
            size.width * 0.1,
            size.height * 0.8,
          ),
        );
        break;
      case WafuIconType.logSearch:
        canvas.drawCircle(
          Offset(size.width * 0.4, size.height * 0.4),
          size.width * 0.3,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        break;
      default:
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
