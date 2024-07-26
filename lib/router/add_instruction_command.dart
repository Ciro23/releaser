import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:releaser/instruction/copy_instruction.dart';
import 'package:releaser/instruction/zip_instruction.dart';
import 'package:releaser/software/software_service.dart';

import '../instruction/instruction.dart';
import '../software/software.dart';

/// Add a release instruction to a software.
/// Instructions may require different parameters, so
/// all implementation details are collected in a second
/// moment using the standard input.
/// TODO: needs refactoring.
class AddInstructionCommand extends Command<void> {
  final SoftwareService _softwareService;
  final ZipFileEncoder _zipFileEncoder;

  AddInstructionCommand({
    required SoftwareService softwareService,
    required ZipFileEncoder zipFileEncoder,
  })  : _softwareService = softwareService,
        _zipFileEncoder = zipFileEncoder {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        mandatory: true,
        help: 'The name of the instruction. Available options are: copy, zip',
      )
      ..addOption(
        'software',
        abbr: 's',
        mandatory: true,
        help: 'The name of the software which the instruction will be added to',
      );
  }

  @override
  String get name => "add-instruction";

  @override
  String get description => "Add a release instruction to an existing software";

  @override
  Future<void> run() async {
    String instructionName = argResults?['name'];
    String softwareName = argResults?['software'];

    Software? software = await _softwareService.findByName(softwareName);
    if (software == null) {
      throw ArgumentError("Software '$softwareName' not found");
    }

    String rootPath = software.rootPath.toFilePath(windows: Platform.isWindows);
    String destPath = software.releasePath.toFilePath(
      windows: Platform.isWindows,
    );
    String hintMessage = "--------------------------------------------"
        "\nAvailable placeholders:"
        "\n- \${name} => ${software.name}"
        "\n- \${root_path} => $rootPath"
        "\n- \${dest_path} => $destPath"
        "\n--------------------------------------------";

    Instruction instruction;
    switch (instructionName.toLowerCase()) {
      case "copy":
        instruction = buildCopyInstruction(hintMessage);
        break;

      case "zip":
        instruction = buildZipInstruction(hintMessage);
        break;

      default:
        throw ArgumentError("Instruction '$instructionName' not found");
    }

    software.addInstruction(instruction);
    await _softwareService.save(software);
  }

  Instruction buildCopyInstruction(String hintMessage) {
    stdout.writeln(hintMessage);
    stdout.writeln("Enter the source path:");
    String? sourcePath = stdin.readLineSync();

    stdout.writeln("Enter the destination path:");
    String? destinationPath = stdin.readLineSync();

    return CopyInstruction(
      sourcePath: Uri.file(sourcePath!),
      destinationPath: Uri.file(destinationPath!),
      os: Platform.operatingSystem,
    );
  }

  Instruction buildZipInstruction(String hintMessage) {
    stdout.writeln(hintMessage);
    stdout.writeln("Enter the source path:");
    String? sourcePath = stdin.readLineSync();

    stdout.writeln("Enter the destination path:");
    String? destinationPath = stdin.readLineSync();

    return ZipInstruction(
      zipFileEncoder: _zipFileEncoder,
      sourceDirectory: Directory(sourcePath!),
      destinationPath: Uri.file(destinationPath!),
    );
  }
}
