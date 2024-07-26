
import 'package:args/command_runner.dart';
import 'package:releaser/software/software_service.dart';

import '../software/software.dart';

/// Lists all saved software along all their details and
/// release instructions.
class ListSoftwareCommand extends Command<void> {
  final SoftwareService _softwareService;
  final void Function(Object?) onPrint;

  ListSoftwareCommand(this._softwareService, this.onPrint);

  @override
  String get name => "list";

  @override
  String get description => "Show the list of all software managed by releaser";

  @override
  void run() async {
    List<Software> softwareList = await _softwareService.findAll();
    for (var element in softwareList) {
      onPrint("Name: ${element.name}");
      onPrint("Root Path: ${element.rootPath.toFilePath()}");
      onPrint("Release Path: ${element.releasePath.toFilePath()}");
      onPrint("Instructions:");
      for (var instruction in element.releaseInstructions) {
        onPrint("  $instruction");
      }
      onPrint("");
    }
  }
}
