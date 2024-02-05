import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:releaser/router/add_software_command.dart';
import 'package:releaser/router/menu_router.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_repository.dart';
import 'package:test/test.dart';

import 'menu_router_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SoftwareRepository>(),
])
void main() {
  // Dependencies
  final SoftwareRepository softwareRepository = MockSoftwareRepository();
  final AddSoftwareCommand addSoftwareCommand =
      AddSoftwareCommand(softwareRepository);

  // System Under Test
  final MenuRouter menuRouter = MenuRouter(
    addSoftwareCommand: addSoftwareCommand,
  );

  test("add software", () {
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

    verify(softwareRepository.save(software)).called(1);
  });
}
