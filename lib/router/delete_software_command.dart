import 'package:args/command_runner.dart';

import '../software/software.dart';
import '../software/software_repository.dart';

class DeleteSoftwareCommand extends Command<void> {
  final SoftwareRepository _softwareRepository;
  final void Function(Object?) onPrint;

  @override
  String get name => "delete-software";

  @override
  String get description => "Delete a software to the managed ones by releaser";

  DeleteSoftwareCommand(this._softwareRepository, this.onPrint);

  @override
  Future<void> run() async {
    String? softwareName = argResults?.rest.firstOrNull;
    if (softwareName == null) {
      throw ArgumentError("No software name specified using positional"
          " arguments");
    }

    Software? software = await _softwareRepository.findByName(softwareName);
    if (software == null) {
      throw ArgumentError("Software '$softwareName' not found");
    }

    bool result = await _softwareRepository.delete(software);
    if (result) {
      onPrint("Software '$softwareName' was successfully deleted");
    } else {
      onPrint("Software '$softwareName' could not be deleted");
    }
  }
}
