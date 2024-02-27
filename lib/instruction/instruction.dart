import 'package:uuid/uuid.dart';

/// [T] is the actual implementation of the instruction.
abstract class Instruction<T> {
  UuidValue? get id;
  String get name;
  List<String> get arguments;
  String get executeMessage;

  Future<void> execute();
  T create(UuidValue? id, List<String> arguments);
}