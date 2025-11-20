import 'package:flutter/foundation.dart';
import 'dart:math';
import '../model/candidate.dart';

class TournamentProvider extends ChangeNotifier {
  // 토너먼트 기본 정보

  String _topicTitle = '';
  String get topicTitle => _topicTitle;

  //현재 라운드에서 실제 대결할 후보 목록
  List<Candidate> _currentRound = <Candidate>[];

  // 다음 라운드에 진출할 후보들을 임시 저장해두는 리스트
  final List<Candidate> _nextRound = <Candidate>[];

  // 현재 라운드의 페어 index (예: 0→첫번째 페어, 2→두번째 페어)
  int _index = 0;

  // 현재 화면에 표시할 좌·우 후보
  Candidate? _left;
  Candidate? _right;

  Candidate? get left => _left;
  Candidate? get right => _right;

  // 최종 우승자
  Candidate? _winner;
  Candidate? get winner => _winner;

  // 우승자 결정 여부
  bool get hasWinner => _winner != null;

  // 현재 페어 반환 (null 제외)
  List<Candidate> get currentPair {
    final list = <Candidate>[];
    if (_left != null) list.add(_left!);
    if (_right != null) list.add(_right!);
    return list;
  }

  // 랜덤 셔플용
  final _rand = Random();

  // 라운드 정보
  int _roundOriginalCount = 0;

  // 이번 라운드 전체 경기 수 (홀수 → 부전승 포함 후 계산)
  int _roundPairsTotal = 0;
  int get roundPairsTotal => _roundPairsTotal;

  // 현재까지 끝난 경기 수
  int _roundPairsPlayed = 0;
  int get roundPairsPlayed => _roundPairsPlayed;

  // 현재 라운드에 부전승 후보가 포함되었는가?
  bool _byeThisRound = false;
  bool get byeThisRound => _byeThisRound;

  // UI용 라벨: "8강", "4강", "결승"
  String get roundLabel {
    if (_roundOriginalCount <= 1) return '';
    if (_roundOriginalCount == 2) return '결승';
    return '${_roundOriginalCount}강';
  }

  // UI용 라운드 진행 표시: "2/4"
  int get currentPairIndexDisplay => _roundPairsTotal == 0
      ? 0
      : (_roundPairsPlayed + 1).clamp(1, _roundPairsTotal);

  // 토너먼트 시작
  void startTournament(String topic, List<Candidate> candidates) {
    _topicTitle = topic;
    _winner = null;
    _nextRound.clear();
    _startNewRound(candidates);
  }

  // 한 페어에서 승자를 선택
  void pickWinner(Candidate selected) {
    if (_winner != null) return; // 이미 우승자 확정됨
    if (selected.isBye) return; // 부전승 카드는 선택될 수 없음

    // 승자 다음 라운드 진출
    _nextRound.add(selected);

    _roundPairsPlayed += 1;
    _index += 2;

    // 라운드 종료 여부 확인
    if (_roundPairsPlayed >= _roundPairsTotal) {
      // 다음 라운드 진출자가 1명 → 우승
      if (_nextRound.length == 1) {
        _winner = _nextRound.first;
        _currentRound = [];
        _left = null;
        _right = null;
        _nextRound.clear();
        notifyListeners();
        return;
      }

      // 다음 라운드 시작
      _startNewRound(_nextRound);
      return;
    }

    // 아직 라운드 남음 → 다음 페어 생성
    _setCurrentPairFromIndex();
    notifyListeners();
  }

  // 새로운 라운드를 준비
  void _startNewRound(List<Candidate> entrants) {
    // 후보 셔플
    _currentRound = List<Candidate>.from(entrants)..shuffle(_rand);

    _nextRound.clear();
    _index = 0;
    _roundPairsPlayed = 0;
    _byeThisRound = false;
    _left = null;
    _right = null;

    _roundOriginalCount = _currentRound.length;

    // 후보가 0 또는 1 → 바로 우승 처리
    if (_roundOriginalCount <= 1) {
      if (_roundOriginalCount == 1) {
        _winner = _currentRound.first;
      }
      _currentRound = [];
      notifyListeners();
      return;
    }

    // 홀수라면 부전승 카드 추가
    if (_currentRound.length.isOdd) {
      _currentRound.add(Candidate.byeCandidate);
      _byeThisRound = true;
    }

    // 라운드 경기 수 = 후보 수 / 2
    _roundPairsTotal = _currentRound.length ~/ 2;

    // 첫 페어 세팅
    _setCurrentPairFromIndex();
    notifyListeners();
  }

  // _index 위치 기준으로 좌·우 후보 배치
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
