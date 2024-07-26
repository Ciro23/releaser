import 'package:args/command_runner.dart';

import 'router.dart';

/// Uses [CommandRunner] to parse command line
/// arguments and run the selected command.
class MenuRouter implements Router {
  final CommandRunner<void> _commandRunner;

  MenuRouter({
    required CommandRunner<void> commandRunner,
  }) : _commandRunner = commandRunner;

  @override
  Future<void> runSelectedAction(List<String> arguments) {
    return _commandRunner.run(arguments);
  }
}
