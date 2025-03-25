import 'package:uuid/uuid.dart';

/// The actual operation ran during the release of
/// a software, which probably requires to execute different
/// actions.
/// [T] is the actual implementation of the instruction.
abstract class Instruction<T> {
  int? get id;

  /// The name is used to make instructions humanly
  /// recognizable.
  String get name;

  int get executionOrder;

  /// The arguments required by the implementation to
  /// properly work. It's the same value passed using
  /// [create]
  List<String> get arguments;

  /// The user message used when this instruction starts
  /// its execution. E.g. "Executing my_instruction".
  String get executeMessage;

  Future<void> execute();

  /// Builder method to create an instance of the actual
  /// implementation. [arguments] are used differently depending
  /// on the implementation.
  T create(int? id, int order, List<String> arguments);
}
