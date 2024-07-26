import 'dart:io';

import 'package:io/io.dart';
import 'package:uuid/uuid.dart';

import 'instruction.dart';

/// Allows to copy files or directories.
/// If the source path ends with a path separator, it will
/// be threaded as a directory, otherwise as a file.
class CopyInstruction implements Instruction<CopyInstruction> {
  final UuidValue? _id;

  final Uri sourcePath;
  final Uri destinationPath;

  /// The name of the operating system to know
  /// which command to use.
  /// See [Platform.operatingSystem].
  final String os;

  CopyInstruction({
    UuidValue? id,
    required this.sourcePath,
    required this.destinationPath,
    required String os,
  })  : os = os.toLowerCase(),
        _id = id {
    if (!['windows', 'macos', 'linux'].contains(this.os)) {
      throw UnsupportedError(
        'The operating system $os is not supported.',
      );
    }
  }

  @override
  Future<void> execute() async {
    String source = sourcePath.toFilePath();
    String destination = destinationPath.toFilePath();

    if (source.endsWith(Platform.pathSeparator)) {
      copyPath(source, destination);
      return;
    }

    File file = File(source);
    file.copy(destination);
  }

  @override
  UuidValue? get id => _id;

  @override
  String get name => "Copy";

  @override
  List<String> get arguments => [
        sourcePath.toFilePath(),
        destinationPath.toFilePath(),
      ];

  @override
  String get executeMessage => "Copying $sourcePath into $destinationPath";

  @override
  String toString() {
    return "Copy (source path: ${sourcePath.toFilePath()},"
        " destination path: ${destinationPath.toFilePath()})";
  }

  @override
  CopyInstruction create(UuidValue? id, List<String> arguments) {
    return CopyInstruction(
      id: id,
      sourcePath: Uri.file(arguments[0]),
      destinationPath: Uri.file(arguments[1]),
      os: os,
    );
  }
}
