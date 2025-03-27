import 'package:args/command_runner.dart';
import 'package:releaser/software/software_repository.dart';

import '../software/software.dart';

class EditSoftwareCommand extends Command<void> {
  final SoftwareRepository softwareRepository;
  final void Function(Object?) onStdOut;
  final void Function(Object?) onStdErr;

  @override
  String get name => "edit-software";

  @override
  String get description => "Edit a software's properties.";

  EditSoftwareCommand({
    required this.softwareRepository,
    required this.onStdOut,
    required this.onStdErr,
  }) {
    argParser
      ..addOption(
        'software',
        abbr: 's',
        help: 'The current name of the software to edit.',
        mandatory: true,
      )
      ..addOption('name', abbr: 'n', help: 'The updated name of the software.')
      ..addOption(
        'root',
        abbr: 'r',
        help: 'The updated root path of the software.',
      )
      ..addOption(
        'dest',
        abbr: 'd',
        help: 'The updated destination path of the released software.',
      );
  }

  @override
  Future<void> run() async {
    String softwareName = argResults?['software'];
    Software? existingSoftware = await softwareRepository.findByName(
      softwareName,
    );
    if (existingSoftware == null) {
      onStdErr("Software with name '$softwareName' doesn't exist.");
      return;
    }

    if (argResults?['name'] == null &&
        argResults?['root'] == null &&
        argResults?['dest'] == null) {
      onStdErr("No software's property set to be updated.");
      onStdOut("Use '$name --help' for more information.");
      return;
    }

    Software updatedSoftware = _updateSoftwareProperties(existingSoftware);

    try {
      await softwareRepository.save(updatedSoftware);
      onStdOut("Software '${existingSoftware.name}' updated successfully.");
    } on StateError catch (e) {
      onStdErr(e);
      onStdOut("  (Use \"releaser list\" to verify existing software)");
    }
  }

  Software _updateSoftwareProperties(Software software) {
    String name = software.name;
    Uri rootPath = software.rootPath;
    Uri destPath = software.releasePath;

    if (argResults?['name'] != null) {
      name = argResults?['name'];
    }

    if (argResults?['root'] != null) {
      rootPath = Uri.directory(argResults?['root']);
    }

    if (argResults?['dest'] != null) {
      destPath = Uri.directory(argResults?['dest']);
    }

    return Software(
      id: software.id,
      name: name,
      rootPath: rootPath,
      releasePath: destPath,
      releaseInstructions: software.releaseInstructions,
    );
  }
}
