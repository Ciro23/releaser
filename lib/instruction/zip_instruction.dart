import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:releaser/instruction/instruction.dart';

class ZipInstruction implements Instruction {
  final ZipFileEncoder zipFileEncoder;

  final String source;
  final String destination;

  ZipInstruction({
    required this.zipFileEncoder,
    required this.source,
    required this.destination,
  });

  @override
  Future<void> execute() async {
    Directory sourceDirectory = Directory(source);
    zipFileEncoder.zipDirectory(sourceDirectory, filename: destination);
  }

  @override
  String get name => "Zip";

  @override
  List<String> get arguments => [source, destination];
}
