import 'package:flutter/foundation.dart';
import 'package:iu_number_place_assistant/puzzle/analyzer.dart';
import 'package:iu_number_place_assistant/puzzle/common/constants.dart';
import 'package:iu_number_place_assistant/puzzle/data/puzzle.dart';

/// Puzzle solver results
enum SolverResults {
  success,
  failed,
  invalid,
}

/// Puzzle solver class
class PuzzleSolver extends PuzzleAnalyzer {
  PuzzleSolver(List<List<int>> puzzle) : super(puzzle);

  /// Solve puzzle
  /// Return result and answer
  ({SolverResults result, List<List<int>>? puzzle}) solve() {
    this.print();
    while (true) {
      // Impose conditions
      var countCond = _imposeConditions();
      debugPrint("condition $countCond");
      if (countCond > 0) continue;
      this.print();

      // Had it finished?
      if (isCompleted()) {
        return (result: SolverResults.success, puzzle: exportPuzzle());
      }

      // Step 1
      var countBlock = _imposeBlockCondtion();
      debugPrint("block $countBlock");
      if (countBlock > 0) continue;

      // Step 2
      var countMatch = _patternMatches();
      debugPrint("pattern $countMatch");
      if (countMatch > 0) continue;

      // Step 3
      var nps = 5;
      var ips = 2;
      for (; ips < nps; ips++) {
        if (_findContradiction(ips)) break;
      }
      if (ips < nps) continue;

      break;
    }

    // Does it have answer?
    if (!isValid()) {
      return (result: SolverResults.invalid, puzzle: null);
    }

    return (result: SolverResults.failed, puzzle: null);
  }

  /// Impose row/column/block conditions
  int _imposeConditions() {
    var count = 0;
    count += _imposeCondition(PuzzleParts.row);
    count += _imposeCondition(PuzzleParts.column);
    count += _imposeCondition(PuzzleParts.block);
    return count;
  }

  /// Impose [part] conditions
  int _imposeCondition(PuzzleParts part) {
    var count = 0;
    for (var pp in puzzle.getProbabilityPart(part)) {
      for (var n in PuzzleConstants.numbers) {
        var p = getPossibleIndex(pp, n).toList();
        if (p.length == 1) {
          var l = p.first;
          if (puzzle.setNumber(l, n + 1)) {
            count++;
          }
        }
      }
    }
    return count;
  }

  /// Impose block condition
  int _imposeBlockCondtion() {
    var count = 0;
    for (var n in PuzzleConstants.numbers) {
      for (var (ir, r) in puzzle.getProbabilityPart(PuzzleParts.row).indexed) {
        var p = getPossibleIndex(r, n).toList();
        if (p.length < 2) continue;

        for (var i = 0; i < 3; i++) {
          var p1 = getPossibleIndex(r.skip(3 * i).take(3), n);
          if (p1.length == p.length) {
            var block = [...PuzzleConstants.blockRows[3 * (ir ~/ 3) + i]];
            block.removeRange(3 * (ir % 3), 3 * (ir % 3 + 1));
            for (var l in block) {
              if (puzzle.setProbability(l, n, false)) {
                count++;
              }
            }
            break;
          }
        }
      }
      for (var (ic, c)
          in puzzle.getProbabilityPart(PuzzleParts.column).indexed) {
        var p = getPossibleIndex(c, n).toList();
        if (p.length < 2) continue;

        for (var i = 0; i < 3; i++) {
          var p1 = getPossibleIndex(c.skip(3 * i).take(3), n);
          if (p1.length == p.length) {
            var block = [...PuzzleConstants.blockColumns[3 * i + ic ~/ 3]];
            block.removeRange(3 * (ic % 3), 3 * (ic % 3 + 1));
            for (var l in block) {
              if (puzzle.setProbability(l, n, false)) {
                count++;
              }
            }
            break;
          }
        }
      }
    }

    return count;
  }

  /// Pattern match solver
  int _patternMatches() {
    var count = 0;
    count += _patternMatch(PuzzleParts.row);
    count += _patternMatch(PuzzleParts.column);
    count += _patternMatch(PuzzleParts.block);
    return count;
  }

  /// Pattern match solver for [part]
  int _patternMatch(PuzzleParts part) {
    var count = 0;
    for (var pp in puzzle.getProbabilityPart(part)) {
      for (var n0 in PuzzleConstants.numbers) {
        var p = getPossibleIndex(pp, n0).toList();
        var np = p.length;
        if (np < 2) continue;

        var ms = [n0];
        for (var n1 in PuzzleConstants.numbers.skip(n0 + 1)) {
          var diff = false;
          for (var (l, _) in pp) {
            diff |= puzzle.getProbability(l, n0) ^ puzzle.getProbability(l, n1);
          }
          if (diff) continue;
          ms.add(n1);
        }

        if (np == ms.length) {
          for (var n1 in PuzzleConstants.numbers) {
            if (ms.contains(n1)) continue;
            for (var l in p) {
              if (puzzle.setProbability(l, n1, false)) {
                count++;
              }
            }
          }
        }
      }
    }
    return count;
  }

  // Contradiction solver
  bool _findContradiction(var nps) {
    // backup
    var puzzleCache = Puzzle.clone(puzzle);

    for (var l = 0; l < PuzzleConstants.n9 * PuzzleConstants.n9; l++) {
      var np = puzzle.getProbabilities(l).fold(0, (y, x) => x ? y + 1 : y);
      if (np == nps) {
        for (var (n, _)
            in puzzle.getProbabilities(l).indexed.where((x) => x.$2)) {
          // assume
          puzzle.setNumber(l, n + 1);

          while (true) {
            // Impose conditions
            var countCond = _imposeConditions();
            if (countCond > 0) continue;

            // Step 1
            var countBlock = _imposeBlockCondtion();
            if (countBlock > 0) continue;

            // Step 2
            var countMatch = _patternMatches();
            if (countMatch > 0) continue;

            break;
          }

          // Is there no contradiction?
          if (isValid()) {
            puzzle = Puzzle.clone(puzzleCache);
            continue;
          }

          // Found it!
          puzzle = Puzzle.clone(puzzleCache);
          puzzle.setProbability(l, n, false);
          return true;
        }
      }
    }
    return false;
  }
}
