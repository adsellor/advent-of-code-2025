import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.stream.LongStream;

boolean isInvalid(long id) {
  String s = String.valueOf(id);
  int len = s.length();
  return len % 2 == 0 && s.substring(0, len / 2).equals(s.substring(len / 2));
}

boolean isInvalidPart2(long id) {
  String s = String.valueOf(id);
  int len = s.length();
  for (int patternLen = 1; patternLen <= len / 2; patternLen++) {
    if (len % patternLen != 0) continue;
    boolean allMatch = true;
    String pattern = s.substring(0, patternLen);
    for (int i = patternLen; i < len; i += patternLen) {
      if (!s.substring(i, i + patternLen).equals(pattern)) {
        allMatch = false;
        break;
      }
    }
    if (allMatch) return true;
  }

  return false;
}

long sumIds(String range) {
  String[] bounds = range.split("-");
  long start = Long.parseLong(bounds[0]);
  long end = Long.parseLong(bounds[1]);

  return LongStream.rangeClosed(start, end)
    .filter(this::isInvalid)
    .sum();
}

long sumIdsPart2(String range) {
  String[] bounds = range.split("-");
  long start = Long.parseLong(bounds[0]);
  long end = Long.parseLong(bounds[1]);

  return LongStream.rangeClosed(start, end)
    .filter(this::isInvalidPart2)
    .sum();
}

void main() throws Exception {
  String input = Files.readString(Path.of("ranges.txt")).replaceAll("\\s+", "");
  String[] splittedInput = input.split(",");
  long resultP1 = Arrays.stream(splittedInput)
    .mapToLong(this::sumIds)
    .sum();

  long resultP2 = Arrays.stream(splittedInput)
    .mapToLong(this::sumIdsPart2)
    .sum();

  System.out.println("Part 1 " + resultP1);
  System.out.println("Part 2 " + resultP2);
}
