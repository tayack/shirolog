import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final isJa = Localizations.localeOf(context).languageCode == 'ja';

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.settings,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),

        // Google連携ボタン (ゲストユーザーのみ)
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
          trailing: Text(isJa ? l10n.japanese : l10n.english),
          onTap: () {
            ShiroLogApp.of(context)?.setLocale(Locale(isJa ? 'en' : 'ja'));
          },
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
      ],
    );
  }
}
