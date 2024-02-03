import 'package:iu_number_place_assistant/puzzle/common/constants.dart';
import 'package:iu_number_place_assistant/puzzle/data/puzzle.dart';

/// Analyzer for puzzle
class PuzzleAnalyzer {
  /// Puzzle
  late Puzzle puzzle;

  /// Create [PuzzleAnalyzer] instance
  PuzzleAnalyzer(List<List<int>> puzzle) {
    this.puzzle = Puzzle(puzzle);
  }

  /// Gets the indexes of which the posibility is [n]
  Iterable<int> getPossibleIndex(Iterable<(int, List<bool>)> map, int n) {
    return map.where((e) => e.$2[n]).map((e) => e.$1);
  }

  /// Whether the puzzle is complated or not
  bool isCompleted() {
    if (!_isCompleted(PuzzleParts.row)) return false;
    if (!_isCompleted(PuzzleParts.column)) return false;
    if (!_isCompleted(PuzzleParts.block)) return false;
    return true;
  }

  /// Whether the puzzle has an answer or not
  bool isValid() {
    if (!_isValid(PuzzleParts.row)) return false;
    if (!_isValid(PuzzleParts.column)) return false;
    if (!_isValid(PuzzleParts.block)) return false;
    return true;
  }

  /// Return puzzle
  List<List<int>> exportPuzzle() {
    var list = <List<int>>[];
    for (var pp in puzzle.getPuzzlePart(PuzzleParts.block)) {
      list.add([...pp]);
    }
    return list;
  }

  /// Print for debug
  void print() {
    puzzle.print();
  }

  /// Whether the puzzle is complated or not for [part]
  bool _isCompleted(PuzzleParts part) {
    for (var ps in puzzle.getProbabilityPart(part)) {
      for (var n in PuzzleConstants.numbers) {
        if (getPossibleIndex(ps, n).length != 1) {
          return false;
        }
      }
    }
    return true;
  }

  /// Whether the puzzle has an answer or not for [part]
  bool _isValid(PuzzleParts part) {
    for (var pp in puzzle.getProbabilityPart(part)) {
      for (var n in PuzzleConstants.numbers) {
        if (getPossibleIndex(pp, n).isEmpty) {
          return false;
        }
      }
    }
    return true;
  }
}
