import 'package:releaser/paths/paths.dart';
import 'package:test/test.dart';

void main() {
  test("all directory paths end with a separator", () {
    String separator = Paths.getSeparator();

    expect(Paths.getReleaserPath().endsWith(separator), true);
    expect(Paths.getHomePath().endsWith(separator), true);
  });

  test("all file paths do not end with a separator", () {
    String separator = Paths.getSeparator();

    expect(Paths.getSoftwarePath().endsWith(separator), false);
  });
}