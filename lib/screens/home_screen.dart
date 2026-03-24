import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models.dart' as models;
import '../theme.dart';
import '../main.dart';
import '../widgets/wafu_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_logs')
          .where('userId', isEqualTo: user?.uid ?? 'guest')
          .orderBy('visitDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final totalCount = docs.length;
        final recentDocs = docs.take(5).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 登城数表示エリア
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kSengokuGold, kSengokuGold.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kSengokuGold.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '総登城数',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$totalCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif', // 和風な雰囲気を出す
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '城',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 最新の訪問履歴タイトル
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '最新の訪問履歴',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kUrushiBlack,
                    ),
                  ),
                  if (totalCount > 5)
                    TextButton(
                      onPressed: () {
                        context
                            .findAncestorStateOfType<
                              MainNavigationScreenState
                            >()
                            ?.setSelectedIndex(2); // ログ検索へ
                      },
                      child: const Text('すべて見る'),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (recentDocs.isEmpty)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.fort_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'まだ記録がありません。\nお城を巡って記録を残しましょう！',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: kIshigakiGrey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...recentDocs.map((doc) {
                  final visit = models.Visit.fromFirestore(
                    doc as DocumentSnapshot<Map<String, dynamic>>,
                  );
                  return _buildRecentLogCard(context, visit);
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentLogCard(BuildContext context, models.Visit visit) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('master_spots')
          .doc(visit.spotId)
          .get(),
      builder: (context, snapshot) {
        String title = '読み込み中...';
        if (snapshot.hasData && snapshot.data!.exists) {
          final spot = models.Spot.fromFirestore(
            snapshot.data! as DocumentSnapshot<Map<String, dynamic>>,
          );
          if (spot != null) {
            title = spot.getName(context);
          }
        }

        final hasImage = visit.photoUrls.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              context
                  .findAncestorStateOfType<MainNavigationScreenState>()
                  ?.navigateToRecord(
                    title,
                    RecordMode.view,
                    spotId: visit.spotId,
                  );
            },
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                // 写真 (またはアイコン)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    image: hasImage
                        ? DecorationImage(
                            image: NetworkImage(visit.photoUrls.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: !hasImage
                      ? const Center(
                          child: WafuIcon(
                            assetName: 'home',
                            fallbackType: WafuIconType.tenshu,
                            color: Colors.grey,
                            size: 32,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // 城名と日付
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kUrushiBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('yyyy/MM/dd').format(visit.visitDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: kIshigakiGrey),
              ],
            ),
          ),
        );
      },
    );
  }
}
