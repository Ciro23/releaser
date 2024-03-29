import 'package:args/command_runner.dart';
import 'package:releaser/router/add_instruction_command.dart';
import 'package:releaser/router/list_software_command.dart';
import 'package:releaser/router/release_command.dart';

import 'add_software_command.dart';
import 'router.dart';

/// Uses [CommandRunner] to parse command line
/// arguments and run the selected command.
class MenuRouter implements Router {
  final CommandRunner<void> _commandRunner;
  final AddSoftwareCommand _addSoftwareCommand;
  final ListSoftwareCommand _listSoftwareCommand;
  final AddInstructionCommand _addInstructionCommand;
  final ReleaseCommand _releaseCommand;

  MenuRouter({
    required CommandRunner<void> commandRunner,
    required AddSoftwareCommand addSoftwareCommand,
    required ListSoftwareCommand listSoftwareCommand,
    required AddInstructionCommand addInstructionCommand,
    required ReleaseCommand releaseCommand,
  })  : _addSoftwareCommand = addSoftwareCommand,
        _commandRunner = commandRunner,
        _listSoftwareCommand = listSoftwareCommand,
        _addInstructionCommand = addInstructionCommand,
        _releaseCommand = releaseCommand {
    _commandRunner.addCommand(_addSoftwareCommand);
    _commandRunner.addCommand(_listSoftwareCommand);
    _commandRunner.addCommand(_addInstructionCommand);
    _commandRunner.addCommand(_releaseCommand);
  }

  @override
  Future<void> runSelectedAction(List<String> arguments) {
    return _commandRunner.run(arguments);
  }
}
