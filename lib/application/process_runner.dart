import 'dart:io';

/// This is a wrapper for the [Process] class to make
/// unit testing possible.
class ProcessRunner {

  /// Runs the given [commands] in a new process and
  /// writes the output to [stdout].
  /// See [Process.run].
  Future<ProcessResult> run(List<String> commands) {
    return Process.run(commands[0], commands.sublist(1));
  }
}