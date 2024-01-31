import 'dart:io';

import 'package:releaser/release/instruction.dart';

import '../application/process_runner.dart';

/// An OS dependent instruction to copy a
/// file or directory.
class CopyInstruction implements Instruction {
  final ProcessRunner processRunner;

  /// The path to the build file or directory
  /// relative to the software repository root.
  final String buildPath;
  final String destinationPath;

  /// The name of the operating system to know
  /// which command to use.
  /// See [Platform.operatingSystem].
  final String os;

  CopyInstruction({
    required this.processRunner,
    required this.buildPath,
    required this.destinationPath,
    required String os,
  }) : os = os.toLowerCase() {
    if (!['windows', 'macos', 'linux'].contains(this.os)) {
      throw UnsupportedError(
        'The operating system $os is not supported.',
      );
    }
  }

  @override
  void execute() {
    List<String> commands;

    if (os == 'windows') {
      commands = [
        'cmd',
        '/c',
        'copy',
        buildPath,
        destinationPath,
      ];
    } else {
      commands = ['cp', buildPath, destinationPath];
    }

    processRunner.run(commands);
  }
}
