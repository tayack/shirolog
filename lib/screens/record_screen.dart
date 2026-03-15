import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models.dart' as models;
import '../main.dart';

class RecordScreen extends StatefulWidget {
  final String initialCastleName;
  final String? initialSpotId;
  final RecordMode initialMode;
  const RecordScreen({
    super.key,
    this.initialCastleName = '',
    this.initialSpotId,
    this.initialMode = RecordMode.newRecord,
  });

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late TextEditingController _castleController,
      _dateController,
      _commentController;
  late RecordMode _currentMode;
  List<models.Spot> _searchResults = [];
  bool _isSearching = false, _alreadyVisited = false;
  String? _selectedSpotId, _existingDocId;
  DateTime _selectedDate = DateTime.now();

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
    if (_selectedSpotId != null) _loadExistingLog(_selectedSpotId!);
  }

  @override
  void didUpdateWidget(RecordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSpotId != oldWidget.initialSpotId ||
        widget.initialMode != oldWidget.initialMode) {
      setState(() {
        _castleController.text = widget.initialCastleName;
        _currentMode = widget.initialMode;
        _selectedSpotId = widget.initialSpotId;
        _alreadyVisited = false;
        _existingDocId = null;
      });
      if (_selectedSpotId != null) _loadExistingLog(_selectedSpotId!);
    }
  }

  Future<void> _loadExistingLog(String spotId) async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('user_logs')
        .where('userId', isEqualTo: user?.uid ?? 'guest')
        .where('spotId', isEqualTo: spotId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final v = models.Visit.fromFirestore(
        snapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>,
      );
      setState(() {
        _existingDocId = snapshot.docs.first.id;
        _commentController.text = v.personalNote ?? '';
        _selectedDate = v.visitDate;
        _dateController.text = DateFormat('yyyy/MM/dd').format(v.visitDate);
        if (_currentMode == RecordMode.newRecord) _alreadyVisited = true;
      });
    }
  }

  Future<void> _saveRecord() async {
    final user = FirebaseAuth.instance.currentUser;
    final data = {
      'userId': user?.uid ?? 'guest',
      'spotId': _selectedSpotId ?? 'unknown',
      'displayTitle': _castleController.text,
      'personalNote': _commentController.text,
      'visitDate': Timestamp.fromDate(_selectedDate),
    };
    if (_existingDocId != null) {
      await FirebaseFirestore.instance
          .collection('user_logs')
          .doc(_existingDocId)
          .update(data);
    } else {
      await FirebaseFirestore.instance.collection('user_logs').add(data);
    }
    setState(() => _currentMode = RecordMode.view);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool isReadOnly = _currentMode == RecordMode.view;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isReadOnly ? l10n.record : l10n.save,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ShiroSearchField(
            hintText: l10n.searchCastle,
            controller: _castleController,
            readOnly: isReadOnly,
            suffixIcon: isReadOnly
                ? null
                : IconButton(
                    icon: const Icon(Icons.search, color: kSengokuGold),
                    onPressed: () async {
                      setState(() => _isSearching = true);
                      final s = await FirebaseFirestore.instance
                          .collection('master_spots')
                          .where(
                            'name',
                            isGreaterThanOrEqualTo: _castleController.text,
                          )
                          .where(
                            'name',
                            isLessThanOrEqualTo:
                                '${_castleController.text}\uf8ff',
                          )
                          .get();
                      setState(() {
                        _searchResults = s.docs
                            .map((d) => models.Spot.fromFirestore(d))
                            .toList();
                        _isSearching = false;
                      });
                    },
                  ),
          ),
          if (_alreadyVisited)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.alreadyVisited,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (!isReadOnly && (_isSearching || _searchResults.isNotEmpty))
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (c, i) => RadioListTile<String>(
                        title: Text(_searchResults[i].displayName),
                        value: _searchResults[i].id,
                        groupValue: _selectedSpotId,
                        activeColor: kSengokuGold,
                        onChanged: (v) {
                          setState(() {
                            _selectedSpotId = v;
                            _castleController.text = _searchResults[i].name;
                            _searchResults = [];
                            _alreadyVisited = false;
                          });
                          _loadExistingLog(v!);
                        },
                      ),
                    ),
            ),
          if (!_alreadyVisited) ...[
            const SizedBox(height: 16),
            ShiroSearchField(
              hintText: l10n.visitDate,
              controller: _dateController,
              readOnly: true,
              onTap: () async {
                final p = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (p != null)
                  setState(() {
                    _selectedDate = p;
                    _dateController.text = DateFormat('yyyy/MM/dd').format(p);
                  });
              },
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 4,
              readOnly: isReadOnly,
              decoration: InputDecoration(
                hintText: l10n.memo,
                filled: true,
                fillColor: isReadOnly ? Colors.grey[50] : Colors.white,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kSengokuGold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
              ),
              onPressed: isReadOnly
                  ? () => setState(() => _currentMode = RecordMode.edit)
                  : _saveRecord,
              child: Text(
                isReadOnly ? l10n.edit : l10n.save,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
