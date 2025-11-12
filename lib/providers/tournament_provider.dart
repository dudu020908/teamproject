import 'package:flutter/foundation.dart';
import '../model/candidate.dart';
import 'dart:math';

enum TournamentState { playing, finished }

class TournamentProvider extends ChangeNotifier {
  // 현재 주제
  String _topicTitle = '';
  String get topicTitle => _topicTitle;

  // 라운드 상태
  List<Candidate> _currentRound = <Candidate>[];
  final List<Candidate> _nextRound = <Candidate>[];
  int _index = 0;

  // 현재 페어
  Candidate? _left;
  Candidate? _right;
  Candidate? get left => _left;
  Candidate? get right => _right;

  // 우승자
  Candidate? _winner;
  Candidate? get winner => _winner;
  bool get hasWinner => _winner != null;

  /// 현재 페어를 리스트로 반환(호환용)
  List<Candidate> get currentPair {
    final list = <Candidate>[];
    if (_left != null) list.add(_left!);
    if (_right != null) list.add(_right!);
    return list;
  }

  // -------------------------------
  // 🔹 라운드 진행 표기용 상태 (추가)
  // -------------------------------
  final _rand = Random();
  int _roundEntrants = 0;     // 이번 라운드 참가자 수(부전승 1명 포함 표기용)
  int _roundPairsTotal = 0;   // 이번 라운드 총 대결 수
  int _roundPairsPlayed = 0;  // 이번 라운드 끝낸 대결 수
  bool _byeThisRound = false; // 이번 라운드에 부전승 발생 여부

  int get roundEntrants => _roundEntrants;
  int get roundPairsTotal => _roundPairsTotal;
  int get roundPairsPlayed => _roundPairsPlayed;
  bool get byeThisRound => _byeThisRound;

  /// 표시용: 현재 몇 번째 대결인지(1-based)
  int get currentPairIndexDisplay =>
      _roundPairsTotal == 0 ? 0 : (_roundPairsPlayed + 1).clamp(1, _roundPairsTotal);

  /// 16강/8강/4강/결승 라벨
String get roundLabel {
  final effective = _effectivePlayableCount; // 이번 라운드 실제 매치 인원(짝수)
  final n = _pow2Floor(effective);
  if (n <= 2) return '결승';
  return '${n}강';
}

// 🔹 실제 매치 인원 계산(부전승 반영 후 _currentRound 길이 사용)
//   - 라운드 막 교체 타이밍 등 edge에선 2 이상 보장
int get _effectivePlayableCount {
  // 라운드 중이면 _currentRound가 짝수(부전승 제거 후 상태)
  var n = _currentRound.isNotEmpty ? _currentRound.length : _nextRound.length;
  if (n < 2) n = 2; // 결승 최소 보정
  // 짝수 보장(이론상 이미 짝수지만 안전 보정)
  if (n.isOdd) n -= 1;
  return n;
}

int _pow2Floor(int n) {
  int p = 1;
  while ((p << 1) <= n) p <<= 1;
  return p;
}

  // -------------------------------

  void setTopic(String topic, List<Candidate> candidates) {
    startTournament(topic, candidates);
  }

  /// 토너먼트 시작/재시작
  void startTournament(String topic, List<Candidate> candidates) {
    _topicTitle = topic;
    _winner = null;
    _nextRound.clear();
    _index = 0;

    _currentRound = List<Candidate>.from(candidates)..shuffle(_rand);

    // 🔹 라운드 메타 초기화
    _roundPairsPlayed = 0;
    _byeThisRound = false;

    // 🔹 부전승 사전 배정(홀수면 1명 bye → 다음 라운드에 선반영)
    if (_currentRound.length.isOdd) {
      final bye = _currentRound.removeAt(_rand.nextInt(_currentRound.length));
      _nextRound.add(bye);
      _byeThisRound = true;
      _roundEntrants = _currentRound.length + 1; // 표기용: 부전승 포함
    } else {
      _roundEntrants = _currentRound.length;
    }

    _roundPairsTotal = (_currentRound.length / 2).floor();

    _dealNextPair();
    notifyListeners();
  }

  void resetTournament() {
    _topicTitle = '';
    _currentRound.clear();
    _nextRound.clear();
    _left = null;
    _right = null;
    _winner = null;
    _index = 0;

    _roundEntrants = 0;
    _roundPairsTotal = 0;
    _roundPairsPlayed = 0;
    _byeThisRound = false;

    notifyListeners();
  }

  /// ✅ 라운드 진행
  void _dealNextPair() {
    _left = null;
    _right = null;

    // 라운드 종료 시
    if (_index >= _currentRound.length) {
      // 다음 라운드 후보가 1명이면 우승 확정
      if (_nextRound.length == 1) {
        _winner = _nextRound.first;
        _currentRound = [];
        _nextRound.clear();
        _index = 0;

        // 라운드 메타 리셋
        _roundEntrants = 1;
        _roundPairsTotal = 0;
        _roundPairsPlayed = 0;
        _byeThisRound = false;
        return;
      }

      // 다음 라운드로 교체
      _currentRound = List<Candidate>.from(_nextRound);
      _nextRound.clear();
      _index = 0;

      // 🔹 새 라운드 메타 초기화
      _roundPairsPlayed = 0;
      _byeThisRound = false;

      // 🔹 홀수면 부전승 처리 (다음 라운드도)
      if (_currentRound.length.isOdd) {
        final bye = _currentRound.removeAt(_rand.nextInt(_currentRound.length));
        _nextRound.add(bye);
        _byeThisRound = true;
        _roundEntrants = _currentRound.length + 1; // 표기용
      } else {
        _roundEntrants = _currentRound.length;
      }
      _roundPairsTotal = (_currentRound.length / 2).floor();
    }

    // 다음 페어 세팅
    if (_index < _currentRound.length) {
      _left = _currentRound[_index];
    }
    if (_index + 1 < _currentRound.length) {
      _right = _currentRound[_index + 1];
    } else {
      // 홀수 부전승: 오른쪽이 없으면 왼쪽 자동 진출
      if (_left != null) {
        _nextRound.add(_left!);
        _index += 2;
        _dealNextPair(); // 다음 페어로 즉시 진행
        return;
      }
    }

    // 다음 비교 인덱스
    _index += 2;
    notifyListeners();
  }

  /// 사용자가 승자 선택
  void pickWinner(Candidate selected) {
    _nextRound.add(selected);
    _roundPairsPlayed += 1; // 🔹 이번 라운드 대결 1건 완료
    _dealNextPair();
    notifyListeners();
  }
}
