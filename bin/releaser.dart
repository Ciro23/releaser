import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:csv/csv.dart';
import 'package:releaser/csv/file_manager.dart';
import 'package:releaser/csv/instruction_csv_manager.dart';
import 'package:releaser/csv/software_csv_manager.dart';
import 'package:releaser/instruction/instruction_csv.dart';
import 'package:releaser/paths/paths.dart';
import 'package:releaser/router/add_instruction_command.dart';
import 'package:releaser/router/add_software_command.dart';
import 'package:releaser/router/list_software_command.dart';
import 'package:releaser/router/menu_router.dart';
import 'package:releaser/router/release_command.dart';
import 'package:releaser/software/software_csv.dart';
import 'package:releaser/software/software_csv_datasource.dart';
import 'package:releaser/software/software_repository.dart';
import 'package:uuid/uuid.dart';

void main(List<String> arguments) {
  Directory appDirectory = Directory(Paths.getReleaserPath());
  if (!appDirectory.existsSync()) {
    appDirectory.createSync(recursive: true);
  }

  String softwareFilePath = Paths.getSoftwarePath();
  String instructionFilePath = Paths.getInstructionPath();

  final csvToList = CsvToListConverter();
  final listToCsv = ListToCsvConverter();

  FileManager<SoftwareCsv> softwareCsvManager = SoftwareCsvManager(
    csvFile: File(softwareFilePath),
    csvToListConverter: csvToList,
    listToCsvConverter: listToCsv,
  );
  FileManager<InstructionCsv> instructionCsvManager = InstructionCsvManager(
    csvFile: File(instructionFilePath),
    csvToListConverter: csvToList,
    listToCsvConverter: listToCsv,
  );

  ZipFileEncoder zipFileEncoder = ZipFileEncoder();
  SoftwareRepository softwareRepository = SoftwareCsvDataSource(
    uuid: Uuid(),
    softwareCsvManager: softwareCsvManager,
    instructionCsvManager: instructionCsvManager,
    zipFileEncoder: zipFileEncoder,
  );

  CommandRunner<void> commandRunner = CommandRunner(
    "releaser",
    "Manage your software releases",
  );
  onPrint(Object? message) {
    stdout.writeln(message);
  }

  String? onInput() {
    return stdin.readLineSync();
  }

  AddSoftwareCommand addSoftwareCommand = AddSoftwareCommand(
    softwareRepository,
    onPrint,
  );
  ListSoftwareCommand listSoftwareCommand = ListSoftwareCommand(
    softwareRepository,
    onPrint,
  );
  AddInstructionCommand addInstructionCommand = AddInstructionCommand(
    softwareRepository: softwareRepository,
    zipFileEncoder: zipFileEncoder,
    onPrint: onPrint,
    onInput: onInput,
  );
  ReleaseCommand releaseCommand = ReleaseCommand(
    softwareRepository: softwareRepository,
  );
  commandRunner.addCommand(addSoftwareCommand);
  commandRunner.addCommand(listSoftwareCommand);
  commandRunner.addCommand(addInstructionCommand);
  commandRunner.addCommand(releaseCommand);

  MenuRouter menuRouter = MenuRouter(commandRunner: commandRunner);

  menuRouter.runSelectedAction(arguments).catchError((error) {
    if (error is ArgumentError) {
      stderr.writeln("Error parsing the command arguments:"
          " ${error.message}"
          " ${error.stackTrace}"
          "\nUse --help for more information.");
    } else {
      stderr.writeln("An error as occurred: $error"
          " ${error.stackTrace}");
    }
  });
}
