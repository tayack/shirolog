import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models.dart' as models;
import '../theme.dart';
import '../main.dart';
import '../widgets/wafu_icon.dart';

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

  // 実際にフィルタリングに使用する検索条件のステート
  String _searchPrefId = '';
  String _searchCastleName = '';
  DateTime? _searchFromDate;
  DateTime? _searchToDate;

  bool _isPanelExpanded = true;
  Timer? _debounce;

  // 城情報のキャッシュ（N+1問題を回避し、高速なリアルタイム検索を実現）
  final Map<String, models.Spot> _spotCache = {};

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
  }

  @override
  void dispose() {
    _castleController.removeListener(_onSearchChanged);
    _castleController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // 入力が変更された際に呼び出される（Debounce処理）
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  // 実際の検索条件に反映してUIを更新
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
    final user = FirebaseAuth.instance.currentUser;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                          const Text(
                            '検索条件',
                            style: TextStyle(
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
                                color: kSengokuGold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '適用中',
                                style: TextStyle(
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
                        decoration: const InputDecoration(
                          labelText: '都道府県',
                          prefixIcon: Icon(
                            Icons.map_outlined,
                            color: kSengokuGold,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        items: _prefectures.map((pref) {
                          return DropdownMenuItem(
                            value: pref['id'],
                            child: Text(isEn ? pref['en']! : pref['ja']!),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedPrefId = val);
                          _onSearchChanged(); // 即座ではなくDebounceを挟む
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _castleController,
                        decoration: InputDecoration(
                          labelText: '城名で検索',
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
                          hintText: '例: 姫路城',
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
                                decoration: const InputDecoration(
                                  labelText: '開始日',
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: kSengokuGold,
                                  ),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  _fromDate == null
                                      ? '指定なし'
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
                                decoration: const InputDecoration(
                                  labelText: '終了日',
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: kSengokuGold,
                                  ),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  _toDate == null
                                      ? '指定なし'
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
                            label: const Text(
                              '検索条件をクリア',
                              style: TextStyle(fontSize: 12),
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
                  // ローディング表示はキャッシュがある場合はチラつき防止のため最小限にする
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
                          const Text('該当する記録が見つかりませんでした。'),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredLogs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
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

  Future<List<Map<String, dynamic>>> _filterLogs(
    List<QueryDocumentSnapshot> docs,
    BuildContext context,
  ) async {
    List<Map<String, dynamic>> results = [];
    for (var doc in docs) {
      final visit = models.Visit.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>,
      );

      // 日付フィルタ（事前チェックでFirestore問い合わせを減らす）
      if (_searchFromDate != null && visit.visitDate.isBefore(_searchFromDate!))
        continue;
      if (_searchToDate != null &&
          visit.visitDate.isAfter(_searchToDate!.add(const Duration(days: 1))))
        continue;

      // 城情報の取得（キャッシュを利用して高速化）
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

      // 都道府県フィルタ
      if (_searchPrefId.isNotEmpty && spot.prefId != _searchPrefId) continue;

      // 城名フィルタ
      final title = spot.getName(context);
      if (_searchCastleName.isNotEmpty &&
          !title.toLowerCase().contains(_searchCastleName.toLowerCase()))
        continue;

      results.add({'visit': visit, 'title': title});
    }
    return results;
  }
}
