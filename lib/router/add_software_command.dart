import 'package:args/command_runner.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_repository.dart';

import '../paths/paths.dart';

/// Software are required to create and configure
/// a release.
class AddSoftwareCommand extends Command<void> {
  final SoftwareRepository _softwareRepository;
  final void Function(Object?) onPrint;

  @override
  String get name => "add-software";

  @override
  String get description => "Save a software";

  AddSoftwareCommand(this._softwareRepository, this.onPrint) {
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
    Software software = Software(
      name: argResults?['name'],
      rootPath: argResults?['root'],
      releasePath: argResults?['dest'],
      releaseInstructions: [],
    );
    await _softwareRepository.save(software);

    onPrint("Software '${software.name}' added successfully"
        " to '${Paths.getSoftwarePath()}'");
  }
}
