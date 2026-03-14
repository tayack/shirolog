import 'package:cloud_firestore/cloud_firestore.dart';

/// お城のマスターデータ
class Spot {
  final String id;
  final String name;
  final String prefecture;

  Spot({required this.id, required this.name, required this.prefecture});

  factory Spot.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Spot(
      id: doc.id,
      name: data['name'] ?? '',
      prefecture: data['prefecture'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'prefecture': prefecture};
  }
}

/// 登城ログのデータ
class Visit {
  final String id;
  final String userId;
  final String spotId;
  final String displayTitle;
  final String? photoUrl;
  final String? personalNote;
  final DateTime visitDate;

  Visit({
    required this.id,
    required this.userId,
    required this.spotId,
    required this.displayTitle,
    this.photoUrl,
    this.personalNote,
    required this.visitDate,
  });

  factory Visit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Visit(
      id: doc.id,
      userId: data['userId'] ?? '',
      spotId: data['spotId'] ?? '',
      displayTitle: data['displayTitle'] ?? '',
      photoUrl: data['photoUrl'],
      personalNote: data['personalNote'],
      visitDate: (data['visitDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'spotId': spotId,
      'displayTitle': displayTitle,
      'photoUrl': photoUrl,
      'personalNote': personalNote,
      'visitDate': Timestamp.fromDate(visitDate),
    };
  }
}

/// ミッションのデータ
class Mission {
  final String id;
  final String title;
  final String description;
  final List<String> targetSpotIds;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.targetSpotIds,
  });

  factory Mission.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Mission(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      targetSpotIds: List<String>.from(data['targetSpotIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'targetSpotIds': targetSpotIds,
    };
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
