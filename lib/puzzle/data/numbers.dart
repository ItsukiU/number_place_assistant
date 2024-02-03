import 'package:flutter/foundation.dart';
import 'package:iu_number_place_assistant/puzzle/common/constants.dart';

/// Puzzle number
class PuzzleNumbers {
  /// Puzzle
  final List<int> _puzzle =
      List.filled(PuzzleConstants.n9 * PuzzleConstants.n9, 0);

  /// Create [PuzzleNumbers] instance
  PuzzleNumbers();

  /// Clone [PuzzleNumbers] class
  PuzzleNumbers.clone(PuzzleNumbers puzzle) {
    for (var l = 0; l < PuzzleConstants.n9 * PuzzleConstants.n9; l++) {
      _puzzle[l] = puzzle._puzzle[l];
    }
  }

  /// Sets [number](1..9) by the [index]
  /// Returns `true` if successed in changing.
  bool set(int index, int number) {
    if (_puzzle[index] != 0) return false;
    _puzzle[index] = number;
    return true;
  }

  /// Gets [number](1..9) by the [index]
  int get(int index) {
    return _puzzle[index];
  }

  /// Gets part of puzzle
  Iterable<List<int>> getPuzzlePart(PuzzleParts part) sync* {
    var map = switch (part) {
      PuzzleParts.row => PuzzleConstants.rows,
      PuzzleParts.column => PuzzleConstants.columns,
      PuzzleParts.block => PuzzleConstants.blockRows
    };
    for (var r in map) {
      yield [for (var l in r) _puzzle[l]];
    }
  }

  /// Print for debug
  void print() {
    for (var r in PuzzleConstants.rows) {
      var str = "";
      for (var l in r) {
        str += "${_puzzle[l]}";
      }
      debugPrint(str);
    }
  }
}
