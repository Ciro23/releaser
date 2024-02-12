import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:releaser/csv/csv_manager.dart';
import 'package:releaser/instruction/instruction_csv.dart';
import 'package:releaser/instruction/zip_instruction.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_csv.dart';
import 'package:releaser/software/software_repository.dart';

import 'package:uuid/uuid.dart';

import '../application/process_runner.dart';
import '../instruction/copy_instruction.dart';
import '../instruction/instruction.dart';

/// This implementation uses a CSV file to store the [Software]
/// objects.
class SoftwareCsvDataSource implements SoftwareRepository {
  final Uuid _uuid;
  final CsvManager<SoftwareCsv> _softwareCsvManager;
  final CsvManager<InstructionCsv> _instructionCsvManager;
  final ZipFileEncoder _zipFileEncoder;

  final int _softwareIdIndex = 0;
  final int _softwareNameIndex = 1;
  final int _softwareRootPathIndex = 2;
  final int _softwareReleasePathIndex = 3;

  final int _instructionSoftwareIdIndex = 0;
  final int _instructionNameIndex = 1;
  final int _instructionArgumentsFirstIndex = 2;

  SoftwareCsvDataSource({
    required Uuid uuid,
    required CsvManager<SoftwareCsv> softwareCsvManager,
    required CsvManager<InstructionCsv> instructionCsvManager,
    required ZipFileEncoder zipFileEncoder,
  })  : _uuid = uuid,
        _softwareCsvManager = softwareCsvManager,
        _instructionCsvManager = instructionCsvManager,
        _zipFileEncoder = zipFileEncoder;

  @override
  Future<Software> save(Software software) async {
    UuidValue? softwareId = software.id;
    softwareId ??= saveSoftware(software);

    if (software.releaseInstructions.isNotEmpty) {
      saveInstructions(softwareId, software.releaseInstructions);
    }

    return Software(
      id: softwareId,
      name: software.name,
      rootPath: software.rootPath,
      releasePath: software.releasePath,
      releaseInstructions: software.releaseInstructions,
    );
  }

  @override
  Future<List<Software>> findAll() async {
    List<SoftwareCsv> softwareCsv =
        _softwareCsvManager.readObjects(_readSoftwareFromCsvLine);

    List<InstructionCsv> instructionsCsv =
        _instructionCsvManager.readObjects(_readInstructionFromCsvLine);

    List<Software> softwareList = [];
    for (final s in softwareCsv) {
      List<InstructionCsv> softwareInstructions =
          instructionsCsv.where((i) => i.softwareId == s.id).toList();

      Software software = _csvToSoftware(s, softwareInstructions);
      softwareList.add(software);
    }

    return softwareList;
  }

  @override
  Future<Software?> findByName(String name) async {
    List<Software> softwareList = await findAll();
    return softwareList.where((s) => s.name == name).firstOrNull;
  }

  UuidValue saveSoftware(Software software) {
    UuidValue id = UuidValue.fromString(_uuid.v4());
    SoftwareCsv savedSoftware = SoftwareCsv(
      id: id,
      name: software.name,
      rootPath: software.rootPath,
      releasePath: software.releasePath,
    );

    _softwareCsvManager.appendObject(savedSoftware);
    return id;
  }

  void saveInstructions(
    UuidValue softwareId,
    List<Instruction> instructions,
  ) {
    List<InstructionCsv> instructionCsvList = instructions
        .map((e) => InstructionCsv(
              softwareId: softwareId,
              name: e.name,
              arguments: e.arguments.join(","),
            ))
        .toList();
    _instructionCsvManager.appendObjects(instructionCsvList);
  }

  SoftwareCsv _readSoftwareFromCsvLine(List<dynamic> csvLine) {
    UuidValue id = UuidValue.fromString(csvLine[_softwareIdIndex]);
    String name = csvLine[_softwareNameIndex];
    String rootPath = csvLine[_softwareRootPathIndex];
    String releasePath = csvLine[_softwareReleasePathIndex];

    return SoftwareCsv(
      id: id,
      name: name,
      rootPath: rootPath,
      releasePath: releasePath,
    );
  }

  InstructionCsv _readInstructionFromCsvLine(List<dynamic> csvLine) {
    UuidValue id = UuidValue.fromString(csvLine[_instructionSoftwareIdIndex]);
    String name = csvLine[_instructionNameIndex];
    String arguments = csvLine[_instructionArgumentsFirstIndex];

    return InstructionCsv(
      softwareId: id,
      name: name,
      arguments: arguments,
    );
  }

  Software _csvToSoftware(
    SoftwareCsv softwareCsv,
    List<InstructionCsv> instructionsCsv,
  ) {
    return Software(
      id: softwareCsv.id,
      name: softwareCsv.name,
      rootPath: softwareCsv.rootPath,
      releasePath: softwareCsv.releasePath,
      releaseInstructions: instructionsCsv.map((e) {
        return csvToInstruction(e);
      }).toList(),
    );
  }

  Instruction csvToInstruction(InstructionCsv csv) {
    List<dynamic> arguments = csv.arguments.split(",");

    if (csv.name.toLowerCase() == "copy") {
      return CopyInstruction(
        processRunner: ProcessRunner(), // Awful. // TODO: visitor.
        sourcePath: arguments[0].replaceAll('\"', ''),
        destinationPath: arguments[1].replaceAll('\"', ''),
        os: Platform.operatingSystem,
      );
    }

    if (csv.name.toLowerCase() == "zip") {
      return ZipInstruction(
        sourcePath: arguments[0].replaceAll('\"', ''),
        destinationPath: arguments[1].replaceAll('\"', ''),
        zipFileEncoder: _zipFileEncoder,
      );
    }

    throw UnsupportedError("The instruction ${csv.name} is not supported and"
        " cannot be deserialized.");
  }
}
