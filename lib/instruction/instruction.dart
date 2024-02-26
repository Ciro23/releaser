/// [T] is the actual implementation of the instruction.
abstract class Instruction<T> {
  String get name;
  List<String> get arguments;
  String get executeMessage;

  Future<void> execute();
  T create(List<String> arguments);
}