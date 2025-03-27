import 'dart:io';

import 'package:io/io.dart';
import 'package:releaser/instruction/instruction_visitor.dart';
import 'package:uuid/uuid.dart';

import 'instruction.dart';

/// A cross-platform compatible instruction to copy files and directories.
/// If [sourcePath] ends with a path separator, it will
/// be threaded as a directory, otherwise as a file.
class CopyInstruction extends Instruction {
  @override
  String get name => "Copy";

  @override
  String get executeMessage => "Copying $sourcePath into $destinationPath";

  @override
  final int? id;

  @override
  final int executionOrder;

  @override
  List<String> get arguments => [
        sourcePath.toFilePath(),
        destinationPath.toFilePath(),
      ];

  late final Uri sourcePath;
  late final Uri destinationPath;

  CopyInstruction({
    this.id,
    required this.executionOrder,
    required this.sourcePath,
    required this.destinationPath,
  });

  @override
  Future<void> accept(InstructionVisitor visitor) async {
    visitor.doForCopy(this);
  }

  @override
  Instruction copyWithArguments(List<String> arguments) {
    return CopyInstruction.fromArguments(
      id: id,
      executionOrder: executionOrder,
      arguments: arguments,
    );
  }

  /// The first element of [arguments] is the path of the source
  /// directory, while the second is the destination path.
  factory CopyInstruction.fromArguments({
    int? id,
    required int executionOrder,
    required List<String> arguments,
  }) {
    return CopyInstruction(
      id: id,
      executionOrder: executionOrder,
      sourcePath: Uri.file(arguments.first),
      destinationPath: Uri.file(arguments[1]),
    );
  }

  @override
  String toString() {
    return "Copy (source path: ${sourcePath.toFilePath()},"
        " destination path: ${destinationPath.toFilePath()})";
  }
}
