import 'dart:io';
import 'dart:math';

int calculate(List<int> nums, String op) =>
    op == '*' ? nums.reduce((a, b) => a * b) : nums.reduce((a, b) => a + b);

bool isEmptyCol(List<String> lines, int col) =>
    lines.every((line) => line[col] == ' ');

int findNextEmpty(List<String> lines, int start, int direction) {
  var col = start;
  while (col >= 0 && col < lines[0].length && !isEmptyCol(lines, col)) {
    col += direction;
  }
  return col;
}

void part1(List<String> lines) {
  var total = 0;
  var col = 0;

  while (col < lines[0].length) {
    if (isEmptyCol(lines, col)) {
      col++;
      continue;
    }

    final end = findNextEmpty(lines, col, 1);

    final column = lines
        .map((line) => line.substring(col, end).trim())
        .toList();

    final op = column.last;
    final nums = column.sublist(0, column.length - 1).map(int.parse).toList();
    final result = calculate(nums, op);

    total += result;
    col = end;
  }

  print('part 1 $total');
}

void part2(List<String> lines) {
  var total = 0;
  var col = lines[0].length - 1;

  while (col >= 0) {
    if (isEmptyCol(lines, col)) {
      col--;
      continue;
    }

    final start = findNextEmpty(lines, col, -1) + 1;
    final nums = <int>[];

    for (var c = col; c >= start; c--) {
      final num = lines
          .sublist(0, lines.length - 1)
          .map((line) => line[c])
          .join();

      if (num.isNotEmpty) nums.add(int.parse(num));
    }

    final op = lines.last.substring(start, col + 1).trim();
    final result = calculate(nums, op);

    total += result;
    col = start - 1;
  }

  print('part 2 $total');
}

void main() async {
  final input = await File('problem.txt').readAsString();
  final lines = input.split('\n').where((l) => l.isNotEmpty).toList();
  final maxLen = lines.map((l) => l.length).reduce(max);
  final padded = lines.map((l) => l.padRight(maxLen)).toList();

  part1(padded);
  part2(padded);
}
