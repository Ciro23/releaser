
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

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

  factory Software.copy(Software software) {
    return Software(
      id: software.id,
      name: software.name,
      rootPath: software.rootPath,
      releasePath: software.releasePath,
      releaseInstructions: software.releaseInstructions,
    );

  }

  void addInstruction(Instruction instruction) {
    releaseInstructions.add(instruction);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        rootPath,
        releasePath,
      ];
}
