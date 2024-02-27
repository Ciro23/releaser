import 'package:releaser/csv/csv_manager.dart';
import 'package:releaser/instruction/instruction_csv.dart';
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
    final int instructionIdIndex = 0;
    final int instructionSoftwareIdIndex = 1;
    final int instructionNameIndex = 2;
    final int instructionArgumentsFirstIndex = 3;

    UuidValue id = UuidValue.fromString(csvLine[instructionIdIndex]);
    UuidValue softwareId = UuidValue.fromString(csvLine[instructionSoftwareIdIndex]);
    String name = csvLine[instructionNameIndex];
    String arguments = csvLine[instructionArgumentsFirstIndex];

    return InstructionCsv(
      id: id,
      softwareId: softwareId,
      name: name,
      arguments: arguments,
    );
  }
}
