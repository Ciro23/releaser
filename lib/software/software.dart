import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:releaser/instruction/instruction_csv.dart';
import 'package:releaser/instruction/copy_instruction.dart';
import 'package:releaser/software/software_csv.dart';
import 'package:uuid/uuid.dart';

import '../application/process_runner.dart';
import '../instruction/instruction.dart';

class Software extends Equatable {
  final UuidValue? id;
  final String name;
  final String rootPath;
  final String releasePath;
  final List<Instruction> releaseInstructions;

  Software({
    this.id,
    required this.name,
    required this.rootPath,
    required this.releasePath,
    required this.releaseInstructions,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        rootPath,
        releasePath,
      ];
}
