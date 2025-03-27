import 'instruction.dart';
import 'instruction_visitor.dart';

/// Use this instruction to execute all kinds of commands
/// using the shell currently installed on the user's computer.
/// For Windows, Powershell is used.
/// For Linux and macOS, the default `$SHELL` is used if the variable
/// is defined, otherwise `/bin/sh`.
/// The script's syntax must be compatible with the installed
/// shell.
class ShellInstruction extends Instruction {
  @override
  final int? id;

  @override
  String get name => "Shell";

  @override
  String get executeMessage => "Running shell script: $shellScript";

  @override
  final int executionOrder;

  @override
  List<String> get arguments => [shellScript];

  /// E.g. "tar -C project_directory/ -czf compressed_folder.tar.gz ./"
  late final String shellScript;

  ShellInstruction({
    this.id,
    required this.executionOrder,
    required this.shellScript,
  });

  @override
  Future<void> accept(InstructionVisitor visitor) async {
    visitor.doForShell(this);
  }

  @override
  Instruction copyWithArguments(List<String> arguments) {
    return ShellInstruction.fromArguments(
      id: id,
      executionOrder: executionOrder,
      arguments: arguments,
    );
  }

  /// The first and only element of [arguments] is the shell script
  /// to run.
  factory ShellInstruction.fromArguments({
    int? id,
    required int executionOrder,
    required List<String> arguments,
  }) {
    return ShellInstruction(
      id: id,
      executionOrder: executionOrder,
      shellScript: arguments.first,
    );
  }

  @override
  String toString() {
    return "Shell (script: $shellScript)";
  }
}
