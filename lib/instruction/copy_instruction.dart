import 'dart:io';

import 'package:io/io.dart';
import 'package:uuid/uuid.dart';

import 'instruction.dart';

/// Allows to copy files or directories.
/// If the source path ends with a path separator, it will
/// be threaded as a directory, otherwise as a file.
class CopyInstruction implements Instruction<CopyInstruction> {
  final UuidValue? _id;

  final String sourcePath;
  final String destinationPath;

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
    if (sourcePath.endsWith(Platform.pathSeparator)) {
      copyPath(sourcePath, destinationPath);
      return;
    }

    File file = File(sourcePath);
    file.copy(destinationPath);
  }

  @override
  UuidValue? get id => _id;

  @override
  String get name => "Copy";

  @override
  List<String> get arguments => [sourcePath, destinationPath];

  @override
  String get executeMessage => "Copying $sourcePath into $destinationPath...";

  @override
  String toString() {
    return "Copy (sourcePath: $sourcePath,"
        " destinationPath: $destinationPath)";
  }

  @override
  CopyInstruction create(UuidValue? id, List<String> arguments) {
    return CopyInstruction(
      id: id,
      sourcePath: arguments[0],
      destinationPath: arguments[1],
      os: os,
    );
  }
}
