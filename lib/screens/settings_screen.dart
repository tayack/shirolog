import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

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
      adUnitId: _adUnitId,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.settings,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),

        if (user != null && user.isAnonymous)
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
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
          onTap: () async {
            if (user != null && user.isAnonymous) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(l10n.logoutWarningTitle),
                  content: Text(l10n.logoutWarningContent),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
            }
            await FirebaseAuth.instance.signOut();
          },
        ),

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
                  child: AdWidget(ad: _nativeAd!),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
