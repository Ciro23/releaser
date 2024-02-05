import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:releaser/application/process_runner.dart';
import 'package:releaser/instruction/copy_instruction.dart';
import 'package:test/test.dart';

import 'copy_instruction_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ProcessRunner>(),
])
void main() {
  final processRunner = MockProcessRunner();

  final String buildPath = "build/path/";
  final String destPath = "dest/path/";

  CopyInstruction getInstruction(String os) {
    return CopyInstruction(
      processRunner: processRunner,
      buildPath: buildPath,
      destinationPath: destPath,
      os: os,
    );
  }

  void verifyCommandIsCalled(String os, List<String> commands) {
    // Do nothing.
    when(processRunner.run(commands)).thenReturn(null);

    CopyInstruction copyInstruction = getInstruction(os);
    copyInstruction.execute();

    verify(processRunner.run(commands));
  }

  test("copy for windows", () {
    List<String> commands = [
      "cmd",
      "/c",
      "copy",
      buildPath,
      destPath,
    ];

    verifyCommandIsCalled("windows", commands);
  });

  test("copy for macos and linux", () {
    List<String> commands = [
      "cp",
      buildPath,
      destPath,
    ];

    verifyCommandIsCalled("macos", commands);
  });

  test("copy for unsupported os", () {
    expect(() => getInstruction("unsupported"), throwsUnsupportedError);
  });
}
