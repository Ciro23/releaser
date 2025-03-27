import 'package:args/command_runner.dart';

import 'router.dart';

/// Uses [CommandRunner] to parse command line
/// arguments and run the selected command.
class MenuRouter implements Router {
  final CommandRunner<void> commandRunner;

  MenuRouter({required this.commandRunner});

  @override
  Future<void> runSelectedAction(List<String> arguments) {
    return commandRunner.run(arguments);
  }
}
