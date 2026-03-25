import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../l10n/app_localizations.dart';
import '../models.dart' as models;
import '../theme.dart';
import '../main.dart';
import '../widgets/wafu_icon.dart';

class RecordScreen extends StatefulWidget {
  final String initialCastleName;
  final String? initialSpotId;
  final RecordMode initialMode;
  final int resetTrigger;
  final List<String>? swipeSpotIds;
  final int swipeInitialIndex;

  const RecordScreen({
    super.key,
    this.initialCastleName = '',
    this.initialSpotId,
    this.initialMode = RecordMode.newRecord,
    this.resetTrigger = 0,
    this.swipeSpotIds,
    this.swipeInitialIndex = 0,
  });

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late TextEditingController _castleController,
      _dateController,
      _commentController;
  late RecordMode _currentMode;
  List<models.Spot> _allSpotsInPref = [];
  List<models.Spot> _filteredSpots = [];
  bool _isLoadingSpots = false, _alreadyVisited = false;
  String? _selectedSpotId, _existingDocId;
  String? _selectedPrefId;
  DateTime _selectedDate = DateTime.now();

  PageController? _pageController;
  int _currentIndex = 0;

  File? _imageFile;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  List<models.Mission> _completedMissionsInThisSession = [];

  static final Map<String, models.Visit> _visitCache = {};
  static final Map<String, models.Spot> _spotCache = {};

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

  static const List<Map<String, String>> _prefectures = [
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
    {'id': '30', 'ja': '和歌山県', 'en': 'Wayakama'},
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
    _castleController = TextEditingController(text: widget.initialCastleName);
    _dateController = TextEditingController(
      text: DateFormat('yyyy/MM/dd').format(_selectedDate),
    );
    _commentController = TextEditingController();
    _currentMode = widget.initialMode;
    _selectedSpotId = widget.initialSpotId;

    _castleController.addListener(_onSearchChanged);

    if (widget.swipeSpotIds != null) {
      _currentIndex = widget.swipeInitialIndex;
      _pageController = PageController(initialPage: _currentIndex);
    }
    _loadAd();
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
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: kIshigakiGrey,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    )..load();
  }

  void _resetToInitialState() {
    setState(() {
      _currentMode = RecordMode.newRecord;
      _selectedSpotId = null;
      _castleController.text = '';
      _commentController.clear();
      _imageFile = null;
      _uploadedImageUrl = null;
      _selectedDate = DateTime.now();
      _dateController.text = DateFormat('yyyy/MM/dd').format(_selectedDate);
      _alreadyVisited = false;
      _selectedPrefId = null;
      _allSpotsInPref = [];
      _filteredSpots = [];
      _existingDocId = null;
      _pageController?.dispose();
      _pageController = null;
    });
  }

  @override
  void didUpdateWidget(RecordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetTrigger != oldWidget.resetTrigger) {
      if (widget.initialSpotId == null && widget.swipeSpotIds == null) {
        _resetToInitialState();
      } else {
        setState(() {
          _castleController.text = widget.initialCastleName;
          _currentMode = widget.initialMode;
          _selectedSpotId = widget.initialSpotId;
          _alreadyVisited = false;
          _existingDocId = null;
          _commentController.clear();
          _uploadedImageUrl = null;
          _imageFile = null;
          _selectedDate = DateTime.now();
          _dateController.text = DateFormat('yyyy/MM/dd').format(_selectedDate);

          if (widget.swipeSpotIds != null) {
            _currentIndex = widget.swipeInitialIndex;
            _pageController?.dispose();
            _pageController = PageController(initialPage: _currentIndex);
            _selectedSpotId = widget.swipeSpotIds![_currentIndex];
          }
        });
        if (_selectedSpotId != null && _currentMode != RecordMode.view) {
          _loadExistingLog(_selectedSpotId!);
        }
      }
    }
  }

  @override
  void dispose() {
    _castleController.removeListener(_onSearchChanged);
    _castleController.dispose();
    _dateController.dispose();
    _commentController.dispose();
    _pageController?.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final text = _castleController.text.trim().toLowerCase();
    if (text.isEmpty) {
      setState(() {
        _filteredSpots = _allSpotsInPref;
        _selectedSpotId = null;
        _alreadyVisited = false;
      });
      return;
    }
    setState(() {
      _filteredSpots = _allSpotsInPref.where((spot) {
        final ja = spot.nameJa.toLowerCase();
        final en = spot.nameEn.toLowerCase();
        return ja.contains(text) || en.contains(text);
      }).toList();
    });
  }

  Future<void> _fetchSpotsByPref(String prefId) async {
    setState(() {
      _isLoadingSpots = true;
      _allSpotsInPref = [];
      _filteredSpots = [];
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('master_spots')
          .where('pref_id', isEqualTo: prefId)
          .get();
      final spots = snapshot.docs
          .map(
            (doc) => models.Spot.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .where((spot) => spot != null)
          .cast<models.Spot>()
          .toList();
      setState(() {
        _allSpotsInPref = spots;
        _filteredSpots = spots;
        _isLoadingSpots = false;
      });
    } catch (e) {
      debugPrint('Fetch spots error: $e');
      setState(() => _isLoadingSpots = false);
    }
  }

  Future<void> _loadExistingLog(
    String spotId, {
    bool forceRefresh = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';
    final fixedDocId = '${userId}_$spotId';

    models.Visit? visit;
    if (!forceRefresh && _visitCache.containsKey(fixedDocId)) {
      visit = _visitCache[fixedDocId];
    } else {
      var doc = await FirebaseFirestore.instance
          .collection('user_logs')
          .doc(fixedDocId)
          .get();
      DocumentSnapshot? targetDoc;
      if (doc.exists) {
        targetDoc = doc;
      } else {
        final snapshot = await FirebaseFirestore.instance
            .collection('user_logs')
            .where('userId', isEqualTo: userId)
            .where('spotId', isEqualTo: spotId)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) targetDoc = snapshot.docs.first;
      }
      if (targetDoc != null && targetDoc.exists) {
        visit = models.Visit.fromFirestore(
          targetDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        _visitCache[fixedDocId] = visit;
      }
    }

    models.Spot? spot;
    if (_spotCache.containsKey(spotId)) {
      spot = _spotCache[spotId];
    } else {
      final spotDoc = await FirebaseFirestore.instance
          .collection('master_spots')
          .doc(spotId)
          .get();
      if (spotDoc.exists) {
        spot = models.Spot.fromFirestore(
          spotDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        if (spot != null) _spotCache[spotId] = spot;
      }
    }

    setState(() {
      if (visit != null) {
        _existingDocId = visit.id;
        _commentController.text = visit.personalNote ?? '';
        _selectedDate = visit.visitDate;
        _dateController.text = DateFormat('yyyy/MM/dd').format(visit.visitDate);
        _uploadedImageUrl = visit.photoUrls.isNotEmpty
            ? visit.photoUrls.first
            : null;
        if (spot != null) {
          _selectedPrefId = spot.prefId;
          _castleController.text = spot.getName(context);
        }
        if (_currentMode == RecordMode.newRecord) _alreadyVisited = true;
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _uploadedImageUrl;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_photos')
        .child(FirebaseAuth.instance.currentUser?.uid ?? 'guest')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putFile(_imageFile!);
    return await storageRef.getDownloadURL();
  }

  Future<void> _shareTo(
    String castleName,
    String dateText,
    String comment, {
    String? platform,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    String shareText = '';
    String missionBonusText = '';
    if (_completedMissionsInThisSession.isNotEmpty) {
      final missionNames = _completedMissionsInThisSession
          .map((m) => '「${m.getTitle(context)}」')
          .join('、');
      missionBonusText =
          '${l10n.missionAccomplishedSharePrefix}$missionNames${l10n.missionCompletedShareSuffix}';
    }
    try {
      // お城名のハッシュタグを追加
      shareText =
          missionBonusText +
          l10n.shareText(castleName, dateText, comment) +
          '\n#$castleName';
    } catch (e) {
      shareText =
          '${missionBonusText}【登城記録】$castleName に行ってきました！ ($dateText)\n\n$comment\n\n#城ログ #城巡り #$castleName';
    }

    if (platform == 'X') {
      final encodedText = Uri.encodeComponent(shareText);
      final nativeUrl = Uri.parse('twitter://post?message=$encodedText');
      final webUrl = Uri.parse(
        'https://twitter.com/intent/tweet?text=$encodedText',
      );

      try {
        if (await canLaunchUrl(nativeUrl)) {
          await launchUrl(nativeUrl);
        } else if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          Share.share(shareText);
        }
      } catch (e) {
        debugPrint('X Share error: $e');
        Share.share(shareText);
      }
    } else {
      Share.share(shareText);
    }
  }

  Future<void> _saveRecord() async {
    if (_isUploading) return;
    if (_selectedSpotId == null) return;

    final l10n = AppLocalizations.of(context)!;
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final spotId = _selectedSpotId!;
    final fixedDocId = '${userId}_$spotId';
    setState(() => _isUploading = true);
    try {
      final imageUrl = await _uploadImage();
      final data = {
        'userId': userId,
        'spotId': spotId,
        'personalNote': _commentController.text,
        'visitDate': Timestamp.fromDate(_selectedDate),
        'photoUrls': imageUrl != null ? [imageUrl] : [],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_existingDocId != null && _existingDocId != fixedDocId) {
        await FirebaseFirestore.instance
            .collection('user_logs')
            .doc(_existingDocId!)
            .delete();
      }

      await FirebaseFirestore.instance
          .collection('user_logs')
          .doc(fixedDocId)
          .set(data, SetOptions(merge: true));

      final newVisit = models.Visit(
        id: fixedDocId,
        userId: userId,
        spotId: spotId,
        photoUrls: imageUrl != null ? [imageUrl] : [],
        personalNote: _commentController.text,
        visitDate: _selectedDate,
      );
      _visitCache[fixedDocId] = newVisit;

      _completedMissionsInThisSession = await _checkNewlyCompletedMissions(
        spotId,
      );

      setState(() {
        _currentMode = RecordMode.view;
        _uploadedImageUrl = imageUrl;
        _existingDocId = fixedDocId;
        _isUploading = false;
      });
      if (mounted) {
        if (_completedMissionsInThisSession.isNotEmpty) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => _MissionAccomplishedDialog(
              missions: _completedMissionsInThisSession,
            ),
          );
        }
        _showShareDialog(l10n);
      }
    } catch (e) {
      setState(() => _isUploading = false);
    }
  }

  void _showShareDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.shareTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.shareContent),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSnsButton(l10n.shareTwitter, Icons.close),
                _buildSnsButton(l10n.shareOthers, Icons.share),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              context
                  .findAncestorStateOfType<MainNavigationScreenState>()
                  ?.setSelectedIndex(0);
            },
            child: Text(l10n.shareLater),
          ),
        ],
      ),
    );
  }

  Widget _buildSnsButton(String label, IconData icon) {
    final l10n = AppLocalizations.of(context);
    final shareTwitterLabel = l10n?.shareTwitter ?? 'X (Twitter)';
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _shareTo(
          _castleController.text,
          _dateController.text,
          _commentController.text,
          platform: label == shareTwitterLabel ? 'X' : 'Others',
        );
        context
            .findAncestorStateOfType<MainNavigationScreenState>()
            ?.setSelectedIndex(0);
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: kSengokuGold.withOpacity(0.1),
            child: Icon(icon, color: kSengokuGold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Future<List<models.Mission>> _checkNewlyCompletedMissions(
    String spotId,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final mSnapshot = await FirebaseFirestore.instance
        .collection('master_missions')
        .get();
    final missions = mSnapshot.docs
        .map((d) => models.Mission.fromFirestore(d))
        .toList();
    final lSnapshot = await FirebaseFirestore.instance
        .collection('user_logs')
        .where('userId', isEqualTo: userId)
        .get();
    final visits = lSnapshot.docs
        .map((d) => models.Visit.fromFirestore(d))
        .toList();
    List<models.Mission> newlyCompleted = [];
    for (var m in missions) {
      if (!m.targetSpotIds.contains(spotId)) continue;
      final visitsWithoutCurrent = visits
          .where((v) => v.spotId != spotId)
          .toList();
      if (m.getAchievedCount(visitsWithoutCurrent) != m.targetSpotIds.length &&
          m.getAchievedCount(visits) == m.targetSpotIds.length)
        newlyCompleted.add(m);
    }
    return newlyCompleted;
  }

  Future<void> _deleteRecord(String docId, String spotId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.deleteLog),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('user_logs')
          .doc(docId)
          .delete();

      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      _visitCache.remove('${userId}_$spotId');

      if (mounted)
        context
            .findAncestorStateOfType<MainNavigationScreenState>()
            ?.setSelectedIndex(2);
    }
  }

  static String _getPrefectureNameStatic(BuildContext context, String? prefId) {
    if (prefId == null) return '-';
    final pref = _prefectures.firstWhere(
      (p) => p['id'] == prefId,
      orElse: () => {'ja': '-', 'en': '-'},
    );
    return Localizations.maybeLocaleOf(context)?.languageCode == 'en'
        ? pref['en']!
        : pref['ja']!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const Center(child: CircularProgressIndicator());

    if (_currentMode == RecordMode.view) {
      if (widget.swipeSpotIds != null) {
        return PageView.builder(
          key: ValueKey('pageview_${widget.resetTrigger}'),
          controller: _pageController,
          itemCount: widget.swipeSpotIds!.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
              _selectedSpotId = widget.swipeSpotIds![index];
            });
          },
          itemBuilder: (context, index) {
            final spotId = widget.swipeSpotIds![index];
            return _RecordDetailView(
              key: ValueKey('detail_$spotId'),
              spotId: spotId,
              onEdit: () {
                _loadExistingLog(spotId);
                setState(() => _currentMode = RecordMode.edit);
              },
              onDelete: (docId) => _deleteRecord(docId, spotId),
              onShare: (castleName, dateText, comment) =>
                  _shareTo(castleName, dateText, comment),
            );
          },
        );
      } else if (_selectedSpotId != null) {
        return _RecordDetailView(
          key: ValueKey(
            'detail_single_${_selectedSpotId}_${widget.resetTrigger}',
          ),
          spotId: _selectedSpotId!,
          onEdit: () {
            _loadExistingLog(_selectedSpotId!);
            setState(() => _currentMode = RecordMode.edit);
          },
          onDelete: (docId) => _deleteRecord(docId, _selectedSpotId!),
          onShare: (castleName, dateText, comment) =>
              _shareTo(castleName, dateText, comment),
        );
      }
    }
    return _buildContent(l10n);
  }

  Widget _buildContent(AppLocalizations l10n) {
    final isEn = Localizations.maybeLocaleOf(context)?.languageCode == 'en';
    String screenTitle = (_currentMode == RecordMode.edit
        ? l10n.editRecord
        : l10n.newRecord);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            screenTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _isUploading ? null : _pickImage,
            child: Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: _imageFile != null
                    ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.contain,
                      )
                    : (_uploadedImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_uploadedImageUrl!),
                              fit: BoxFit.contain,
                            )
                          : null),
              ),
              child: _imageFile == null && _uploadedImageUrl == null
                  ? const Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.grey,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          if (_currentMode == RecordMode.newRecord) ...[
            DropdownButtonFormField<String>(
              value: _selectedPrefId,
              decoration: InputDecoration(
                labelText: l10n.selectPrefecture,
                prefixIcon: const Icon(Icons.map_outlined, color: kSengokuGold),
                border: const OutlineInputBorder(),
              ),
              items: _prefectures
                  .map(
                    (p) => DropdownMenuItem(
                      value: p['id'],
                      child: Text(isEn ? p['en']! : p['ja']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedPrefId = v;
                    _selectedSpotId = null;
                    _castleController.clear();
                  });
                  _fetchSpotsByPref(v);
                }
              },
            ),
            const SizedBox(height: 16),
            ShiroSearchField(
              hintText: l10n.searchCastle,
              controller: _castleController,
              readOnly: _selectedPrefId == null,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: WafuIcon(
                  assetName: 'home',
                  fallbackType: WafuIconType.tenshu,
                  color: _selectedPrefId == null ? Colors.grey : kSengokuGold,
                  size: 20,
                ),
              ),
            ),
            if (_filteredSpots.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredSpots.length,
                  itemBuilder: (c, i) => RadioListTile<String>(
                    value: _filteredSpots[i].id,
                    groupValue: _selectedSpotId,
                    title: Text(_filteredSpots[i].getDisplayName(context)),
                    activeColor: kSengokuGold,
                    onChanged: (v) {
                      setState(() {
                        _selectedSpotId = v;
                        _castleController.text = _filteredSpots[i].getName(
                          context,
                        );
                        _filteredSpots = [];
                      });
                      _loadExistingLog(v!);
                    },
                  ),
                ),
              ),
          ] else ...[
            _buildLabelFieldStatic(
              context,
              l10n.selectPrefecture, // 都道府県
              _getPrefectureNameStatic(context, _selectedPrefId),
              Icons.map_outlined,
            ),
            const SizedBox(height: 16),
            _buildLabelFieldStatic(
              context,
              l10n.searchCastle, // 城名
              _castleController.text,
              'home',
            ),
          ],
          const SizedBox(height: 16),
          if (_alreadyVisited && _currentMode == RecordMode.newRecord)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.alreadyVisited,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => _currentMode = RecordMode.view),
                    child: Text(l10n.viewRecord),
                  ),
                ],
              ),
            )
          else ...[
            ShiroSearchField(
              hintText: l10n.visitDate,
              controller: _dateController,
              readOnly: true,
              prefixIcon: const Icon(
                Icons.calendar_today,
                size: 20,
                color: kSengokuGold,
              ),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (d != null)
                  setState(() {
                    _selectedDate = d;
                    _dateController.text = DateFormat('yyyy/MM/dd').format(d);
                  });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.memo,
                prefixIcon: const Icon(Icons.notes, color: kSengokuGold),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kSengokuGold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveRecord,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      l10n.save,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
            if (_currentMode == RecordMode.edit) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _currentMode = RecordMode.view),
                child: Text(
                  l10n.cancelEdit,
                  style: const TextStyle(color: kIshigakiGrey),
                ),
              ),
            ],
          ],

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
                  height: 130, // Validator対策で130に設定
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
  }

  static Widget _buildLabelFieldStatic(
    BuildContext context,
    String label,
    String value,
    dynamic icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon is IconData)
              Icon(icon, size: 16, color: kSengokuGold)
            else if (icon is String)
              WafuIcon(
                assetName: icon,
                fallbackType: WafuIconType.tenshu,
                color: kSengokuGold,
                size: 16,
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: kIshigakiGrey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 16, color: kUrushiBlack),
          ),
        ),
      ],
    );
  }
}

class _RecordDetailView extends StatefulWidget {
  final String spotId;
  final VoidCallback onEdit;
  final Function(String docId) onDelete;
  final Function(String castleName, String dateText, String comment) onShare;

  const _RecordDetailView({
    super.key,
    required this.spotId,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
  });

  @override
  State<_RecordDetailView> createState() => _RecordDetailViewState();
}

class _RecordDetailViewState extends State<_RecordDetailView> {
  models.Visit? _visit;
  models.Spot? _spot;
  bool _isLoading = true;

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadAd();
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
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: kIshigakiGrey,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final fixedDocId = '${userId}_${widget.spotId}';

    try {
      models.Visit? visit;
      if (_RecordScreenState._visitCache.containsKey(fixedDocId)) {
        visit = _RecordScreenState._visitCache[fixedDocId];
      } else {
        // 1. 固定IDで試行
        var doc = await FirebaseFirestore.instance
            .collection('user_logs')
            .doc(fixedDocId)
            .get();

        if (doc.exists) {
          visit = models.Visit.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          );
        } else {
          // 2. ランダムID（古いデータ）でのフォールバック試行
          final snapshot = await FirebaseFirestore.instance
              .collection('user_logs')
              .where('userId', isEqualTo: userId)
              .where('spotId', isEqualTo: widget.spotId)
              .limit(1)
              .get();
          if (snapshot.docs.isNotEmpty) {
            visit = models.Visit.fromFirestore(
              snapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>,
            );
          }
        }
        if (visit != null) {
          _RecordScreenState._visitCache[fixedDocId] = visit;
        }
      }

      models.Spot? spot;
      if (_RecordScreenState._spotCache.containsKey(widget.spotId)) {
        spot = _RecordScreenState._spotCache[widget.spotId];
      } else {
        final spotDoc = await FirebaseFirestore.instance
            .collection('master_spots')
            .doc(widget.spotId)
            .get();
        if (spotDoc.exists) {
          spot = models.Spot.fromFirestore(
            spotDoc as DocumentSnapshot<Map<String, dynamic>>,
          );
          if (spot != null) _RecordScreenState._spotCache[widget.spotId] = spot;
        }
      }

      if (mounted) {
        setState(() {
          _visit = visit;
          _spot = spot;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: kOffWhite,
        child: const Center(
          child: CircularProgressIndicator(color: kSengokuGold),
        ),
      );
    }

    if (_spot == null) return const Center(child: Text('データが見つかりません'));

    final l10n = AppLocalizations.of(context)!;
    final castleName = _spot!.getName(context);
    final dateText = _visit != null
        ? DateFormat('yyyy/MM/dd').format(_visit!.visitDate)
        : '-';
    final comment = _visit?.personalNote ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.record,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: kSengokuGold),
                onPressed: () => widget.onShare(castleName, dateText, comment),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              image: (_visit?.photoUrls.isNotEmpty ?? false)
                  ? DecorationImage(
                      image: NetworkImage(_visit!.photoUrls.first),
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
            child: (_visit?.photoUrls.isEmpty ?? true)
                ? const Center(
                    child: Icon(
                      Icons.fort_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 24),
          _RecordScreenState._buildLabelFieldStatic(
            context,
            l10n.selectPrefecture, // 都道府県
            _RecordScreenState._getPrefectureNameStatic(context, _spot!.prefId),
            Icons.map_outlined,
          ),
          const SizedBox(height: 16),
          _RecordScreenState._buildLabelFieldStatic(
            context,
            l10n.searchCastle, // 城名
            castleName,
            'home',
          ),
          const SizedBox(height: 16),
          _RecordScreenState._buildLabelFieldStatic(
            context,
            l10n.visitDate,
            dateText,
            Icons.calendar_today,
          ),
          const SizedBox(height: 16),
          _RecordScreenState._buildLabelFieldStatic(
            context,
            l10n.memo,
            comment.isEmpty ? '-' : comment,
            Icons.notes,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kSengokuGold,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: widget.onEdit,
            child: Text(
              l10n.edit,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => widget.onDelete(_visit?.id ?? ''),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.deleteLog,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

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
                  height: 130, // Validator対策で130に設定
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
  }
}

class _MissionAccomplishedDialog extends StatelessWidget {
  final List<models.Mission> missions;
  const _MissionAccomplishedDialog({required this.missions});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        l10n.missionAccomplished,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const WafuIcon(
            assetName: 'kabuto',
            fallbackType: WafuIconType.kabuto,
            color: kSengokuGold,
            size: 64,
          ),
          const SizedBox(height: 16),
          ...missions.map(
            (m) => Text(
              '「${m.getTitle(context)}」',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.missionCompletedMessage),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.bravo),
        ),
      ],
    );
  }
}
