import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:releaser/router/add_instruction_command.dart';
import 'package:releaser/router/add_software_command.dart';
import 'package:releaser/router/list_software_command.dart';
import 'package:releaser/router/menu_router.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_repository.dart';
import 'package:test/test.dart';

import 'menu_router_test.mocks.dart';

/// This makes sure that the commands executes the correct actions.
@GenerateNiceMocks([
  MockSpec<SoftwareRepository>(),
  MockSpec<CommandRunner<void>>(),
  MockSpec<ZipFileEncoder>(),
])
void main() {
  // Dependencies
  final SoftwareRepository softwareRepository = MockSoftwareRepository();
  final ZipFileEncoder zipFileEncoder = MockZipFileEncoder();
  onPrint(Object? message) {}
  final AddSoftwareCommand addSoftwareCommand = AddSoftwareCommand(
    softwareRepository,
    onPrint,
  );
  final ListSoftwareCommand listSoftwareCommand = ListSoftwareCommand(
    softwareRepository,
    onPrint,
  );
  final AddInstructionCommand addInstructionCommand = AddInstructionCommand(
    softwareRepository: softwareRepository,
    zipFileEncoder: zipFileEncoder,
  );
  late CommandRunner<void> commandRunner;

  // System Under Test
  late MenuRouter menuRouter;

  setUp(() {
    commandRunner = CommandRunner("test", "test");
    menuRouter = MenuRouter(
      commandRunner: commandRunner,
      addSoftwareCommand: addSoftwareCommand,
      listSoftwareCommand: listSoftwareCommand,
      addInstructionCommand: addInstructionCommand,
    );
  });

  test("add-software should add a software", () {
    Software software = Software(
      name: "test",
      rootPath: "/home/software/root",
      releasePath: "/home/software/dest",
      releaseInstructions: [],
    );

    when(softwareRepository.save(software)).thenAnswer((_) async {});
    menuRouter.runSelectedAction([
      'add-software',
      '--name',
      software.name,
      '--root',
      software.rootPath,
      '--dest',
      software.releasePath,
    ]);
    verify(addSoftwareCommand.run()).called(1);
  });

  test("list-software should list software", () {
    when(softwareRepository.findAll()).thenAnswer((_) async => []);
    menuRouter.runSelectedAction(['list-software']);
    verify(listSoftwareCommand.run()).called(1);
  });
}
