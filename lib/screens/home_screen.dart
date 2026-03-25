import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models.dart' as models;
import '../theme.dart';
import '../main.dart';
import '../widgets/wafu_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  // テスト用ネイティブ広告ユニットID
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
          debugPrint('$NativeAd loaded.');
          setState(() {
            _nativeAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('$NativeAd failed to load: $error');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      // 既存のUIに馴染ませるためのスタイリング
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
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: kIshigakiGrey,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    )..load();
  }

  void _showSupportDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kUrushiBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: kSengokuGold, width: 0.5),
        ),
        title: Text(
          l10n.supportDeveloper,
          style: const TextStyle(
            color: kSengokuGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.supportMessage,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.close,
              style: const TextStyle(color: kIshigakiGrey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kSengokuGold,
              foregroundColor: kUrushiBlack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final url = Uri.parse('https://buymeacoffee.com/tayack');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              l10n.supportConfirm,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_logs')
          .where('userId', isEqualTo: user?.uid ?? 'guest')
          .orderBy('visitDate', descending: true)
          .orderBy('updatedAt', descending: true)
          .orderBy(FieldPath.documentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.errorFetchingData}\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final totalCount = docs.length;

        final allSpotIds = docs.map((doc) {
          final v = models.Visit.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          );
          return v.spotId;
        }).toList();

        final recentDocs = docs.take(5).toList();

        final Map<int, int> yearlyCounts = {};
        for (var doc in docs) {
          final visit = models.Visit.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          );
          final year = visit.visitDate.year;
          yearlyCounts[year] = (yearlyCounts[year] ?? 0) + 1;
        }
        final sortedYears = yearlyCounts.keys.toList()
          ..sort((a, b) => a.compareTo(b));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 登城数表示エリア
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kSengokuGold, kSengokuGold.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kSengokuGold.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.totalVisits,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$totalCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.castleUnit,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (sortedYears.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Colors.white24, height: 1),
                      ),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: sortedYears.map((year) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$year${l10n.yearUnit}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${yearlyCounts[year]}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 開発支援ボタン
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showSupportDialog(context),
                  icon: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 20,
                    height: 20,
                  ),
                  label: Text(
                    l10n.supportApp,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kSengokuGold,
                    side: const BorderSide(color: kSengokuGold, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 最新の訪問履歴タイトル
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentVisits,
                    style: const TextStyle(
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
                            ?.setSelectedIndex(2);
                      },
                      child: Text(l10n.seeAll),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (docs.isEmpty)
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
                        Text(
                          l10n.noRecords,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: kIshigakiGrey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...recentDocs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final doc = entry.value;
                  final visit = models.Visit.fromFirestore(
                    doc as DocumentSnapshot<Map<String, dynamic>>,
                  );
                  return _buildRecentLogCard(context, visit, allSpotIds, index);
                }).toList(),

              // ネイティブ広告エリア
              if (_nativeAdIsLoaded)
                Column(
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
                            border: Border.all(
                              color: kIshigakiGrey,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PR',
                            style: TextStyle(
                              fontSize: 10,
                              color: kIshigakiGrey,
                            ),
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
                      height: 130, // Validator対策で120から130に微増
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
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentLogCard(
    BuildContext context,
    models.Visit visit,
    List<String> allSpotIds,
    int index,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('master_spots')
          .doc(visit.spotId)
          .get(),
      builder: (context, snapshot) {
        String title = l10n.loading;
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
                    spotIds: allSpotIds,
                    initialIndex: index,
                  );
            },
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
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
