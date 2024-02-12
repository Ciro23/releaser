import 'package:args/command_runner.dart';
import 'package:releaser/software/software_repository.dart';

import '../software/software.dart';

/// Lists all saved software along all their details and
/// release instructions.
class ListSoftwareCommand extends Command<void> {
  final SoftwareRepository _softwareRepository;
  final void Function(Object?) onPrint;

  ListSoftwareCommand(this._softwareRepository, this.onPrint);

  @override
  String get name => "list-software";

  @override
  String get description => "Show a list of all saved software";

  @override
  void run() async {
    List<Software> softwareList = await _softwareRepository.findAll();
    for (var element in softwareList) {
      onPrint("Name: ${element.name}");
      onPrint("Root Path: ${element.rootPath}");
      onPrint("Release Path: ${element.releasePath}");
      onPrint("Instructions:");
      for (var instruction in element.releaseInstructions) {
        onPrint("  $instruction");
      }
      onPrint("");
    }
  }
}
