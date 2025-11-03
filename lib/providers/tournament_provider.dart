import 'package:flutter/foundation.dart';
import '../model/candidate.dart';

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

  void setTopic(String topic, List<Candidate> candidates) {
    startTournament(topic, candidates);
  }

  /// 토너먼트 시작/재시작
  void startTournament(String topic, List<Candidate> candidates) {
    _topicTitle = topic;
    _winner = null;
    _nextRound.clear();
    _index = 0;

    _currentRound = List<Candidate>.from(candidates);
    // 필요하면 섞기
    // _currentRound.shuffle();

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
    notifyListeners();
  }

  // === 선택 (두 방식 모두 지원) ===
  void chooseLeft() => _choose(_left);
  void chooseRight() => _choose(_right);
  void pickWinner(Candidate selected) => _choose(selected);

  void _choose(Candidate? chosen) {
    if (chosen == null) return;
    _nextRound.add(chosen);
    _dealNextPair();
    notifyListeners();
  }

  // === 라운드 진행 로직 ===
  void _dealNextPair() {
    _left = null;
    _right = null;

    // 현재 라운드 소진 시
    if (_index >= _currentRound.length) {
      // 다음 라운드 후보가 1명이면 우승 확정
      if (_nextRound.length == 1) {
        _winner = _nextRound.first;
        _currentRound = <Candidate>[];
        _nextRound.clear();
        _index = 0;
        return;
      }
      // 다음 라운드로 교체
      _currentRound = List<Candidate>.from(_nextRound);
      _nextRound.clear();
      _index = 0;
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
  }
}
