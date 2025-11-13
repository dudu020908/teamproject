import 'package:flutter/foundation.dart';
import '../model/candidate.dart';
import 'dart:math';

enum TournamentState { playing, finished }

class TournamentProvider extends ChangeNotifier {
  String _topicTitle = '';
  String get topicTitle => _topicTitle;

  List<Candidate> _currentRound = <Candidate>[];
  final List<Candidate> _nextRound = <Candidate>[];
  int _index = 0;

  Candidate? _left;
  Candidate? _right;
  Candidate? get left => _left;
  Candidate? get right => _right;

  Candidate? _winner;
  Candidate? get winner => _winner;
  bool get hasWinner => _winner != null;

  List<Candidate> get currentPair {
    final list = <Candidate>[];
    if (_left != null) list.add(_left!);
    if (_right != null) list.add(_right!);
    return list;
  }

  final _rand = Random();

  int _roundEntrants = 0;
  int _roundPairsTotal = 0;
  int _roundPairsPlayed = 0;
  bool _byeThisRound = false;

  int get roundEntrants => _roundEntrants;
  int get roundPairsTotal => _roundPairsTotal;
  int get roundPairsPlayed => _roundPairsPlayed;
  bool get byeThisRound => _byeThisRound;

  int get currentPairIndexDisplay {
    if (_roundPairsTotal == 0) return 0;

    // 이번 라운드에서 이미 확정된 진출 슬롯 수 (부전승 + 승자들)
    final decided = _nextRound.length;

    // 아직 아무도 안 정해졌으면 1부터 시작
    if (decided <= 0) return 1;

    return decided.clamp(1, _roundPairsTotal);
  }

  String get roundLabel {
    // 이번 라운드 참가 인원 수 (부전승 포함)
    var total = _roundEntrants;

    // 혹시 초기 상태 등에서 0이면, 안전하게 보정
    if (total == 0) {
      total = _currentRound.length + (_byeThisRound ? 1 : 0);
    }

    if (total <= 1) return ''; // 우승 확정 후 등 라벨 불필요
    if (total == 2) return '결승';
    return '${total}강';
  }

  void setTopic(String topic, List<Candidate> candidates) {
    startTournament(topic, candidates);
  }

  //토너먼트 시작
  void startTournament(String topic, List<Candidate> candidates) {
    _topicTitle = topic;
    _winner = null;
    _nextRound.clear();
    _index = 0;

    _currentRound = List<Candidate>.from(candidates)..shuffle(_rand);

    _roundPairsPlayed = 0;
    _byeThisRound = false;

    // 라운드 시작 시 1명만 부전승
    if (_currentRound.length.isOdd) {
      final bye = _currentRound.removeAt(_rand.nextInt(_currentRound.length));
      _nextRound.add(bye);
      _byeThisRound = true;

      // 이번 라운드 총 인원 = 대결 인원 + 부전승 1명
      _roundEntrants = _currentRound.length + 1;
    } else {
      _roundEntrants = _currentRound.length;
    }

    // ✅ 이번 라운드 종료 후 남게 될 인원 수 (ceil)
    _roundPairsTotal = (_roundEntrants + 1) ~/ 2;

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

  //라운드 페어 진행
  void _dealNextPair() {
    _left = null;
    _right = null;

    // 라운드 끝났는지 확인
    if (_index >= _currentRound.length) {
      //우승자 확정
      if (_nextRound.length == 1) {
        _winner = _nextRound.first;
        _currentRound = [];
        _nextRound.clear();
        _index = 0;

        _roundEntrants = 1;
        _roundPairsTotal = 0;
        _roundPairsPlayed = 0;
        _byeThisRound = false;
        notifyListeners();
        return;
      }

      // 다음 라운드로 이동
      _currentRound = List<Candidate>.from(_nextRound);
      _nextRound.clear();
      _index = 0;

      _roundPairsPlayed = 0;
      _byeThisRound = false;

      //다음 라운드에서도 홀수면 부전승 1명만 배정
      if (_currentRound.length.isOdd) {
        final bye = _currentRound.removeAt(_rand.nextInt(_currentRound.length));
        _nextRound.add(bye);
        _byeThisRound = true;
        _roundEntrants = _currentRound.length + 1;
      } else {
        _roundEntrants = _currentRound.length;
      }

      // 이번 라운드 총 인원(_roundEntrants)을 기준으로
      // 종료 후 남을 인원 수(슬롯 수)를 다시 계산
      _roundPairsTotal = (_roundEntrants + 1) ~/ 2;
    }

    // 페어 세팅
    if (_index < _currentRound.length) {
      _left = _currentRound[_index];
      _right = _currentRound[_index + 1];
    }

    _index += 2;
    notifyListeners();
  }

  // 승자 선택
  void pickWinner(Candidate selected) {
    _nextRound.add(selected);
    _roundPairsPlayed += 1;
    _dealNextPair();
  }
}
