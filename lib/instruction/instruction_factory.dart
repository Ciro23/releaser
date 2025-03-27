import 'package:releaser/instruction/shell_instruction.dart';
import 'package:releaser/instruction/zip_instruction.dart';

import 'copy_instruction.dart';
import 'instruction.dart';

class InstructionFactory {
  Instruction createInstruction(
    String name,
    int id,
    int executionOrder,
    List<String> arguments,
  ) {
    if (name.toLowerCase() == "copy") {
      return CopyInstruction.fromArguments(
        id: id,
        executionOrder: executionOrder,
        arguments: arguments,
      );
    }

    if (name.toLowerCase() == "zip") {
      return ZipInstruction.fromArguments(
        id: id,
        executionOrder: executionOrder,
        arguments: arguments,
      );
    }

    if (name.toLowerCase() == "shell") {
      return ShellInstruction.fromArguments(
        id: id,
        executionOrder: executionOrder,
        arguments: arguments,
      );
    }

    throw UnsupportedError("The instruction '$name' is not supported and"
        " cannot be deserialized.");
  }
}
