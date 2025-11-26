import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
    static final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();

  static Future<SharedPreferences> get _prefs async => _prefsFuture;

  static Future<void> ensureInitialized() => _prefsFuture.then((_) {});

  // 유저 정보 저장 (성별, 나이)
  static Future<void> saveUserInfo(String gender, int age) async {
    final prefs = await _prefs;
    await prefs.setString('gender', gender);
    await prefs.setInt('age', age);

    print('저장된 유저 정보: {gender: $gender, age: $age}');
  }

  // 유저 정보 불러오기
  static Future<Map<String, dynamic>?> loadUserInfo() async {
    final prefs = await _prefs;
    final gender = prefs.getString('gender');
    final age = prefs.getInt('age');

    if (gender != null && age != null) {
      print('불러온 유저 정보: {gender: $gender, age: $age}');
      return {'gender': gender, 'age': age};
    }
    return null;
  }

  // 유저 정보 존재 여부 확인
  static Future<bool> hasUserInfo() async {
    final prefs = await _prefs;
    return prefs.containsKey('gender') && prefs.containsKey('age');
  }

  // 로그아웃: 유저 정보만 삭제
  static Future<void> clearUserInfo() async {
    final prefs = await _prefs;
    await prefs.remove('gender');
    await prefs.remove('age');

    print('유저 정보 삭제 완료 (로그아웃)');
  }

  // 월드컵 결과 저장
  static Future<void> saveResult(String topic, String winner) async {
    final prefs = await _prefs;
    await prefs.setString('topic', topic);
    await prefs.setString('winner', winner);

    print('저장된 결과: {topic: $topic, winner: $winner}');
  }

  // 결과 불러오기
  static Future<Map<String, dynamic>?> loadResult() async {
    final prefs = await _prefs;
    final topic = prefs.getString('topic');
    final winner = prefs.getString('winner');

    if (topic != null && winner != null) {
      print('불러온 결과: {topic: $topic, winner: $winner}');
      return {'topic': topic, 'winner': winner};
    }
    return null;
  }

  // 전체 초기화 (테스트 시 사용)
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();

    print('모든 로컬 데이터 초기화 완료');
  }
}
