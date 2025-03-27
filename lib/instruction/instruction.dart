import 'package:releaser/instruction/instruction_visitor.dart';

/// The actual operation to run during the release of
/// a software.
abstract class Instruction implements Comparable<Instruction> {
  int? get id;

  /// The name is used to make instructions humanly
  /// recognizable.
  String get name;

  /// The user message used when this instruction starts
  /// its execution. E.g. "Executing my_instruction".
  String get executeMessage;

  /// The execution order of the instructions set of each
  /// software can be customized.
  /// The execution order only affects the instructions
  /// linked to a specific software. For example, two
  /// instructions can share the same execution order, only
  /// if they belong to different software.
  int get executionOrder;

  /// Each implementation will use a different number
  /// of arguments and in different ways.
  List<String> get arguments;

  /// Visitor pattern is used to handle the business logic
  /// of each kinds of instructions.
  Future<void> accept(InstructionVisitor visitor);

  /// Creates a new instance, starting from the existing one.
  /// Only the arguments are changed, used differently based on
  /// the implementation.
  Instruction copyWithArguments(List<String> arguments);

  @override
  int compareTo(Instruction that) {
    return executionOrder.compareTo(that.executionOrder);
  }
}
