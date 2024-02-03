import 'package:flutter/foundation.dart';
import 'package:iu_number_place_assistant/puzzle/common/constants.dart';

class PuzzleProbabilities {
  /// Probability
  final List<List<bool>> _probability = List<List<bool>>.generate(
      PuzzleConstants.n9 * PuzzleConstants.n9,
      (_) => List<bool>.filled(PuzzleConstants.n9, true));

  PuzzleProbabilities();

  /// Clone [Puzzle] class
  PuzzleProbabilities.clone(PuzzleProbabilities probability) {
    for (var l = 0; l < PuzzleConstants.n9 * PuzzleConstants.n9; l++) {
      for (var n in PuzzleConstants.numbers) {
        _probability[l][n] = probability._probability[l][n];
      }
    }
  }

  /// Gets probavility which the number of the cell[index] is [n] + 1
  bool get(int index, int n) {
    return _probability[index][n];
  }

  /// Sets the probability[prob] whether the number of the cell[index] is [n] + 1
  /// Returns `true` if the probablity changes.
  bool set(int index, int n, bool prob) {
    if (_probability[index][n] == prob) {
      return false;
    }
    _probability[index][n] = prob;
    return true;
  }

  /// Gets probavilities which the numbers of the cell[index]
  List<bool> getAll(int index) {
    return _probability[index];
  }

  /// Confirm the number of the cell[index] is [n] (0..8)
  void confirmNumber(int index, int n) {
    for (var l in PuzzleConstants.rows[index ~/ PuzzleConstants.n9]) {
      _probability[l][n] = false;
    }

    for (var l in PuzzleConstants.columns[index % PuzzleConstants.n9]) {
      _probability[l][n] = false;
    }

    for (var l in PuzzleConstants.blockRows[
        3 * (index ~/ (3 * PuzzleConstants.n9)) +
            (index % PuzzleConstants.n9) ~/ 3]) {
      _probability[l][n] = false;
    }

    for (var n in PuzzleConstants.numbers) {
      _probability[index][n] = false;
    }

    _probability[index][n] = true;
  }

  /// Gets part of probability
  Iterable<Iterable<(int, List<bool>)>> getPart(PuzzleParts part) sync* {
    var map = switch (part) {
      PuzzleParts.row => PuzzleConstants.rows,
      PuzzleParts.column => PuzzleConstants.columns,
      PuzzleParts.block => PuzzleConstants.blockRows
    };

    iter(List<int> r) sync* {
      for (var l in r) {
        yield (l, _probability[l]);
      }
    }

    for (var r in map) {
      yield iter(r);
    }
  }

  /// Print for debug
  void print() {
    for (var r in PuzzleConstants.rows) {
      var str = "";
      for (var l in r) {
        str +=
            "${_probability[l].fold(0, (previousValue, element) => element ? previousValue + 1 : previousValue)}";
      }
      debugPrint(str);
    }
  }
}
