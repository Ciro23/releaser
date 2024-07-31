import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:releaser/instruction/instruction.dart';
import 'package:uuid/uuid.dart';

import 'package:path/path.dart' as path;

/// Currently only directories are supported, so it's necessary
/// that the source path ends with a path separator.
class ZipInstruction implements Instruction<ZipInstruction> {
  final UuidValue? _id;
  final ZipFileEncoder zipFileEncoder;

  final Directory sourceDirectory;
  final Uri destinationPath;

  ZipInstruction({
    UuidValue? id,
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
  UuidValue? get id => _id;

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
  ZipInstruction create(UuidValue? id, List<String> arguments) {
    return ZipInstruction(
      id: id,
      zipFileEncoder: zipFileEncoder,
      sourceDirectory: Directory(arguments[0]),
      destinationPath: Uri(path: arguments[1]),
    );
  }
}
