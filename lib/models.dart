import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// お城のマスターデータ
class Spot {
  final String id;
  final String nameJa;
  final String nameEn;
  final String prefectureJa;
  final String prefectureEn;
  final String? prefId;

  Spot({
    required this.id,
    required this.nameJa,
    required this.nameEn,
    required this.prefectureJa,
    required this.prefectureEn,
    this.prefId,
  });

  static Spot? fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;

    return Spot(
      id: doc.id,
      nameJa: data['name_ja'] ?? '',
      nameEn: data['name_en'] ?? '',
      prefectureJa: data['prefecture_ja'] ?? '',
      prefectureEn: data['prefecture_en'] ?? '',
      prefId: data['pref_id']?.toString(),
    );
  }

  String getName(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    return locale?.languageCode == 'en' ? nameEn : nameJa;
  }

  String getPrefecture(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    return locale?.languageCode == 'en' ? prefectureEn : prefectureJa;
  }

  String getDisplayName(BuildContext context) {
    return '${getName(context)} (${getPrefecture(context)})';
  }
}

/// 登城ログのデータ
class Visit {
  final String id;
  final String userId;
  final String spotId;
  final List<String> photoUrls;
  final String? personalNote;
  final DateTime visitDate;
  final DateTime? updatedAt;

  Visit({
    required this.id,
    required this.userId,
    required this.spotId,
    required this.photoUrls,
    this.personalNote,
    required this.visitDate,
    this.updatedAt,
  });

  factory Visit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final visitTimestamp = data['visitDate'] as Timestamp?;
    final updatedTimestamp = data['updatedAt'] as Timestamp?;
    return Visit(
      id: doc.id,
      userId: data['userId'] ?? '',
      spotId: data['spotId'] ?? '',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      personalNote: data['personalNote'],
      visitDate: visitTimestamp?.toDate() ?? DateTime.now(),
      updatedAt: updatedTimestamp?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'spotId': spotId,
      'photoUrls': photoUrls,
      'personalNote': personalNote,
      'visitDate': Timestamp.fromDate(visitDate),
      'updatedAt': FieldValue.serverTimestamp(), // 保存・更新時に常にサーバー時刻で更新
    };
  }
}

/// ミッションのデータ
class Mission {
  final String id;
  final String titleJa;
  final String titleEn;
  final String descriptionJa;
  final String descriptionEn;
  final List<String> targetSpotIds;

  Mission({
    required this.id,
    required this.titleJa,
    required this.titleEn,
    required this.descriptionJa,
    required this.descriptionEn,
    required this.targetSpotIds,
  });

  factory Mission.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Mission(
      id: doc.id,
      titleJa: data['title_ja'] ?? '',
      titleEn: data['title_en'] ?? '',
      descriptionJa: data['description_ja'] ?? '',
      descriptionEn: data['description_en'] ?? '',
      targetSpotIds: List<String>.from(data['targetSpotIds'] ?? []),
    );
  }

  String getTitle(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    return locale?.languageCode == 'en' ? titleEn : titleJa;
  }

  String getDescription(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    return locale?.languageCode == 'en' ? descriptionEn : descriptionJa;
  }

  int getAchievedCount(List<Visit> userVisits) {
    final visitedSpotIds = userVisits.map((visit) => visit.spotId).toSet();
    return targetSpotIds
        .where((spotId) => visitedSpotIds.contains(spotId))
        .length;
  }

  bool isSpotAchieved(String spotId, List<Visit> userVisits) {
    return userVisits.any((visit) => visit.spotId == spotId);
  }
}
