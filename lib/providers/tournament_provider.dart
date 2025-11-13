// providers/tournament_provider.dart

import 'package:flutter/foundation.dart';
import '../model/candidate.dart';
import 'dart:math';

class TournamentProvider extends ChangeNotifier {
  // ===== 기본 메타 정보 =====
  String _topicTitle = '';
  String get topicTitle => _topicTitle;

  // 현재 라운드에서 실제로 대결할 후보 리스트
  // (홀수인 경우, 여기 안에 부전승용 Candidate를 한 명 추가해서 짝수로 맞춤)
  List<Candidate> _currentRound = <Candidate>[];

  // 다음 라운드 진출 후보를 모아두는 리스트
  final List<Candidate> _nextRound = <Candidate>[];

  // 현재 라운드에서 몇 번째 페어를 보고 있는지 (0,2,4,...)
  int _index = 0;

  // 현재 화면에 보여줄 좌/우 후보
  Candidate? _left;
  Candidate? _right;
  Candidate? get left => _left;
  Candidate? get right => _right;

  // 최종 우승자
  Candidate? _winner;
  Candidate? get winner => _winner;
  bool get hasWinner => _winner != null;

  // 현재 화면에 표시할 페어 (null 제외한 좌/우 후보 리스트)
  List<Candidate> get currentPair {
    final list = <Candidate>[];
    if (_left != null) list.add(_left!);
    if (_right != null) list.add(_right!);
    return list;
  }

  final _rand = Random();

  // ===== 라운드 정보 =====

  // 이번 라운드 "원래" 인원 수 (부전승 더 넣기 전 기준)
  // 9명 → 9, 5명 → 5, 3명 → 3, 2명 → 2
  int _roundOriginalCount = 0;

  // 이번 라운드 전체 경기(페어) 수 = ceil(N / 2)
  int _roundPairsTotal = 0;

  // 지금까지 끝낸 경기(페어) 수
  int _roundPairsPlayed = 0;

  // 이번 라운드에 부전승 카드가 포함되어 있는지
  bool _byeThisRound = false;

  int get roundPairsTotal => _roundPairsTotal;
  int get roundPairsPlayed => _roundPairsPlayed;
  bool get byeThisRound => _byeThisRound;

  // 9명 → "9강", 5명 → "5강", 3명 → "3강", 2명 → "결승"
  String get roundLabel {
    if (_roundOriginalCount <= 1) return '';
    if (_roundOriginalCount == 2) return '결승';
    return '${_roundOriginalCount}강';
  }

  // 예: 9명 라운드면 1/5, 2/5, ..., 5/5
  int get currentPairIndexDisplay => _roundPairsTotal == 0
      ? 0
      : (_roundPairsPlayed + 1).clamp(1, _roundPairsTotal);

  // ===== 공개 API =====

  // 토너먼트 시작 (맨 처음 한 번만 호출)
  void startTournament(String topic, List<Candidate> candidates) {
    _topicTitle = topic;
    _winner = null;
    _nextRound.clear();
    _startNewRound(candidates); // 첫 라운드 준비
  }

  // 승자 선택 (PIKU 스타일: 한 페어에서 정확히 한 명만 선택)
  void pickWinner(Candidate selected) {
    // 이미 우승자가 결정된 후면 더 이상 처리하지 않음
    if (_winner != null) return;

    // 혹시라도 부전승 카드가 눌렸다면 무시(보통 UI에서 막지만 안정성 차원)
    if (selected.isBye) return;

    // 이번 라운드 진출 후보에 승자 추가
    _nextRound.add(selected);
    _roundPairsPlayed += 1;
    _index += 2; // 다음 페어 인덱스로 이동

    // ===== 이번 라운드가 끝났는지 확인 =====
    if (_roundPairsPlayed >= _roundPairsTotal) {
      // 다음 라운드 진출자가 1명이면 → 최종 우승
      if (_nextRound.length == 1) {
        _winner = _nextRound.first;
        _currentRound = [];
        _left = null;
        _right = null;
        _nextRound.clear();
        notifyListeners();
        return;
      }

      // 그 외에는 다음 라운드 시작
      _startNewRound(_nextRound);
      return;
    }

    // 아직 이번 라운드가 남았으면 다음 페어 세팅
    _setCurrentPairFromIndex();
    notifyListeners();
  }

  // ===== 내부 헬퍼 =====

  // 새 라운드를 준비하는 함수
  // entrants: 이번 라운드에 참가할 "실제 후보들" 리스트
  void _startNewRound(List<Candidate> entrants) {
    // entrants 를 복사해서 셔플
    _currentRound = List<Candidate>.from(entrants)..shuffle(_rand);
    _nextRound.clear();
    _index = 0;
    _roundPairsPlayed = 0;
    _byeThisRound = false;
    _left = null;
    _right = null;

    _roundOriginalCount = _currentRound.length;

    // 후보가 0명 또는 1명인 경우: 바로 우승 처리
    if (_roundOriginalCount <= 1) {
      if (_roundOriginalCount == 1) {
        _winner = _currentRound.first;
      }
      _currentRound = [];
      notifyListeners();
      return;
    }

    // 홀수인 경우: 부전승용 Candidate 를 하나 추가해서 짝수로 맞춤
    if (_currentRound.length.isOdd) {
      _currentRound.add(Candidate.byeCandidate);
      _byeThisRound = true;
    }

    // 이번 라운드 총 경기 수 = 짝수로 맞춘 후 / 2
    _roundPairsTotal = _currentRound.length ~/ 2;

    // 첫 번째 페어 세팅
    _setCurrentPairFromIndex();
    notifyListeners();
  }

  // 현재 _index 기준으로 _left, _right 설정
  void _setCurrentPairFromIndex() {
    if (_index >= 0 && _index + 1 < _currentRound.length) {
      _left = _currentRound[_index];
      _right = _currentRound[_index + 1];
    } else {
      _left = null;
      _right = null;
    }
  }
}
