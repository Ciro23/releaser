import 'package:args/command_runner.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_repository.dart';

import '../paths/paths.dart';

/// Software are required to create and configure
/// a release.
class AddSoftwareCommand extends Command<void> {
  final SoftwareRepository softwareRepository;
  final void Function(Object?) onStdOut;
  final void Function(Object?) onStdErr;

  @override
  String get name => "add-software";

  @override
  String get description => "Add a software to the managed ones by releaser.";

  AddSoftwareCommand({
    required this.softwareRepository,
    required this.onStdOut,
    required this.onStdErr,
  }) {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        mandatory: true,
        help: 'The name of the software.',
      )
      ..addOption(
        'root',
        abbr: 'r',
        mandatory: true,
        help: 'The root path of the software source code.',
      )
      ..addOption(
        'dest',
        abbr: 'd',
        mandatory: true,
        help: 'The destination path of the released software.',
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

    try {
      await softwareRepository.save(software);

      onStdOut("Software '${software.name}' added successfully"
          " to '${Paths.getDatabasePath()}'.");
      onStdOut(
          "  (Use \"releaser add-instruction -s ${software.name}\" to create"
          " the first release instruction)");
    } on StateError catch (e) {
      onStdErr(e);
      onStdOut("  (Use \"releaser list\" to verify existing software)");
    }
  }
}
