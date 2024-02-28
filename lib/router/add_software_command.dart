import 'package:args/command_runner.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_service.dart';

import '../paths/paths.dart';

/// Software are required to create and configure
/// a release.
class AddSoftwareCommand extends Command<void> {
  final SoftwareService _softwareService;
  final void Function(Object?) onPrint;

  @override
  String get name => "add-software";

  @override
  String get description => "Save a software";

  AddSoftwareCommand(this._softwareService, this.onPrint) {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        mandatory: true,
        help: 'The name of the software',
      )
      ..addOption(
        'root',
        abbr: 'r',
        mandatory: true,
        help: 'The root path of the software',
      )
      ..addOption(
        'dest',
        abbr: 'd',
        mandatory: true,
        help: 'The destination path of the software',
      );
  }

  @override
  Future<void> run() async {
    Uri rootPath = Uri.directory(argResults?['root']!);
    Uri destPath = Uri.directory(argResults?['dest']!);

    Software software = Software(
      name: argResults?['name'],
      rootPath: rootPath,
      releasePath: destPath,
      releaseInstructions: [],
    );
    await _softwareService.save(software);

    onPrint("Software '${software.name}' added successfully"
        " to '${Paths.getSoftwarePath()}'");
  }
}
