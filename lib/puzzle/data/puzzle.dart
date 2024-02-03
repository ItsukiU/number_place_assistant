import 'package:iu_number_place_assistant/puzzle/common/constants.dart';
import 'package:iu_number_place_assistant/puzzle/data/numbers.dart';
import 'package:iu_number_place_assistant/puzzle/data/probability.dart';

/// Puzzle
class Puzzle {
  /// Puzzle
  late PuzzleNumbers _numbers;

  /// Probability
  late PuzzleProbabilities _probabilities;

  /// Create [Puzzle] instance
  Puzzle(List<List<int>> puzzle) {
    _numbers = PuzzleNumbers();
    _probabilities = PuzzleProbabilities();

    var i = 0;
    for (var r = 0; r < PuzzleConstants.n9; r++) {
      for (var c = 0; c < PuzzleConstants.n9; c++) {
        var block = 3 * (r ~/ 3) + c ~/ 3;
        var pos = 3 * (r % 3) + c % 3;
        if (puzzle[block][pos] != 0) {
          setNumber(i, puzzle[block][pos]);
        }
        i++;
      }
    }
  }

  /// Clone [Puzzle] class
  Puzzle.clone(Puzzle puzzle) {
    _numbers = PuzzleNumbers.clone(puzzle._numbers);
    _probabilities = PuzzleProbabilities.clone(puzzle._probabilities);
  }

  /// Sets the probability[prob] whether the number of the cell[index] is [n] + 1
  /// Returns `true` if the probablity changes.
  bool setProbability(int index, int n, bool prob) {
    return _probabilities.set(index, n, prob);
  }

  /// Gets probability which the number of the cell[index] is [n] + 1
  bool getProbability(int index, int n) {
    return _probabilities.get(index, n);
  }

  /// Gets probabilities for the cell[index]
  List<bool> getProbabilities(int index) {
    return _probabilities.getAll(index);
  }

  /// Gets part of probability
  Iterable<Iterable<(int, List<bool>)>> getProbabilityPart(
      PuzzleParts part) sync* {
    yield* _probabilities.getPart(part);
  }

  /// Sets [number](1..9) by the [index]
  bool setNumber(int index, int number) {
    if (!_numbers.set(index, number)) return false;
    _probabilities.confirmNumber(index, number - 1);
    return true;
  }

  /// Gets part of puzzle
  Iterable<List<int>> getPuzzlePart(PuzzleParts part) sync* {
    yield* _numbers.getPuzzlePart(part);
  }

  /// Print for debug
  void print() {
    _numbers.print();
    _probabilities.print();
  }
}
