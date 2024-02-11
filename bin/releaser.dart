import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:csv/csv.dart';
import 'package:releaser/csv/csv_manager.dart';
import 'package:releaser/instruction/instruction_csv.dart';
import 'package:releaser/paths/paths.dart';
import 'package:releaser/router/add_software_command.dart';
import 'package:releaser/router/list_software_command.dart';
import 'package:releaser/router/menu_router.dart';
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

  CsvManager<SoftwareCsv> softwareCsvManager = CsvManager(
    csvFile: File(softwareFilePath),
    csvToListConverter: csvToList,
    listToCsvConverter: listToCsv,
  );
  CsvManager<InstructionCsv> instructionCsvManager = CsvManager(
    csvFile: File(instructionFilePath),
    csvToListConverter: csvToList,
    listToCsvConverter: listToCsv,
  );

  SoftwareRepository softwareRepository = SoftwareCsvDataSource(
    uuid: Uuid(),
    softwareCsvManager: softwareCsvManager,
    instructionCsvManager: instructionCsvManager,
  );

  CommandRunner<void> commandRunner = CommandRunner(
    "Releaser",
    "Manage your software releases",
  );
  onPrint(Object? message) {
    stdout.writeln(message);
  }

  AddSoftwareCommand addSoftwareCommand = AddSoftwareCommand(
    softwareRepository,
    onPrint,
  );
  ListSoftwareCommand listSoftwareCommand = ListSoftwareCommand(
    softwareRepository,
    onPrint,
  );
  MenuRouter menuRouter = MenuRouter(
    commandRunner: commandRunner,
    addSoftwareCommand: addSoftwareCommand,
    listSoftwareCommand: listSoftwareCommand,
  );

  menuRouter.runSelectedAction(arguments).catchError((error) {
    if (error is ArgumentError) {
      stdout.writeln("Error parsing the command arguments:"
          " ${error.message}");
      stdout.writeln(error.stackTrace);
    } else {
      stderr.writeln("An error as occurred: $error");
    }
  });
}
