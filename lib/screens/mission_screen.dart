import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../l10n/app_localizations.dart';
import '../models.dart' as models;
import '../theme.dart';
import '../widgets/wafu_icon.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  Set<String> _favoriteMissionIds = {};
  final Map<String, bool> _sectionExpanded = {
    'favorites': true,
    'inProgress': true,
    'unstarted': false,
    'completed': false,
  };

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
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

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteMissionIds = (prefs.getStringList('favorite_missions') ?? [])
          .toSet();
    });
  }

  Future<void> _toggleFavorite(String missionId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteMissionIds.contains(missionId)) {
        _favoriteMissionIds.remove(missionId);
      } else {
        _favoriteMissionIds.add(missionId);
      }
      prefs.setStringList('favorite_missions', _favoriteMissionIds.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamic l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('master_missions')
          .snapshots(),
      builder: (context, mSnapshot) {
        if (!mSnapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user_logs')
              .where('userId', isEqualTo: user?.uid ?? 'guest')
              .snapshots(),
          builder: (context, lSnapshot) {
            final visits = lSnapshot.hasData
                ? lSnapshot.data!.docs
                      .map(
                        (d) => models.Visit.fromFirestore(
                          d as DocumentSnapshot<Map<String, dynamic>>,
                        ),
                      )
                      .toList()
                : <models.Visit>[];

            final missions = mSnapshot.data!.docs
                .map(
                  (d) => models.Mission.fromFirestore(
                    d as DocumentSnapshot<Map<String, dynamic>>,
                  ),
                )
                .toList();

            final favoriteMissions = <models.Mission>[];
            final completedMissions = <models.Mission>[];
            final inProgressMissions = <models.Mission>[];
            final unstartedMissions = <models.Mission>[];

            for (final mission in missions) {
              final count = mission.getAchievedCount(visits);
              final isFav = _favoriteMissionIds.contains(mission.id);

              if (isFav) {
                favoriteMissions.add(mission);
              } else if (count == mission.targetSpotIds.length) {
                completedMissions.add(mission);
              } else if (count > 0) {
                inProgressMissions.add(mission);
              } else {
                unstartedMissions.add(mission);
              }
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildExpandableSection(
                  'favorites',
                  _getTranslation(l10n, 'favoriteMissions', 'お気に入り'),
                  favoriteMissions,
                  visits,
                ),
                _buildExpandableSection(
                  'inProgress',
                  _getTranslation(l10n, 'inProgressMissions', '挑戦中'),
                  inProgressMissions,
                  visits,
                ),
                _buildExpandableSection(
                  'unstarted',
                  _getTranslation(l10n, 'unstartedMissions', '未挑戦'),
                  unstartedMissions,
                  visits,
                ),
                _buildExpandableSection(
                  'completed',
                  _getTranslation(l10n, 'completedMissions', '達成済み'),
                  completedMissions,
                  visits,
                ),

                // ネイティブ広告エリア
                if (_nativeAdIsLoaded)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
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
                          const Text(
                            'おすすめコンテンツ',
                            style: TextStyle(
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
                      const SizedBox(height: 16),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildExpandableSection(
    String key,
    String title,
    List<models.Mission> missions,
    List<models.Visit> visits,
  ) {
    if (missions.isEmpty) return const SizedBox.shrink();

    final isExpanded = _sectionExpanded[key] ?? false;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _sectionExpanded[key] = !isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$title (${missions.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kIshigakiGrey,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: kIshigakiGrey,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          ...missions.map((m) => _buildMissionCard(context, m, visits)),
        const SizedBox(height: 12),
      ],
    );
  }

  String _getTranslation(dynamic l10n, String key, String fallback) {
    try {
      switch (key) {
        case 'favoriteMissions':
          return l10n.favoriteMissions;
        case 'inProgressMissions':
          return l10n.inProgressMissions;
        case 'unstartedMissions':
          return l10n.unstartedMissions;
        case 'completedMissions':
          return l10n.completedMissions;
        default:
          return fallback;
      }
    } catch (_) {
      return fallback;
    }
  }

  Widget _buildMissionCard(
    BuildContext context,
    models.Mission mission,
    List<models.Visit> visits,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final count = mission.getAchievedCount(visits);
    final isCompleted = count == mission.targetSpotIds.length;
    final isFav = _favoriteMissionIds.contains(mission.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        key: PageStorageKey(mission.id),
        leading: WafuIcon(
          assetName: 'kabuto',
          fallbackType: WafuIconType.kabuto,
          color: isCompleted ? kVisitedGreen : kSengokuGold,
          size: 28,
        ),
        title: Text(
          mission.getTitle(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$count / ${mission.targetSpotIds.length} ${l10n.achieved}',
        ),
        trailing: IconButton(
          icon: Icon(isFav ? Icons.star : Icons.star_border),
          color: isFav ? Colors.amber : Colors.grey,
          onPressed: () => _toggleFavorite(mission.id),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.getDescription(context),
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
                    builder: (context, s) {
                      final spot = s.hasData
                          ? models.Spot.fromFirestore(s.data!)
                          : null;
                      final name = spot != null
                          ? spot.getDisplayName(context)
                          : id;
                      final done = mission.isSpotAchieved(id, visits);
                      return ListTile(
                        leading: Icon(
                          done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: done ? kVisitedGreen : kUnselectedGrey,
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: done
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
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
