import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models.dart' as models;
import '../main.dart';
import '../widgets/wafu_icon.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          l10n.mission,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kUrushiBlack,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('master_missions')
                .snapshots(),
            builder: (context, mSnapshot) {
              if (!mSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user_logs')
                    .where('userId', isEqualTo: user?.uid ?? 'guest')
                    .snapshots(),
                builder: (context, lSnapshot) {
                  final userVisits = lSnapshot.hasData
                      ? lSnapshot.data!.docs
                            .map(
                              (doc) => models.Visit.fromFirestore(
                                doc as DocumentSnapshot<Map<String, dynamic>>,
                              ),
                            )
                            .toList()
                      : <models.Visit>[];

                  final missions = mSnapshot.data!.docs
                      .map(
                        (doc) => models.Mission.fromFirestore(
                          doc as DocumentSnapshot<Map<String, dynamic>>,
                        ),
                      )
                      .toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: missions.length,
                    itemBuilder: (context, index) =>
                        _buildMissionItem(context, missions[index], userVisits),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMissionItem(
    BuildContext context,
    models.Mission mission,
    List<models.Visit> userVisits,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final count = mission.getAchievedCount(userVisits);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const WafuIcon(
          assetName: 'kabuto',
          fallbackType: WafuIconType.kabuto,
          color: kSengokuGold,
          size: 28,
        ),
        title: Text(
          mission.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$count / ${mission.targetSpotIds.length} ${l10n.achieved}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.description,
                  style: const TextStyle(fontSize: 13, color: kIshigakiGrey),
                ),
                const SizedBox(height: 12),
                ...mission.targetSpotIds.map(
                  (id) => FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future:
                        FirebaseFirestore.instance
                                .collection('master_spots')
                                .doc(id)
                                .get()
                            as Future<DocumentSnapshot<Map<String, dynamic>>>,
                    builder: (context, snapshot) {
                      final name = snapshot.hasData
                          ? models.Spot.fromFirestore(
                              snapshot.data!,
                            ).displayName
                          : id;
                      final visited = mission.isSpotAchieved(id, userVisits);
                      return ListTile(
                        leading: Icon(
                          visited
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: visited ? kVisitedGreen : kUnselectedGrey,
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: visited
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          final navState = context
                              .findAncestorStateOfType<
                                MainNavigationScreenState
                              >();
                          navState?.navigateToRecord(
                            name.split(' (')[0],
                            visited ? RecordMode.view : RecordMode.newRecord,
                            spotId: id,
                          );
                        },
                      );
                    },
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
