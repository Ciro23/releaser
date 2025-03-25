import 'dart:io';

import 'package:io/io.dart';
import 'package:uuid/uuid.dart';

import 'instruction.dart';

/// A cross-platform compatible instruction to copy files and directories.
/// If [sourcePath] ends with a path separator, it will
/// be threaded as a directory, otherwise as a file.
class CopyInstruction implements Instruction<CopyInstruction> {
  final int? _id;

  @override
  final int executionOrder;

  final Uri sourcePath;
  final Uri destinationPath;

  /// The name of the operating system to know
  /// which command to use.
  /// See [Platform.operatingSystem].
  final String os;

  CopyInstruction({
    int? id,
    required this.executionOrder,
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
  int? get id => _id;

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

  /// The first element of [arguments] is the path of the source
  /// directory, while the second is the destination path.
  @override
  CopyInstruction create(
    int? id,
    int order,
    List<String> arguments,
  ) {
    return CopyInstruction(
      id: id,
      executionOrder: order,
      sourcePath: Uri.file(arguments[0]),
      destinationPath: Uri.file(arguments[1]),
      os: os,
    );
  }
}
