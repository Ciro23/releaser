import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_repository.dart';

import '../paths/paths.dart';

/// Software are required to create and configure
/// a release.
class AddSoftwareCommand extends Command {
  final SoftwareRepository _softwareRepository;

  @override
  String get name => "add-software";

  @override
  String get description => "Save a software";

  AddSoftwareCommand(this._softwareRepository) {
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
  void run() async {
    Software software = Software(
      name: argResults?['name'],
      rootPath: argResults?['root'],
      releasePath: argResults?['dest'],
    );
    await _softwareRepository.save(software);
    stdout.writeln("Software '${software.name}'"
        " added successfully to '${Paths.getSoftwarePath()}'");
  }
}
