import 'package:args/command_runner.dart';
import 'package:releaser/software/software_repository.dart';

import '../instruction/instruction.dart';
import '../software/software.dart';

/// Lists all saved software along all their details and
/// release instructions.
class ListSoftwareCommand extends Command<void> {
  final SoftwareRepository _softwareRepository;
  final void Function(Object?) onPrint;

  ListSoftwareCommand(this._softwareRepository, this.onPrint);

  @override
  String get name => "list";

  @override
  String get description => "Show the list of all software managed by releaser";

  @override
  void run() async {
    List<Software> softwareList = await _softwareRepository.findAll();
    if (softwareList.isEmpty) {
      onPrint("No registered software");
      onPrint(
          "  (Use \"releaser add-software\" to register the first software)");
    }

    for (var element in softwareList) {
      onPrint("Name: ${element.name}");
      onPrint("Root path: ${element.rootPath.toFilePath()}");
      onPrint("Release path: ${element.releasePath.toFilePath()}");
      onPrint(
          "Instructions: ${element.releaseInstructions.isEmpty ? 'none' : ''}");

      for (int i = 0; i < element.releaseInstructions.length; i++) {
        Instruction instruction = element.releaseInstructions[i];
        onPrint("  ${i + 1}. $instruction");
      }
      onPrint("----------------------------------------");
    }
  }
}
