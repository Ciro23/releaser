abstract class Instruction {
  String get name;
  List<String> get arguments;

  Future<void> execute(); // TODO: visitor pattern
}