abstract class Instruction {
  String get name;
  List<String> get arguments;
  String get executeMessage;

  Future<void> execute(); // TODO: visitor pattern
}