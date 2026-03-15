import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models.dart' as models;
import '../main.dart';
import '../widgets/wafu_icon.dart';

class LogSearchScreen extends StatelessWidget {
  const LogSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ShiroSearchField(hintText: l10n.search),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user_logs')
                .where('userId', isEqualTo: user?.uid ?? 'guest')
                .orderBy('visitDate', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty)
                return const Center(child: Text('No records found.'));

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final visit = models.Visit.fromFirestore(
                    docs[index] as DocumentSnapshot<Map<String, dynamic>>,
                  );
                  return ListTile(
                    leading: const WafuIcon(
                      assetName: 'home',
                      fallbackType: WafuIconType.tenshu,
                      color: kSengokuGold,
                      size: 24,
                    ),
                    title: Text(
                      visit.displayTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat('yyyy/MM/dd').format(visit.visitDate),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: kIshigakiGrey,
                    ),
                    onTap: () {
                      final navState = context
                          .findAncestorStateOfType<MainNavigationScreenState>();
                      navState?.navigateToRecord(
                        visit.displayTitle,
                        RecordMode.view,
                        spotId: visit.spotId,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
