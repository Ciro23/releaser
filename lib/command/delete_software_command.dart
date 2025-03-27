import 'package:args/command_runner.dart';

import '../software/software.dart';
import '../software/software_repository.dart';

class DeleteSoftwareCommand extends Command<void> {
  final SoftwareRepository softwareRepository;
  final void Function(Object?) onStdOut;
  final void Function(Object?) onStdErr;

  @override
  String get name => "delete-software";

  @override
  String get description => "Delete a software and all its instructions.";

  DeleteSoftwareCommand({
    required this.softwareRepository,
    required this.onStdOut,
    required this.onStdErr,
  });

  @override
  Future<void> run() async {
    String? softwareName = argResults?.rest.firstOrNull;
    if (softwareName == null) {
      onStdErr("No software name specified using positional"
          " arguments.");
      return;
    }

    Software? software = await softwareRepository.findByName(softwareName);
    if (software == null) {
      onStdErr("Software '$softwareName' not found.");
      return;
    }

    bool result = await softwareRepository.delete(software);
    if (result) {
      onStdOut("Software '$softwareName' was successfully deleted.");
    } else {
      onStdErr("Software '$softwareName' could not be deleted.");
    }
  }
}
