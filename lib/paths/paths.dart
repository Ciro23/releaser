import 'dart:io';

/// Provides paths useful for application file
/// handling.
class Paths {

  /// The main folder for all application files.
  static String getReleaserPath() {
    String sep = getSeparator();
    return '${getHomePath()}$sep.releaser$sep';
  }

  /// The file containing the list of saved software.
  static String getSoftwarePath() {
    return '${getReleaserPath()}software.csv';
  }

  /// The OS specific home path.
  static String getHomePath() {
    if (Platform.isWindows) {
      return Platform.environment['UserProfile']!;
    }

    return Platform.environment['HOME']!;
  }

  /// The OS specific path separator.
  static String getSeparator() {
    if (Platform.isWindows) {
      return '\\';
    }

    return '/';
  }

  static String getNewLine() {
    return Platform.isWindows ? "\r\n" : "\n";
  }
}