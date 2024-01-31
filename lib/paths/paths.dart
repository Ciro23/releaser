import 'dart:io';

/// Provides paths useful for application file
/// handling.
/// 
/// All directory paths ends with a separator.
///
/// All file paths do not ends with a separator.
class Paths {

  /// The main folder for all application files.
  static String getReleaserPath() {
    String sep = getSeparator();
    return '${getHomePath()}.releaser$sep';
  }

  /// The file containing the list of saved software.
  static String getSoftwarePath() {
    return '${getReleaserPath()}software.csv';
  }

  /// The OS specific home path.
  static String getHomePath() {
    String sep = getSeparator();
    if (Platform.isWindows) {
      return Platform.environment['UserProfile']! + sep;
    }

    return Platform.environment['HOME']! + sep;
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