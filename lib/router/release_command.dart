import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:releaser/software/software_repository.dart';

import '../software/software.dart';

/// Starts the execution of all the release instructions for
/// the specified software.
class ReleaseCommand extends Command<void> {
  final SoftwareRepository _softwareRepository;

  ReleaseCommand({
    required SoftwareRepository softwareRepository,
  }) : _softwareRepository = softwareRepository {
    argParser
      .addOption(
        'software',
        abbr: 's',
        mandatory: true,
        help: 'The name of the software which the instruction will be added to',
      );
  }

  @override
  String get name => "release";

  @override
  String get description => "Execute the release process, involving all"
      " associated instructions.";

  @override
  Future<void> run() async {
    String softwareName = argResults?['software'];

    Software? software = await _softwareRepository.findByName(softwareName);
    if (software == null) {
      throw ArgumentError("Software '$softwareName' not found");
    }

    for (final instruction in software.releaseInstructions) {
      stdout.writeln(instruction.executeMessage);
      await instruction.execute();
    }
  }
}
