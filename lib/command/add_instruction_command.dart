import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:releaser/instruction/copy_instruction.dart';
import 'package:releaser/instruction/shell_instruction.dart';
import 'package:releaser/instruction/zip_instruction.dart';
import 'package:releaser/software/software_repository.dart';

import '../instruction/instruction.dart';
import '../software/software.dart';

/// Add a release instruction to a software.
/// Instructions may require different parameters, so
/// all implementation details are collected in a second
/// moment using [onStdIn].
class AddInstructionCommand extends Command<void> {
  final SoftwareRepository softwareRepository;

  final void Function(Object?) onStdOut;
  final String? Function() onStdIn;

  AddInstructionCommand({
    required this.softwareRepository,
    required this.onStdOut,
    required this.onStdIn,
  }) {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        mandatory: true,
        help:
            'The name of the instruction. Available options are: copy,'
            ' zip, shell.',
      )
      ..addOption(
        'software',
        abbr: 's',
        mandatory: true,
        help:
            'The name of the software which the instruction will be added to.',
      );
  }

  @override
  String get name => "add-instruction";

  @override
  String get description =>
      "Add a release instruction to an existing software.";

  @override
  Future<void> run() async {
    String instructionName = argResults?['name'].toLowerCase();
    String softwareName = argResults?['software'];

    Software? software = await softwareRepository.findByName(softwareName);
    if (software == null) {
      throw ArgumentError("Software '$softwareName' not found.");
    }

    int executionOrder = 1;
    if (software.releaseInstructions.isNotEmpty) {
      software.releaseInstructions.sort();
      executionOrder = software.releaseInstructions.last.executionOrder + 1;
    }

    String rootPath = software.rootPath.toFilePath();
    String destPath = software.releasePath.toFilePath();
    String hintMessage =
        "\n┌────────────────────────────────────────────────────────────────────┐"
        "\n│ Available placeholders (be careful for trailing path separators!): │"
        "\n│ - \${name} => '${software.name}"
        "\n│ - \${root_path} => '$rootPath"
        "\n│ - \${dest_path} => '$destPath"
        "\n│ - \${version} => the specified version during "
        "\n└────────────────────────────────────────────────────────────────────┘";

    Instruction instruction;
    switch (instructionName) {
      case "copy":
        instruction = _buildCopyInstruction(hintMessage, executionOrder);
        break;

      case "zip":
        instruction = _buildZipInstruction(hintMessage, executionOrder);
        break;

      case "shell":
        instruction = _buildShellInstruction(hintMessage, executionOrder);

      default:
        throw ArgumentError("Instruction '$instructionName' not found");
    }

    software.addInstruction(instruction);
    await softwareRepository.save(software);

    onStdOut(
      "Instruction '$instructionName' added successfully to software"
      " '${software.name}.",
    );
    onStdOut(
      "  (Use \"releaser release -s ${software.name}\" to execute all"
      " instruction for this software)",
    );
  }

  Instruction _buildCopyInstruction(String hintMessage, int executionOrder) {
    onStdOut(hintMessage);
    onStdOut("Enter the source path:");
    String? sourcePath = onStdIn();

    onStdOut("Enter the destination path:");
    String? destinationPath = onStdIn();

    return CopyInstruction(
      executionOrder: executionOrder,
      sourcePath: Uri.file(sourcePath!),
      destinationPath: Uri.file(destinationPath!),
    );
  }

  Instruction _buildZipInstruction(String hintMessage, int executionOrder) {
    onStdOut(hintMessage);
    onStdOut("Enter the source path:");
    String? sourcePath = onStdIn();

    onStdOut("Enter the destination path:");
    String? destinationPath = onStdIn();

    return ZipInstruction(
      executionOrder: executionOrder,
      sourceDirectory: Directory(sourcePath!),
      destinationPath: Uri.file(destinationPath!),
    );
  }

  Instruction _buildShellInstruction(String hintMessage, int executionOrder) {
    onStdOut(hintMessage);
    onStdOut(
      "Try to execute the script manually, before adding it here,"
      " to check if it's correct and working as expected.",
    );
    onStdOut("Enter the shell script:");
    String? shellScript = onStdIn();

    return ShellInstruction(
      executionOrder: executionOrder,
      shellScript: shellScript!,
    );
  }
}
