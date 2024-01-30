import 'package:args/command_runner.dart';

import 'add_software_command.dart';
import 'router.dart';

/// Uses [CommandRunner] to parse command line
/// arguments and run the selected command.
class MenuRouter implements Router {
  final AddSoftwareCommand _addSoftwareCommand;

  MenuRouter({
    required AddSoftwareCommand addSoftwareCommand,
  }) : _addSoftwareCommand = addSoftwareCommand;

  /// Throws [ArgumentError] if a mandatory option
  /// is missing.
  @override
  void runSelectedAction(List<String> arguments) {
    CommandRunner("Releaser", "Manage your software releases")
      ..addCommand(_addSoftwareCommand)
      ..run(arguments).catchError((error) {
        if (error is ArgumentError) {
          print("Error parsing the command arguments: ${error.message}");
          print(_addSoftwareCommand.usage);
        } else {
          print("An error as occurred: $error");
        }
      });
  }
}
