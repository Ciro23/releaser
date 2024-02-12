import 'dart:io';

import '../application/process_runner.dart';
import 'instruction.dart';

/// An OS dependent instruction to copy a
/// file or directory.
class CopyInstruction implements Instruction {
  final ProcessRunner processRunner;

  final String sourcePath;
  final String destinationPath;

  /// The name of the operating system to know
  /// which command to use.
  /// See [Platform.operatingSystem].
  final String os;

  CopyInstruction({
    required this.processRunner,
    required this.sourcePath,
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
  Future<void> execute() async {
    List<String> commands;

    if (os == 'windows') {
      commands = [
        'cmd',
        '/c',
        'copy',
        sourcePath,
        destinationPath,
      ];
    } else {
      commands = ['cp', sourcePath, destinationPath];
    }

    processRunner.run(commands);
  }

  @override
  String get name => "Copy";

  @override
  List<String> get arguments => [sourcePath, destinationPath];
}
