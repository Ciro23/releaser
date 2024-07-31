import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/args.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:releaser/instruction/copy_instruction.dart';
import 'package:releaser/router/add_instruction_command.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_repository.dart';
import 'package:test/test.dart';

import 'add_instruction_command_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SoftwareRepository>(),
  MockSpec<ZipFileEncoder>(),
])
void main() {
  // Dependencies
  late SoftwareRepository softwareRepository;
  late ZipFileEncoder zipFileEncoder;

  // System under test
  late AddInstructionCommand addNonExistentInstruction;
  late AddInstructionCommand addCopyInstruction;
  late AddInstructionCommand addZipInstruction;

  setUp(() {
    softwareRepository = MockSoftwareRepository();
    zipFileEncoder = MockZipFileEncoder();

    addNonExistentInstruction = TestableAddInstruction(
      softwareRepository: softwareRepository,
      zipFileEncoder: zipFileEncoder,
      arguments: [
        "--software",
        "test_software",
        "--name",
        "nonexistent_instruction",
      ],
    );
    addCopyInstruction = TestableAddInstruction(
      softwareRepository: softwareRepository,
      zipFileEncoder: zipFileEncoder,
      arguments: [
        "--software",
        "test_software",
        "--name",
        "copy",
      ],
    );
    addZipInstruction = TestableAddInstruction(
      softwareRepository: softwareRepository,
      zipFileEncoder: zipFileEncoder,
      arguments: [
        "--software",
        "test_software",
        "--name",
        "zip",
      ],
    );
  });

  test("throws exception if software doesn't exist", () {
    expect(
      () => addCopyInstruction.run(),
      throwsA(TypeMatcher<ArgumentError>()),
    );
  });

  test("throws exception if instruction doesn't exist", () {
    Software software = Software(
      name: "test_software",
      rootPath: Uri.file("rootPath"),
      releasePath: Uri.file("releasePath"),
      releaseInstructions: [],
    );
    when(softwareRepository.findByName("test_software"))
        .thenAnswer((_) async => software);

    expect(
      () => addNonExistentInstruction.run(),
      throwsA(TypeMatcher<ArgumentError>()),
    );
  });

  test("add copy instruction", () async {
    Software software = Software(
      name: "test_software",
      rootPath: Uri.file("rootPath"),
      releasePath: Uri.file("releasePath"),
      releaseInstructions: [],
    );
    when(softwareRepository.findByName(software.name))
        .thenAnswer((_) async => software);

    await addCopyInstruction.run();
    software.addInstruction(CopyInstruction(
      sourcePath: Uri.file("test"),
      destinationPath: Uri.file("test"),
      os: Platform.operatingSystem,
    ));

    verify(softwareRepository.save(software)).called(1);
  });

  test("add zip instruction", () async {
    Software software = Software(
      name: "test_software",
      rootPath: Uri.file("rootPath"),
      releasePath: Uri.file("releasePath"),
      releaseInstructions: [],
    );
    when(softwareRepository.findByName(software.name))
        .thenAnswer((_) async => software);

    await addZipInstruction.run();
    software.addInstruction(CopyInstruction(
      sourcePath: Uri.file("test"),
      destinationPath: Uri.file("test"),
      os: Platform.operatingSystem,
    ));

    verify(softwareRepository.save(software)).called(1);
  });
}

/// This subclass is necessary as [argResults] cannot be modified
/// or mocked directly.
class TestableAddInstruction extends AddInstructionCommand {
  final List<String> arguments;

  TestableAddInstruction({
    required SoftwareRepository softwareRepository,
    required ZipFileEncoder zipFileEncoder,
    required this.arguments,
  }) : super(
          softwareRepository: softwareRepository,
          zipFileEncoder: zipFileEncoder,
          onPrint: (_) {},
          onInput: () => "mocked_user_input",
        );

  @override
  ArgResults? get argResults => argParser.parse(arguments);
}
