import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:releaser/instruction/copy_instruction.dart';
import 'package:releaser/instruction/zip_instruction.dart';
import 'package:releaser/software/software_repository.dart';

import '../instruction/instruction.dart';
import '../software/software.dart';

/// Add a release instruction to a software.
/// Instructions may require different parameters, so
/// all implementation details are collected in a second
/// moment using [onInput].
class AddInstructionCommand extends Command<void> {
  final SoftwareRepository _softwareRepository;
  final ZipFileEncoder _zipFileEncoder;

  final void Function(Object?) onPrint;
  final String? Function() onInput;

  AddInstructionCommand({
    required SoftwareRepository softwareRepository,
    required ZipFileEncoder zipFileEncoder,
    required this.onPrint,
    required this.onInput,
  })  : _softwareRepository = softwareRepository,
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

    Software? software = await _softwareRepository.findByName(softwareName);
    if (software == null) {
      throw ArgumentError("Software '$softwareName' not found");
    }

    String rootPath = software.rootPath.toFilePath();
    String destPath = software.releasePath.toFilePath();
    String hintMessage = "--------------------------------------------"
        "\nAvailable placeholders:"
        "\n- \${name} => '${software.name}'"
        "\n- \${root_path} => '$rootPath'"
        "\n- \${dest_path} => '$destPath'"
        "\n- \${version} => the specified version during release"
        "\n--------------------------------------------";

    Instruction instruction;
    switch (instructionName.toLowerCase()) {
      case "copy":
        instruction = _buildCopyInstruction(hintMessage);
        break;

      case "zip":
        instruction = _buildZipInstruction(hintMessage);
        break;

      default:
        throw ArgumentError("Instruction '$instructionName' not found");
    }

    software.addInstruction(instruction);
    await _softwareRepository.save(software);
  }

  Instruction _buildCopyInstruction(String hintMessage) {
    onPrint(hintMessage);
    onPrint("Enter the source path:");
    String? sourcePath = onInput();

    onPrint("Enter the destination path:");
    String? destinationPath = onInput();

    return CopyInstruction(
      sourcePath: Uri.file(sourcePath!),
      destinationPath: Uri.file(destinationPath!),
      os: Platform.operatingSystem,
    );
  }

  Instruction _buildZipInstruction(String hintMessage) {
    onPrint(hintMessage);
    onPrint("Enter the source path:");
    String? sourcePath = onInput();

    onPrint("Enter the destination path:");
    String? destinationPath = onInput();

    return ZipInstruction(
      zipFileEncoder: _zipFileEncoder,
      sourceDirectory: Directory(sourcePath!),
      destinationPath: Uri.file(destinationPath!),
    );
  }
}
