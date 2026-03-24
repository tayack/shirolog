import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/record_screen.dart';
import 'screens/log_search_screen.dart';
import 'screens/mission_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/wafu_icon.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase error: $e');
  }
  final prefs = await SharedPreferences.getInstance();
  final String? languageCode = prefs.getString('language_code');
  runApp(
    ShiroLogApp(
      initialLocale: languageCode != null ? Locale(languageCode) : null,
    ),
  );
}

class ShiroLogApp extends StatefulWidget {
  final Locale? initialLocale;
  const ShiroLogApp({super.key, this.initialLocale});
  static ShiroLogAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<ShiroLogAppState>();
  @override
  State<ShiroLogApp> createState() => ShiroLogAppState();
}

class ShiroLogAppState extends State<ShiroLogApp> {
  Locale? _locale;
  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  Future<void> setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '城ログ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kOffWhite,
        colorScheme: ColorScheme.fromSeed(seedColor: kSengokuGold),
        fontFamily: 'serif',
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja'), Locale('en')],
      locale: _locale,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.hasData
            ? const MainNavigationScreen()
            : const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.isAnonymous) {
        await user.linkWithCredential(credential);
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isJa = Localizations.localeOf(context).languageCode == 'ja';
    final splitIdx = isJa ? 1 : 5; // "城" (1文字) または "Shiro" (5文字)
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const WafuIcon(
                assetName: 'home',
                fallbackType: WafuIconType.tenshu,
                color: kSengokuGold,
                size: 100,
              ),
              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.loginTitle.substring(0, splitIdx),
                      style: const TextStyle(
                        color: kUrushiBlack,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    TextSpan(
                      text: l10n.loginTitle.substring(splitIdx),
                      style: const TextStyle(
                        color: kSengokuGold,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.loginSubtitle,
                style: const TextStyle(fontSize: 16, color: kIshigakiGrey),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.japanese,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isJa ? FontWeight.bold : FontWeight.normal,
                      color: isJa ? kSengokuGold : kIshigakiGrey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Switch(
                      value: !isJa,
                      activeColor: kSengokuGold,
                      onChanged: (v) => ShiroLogApp.of(
                        context,
                      )?.setLocale(Locale(v ? 'en' : 'ja')),
                    ),
                  ),
                  Text(
                    l10n.english,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: !isJa ? FontWeight.bold : FontWeight.normal,
                      color: !isJa ? kSengokuGold : kIshigakiGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 280,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.login),
                  label: Text(l10n.googleLogin),
                  onPressed: () => _handleGoogleSignIn(context),
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signInAnonymously(),
                child: Text(
                  l10n.guestLogin,
                  style: const TextStyle(
                    color: kIshigakiGrey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  MainNavigationScreenState createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // 記録画面用のパラメータ
  String _prefilledCastleName = '';
  String? _prefilledSpotId;
  RecordMode _currentMode = RecordMode.newRecord;

  // スワイプ閲覧用のパラメータ
  List<String>? _swipeSpotIds;
  int _swipeInitialIndex = 0;

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _prefilledCastleName = '';
        _prefilledSpotId = null;
        _currentMode = RecordMode.newRecord;
        _swipeSpotIds = null;
      }
    });
  }

  void navigateToRecord(
    String castleName,
    RecordMode mode, {
    String? spotId,
    List<String>? spotIds,
    int initialIndex = 0,
  }) {
    setState(() {
      _prefilledCastleName = castleName;
      _prefilledSpotId = spotId;
      _currentMode = mode;
      _swipeSpotIds = spotIds;
      _swipeInitialIndex = initialIndex;
      _selectedIndex = 1;
    });
  }

  Future<void> handleLink() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.linkSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final isJa = Localizations.localeOf(context).languageCode == 'ja';
    final splitIdx = isJa ? 1 : 5; // "城" (1文字) または "Shiro" (5文字)

    final List<Widget> screens = [
      const HomeScreen(),
      RecordScreen(
        initialCastleName: _prefilledCastleName,
        initialSpotId: _prefilledSpotId,
        initialMode: _currentMode,
        swipeSpotIds: _swipeSpotIds,
        swipeInitialIndex: _swipeInitialIndex,
      ),
      const LogSearchScreen(),
      const MissionScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kUrushiBlack,
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: l10n.appTitle.substring(0, splitIdx),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              TextSpan(
                text: l10n.appTitle.substring(splitIdx),
                style: const TextStyle(
                  color: kSengokuGold,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        bottom: (user != null && user.isAnonymous)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(36),
                child: InkWell(
                  onTap: handleLink,
                  child: Container(
                    width: double.infinity,
                    color: kBannerYellow,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n.guestModeWarning,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: kUrushiBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: setSelectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: kUrushiBlack,
        selectedItemColor: kSengokuGold,
        unselectedItemColor: kUnselectedGrey,
        items: [
          BottomNavigationBarItem(
            icon: const WafuIcon(
              assetName: 'home',
              fallbackType: WafuIconType.tenshu,
              color: kUnselectedGrey,
            ),
            activeIcon: const WafuIcon(
              assetName: 'home',
              fallbackType: WafuIconType.tenshu,
              color: kSengokuGold,
            ),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const WafuIcon(
              assetName: 'record',
              fallbackType: WafuIconType.record,
              color: kUnselectedGrey,
            ),
            activeIcon: const WafuIcon(
              assetName: 'record',
              fallbackType: WafuIconType.record,
              color: kSengokuGold,
            ),
            label: l10n.record,
          ),
          BottomNavigationBarItem(
            icon: const WafuIcon(
              assetName: 'search',
              fallbackType: WafuIconType.logSearch,
              color: kUnselectedGrey,
            ),
            activeIcon: const WafuIcon(
              assetName: 'search',
              fallbackType: WafuIconType.logSearch,
              color: kSengokuGold,
            ),
            label: l10n.search,
          ),
          BottomNavigationBarItem(
            icon: const WafuIcon(
              assetName: 'mission',
              fallbackType: WafuIconType.gunbai,
              color: kUnselectedGrey,
            ),
            activeIcon: const WafuIcon(
              assetName: 'mission',
              fallbackType: WafuIconType.gunbai,
              color: kSengokuGold,
            ),
            label: l10n.mission,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings, size: 24),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
