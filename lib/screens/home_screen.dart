import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models.dart' as models;
import '../main.dart';
import '../widgets/wafu_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentSummary,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kUrushiBlack,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user_logs')
                .where('userId', isEqualTo: user?.uid ?? 'guest')
                .orderBy('visitDate', descending: true)
                .limit(2)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No records found.'),
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final visit = models.Visit.fromFirestore(
                    doc as DocumentSnapshot<Map<String, dynamic>>,
                  );
                  return _buildSummaryCard(context, visit);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, models.Visit visit) {
    return InkWell(
      onTap: () {
        final navState = context
            .findAncestorStateOfType<MainNavigationScreenState>();
        navState?.navigateToRecord(
          visit.displayTitle,
          RecordMode.view,
          spotId: visit.spotId,
        );
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
                  Expanded(
                    child: Text(
                      visit.displayTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy/MM/dd').format(visit.visitDate),
                    style: const TextStyle(fontSize: 12, color: kIshigakiGrey),
                  ),
                ],
              ),
              if (visit.personalNote != null &&
                  visit.personalNote!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  visit.personalNote!,
                  style: const TextStyle(fontSize: 14, color: kUrushiBlack),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
