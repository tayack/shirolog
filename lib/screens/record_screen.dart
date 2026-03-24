import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models.dart' as models;
import '../theme.dart';
import '../main.dart';
import '../widgets/wafu_icon.dart';

class RecordScreen extends StatefulWidget {
  final String initialCastleName;
  final String? initialSpotId;
  final RecordMode initialMode;
  final List<String>? swipeSpotIds; // スワイプ用のIDリスト
  final int swipeInitialIndex; // 開始インデックス

  const RecordScreen({
    super.key,
    this.initialCastleName = '',
    this.initialSpotId,
    this.initialMode = RecordMode.newRecord,
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

  // スワイプ用
  PageController? _pageController;
  int _currentIndex = 0;

  // 写真用
  File? _imageFile;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  final List<Map<String, String>> _prefectures = [
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
      _selectedSpotId = widget.swipeSpotIds![_currentIndex];
    }

    if (_selectedSpotId != null) {
      _loadExistingLog(_selectedSpotId!);
    }
  }

  @override
  void dispose() {
    _castleController.removeListener(_onSearchChanged);
    _castleController.dispose();
    _dateController.dispose();
    _commentController.dispose();
    _pageController?.dispose();
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

  @override
  void didUpdateWidget(RecordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSpotId != oldWidget.initialSpotId ||
        widget.initialMode != oldWidget.initialMode ||
        widget.initialCastleName != oldWidget.initialCastleName ||
        widget.swipeSpotIds != oldWidget.swipeSpotIds) {
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
          _pageController?.jumpToPage(_currentIndex);
          _selectedSpotId = widget.swipeSpotIds![_currentIndex];
        }
      });
      if (_selectedSpotId != null) {
        _loadExistingLog(_selectedSpotId!);
      }
    }
  }

  Future<void> _loadExistingLog(String spotId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';
    final fixedDocId = '${userId}_$spotId';

    // 1. まずは固定ID（新しい形式）で取得を試みる
    var doc = await FirebaseFirestore.instance
        .collection('user_logs')
        .doc(fixedDocId)
        .get();

    DocumentSnapshot? targetDoc;
    if (doc.exists) {
      targetDoc = doc;
    } else {
      // 2. 見つからない場合は、従来の userId と spotId のペアで検索（古いデータ用）
      final snapshot = await FirebaseFirestore.instance
          .collection('user_logs')
          .where('userId', isEqualTo: userId)
          .where('spotId', isEqualTo: spotId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        targetDoc = snapshot.docs.first;
      }
    }

    final spotDoc = await FirebaseFirestore.instance
        .collection('master_spots')
        .doc(spotId)
        .get();

    if (targetDoc != null && targetDoc.exists) {
      final v = models.Visit.fromFirestore(
        targetDoc as DocumentSnapshot<Map<String, dynamic>>,
      );
      setState(() {
        _existingDocId = targetDoc!.id;
        _commentController.text = v.personalNote ?? '';
        _selectedDate = v.visitDate;
        _dateController.text = DateFormat('yyyy/MM/dd').format(v.visitDate);
        _uploadedImageUrl = v.photoUrls.isNotEmpty ? v.photoUrls.first : null;

        if (spotDoc.exists) {
          final spot = models.Spot.fromFirestore(
            spotDoc as DocumentSnapshot<Map<String, dynamic>>,
          );
          _selectedPrefId = spot?.prefId;
          if (spot != null) {
            _castleController.text = spot.getName(context);
          }
        }

        if (_currentMode == RecordMode.newRecord) {
          _alreadyVisited = true;
        }
      });
    } else {
      // データがない場合（新規登録状態にする）
      setState(() {
        _existingDocId = null;
        _commentController.clear();
        _selectedDate = DateTime.now();
        _dateController.text = DateFormat('yyyy/MM/dd').format(_selectedDate);
        _uploadedImageUrl = null;
        if (spotDoc.exists) {
          final spot = models.Spot.fromFirestore(
            spotDoc as DocumentSnapshot<Map<String, dynamic>>,
          );
          _selectedPrefId = spot?.prefId;
          if (spot != null) {
            _castleController.text = spot.getName(context);
          }
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _uploadedImageUrl;

    try {
      final user = FirebaseAuth.instance.currentUser;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_photos')
          .child(user?.uid ?? 'guest')
          .child(fileName);

      await storageRef.putFile(_imageFile!);
      final url = await storageRef.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Upload error: $e');
      rethrow;
    }
  }

  Future<void> _shareTo(String platform) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    String shareText = '';
    try {
      shareText = l10n.shareText(
        _castleController.text,
        _dateController.text,
        _commentController.text,
      );
    } catch (e) {
      shareText =
          '【登城記録】${_castleController.text} に行ってきました！ (${_dateController.text})\n\n${_commentController.text}\n\n#城ログ #城巡り';
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

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';
    final spotId = _selectedSpotId ?? 'unknown';
    final docId = '${userId}_$spotId';

    setState(() => _isUploading = true);

    try {
      final imageUrl = await _uploadImage();

      final data = {
        'userId': userId,
        'spotId': spotId,
        'personalNote': _commentController.text,
        'visitDate': Timestamp.fromDate(_selectedDate),
        'photoUrls': imageUrl != null ? [imageUrl] : [],
      };

      await FirebaseFirestore.instance
          .collection('user_logs')
          .doc(docId)
          .set(data, SetOptions(merge: true));

      setState(() {
        _currentMode = RecordMode.view;
        _uploadedImageUrl = imageUrl;
        _imageFile = null;
        _existingDocId = docId;
        _isUploading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
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
                  Navigator.pop(context);
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
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
      }
    }
  }

  Widget _buildSnsButton(String label, IconData icon) {
    final l10n = AppLocalizations.of(context);
    final shareTwitterLabel = l10n?.shareTwitter ?? 'X (Twitter)';
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _shareTo(label == shareTwitterLabel ? 'X' : 'Others');
        context
            .findAncestorStateOfType<MainNavigationScreenState>()
            ?.setSelectedIndex(0);
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: kSengokuGold.withValues(alpha: 0.1),
            child: Icon(icon, color: kSengokuGold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Future<void> _deleteRecord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログの削除'),
        content: const Text('この登城記録を削除してもよろしいですか？\n取り消すことはできません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除する'),
          ),
        ],
      ),
    );

    if (confirm == true && _existingDocId != null) {
      await FirebaseFirestore.instance
          .collection('user_logs')
          .doc(_existingDocId!)
          .delete();
      if (mounted) {
        context
            .findAncestorStateOfType<MainNavigationScreenState>()
            ?.setSelectedIndex(2);
      }
    }
  }

  String _getPrefectureName(String? prefId) {
    if (prefId == null) return '-';
    final pref = _prefectures.firstWhere(
      (p) => p['id'] == prefId,
      orElse: () => {'ja': '-', 'en': '-'},
    );
    final isEn = Localizations.maybeLocaleOf(context)?.languageCode == 'en';
    return isEn ? pref['en']! : pref['ja']!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const Center(child: CircularProgressIndicator());

    if (_currentMode == RecordMode.view && widget.swipeSpotIds != null) {
      return PageView.builder(
        controller: _pageController,
        itemCount: widget.swipeSpotIds!.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _selectedSpotId = widget.swipeSpotIds![index];
          });
          _loadExistingLog(_selectedSpotId!);
        },
        itemBuilder: (context, index) => _buildContent(l10n),
      );
    }

    return _buildContent(l10n);
  }

  Widget _buildContent(AppLocalizations l10n) {
    final isEn = Localizations.maybeLocaleOf(context)?.languageCode == 'en';
    bool isReadOnly = _currentMode == RecordMode.view;
    bool isNewRecord = _currentMode == RecordMode.newRecord;
    bool canSave = _selectedSpotId != null && _castleController.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isReadOnly ? l10n.record : l10n.save,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isReadOnly)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: kSengokuGold),
                      onPressed: () => _shareTo('General'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        context
                            .findAncestorStateOfType<
                              MainNavigationScreenState
                            >()
                            ?.setSelectedIndex(2);
                      },
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('一覧へ戻る'),
                      style: TextButton.styleFrom(
                        foregroundColor: kIshigakiGrey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),

          Center(
            child: GestureDetector(
              onTap: isReadOnly || _isUploading ? null : _pickImage,
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_imageFile == null && _uploadedImageUrl == null)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isReadOnly ? '写真なし' : '写真をアップロード',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    if (!isReadOnly &&
                        (_imageFile != null || _uploadedImageUrl != null))
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                '写真を変更',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (isNewRecord)
            Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedPrefId,
                  decoration: const InputDecoration(
                    labelText: '都道府県を選択',
                    prefixIcon: Icon(Icons.map_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _prefectures
                      .map(
                        (pref) => DropdownMenuItem(
                          value: pref['id'],
                          child: Text(isEn ? pref['en']! : pref['ja']!),
                        ),
                      )
                      .toList(),
                  onChanged: _isUploading
                      ? null
                      : (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPrefId = val;
                              _selectedSpotId = null;
                              _castleController.clear();
                              _alreadyVisited = false;
                            });
                            _fetchSpotsByPref(val);
                          }
                        },
                ),
                const SizedBox(height: 16),
                ShiroSearchField(
                  hintText: l10n.searchCastle,
                  controller: _castleController,
                  readOnly: _selectedPrefId == null || _isUploading,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: WafuIcon(
                      assetName: 'home',
                      fallbackType: WafuIconType.tenshu,
                      color: _selectedPrefId == null
                          ? Colors.grey
                          : kSengokuGold,
                      size: 20,
                    ),
                  ),
                  suffixIcon: _isLoadingSpots
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                if (_selectedPrefId != null && _filteredSpots.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredSpots.length,
                      itemBuilder: (c, i) {
                        final spot = _filteredSpots[i];
                        return RadioListTile<String>(
                          value: spot.id,
                          groupValue: _selectedSpotId,
                          title: Text(spot.getDisplayName(context)),
                          activeColor: kSengokuGold,
                          onChanged: _isUploading
                              ? null
                              : (val) {
                                  setState(() {
                                    _selectedSpotId = val;
                                    _castleController.text = spot.getName(
                                      context,
                                    );
                                    _filteredSpots = [];
                                    _alreadyVisited = false;
                                  });
                                  _loadExistingLog(spot.id);
                                },
                        );
                      },
                    ),
                  ),
                if (_alreadyVisited)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.red,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.alreadyVisited,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => _currentMode = RecordMode.view),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('記録を表示・編集する'),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          else ...[
            _buildDetailLabel(
              isEn ? 'Prefecture' : '都道府県',
              _getPrefectureName(_selectedPrefId),
              icon: Icons.map_outlined,
            ),
            const SizedBox(height: 16),
            _buildDetailLabel(
              l10n.searchCastle,
              _castleController.text,
              icon: 'home',
            ),
          ],

          const SizedBox(height: 16),

          if (!_alreadyVisited) ...[
            if (isReadOnly)
              _buildDetailLabel(
                l10n.visitDate,
                _dateController.text,
                icon: Icons.calendar_today,
              )
            else
              ShiroSearchField(
                hintText: l10n.visitDate,
                controller: _dateController,
                readOnly: true,
                prefixIcon: const Icon(Icons.calendar_today, size: 20),
                onTap: _isUploading
                    ? null
                    : () async {
                        final p = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (p != null)
                          setState(() {
                            _selectedDate = p;
                            _dateController.text = DateFormat(
                              'yyyy/MM/dd',
                            ).format(p);
                          });
                      },
              ),
            const SizedBox(height: 16),
            if (isReadOnly)
              _buildDetailLabel(
                l10n.memo,
                _commentController.text,
                icon: Icons.notes,
              )
            else
              TextField(
                controller: _commentController,
                maxLines: 4,
                enabled: !_isUploading,
                decoration: InputDecoration(
                  hintText: l10n.memo,
                  labelText: l10n.memo,
                  prefixIcon: const Icon(Icons.notes, color: kSengokuGold),
                  border: const OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: (_isUploading || (!isReadOnly && !canSave))
                    ? Colors.grey
                    : kSengokuGold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isUploading || (!isReadOnly && !canSave)
                  ? null
                  : (isReadOnly
                        ? () => setState(() => _currentMode = RecordMode.edit)
                        : _saveRecord),
              child: _isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isReadOnly ? l10n.edit : l10n.save,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
          if (isReadOnly) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isUploading ? null : _deleteRecord,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[700],
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('このログを削除する'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailLabel(String label, String value, {dynamic icon}) {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
