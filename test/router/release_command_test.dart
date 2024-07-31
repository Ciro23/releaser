import 'dart:io';

import 'package:args/args.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:releaser/instruction/copy_instruction.dart';
import 'package:releaser/instruction/instruction.dart';
import 'package:releaser/router/release_command.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_repository.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'add_instruction_command_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SoftwareRepository>()])
void main() {
  // Dependencies
  final SoftwareRepository softwareRepository = MockSoftwareRepository();

  // System under test
  late ReleaseCommand releaseCommand;

  setUp(() {
    releaseCommand = TestableReleaseCommand(
      softwareRepository: softwareRepository,
      arguments: [
        "--software",
        "test_software",
        "--version",
        "1.0.0",
      ],
    );
  });

  test("throws exception if software doesn't exist", () {
    expect(
      () => releaseCommand.run(),
      throwsA(TypeMatcher<ArgumentError>()),
    );
  });

  test("instruction variables should be parsed", () async {
    TestableInstruction instruction = TestableInstruction(
        sourcePath: Uri.file(r"${root_path}"),
        destinationPath: Uri.file(
          r"${dest_path}",
        ));

    Software software = Software(
      name: "test_software",
      rootPath: Uri.file("/test/root/path/"),
      releasePath: Uri.file(r"/test/${name}/${version}/"),
      releaseInstructions: [instruction],
    );
    when(softwareRepository.findByName(software.name))
        .thenAnswer((_) async => software);

    await releaseCommand.run();

    TestableInstruction parsedInstruction = instruction.parsedInstruction!;
    expect(parsedInstruction.arguments[0], "/test/root/path/");
    expect(parsedInstruction.arguments[1], "/test/test_software/1.0.0/");
  });
}

/// This subclass is necessary as [argResults] cannot be modified
/// or mocked directly.
class TestableReleaseCommand extends ReleaseCommand {
  final List<String> arguments;

  TestableReleaseCommand({
    required SoftwareRepository softwareRepository,
    required this.arguments,
  }) : super(
          softwareRepository: softwareRepository,
          //onPrint: (_) {},
        );

  @override
  ArgResults? get argResults => argParser.parse(arguments);
}

/// I wasn't able to properly mock [Instruction] using mockito,
/// so I created this subclass. The parsed instance is saved in
/// the class attributes so that it can be checked in the test
/// case, as it is never passed out from [ReleaseCommand]
class TestableInstruction extends CopyInstruction {
  TestableInstruction? parsedInstruction;

  TestableInstruction({
    required super.sourcePath,
    required super.destinationPath,
  }) : super(os: Platform.operatingSystem);

  @override
  Future<void> execute() async {}

  @override
  CopyInstruction create(UuidValue? id, List<String> arguments) {
    parsedInstruction = TestableInstruction(
      sourcePath: Uri.file(arguments[0]),
      destinationPath: Uri.file(arguments[1]),
    );
    return parsedInstruction!;
  }
}
