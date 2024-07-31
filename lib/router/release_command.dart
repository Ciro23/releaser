import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:releaser/software/software_repository.dart';

import '../instruction/instruction.dart';
import '../software/software.dart';

/// Starts the execution of all the release instructions for
/// the specified software.
class ReleaseCommand extends Command<void> {
  final SoftwareRepository _softwareRepository;

  ReleaseCommand({
    required SoftwareRepository softwareRepository,
  }) : _softwareRepository = softwareRepository {
    argParser
      ..addOption(
        'software',
        abbr: 's',
        mandatory: true,
        help: 'The name of the software which the instruction will be added to',
      )
      ..addOption(
        'version',
        abbr: 'v',
        mandatory: true,
        help: 'The version to be assigned to the release',
      );
  }

  @override
  String get name => "release";

  @override
  String get description => "Execute the release process of a software,"
      " involving all associated instructions.";

  @override
  Future<void> run() async {
    String softwareName = argResults?['software'];
    String version = argResults?['version'];

    Software? software = await _softwareRepository.findByName(softwareName);
    if (software == null) {
      throw ArgumentError("Software '$softwareName' not found");
    }

    Software parsedSoftware = _parseInstructions(software, version: version);
    for (final instruction in parsedSoftware.releaseInstructions) {
      stdout.writeln(instruction.executeMessage);
      await instruction.execute();
    }
  }

  /// Only variables inside instructions are parsed.
  /// Variables inside the software object are used as reference,
  /// as they're not being directly used, if not through its
  /// instructions.
  Software _parseInstructions(Software software, {String? version}) {
    List<Instruction> parsedInstructions = [];
    for (Instruction instruction in software.releaseInstructions) {
      List<String> parsedArguments = [];

      for (String argument in instruction.arguments) {
        String parsedArgument = _parseVariables(
          argument,
          software,
          version: version,
        );
        parsedArguments.add(parsedArgument);
      }

      Instruction parsedInstruction = instruction.create(
        instruction.id,
        parsedArguments,
      );
      parsedInstructions.add(parsedInstruction);
    }

    return Software(
      id: software.id,
      name: software.name,
      rootPath: software.rootPath,
      releasePath: software.releasePath,
      releaseInstructions: parsedInstructions,
    );
  }

  String _parseVariables(
    String text,
    Software software, {
    String? version,
  }) {
    String rootPath = software.rootPath.toFilePath();
    String releasePath = software.releasePath.toFilePath();

    String parsedVariables = text
        .replaceAll(r'${root_path}', rootPath)
        .replaceAll(r'${dest_path}', releasePath)
        .replaceAll(r'${name}', software.name);

    if (version != null) {
      return parsedVariables.replaceAll(r'${version}', version);
    }
    return parsedVariables;
  }
}
