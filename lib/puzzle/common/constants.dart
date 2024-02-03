/// Types of puzzle
enum PuzzleParts {
  row,
  column,
  block,
}

/// Puzzle data base
class PuzzleConstants {
  /// The number of row, column, and block
  static const int n9 = 9;

  /// The list of numbers from 0 to [n9] - 1
  static final List<int> numbers = List.generate(n9, (n) => n);

  /// The list of rows
  static final List<List<int>> rows =
      List.generate(n9, (r) => List.generate(n9, (c) => n9 * r + c));

  /// The list of columns
  static final List<List<int>> columns =
      List.generate(n9, (c) => List.generate(n9, (r) => n9 * r + c));

  /// The list of blocks(rows)
  static final List<List<int>> blockRows = List.generate(
      n9,
      (b) => List.generate(
          n9, (i) => 3 * (n9 * (b ~/ 3) + b % 3) + n9 * (i ~/ 3) + i % 3));

  /// The list of blocks(columns)
  static final List<List<int>> blockColumns = List.generate(
      n9,
      (b) => List.generate(
          n9, (i) => 3 * (n9 * (b ~/ 3) + b % 3) + n9 * (i % 3) + i ~/ 3));
}
