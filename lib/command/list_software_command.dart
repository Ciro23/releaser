import 'package:args/command_runner.dart';
import 'package:releaser/software/software_repository.dart';

import '../instruction/instruction.dart';
import '../software/software.dart';

/// Lists all saved software along all their details and
/// release instructions.
class ListSoftwareCommand extends Command<void> {
  final SoftwareRepository softwareRepository;
  final void Function(Object?) onStdOut;
  final void Function(Object?) onStdErr;

  ListSoftwareCommand({
    required this.softwareRepository,
    required this.onStdOut,
    required this.onStdErr,
  });

  @override
  String get name => "list";

  @override
  String get description =>
      "Show the list of all software managed by releaser.";

  @override
  void run() async {
    List<Software> softwareList = await softwareRepository.findAll();
    if (softwareList.isEmpty) {
      onStdErr("No registered software.");
      onStdOut(
        "  (Use \"releaser add-software\" to register the first software)",
      );
    }

    for (var element in softwareList) {
      onStdOut("Name: ${element.name}");
      onStdOut("Root path: ${element.rootPath.toFilePath()}");
      onStdOut("Release path: ${element.releasePath.toFilePath()}");
      onStdOut(
        "Instructions: ${element.releaseInstructions.isEmpty ? 'none' : ''}",
      );

      element.releaseInstructions.sort();
      for (int i = 0; i < element.releaseInstructions.length; i++) {
        Instruction instruction = element.releaseInstructions[i];
        onStdOut("  ${i + 1}. $instruction");
      }
      onStdOut("----------------------------------------");
    }
  }
}
