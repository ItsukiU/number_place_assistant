import 'package:iu_number_place_assistant/puzzle/analyzer.dart';
import 'package:iu_number_place_assistant/puzzle/common/constants.dart';

/// Puzzle helper class
class PuzzleAssistant extends PuzzleAnalyzer {
  PuzzleAssistant(List<List<int>> puzzle) : super(puzzle);

  ({List<(int, int)> positions, List<int> numbers})? getHint() {
    return _findHintConditions();
  }

  /// Find hint from row/column/block conditions
  ({List<(int, int)> positions, List<int> numbers})? _findHintConditions() {
    var funcs = [
      () => _findHintcondition(PuzzleParts.row),
      () => _findHintcondition(PuzzleParts.column),
      () => _findHintcondition(PuzzleParts.block),
    ];
    funcs.shuffle();

    for (var f in funcs) {
      var a = f();
      if (a != null) return a;
    }
    return null;
  }

  /// Impose [part] conditions
  ({List<(int, int)> positions, List<int> numbers})? _findHintcondition(
      PuzzleParts part) {
    var parts = puzzle.getProbabilityPart(part).toList();
    parts.shuffle();
    var numbers = [...PuzzleConstants.numbers];
    numbers.shuffle();

    for (var pp in parts) {
      for (var n in numbers) {
        var p = getPossibleIndex(pp, n).toList();
        if (p.length == 1) {
          if (!puzzle.setNumber(p.first, n + 1)) continue;
          var pos = <(int, int)>[];
          for (var (l, _) in pp) {
            pos.add((
              3 * (l ~/ (3 * PuzzleConstants.n9)) +
                  (l % PuzzleConstants.n9) ~/ 3,
              3 * ((l % (3 * PuzzleConstants.n9)) ~/ PuzzleConstants.n9) + l % 3
            ));
          }

          return (positions: pos, numbers: [n]);
        }
      }
    }
    return null;
  }
}
