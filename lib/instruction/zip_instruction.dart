import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:releaser/instruction/instruction.dart';
import 'package:uuid/uuid.dart';

import 'package:path/path.dart' as path;

/// A cross-platform compatible instruction to zip directories.
/// Since only directories are supported, [sourceDirectory]
/// must end with a path separator.
class ZipInstruction implements Instruction<ZipInstruction> {
  final int? _id;
  final ZipFileEncoder zipFileEncoder;

  @override
  final int executionOrder;
 
  final Directory sourceDirectory;
  final Uri destinationPath;

  ZipInstruction({
    int? id,
    required this.executionOrder,
    required this.zipFileEncoder,
    required this.sourceDirectory,
    required this.destinationPath,
  }) : _id = id;

  @override
  Future<void> execute() async {
    zipFileEncoder.zipDirectory(sourceDirectory,
        filename: path.fromUri(destinationPath));
  }

  @override
  int? get id => _id;

  @override
  String get name => "Zip";

  @override
  List<String> get arguments => [
        sourceDirectory.path,
        destinationPath.toFilePath(),
      ];

  @override
  String get executeMessage => "Zipping $sourceDirectory into $destinationPath";

  @override
  String toString() {
    return "Zip (source path: ${sourceDirectory.path},"
        " destination path: ${destinationPath.toFilePath()})";
  }

  /// The first element of [arguments] is the path of the source
  /// directory, while the second is the destination path.
  @override
  ZipInstruction create(int? id, int order, List<String> arguments,) {
    return ZipInstruction(
      id: id,
      executionOrder: order,
      zipFileEncoder: zipFileEncoder,
      sourceDirectory: Directory(arguments[0]),
      destinationPath: Uri(path: arguments[1]),
    );
  }
}
