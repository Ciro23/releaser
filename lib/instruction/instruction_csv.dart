import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents how a [Instruction] is stored in a CSV file.
class InstructionCsv extends Equatable {
  final UuidValue softwareId;
  final String name;

  /// The arguments are stored as a single string, separated by commas.
  /// E.g. "arg1,arg2,arg3".
  final String arguments;

  InstructionCsv({
    required this.softwareId,
    required this.name,
    required this.arguments,
  });

  @override
  List<Object?> get props => [
        softwareId,
        name,
        arguments,
      ];
}
