import 'package:flutter/foundation.dart';
import '../model/candidate.dart';

enum TournamentState { playing, finished }

class TournamentProvider with ChangeNotifier {
  final List<Candidate> _initial;
  List<Candidate> _currentRound = [];
  List<Candidate> _nextRound = [];
  Candidate? _left;
  Candidate? _right;
  Candidate? _winner;
  TournamentState _state = TournamentState.playing;

  TournamentProvider(List<Candidate> initial)
    : _initial = List.of(initial)..shuffle() {
    _currentRound = List.of(_initial);
    _dealNextPair();
  }

  TournamentState get state => _state;
  Candidate? get left => _left;
  Candidate? get right => _right;
  Candidate? get winner => _winner;

  int get currentRoundSize => _currentRound.length;
  int get remainingPairs =>
      (_currentRound.length / 2).ceil() +
      (_left != null && _right != null ? 1 : 0);

  void chooseLeft() => _choose(_left);
  void chooseRight() => _choose(_right);

  void _choose(Candidate? chosen) {
    if (chosen == null) return;
    _nextRound.add(chosen);
    _dealNextPair();
    notifyListeners();
  }

  void _dealNextPair() {
    _left = null;
    _right = null;

    // 라운드 소진 시 다음 라운드로
    if (_currentRound.isEmpty) {
      if (_nextRound.length == 1) {
        _winner = _nextRound.first;
        _state = TournamentState.finished;
        return;
      }
      _currentRound = List.of(_nextRound);
      _nextRound.clear();
    }

    // 후보가 홀수면 마지막 하나는 부전승(nextRound로 미리 이동)
    if (_currentRound.length == 1) {
      _nextRound.add(_currentRound.removeAt(0));
      _dealNextPair(); // 재귀적으로 다음 페어 세팅
      return;
    }

    // 두 명 뽑아 페어 구성
    _left = _currentRound.removeAt(0);
    _right = _currentRound.removeAt(0);
  }

  void reset() {
    _currentRound = List.of(_initial)..shuffle();
    _nextRound.clear();
    _left = null;
    _right = null;
    _winner = null;
    _state = TournamentState.playing;
    _dealNextPair();
    notifyListeners();
  }
}
