import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:csv/csv.dart';
import 'package:releaser/command/delete_software_command.dart';
import 'package:releaser/command/edit_software_command.dart';
import 'package:releaser/command/release_command.dart';
import 'package:releaser/database/database.dart';
import 'package:releaser/database/instruction_entity.dart';
import 'package:releaser/paths/paths.dart';
import 'package:releaser/command/add_instruction_command.dart';
import 'package:releaser/command/add_software_command.dart';
import 'package:releaser/command/list_software_command.dart';
import 'package:releaser/router/menu_router.dart';
import 'package:releaser/database/software_entity.dart';
import 'package:releaser/software/software_datasource.dart';
import 'package:releaser/software/software_repository.dart';
import 'package:uuid/uuid.dart';

/// This is the entry point of "releaser".
/// Here the application and its dependencies are initialized,
/// then command line arguments are parsed to run the program.
void main(List<String> arguments) {
  _createSystemFolder();
  CommandRunner<void> commandRunner = _initializeDependencies();
  _runApplication(commandRunner, arguments);
}

void _runApplication(
    CommandRunner<void> commandRunner, List<String> arguments) {
  MenuRouter menuRouter = MenuRouter(commandRunner: commandRunner);
  ArgResults parsedArgs;

  try {
    parsedArgs = commandRunner.argParser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln("$e");
    stderr.writeln("Use --help for more information.");
    return;
  }

  if (parsedArgs['version']) {
    stdout.writeln("releaser version 1.1.0");
    return;
  }

  menuRouter.runSelectedAction(arguments).catchError((error, stackTrace) {
    if (error is ArgumentError) {
      stderr.writeln("$error");
      if (parsedArgs['verbose']) {
        stderr.writeln("$stackTrace");
      }
      stderr.writeln("Use --help for more information.");
    } else {
      stderr.writeln("An unknown error has occurred: $error");
      if (parsedArgs['verbose']) {
        stderr.writeln("$stackTrace");
      }
    }
  });
}

void _createSystemFolder() {
  Directory appDirectory = Directory(Paths.getReleaserPath());
  if (!appDirectory.existsSync()) {
    appDirectory.createSync(recursive: true);
  }
}

CommandRunner<void> _initializeDependencies() {
  DatabaseManager databaseManager = DatabaseManager(Paths.getDatabasePath());
  ZipFileEncoder zipFileEncoder = ZipFileEncoder();

  SoftwareRepository softwareRepository = SoftwareDataSource(
    softwareDao: databaseManager.softwareDao,
    instructionDao: databaseManager.instructionDao,
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
  EditSoftwareCommand editSoftwareCommand = EditSoftwareCommand(
    softwareRepository,
    onPrint,
  );
  ListSoftwareCommand listSoftwareCommand = ListSoftwareCommand(
    softwareRepository,
    onPrint,
  );
  DeleteSoftwareCommand deleteSoftwareCommand = DeleteSoftwareCommand(
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
  commandRunner.addCommand(editSoftwareCommand);
  commandRunner.addCommand(listSoftwareCommand);
  commandRunner.addCommand(deleteSoftwareCommand);
  commandRunner.addCommand(addInstructionCommand);
  commandRunner.addCommand(releaseCommand);

  commandRunner.argParser.addFlag(
    "verbose",
    abbr: "v",
    help: "Displays the entire stack trace in case of errors",
    negatable: false,
  );
  commandRunner.argParser.addFlag(
    "version",
    help: "Displays this program's version",
    negatable: false,
  );

  return commandRunner;
}
