import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:releaser/router/list_software_command.dart';

import 'add_software_command.dart';
import 'router.dart';

/// Uses [CommandRunner] to parse command line
/// arguments and run the selected command.
class MenuRouter implements Router {
  final AddSoftwareCommand _addSoftwareCommand;
  final ListSoftwareCommand _listSoftwareCommand;

  MenuRouter({
    required AddSoftwareCommand addSoftwareCommand,
    required ListSoftwareCommand listSoftwareCommand,
  })  : _addSoftwareCommand = addSoftwareCommand,
        _listSoftwareCommand = listSoftwareCommand;

  /// Throws [ArgumentError] if a mandatory option
  /// is missing.
  @override
  void runSelectedAction(List<String> arguments) {
    CommandRunner("Releaser", "Manage your software releases")
      ..addCommand(_addSoftwareCommand)
      ..addCommand(_listSoftwareCommand)
      ..run(arguments).catchError((error) {
        if (error is ArgumentError) {
          stdout
              .writeln("Error parsing the command arguments: ${error.message}");
          stdout.writeln(error.stackTrace);
        } else {
          stderr.writeln("An error as occurred: $error");
        }
      });
  }
}
