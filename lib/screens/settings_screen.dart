import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../theme.dart';
import '../ad_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AdHelper.settingsNativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _nativeAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: Colors.white,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: kSengokuGold,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: kUrushiBlack,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: kIshigakiGrey,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
      ),
    )..load();
  }

  String _getLanguageName(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    switch (code) {
      case 'ja':
        return '日本語';
      case 'en':
        return 'English';
      case 'zh':
        return '简体中文';
      case 'ko':
        return '한국어';
      default:
        return code;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('日本語'),
              onTap: () {
                ShiroLogApp.of(context)?.setLocale(const Locale('ja'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                ShiroLogApp.of(context)?.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('简体中文'),
              onTap: () {
                ShiroLogApp.of(context)?.setLocale(const Locale('zh'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('한국어'),
              onTap: () {
                ShiroLogApp.of(context)?.setLocale(const Locale('ko'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // 1. ユーザーデータの削除 (Firestore)
      final logsSnapshot = await FirebaseFirestore.instance
          .collection('user_logs')
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in logsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // 2. Authアカウントの削除
      await user.delete();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.accountDeletedMessage)));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (mounted) {
          showDialog(
            context: context,
            builder: (c) => AlertDialog(
              title: Text(l10n.reauthenticationRequiredTitle),
              content: Text(l10n.reauthenticationRequiredMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: Text(l10n.ok),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous = user?.isAnonymous ?? false;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.settings,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),

        if (isAnonymous)
          ListTile(
            leading: const Icon(Icons.sync, color: kSengokuGold),
            title: Text(l10n.linkGoogleAccount),
            onTap: () => context
                .findAncestorStateOfType<MainNavigationScreenState>()
                ?.handleLink(),
          ),

        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          trailing: const Icon(Icons.chevron_right),
          subtitle: Text(_getLanguageName(context)),
          onTap: () => _showLanguageDialog(context),
        ),
        const Divider(),

        // 匿名ユーザー（ゲスト）以外の場合のみ、通常のログアウトを表示
        if (!isAnonymous)
          ListTile(
            leading: const Icon(Icons.logout, color: kIshigakiGrey),
            title: Text(l10n.logout),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),

        // アカウント削除は共通（ゲストにとっては実質的なログアウト+データ清掃）
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: Text(
            l10n.deleteAccount,
            style: const TextStyle(color: Colors.red),
          ),
          onTap: _handleDeleteAccount,
        ),

        const SizedBox(height: 48),

        // 寄付者一覧（石垣風）
        _buildSupportersSection(context),

        // ネイティブ広告エリア
        if (_nativeAdIsLoaded)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: kIshigakiGrey, width: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PR',
                        style: TextStyle(fontSize: 10, color: kIshigakiGrey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.recommendedContent,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kIshigakiGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AdWidget(
                    key: const Key('native_ad_settings'),
                    ad: _nativeAd!,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSupportersSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('supporters').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final supporterNames = snapshot.data!.docs
            .map(
              (doc) => (doc.data() as Map<String, dynamic>)['name'] as String,
            )
            .toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.volunteer_activism, color: kSengokuGold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Supporters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kUrushiBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 野面積みの石垣風レイアウト（密度を高く、背景なし）
              Wrap(
                spacing: 3, // 隙間を最小限に
                runSpacing: 3,
                children: supporterNames.asMap().entries.map((entry) {
                  return _buildIshigakiStone(entry.value, entry.key);
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.supporterIntro,
                style: const TextStyle(fontSize: 11, color: kIshigakiGrey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIshigakiStone(String name, int index) {
    final random = math.Random(index);
    // 石の色を個別に設定（一個前よりも少し明るめのグレーからランダムに）
    final stoneColor = Color.lerp(
      kIshigakiGrey.withOpacity(0.2),
      kIshigakiGrey.withOpacity(0.4),
      random.nextDouble(),
    );

    // よりいびつな形状
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(6 + random.nextDouble() * 15),
      topRight: Radius.circular(6 + random.nextDouble() * 15),
      bottomLeft: Radius.circular(6 + random.nextDouble() * 15),
      bottomRight: Radius.circular(6 + random.nextDouble() * 15),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: stoneColor,
        borderRadius: borderRadius,
        // 石の輪郭をうっすら出す
        border: Border.all(color: kIshigakiGrey.withOpacity(0.1), width: 0.5),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: kIshigakiGrey,
          fontFamily: 'serif',
        ),
      ),
    );
  }
}
