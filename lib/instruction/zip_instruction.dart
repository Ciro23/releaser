import 'dart:io';

import 'package:releaser/instruction/instruction.dart';

import 'instruction_visitor.dart';

/// A cross-platform compatible instruction to zip directories.
/// Since only directories are supported, [sourceDirectory]
/// must end with a path separator.
class ZipInstruction extends Instruction {
  @override
  final int? id;

  @override
  String get name => "Zip";

  @override
  String get executeMessage => "Zipping $sourceDirectory into $destinationPath";

  @override
  final int executionOrder;

  @override
  List<String> get arguments => [
    sourceDirectory.path,
    destinationPath.toFilePath(),
  ];

  late final Directory sourceDirectory;
  late final Uri destinationPath;

  ZipInstruction({
    this.id,
    required this.executionOrder,
    required this.sourceDirectory,
    required this.destinationPath,
  });

  @override
  Future<void> accept(InstructionVisitor visitor) async {
    visitor.doForZip(this);
  }

  @override
  Instruction copyWithArguments(List<String> arguments) {
    return ZipInstruction.fromArguments(
      id: id,
      executionOrder: executionOrder,
      arguments: arguments,
    );
  }

  /// The first element of [arguments] is the path of the source
  /// directory, while the second is the destination path.
  factory ZipInstruction.fromArguments({
    int? id,
    required int executionOrder,
    required List<String> arguments,
  }) {
    return ZipInstruction(
      id: id,
      executionOrder: executionOrder,
      sourceDirectory: Directory(arguments[0]),
      destinationPath: Uri(path: arguments[1]),
    );
  }

  @override
  String toString() {
    return "Zip (source path: ${sourceDirectory.path},"
        " destination path: ${destinationPath.toFilePath()})";
  }
}
