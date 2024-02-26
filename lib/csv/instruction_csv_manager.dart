import 'package:releaser/csv/csv_manager.dart';
import 'package:releaser/instruction/instruction_csv.dart';
import 'package:releaser/software/software_csv.dart';
import 'package:uuid/uuid_value.dart';

class InstructionCsvManager extends CsvManager<InstructionCsv> {
  InstructionCsvManager({
    required csvFile,
    required csvToListConverter,
    required listToCsvConverter,
  }) : super(
          csvFile: csvFile,
          csvToListConverter: csvToListConverter,
          listToCsvConverter: listToCsvConverter,
          onBuildObject: readInstructionFromCsvLine,
        );

  static InstructionCsv readInstructionFromCsvLine(List<dynamic> csvLine) {
    final int instructionSoftwareIdIndex = 0;
    final int instructionNameIndex = 1;
    final int instructionArgumentsFirstIndex = 2;

    UuidValue id = UuidValue.fromString(csvLine[instructionSoftwareIdIndex]);
    String name = csvLine[instructionNameIndex];
    String arguments = csvLine[instructionArgumentsFirstIndex];

    return InstructionCsv(
      softwareId: id,
      name: name,
      arguments: arguments,
    );
  }
}
