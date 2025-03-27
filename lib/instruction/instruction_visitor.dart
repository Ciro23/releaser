import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:archive/archive_io.dart';
import 'package:io/io.dart';
import 'package:releaser/instruction/copy_instruction.dart';
import 'package:releaser/instruction/shell_instruction.dart';
import 'package:releaser/instruction/zip_instruction.dart';

/// Contains the business logic for the execution of [Instruction].
/// Visitor pattern is used to remove business logic from models.
class InstructionVisitor {
  /// The name of the operating system in use.
  /// See [Platform.operatingSystem].
  final String os;

  final ZipFileEncoder zipFileEncoder;

  InstructionVisitor({required this.os, required this.zipFileEncoder});

  void doForCopy(CopyInstruction instruction) {
    if (!['windows', 'macos', 'linux'].contains(os)) {
      throw UnsupportedError(
        'The operating system $os is not supported.',
      );
    }

    String source = instruction.sourcePath.toFilePath();
    String destination = instruction.destinationPath.toFilePath();

    if (source.endsWith(Platform.pathSeparator)) {
      copyPath(source, destination);
      return;
    }

    File file = File(source);
    file.copy(destination);
  }

  void doForZip(ZipInstruction instruction) {
    zipFileEncoder.zipDirectory(instruction.sourceDirectory,
        filename: path.fromUri(instruction.destinationPath));
  }

  Future<void> doForShell(ShellInstruction instruction) async {
    String? shell;
    List<String> args;

    if (os == "windows") {
      shell = 'powershell';
      args = ['-Command', instruction.shellScript];
    } else {
      shell = Platform.environment['SHELL'] ?? '/bin/sh';
      args = ['-c', instruction.shellScript];
    }

    final result = await Process.run(shell, args);
    if (result.exitCode != 0) {
      throw Exception('Script execution failed: ${result.stderr}');
    }
  }
}