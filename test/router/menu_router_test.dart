import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:releaser/router/add_instruction_command.dart';
import 'package:releaser/router/add_software_command.dart';
import 'package:releaser/router/list_software_command.dart';
import 'package:releaser/router/menu_router.dart';
import 'package:releaser/router/release_command.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_service.dart';
import 'package:test/test.dart';

import 'menu_router_test.mocks.dart';

/// This makes sure that the commands executes the correct actions.
@GenerateNiceMocks([
  MockSpec<SoftwareService>(),
  MockSpec<CommandRunner<void>>(),
  MockSpec<ZipFileEncoder>(),
])
void main() {
  // Dependencies
  final SoftwareService softwareService = MockSoftwareService();

  final ZipFileEncoder zipFileEncoder = MockZipFileEncoder();
  onPrint(Object? message) {}

  final AddSoftwareCommand addSoftwareCommand = AddSoftwareCommand(
    softwareService,
    onPrint,
  );
  final ListSoftwareCommand listSoftwareCommand = ListSoftwareCommand(
    softwareService,
    onPrint,
  );
  final AddInstructionCommand addInstructionCommand = AddInstructionCommand(
    softwareService: softwareService,
    zipFileEncoder: zipFileEncoder,
  );
  final ReleaseCommand releaseCommand = ReleaseCommand(
    softwareService: softwareService,
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
      releaseCommand: releaseCommand,
    );
  });

  test("add-software should add a software", () {
    Software software = Software(
      name: "test",
      rootPath: "/home/software/root",
      releasePath: "/home/software/dest",
      releaseInstructions: [],
    );

    when(softwareService.save(software)).thenAnswer((_) async => software);
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
    when(softwareService.findAll()).thenAnswer((_) async => []);
    menuRouter.runSelectedAction(['list-software']);
    verify(listSoftwareCommand.run()).called(1);
  });
}
