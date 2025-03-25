import 'dart:io';

import 'package:io/io.dart';
import 'package:uuid/uuid.dart';

import 'instruction.dart';

/// Use this instruction to execute all kinds of commands
/// using the shell currently installed on the user's computer.
/// For Windows, Powershell is used.
/// For Linux and macOS, the default `$SHELL` is used if the variable
/// is defined, otherwise `/bin/sh`.
/// The script's syntax must be compatible with the installed
/// shell.
class ShellInstruction implements Instruction<ShellInstruction> {
  final int? _id;

  @override
  final int executionOrder;

  /// E.g. "tar -C project_directory/ -czf compressed_folder.tar.gz ./"
  final String shellScript;

  /// The name of the operating system to know
  /// which shell to use.
  /// See [Platform.operatingSystem].
  final String os;

  ShellInstruction({
    int? id,
    required this.executionOrder,
    required this.shellScript,
    required String os,
  })  : _id = id,
        os = os.toLowerCase();

  @override
  Future<void> execute() async {
    String? shell;
    List<String> args;

    if (os == "windows") {
      shell = 'powershell';
      args = ['-Command', shellScript];
    } else {
      shell = Platform.environment['SHELL'] ?? '/bin/sh';
      args = ['-c', shellScript];
    }

    final result = await Process.run(shell, args);
    if (result.exitCode != 0) {
      throw Exception('Script execution failed: ${result.stderr}');
    }
  }

  @override
  int? get id => _id;

  @override
  String get name => "Shell";

  @override
  List<String> get arguments => [shellScript];

  @override
  String get executeMessage => "Running shell script: $shellScript";

  @override
  String toString() {
    return "Shell (script: $shellScript)";
  }

  @override
  ShellInstruction create(
    int? id,
    int order,
    List<String> arguments,
  ) {
    return ShellInstruction(
      id: id,
      executionOrder: order,
      shellScript: arguments[0],
      os: os,
    );
  }
}
