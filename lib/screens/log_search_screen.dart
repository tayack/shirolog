import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../l10n/app_localizations.dart';
import '../models.dart' as models;
import '../theme.dart';
import '../main.dart';
import '../widgets/wafu_icon.dart';
import '../ad_helper.dart';

class LogSearchScreen extends StatefulWidget {
  const LogSearchScreen({super.key});

  @override
  State<LogSearchScreen> createState() => _LogSearchScreenState();
}

class _LogSearchScreenState extends State<LogSearchScreen> {
  String? _selectedPrefId;
  final TextEditingController _castleController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  String _searchPrefId = '';
  String _searchCastleName = '';
  DateTime? _searchFromDate;
  DateTime? _searchToDate;

  bool _isPanelExpanded = true;
  Timer? _debounce;

  final Map<String, models.Spot> _spotCache = {};

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  final List<Map<String, String>> _prefectures = [
    {'id': '', 'ja': 'すべて', 'en': 'All'},
    {'id': '01', 'ja': '北海道', 'en': 'Hokkaido'},
    {'id': '02', 'ja': '青森県', 'en': 'Aomori'},
    {'id': '03', 'ja': '岩手県', 'en': 'Iwate'},
    {'id': '04', 'ja': '宮城県', 'en': 'Miyagi'},
    {'id': '05', 'ja': '秋田県', 'en': 'Akita'},
    {'id': '06', 'ja': '山形県', 'en': 'Yamagata'},
    {'id': '07', 'ja': '福島県', 'en': 'Fukushima'},
    {'id': '08', 'ja': '茨城県', 'en': 'Ibaraki'},
    {'id': '09', 'ja': '栃木県', 'en': 'Tochigi'},
    {'id': '10', 'ja': '群馬県', 'en': 'Gunma'},
    {'id': '11', 'ja': '埼玉県', 'en': 'Saitama'},
    {'id': '12', 'ja': '千葉県', 'en': 'Chiba'},
    {'id': '13', 'ja': '東京都', 'en': 'Tokyo'},
    {'id': '14', 'ja': '神奈川県', 'en': 'Kanagawa'},
    {'id': '15', 'ja': '新潟県', 'en': 'Niigata'},
    {'id': '16', 'ja': '富山県', 'en': 'Toyama'},
    {'id': '17', 'ja': '石川県', 'en': 'Ishikawa'},
    {'id': '18', 'ja': '福井県', 'en': 'Fukui'},
    {'id': '19', 'ja': '山梨県', 'en': 'Yamanashi'},
    {'id': '20', 'ja': '長野県', 'en': 'Nagano'},
    {'id': '21', 'ja': '岐阜県', 'en': 'Gifu'},
    {'id': '22', 'ja': '静岡県', 'en': 'Shizuoka'},
    {'id': '23', 'ja': '愛知県', 'en': 'Aichi'},
    {'id': '24', 'ja': '三重県', 'en': 'Mie'},
    {'id': '25', 'ja': '滋賀県', 'en': 'Shiga'},
    {'id': '26', 'ja': '京都府', 'en': 'Kyoto'},
    {'id': '27', 'ja': '大阪府', 'en': 'Osaka'},
    {'id': '28', 'ja': '兵庫県', 'en': 'Hyogo'},
    {'id': '29', 'ja': '奈良県', 'en': 'Nara'},
    {'id': '30', 'ja': '和歌山県', 'en': 'Wakayama'},
    {'id': '31', 'ja': '鳥取県', 'en': 'Tottori'},
    {'id': '32', 'ja': '島根県', 'en': 'Shimane'},
    {'id': '33', 'ja': '岡山県', 'en': 'Okayama'},
    {'id': '34', 'ja': '広島県', 'en': 'Hiroshima'},
    {'id': '35', 'ja': '山口県', 'en': 'Yamaguchi'},
    {'id': '36', 'ja': '徳島県', 'en': 'Tokushima'},
    {'id': '37', 'ja': '香川県', 'en': 'Kagawa'},
    {'id': '38', 'ja': '愛媛県', 'en': 'Ehime'},
    {'id': '39', 'ja': '高知県', 'en': 'Kochi'},
    {'id': '40', 'ja': '福岡県', 'en': 'Fukuoka'},
    {'id': '41', 'ja': '佐賀県', 'en': 'Saga'},
    {'id': '42', 'ja': '長崎県', 'en': 'Nagasaki'},
    {'id': '43', 'ja': '熊本県', 'en': 'Kumamoto'},
    {'id': '44', 'ja': '大分県', 'en': 'Oita'},
    {'id': '45', 'ja': '宮崎県', 'en': 'Miyazaki'},
    {'id': '46', 'ja': '鹿児島県', 'en': 'Kagoshima'},
    {'id': '47', 'ja': '沖縄県', 'en': 'Okinawa'},
  ];

  @override
  void initState() {
    super.initState();
    _castleController.addListener(_onSearchChanged);
    _loadAd();
  }

  @override
  void dispose() {
    _castleController.removeListener(_onSearchChanged);
    _castleController.dispose();
    _debounce?.cancel();
    _nativeAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AdHelper.logSearchNativeAdUnitId,
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

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      _searchPrefId = _selectedPrefId ?? '';
      _searchCastleName = _castleController.text.trim();
      _searchFromDate = _fromDate;
      _searchToDate = _toDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final code = Localizations.localeOf(context).languageCode;
    final showEnglishLabel = code == 'en' || code == 'zh' || code == 'ko';

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _isPanelExpanded = !_isPanelExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.filter_list,
                            color: kSengokuGold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.searchCriteria,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kUrushiBlack,
                            ),
                          ),
                          if (!_isPanelExpanded &&
                              (_searchPrefId.isNotEmpty ||
                                  _searchCastleName.isNotEmpty ||
                                  _searchFromDate != null ||
                                  _searchToDate != null))
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: kSengokuGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                l10n.applying,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: kSengokuGold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Icon(
                        _isPanelExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: kIshigakiGrey,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedPrefId,
                        decoration: InputDecoration(
                          labelText: l10n.selectPrefecture,
                          prefixIcon: const Icon(
                            Icons.map_outlined,
                            color: kSengokuGold,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        items: _prefectures.map((pref) {
                          String label = showEnglishLabel
                              ? pref['en']!
                              : pref['ja']!;
                          if (pref['id'] == '') label = l10n.all;
                          return DropdownMenuItem(
                            value: pref['id'],
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedPrefId = val);
                          _onSearchChanged();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _castleController,
                        decoration: InputDecoration(
                          labelText: l10n.searchByCastleName,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: WafuIcon(
                              assetName: 'home',
                              fallbackType: WafuIconType.tenshu,
                              color: kSengokuGold,
                              size: 20,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                          hintText: l10n.exampleCastle,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _fromDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _fromDate = date);
                                  _onSearchChanged();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: l10n.startDate,
                                  prefixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: kSengokuGold,
                                  ),
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  _fromDate == null
                                      ? l10n.notSpecified
                                      : DateFormat(
                                          'yyyy/MM/dd',
                                        ).format(_fromDate!),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('〜'),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _toDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _toDate = date);
                                  _onSearchChanged();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: l10n.endDate,
                                  prefixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: kSengokuGold,
                                  ),
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  _toDate == null
                                      ? l10n.notSpecified
                                      : DateFormat(
                                          'yyyy/MM/dd',
                                        ).format(_toDate!),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if ((_selectedPrefId != null &&
                              _selectedPrefId!.isNotEmpty) ||
                          _castleController.text.isNotEmpty ||
                          _fromDate != null ||
                          _toDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedPrefId = '';
                                _castleController.clear();
                                _fromDate = null;
                                _toDate = null;
                              });
                              _applyFilters();
                            },
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: Text(
                              l10n.clearCriteria,
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                crossFadeState: _isPanelExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user_logs')
                .where('userId', isEqualTo: user?.uid ?? 'guest')
                .orderBy('visitDate', descending: true)
                .orderBy('updatedAt', descending: true)
                .orderBy(FieldPath.documentId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());

              final allDocs = snapshot.data!.docs;

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _filterLogs(allDocs, context),
                builder: (context, filterSnapshot) {
                  if (!filterSnapshot.hasData && _spotCache.isEmpty)
                    return const Center(child: CircularProgressIndicator());

                  final filteredLogs = filterSnapshot.data ?? [];
                  if (filteredLogs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(l10n.noMatchingRecords),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        filteredLogs.length + (_nativeAdIsLoaded ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == filteredLogs.length) {
                        return _buildAdSection(context);
                      }

                      final log = filteredLogs[index];
                      final visit = log['visit'] as models.Visit;
                      final title = log['title'] as String;
                      final hasImage = visit.photoUrls.isNotEmpty;

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              image: hasImage
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        visit.photoUrls.first,
                                      ),
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
                                      size: 24,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('yyyy/MM/dd').format(visit.visitDate),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: kIshigakiGrey,
                          ),
                          onTap: () {
                            final allSpotIds = filteredLogs
                                .map((l) => (l['visit'] as models.Visit).spotId)
                                .toList();
                            context
                                .findAncestorStateOfType<
                                  MainNavigationScreenState
                                >()
                                ?.navigateToRecord(
                                  title,
                                  RecordMode.view,
                                  spotId: visit.spotId,
                                  spotIds: allSpotIds,
                                  initialIndex: index,
                                );
                          },
                        ),
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

  Widget _buildAdSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            key: const Key('native_ad_log_search'),
            ad: _nativeAd!,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _filterLogs(
    List<QueryDocumentSnapshot> docs,
    BuildContext context,
  ) async {
    List<Map<String, dynamic>> results = [];
    for (var doc in docs) {
      final visit = models.Visit.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>,
      );

      if (_searchFromDate != null && visit.visitDate.isBefore(_searchFromDate!))
        continue;
      if (_searchToDate != null &&
          visit.visitDate.isAfter(_searchToDate!.add(const Duration(days: 1))))
        continue;

      models.Spot? spot = _spotCache[visit.spotId];
      if (spot == null) {
        final spotDoc = await FirebaseFirestore.instance
            .collection('master_spots')
            .doc(visit.spotId)
            .get();
        if (spotDoc.exists) {
          spot = models.Spot.fromFirestore(
            spotDoc as DocumentSnapshot<Map<String, dynamic>>,
          );
          if (spot != null) {
            _spotCache[visit.spotId] = spot;
          }
        }
      }

      if (spot == null) continue;

      if (_searchPrefId.isNotEmpty && spot.prefId != _searchPrefId) continue;

      final title = spot.getName(context);
      if (_searchCastleName.isNotEmpty &&
          !title.toLowerCase().contains(_searchCastleName.toLowerCase()))
        continue;

      results.add({'visit': visit, 'title': title});
    }
    return results;
  }
}
