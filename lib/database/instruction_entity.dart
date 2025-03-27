import 'package:equatable/equatable.dart';

/// Represents how a [Instruction] is stored in the database.
class InstructionEntity extends Equatable {
  final int? id;
  final int softwareId;
  final String name;
  final int executionOrder;

  /// The arguments are stored as a single string, separated by commas.
  /// E.g. "arg1,arg2,arg3".
  final String arguments;

  InstructionEntity({
    required this.id,
    required this.softwareId,
    required this.name,
    required this.executionOrder,
    required this.arguments,
  });

  @override
  List<Object?> get props => [id, softwareId, name, executionOrder, arguments];
}
