import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:releaser/application/process_runner.dart';
import 'package:releaser/instruction/copy_instruction.dart';
import 'package:releaser/instruction/zip_instruction.dart';
import 'package:releaser/software/software_repository.dart';

import '../instruction/instruction.dart';
import '../software/software.dart';

/// Add a release instruction to a software.
/// Instructions may require different parameters, so
/// all implementation details are collected in a second
/// moment using the standard input.
/// TODO: needs refactoring.
class AddInstructionCommand extends Command<void> {
  final SoftwareRepository _softwareRepository;
  final ZipFileEncoder _zipFileEncoder;

  AddInstructionCommand({
    required SoftwareRepository softwareRepository,
    required ZipFileEncoder zipFileEncoder,
  })  : _softwareRepository = softwareRepository,
        _zipFileEncoder = zipFileEncoder {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        mandatory: true,
        help: 'The name of the instruction',
      )
      ..addOption(
        'software',
        abbr: 'r',
        mandatory: true,
        help: 'The name of the software which the instruction will be added to',
      );
  }

  @override
  String get name => "add-instruction";

  @override
  String get description => "Add a release instruction";

  @override
  Future<void> run() async {
    String instructionName = argResults?['name'];
    String softwareName = argResults?['software'];

    Software? software = await _softwareRepository.findByName(softwareName);
    if (software == null) {
      throw ArgumentError("Software '$softwareName' not found");
    }

    Instruction instruction;
    switch (instructionName.toLowerCase()) {
      case "copy":
        instruction = buildCopyInstruction();
        break;

      case "zip":
        instruction = buildZipInstruction();
        break;

      default:
        throw ArgumentError("Instruction '$instructionName' not found");
    }

    software.addInstruction(instruction);
    await _softwareRepository.save(software);
  }

  Instruction buildCopyInstruction() {
    stdout.writeln("Enter the source path:");
    String? sourcePath = stdin.readLineSync();

    stdout.writeln("Enter the destination path:");
    String? destinationPath = stdin.readLineSync();

    return CopyInstruction(
      processRunner: ProcessRunner(),
      buildPath: sourcePath!,
      destinationPath: destinationPath!,
      os: Platform.operatingSystem,
    );
  }

  Instruction buildZipInstruction() {
    stdout.writeln("Enter the source path:");
    String? sourcePath = stdin.readLineSync();

    stdout.writeln("Enter the destination path:");
    String? destinationPath = stdin.readLineSync();

    return ZipInstruction(
      zipFileEncoder: _zipFileEncoder,
      source: sourcePath!,
      destination: destinationPath!,
    );
  }
}
