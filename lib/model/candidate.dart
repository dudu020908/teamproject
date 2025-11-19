import 'package:cloud_firestore/cloud_firestore.dart';

class Candidate {
  /// 부전승용 특수 ID (실제 데이터와 겹치지 않게 고정 문자열 사용)
  static const String byeId = '__bye__';

  /// 부전승 카드 (Firebase에서 가져오는 데이터가 아니라 앱 내부에서만 사용)
  static const Candidate byeCandidate = Candidate(
    id: byeId,
    title: '부전승입니다. 옆 후보를 선택하세요.',
    imageUrl: '',
  );

  final String id; // Firestore 문서 ID
  final String title; // 후보 이름
  final String imageUrl; // 후보 이미지 URL

  /// 🔹 새로 추가: 후보 타입 리스트 (예: ['귀여움', '지적임', ...])
  final List<String> types;

  const Candidate({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.types = const [], // 기본값: 빈 리스트
  });

  /// 이 후보가 부전승 카드인지 여부
  bool get isBye => id == byeId;

  /// Firestore 문서 → Candidate 객체로 변환
  factory Candidate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Candidate(
      id: doc.id,
      title: data['name'] ?? data['title'] ?? '제목 없음',
      imageUrl: data['imageUrl'] ?? '',
      // 🔹 Firestore에 'types' 배열이 있으면 읽어오기
      types: (data['types'] is List)
          ? (data['types'] as List).map((e) => e.toString()).toList()
          : const [],
    );
  }

  /// Candidate → Firestore에 저장할 때 사용할 Map
  /// (후보를 직접 추가/수정할 때 사용 가능)
  Map<String, dynamic> toFirestore({
    required String topic, // 예: '강아지', '고양이', '카페 메뉴' 등
    String? subtopic,
    String? ownerUid,
    List<String>? typesOverride,
  }) {
    final effectiveTypes = typesOverride ?? types;

    return {
      'title': title,
      'imageUrl': imageUrl,
      'topic': topic,
      if (subtopic != null) 'subtopic': subtopic,
      if (ownerUid != null) 'ownerUid': ownerUid,
      if (effectiveTypes.isNotEmpty) 'types': effectiveTypes,
    };
  }
}
