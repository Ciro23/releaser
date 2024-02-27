import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:releaser/instruction/instruction.dart';
import 'package:uuid/uuid.dart';

/// Currently only directories are supported, so it's necessary
/// that the source path ends with a path separator.
class ZipInstruction implements Instruction<ZipInstruction> {
  final UuidValue? _id;
  final ZipFileEncoder zipFileEncoder;

  final String sourcePath;
  final String destinationPath;

  ZipInstruction({
    UuidValue? id,
    required this.zipFileEncoder,
    required this.sourcePath,
    required this.destinationPath,
  }) : _id = id;

  @override
  Future<void> execute() async {
    Directory sourceDirectory = Directory(sourcePath);
    zipFileEncoder.zipDirectory(sourceDirectory, filename: destinationPath);
  }

  @override
  UuidValue? get id => _id;

  @override
  String get name => "Zip";

  @override
  List<String> get arguments => [sourcePath, destinationPath];

  @override
  String get executeMessage => "Zipping $sourcePath into $destinationPath...";

  @override
  String toString() {
    return "Zip (sourcePath: $sourcePath,"
        " destinationPath: $destinationPath)";
  }

  @override
  ZipInstruction create(UuidValue? id, List<String> arguments) {
    return ZipInstruction(
      id: id,
      zipFileEncoder: zipFileEncoder,
      sourcePath: arguments[0],
      destinationPath: arguments[1],
    );
  }
}
