import 'package:args/command_runner.dart';
import 'package:releaser/router/list_software_command.dart';

import 'add_software_command.dart';
import 'router.dart';

/// Uses [CommandRunner] to parse command line
/// arguments and run the selected command.
class MenuRouter implements Router {
  final CommandRunner<void> _commandRunner;
  final AddSoftwareCommand _addSoftwareCommand;
  final ListSoftwareCommand _listSoftwareCommand;

  MenuRouter({
    required CommandRunner<void> commandRunner,
    required AddSoftwareCommand addSoftwareCommand,
    required ListSoftwareCommand listSoftwareCommand,
  })  : _addSoftwareCommand = addSoftwareCommand,
        _commandRunner = commandRunner,
        _listSoftwareCommand = listSoftwareCommand {
    _commandRunner.addCommand(_addSoftwareCommand);
    _commandRunner.addCommand(_listSoftwareCommand);
  }

  @override
  Future<void> runSelectedAction(List<String> arguments) {
    return _commandRunner.run(arguments);
  }
}
