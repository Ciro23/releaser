import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:releaser/instruction/instruction.dart';

class ZipInstruction implements Instruction {
  final ZipFileEncoder zipFileEncoder;

  final String sourcePath;
  final String destinationPath;

  ZipInstruction({
    required this.zipFileEncoder,
    required this.sourcePath,
    required this.destinationPath,
  });

  @override
  Future<void> execute() async {
    Directory sourceDirectory = Directory(sourcePath);
    zipFileEncoder.zipDirectory(sourceDirectory, filename: destinationPath);
  }

  @override
  String get name => "Zip";

  @override
  List<String> get arguments => [sourcePath, destinationPath];
}
