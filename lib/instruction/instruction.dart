abstract class Instruction<T> {
  String get name;
  List<String> get arguments;
  String get executeMessage;

  Future<void> execute(); // TODO: visitor pattern
  T create(List<String> arguments);
}