abstract class Instruction {
  String get name;
  List<String> get arguments;

  void execute(); // TODO: visitor pattern
}