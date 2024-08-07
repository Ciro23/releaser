import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:releaser/csv/file_manager.dart';
import 'package:releaser/instruction/instruction_csv.dart';
import 'package:releaser/instruction/zip_instruction.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_csv.dart';
import 'package:releaser/software/software_repository.dart';

import 'package:uuid/uuid.dart';

import '../instruction/copy_instruction.dart';
import '../instruction/instruction.dart';

/// This implementation uses CSV to store the [Software]
/// objects.
class SoftwareCsvDataSource implements SoftwareRepository {
  final Uuid _uuid;
  final FileManager<SoftwareCsv> _softwareCsvManager;
  final FileManager<InstructionCsv> _instructionCsvManager;
  final ZipFileEncoder _zipFileEncoder;

  SoftwareCsvDataSource({
    required Uuid uuid,
    required FileManager<SoftwareCsv> softwareCsvManager,
    required FileManager<InstructionCsv> instructionCsvManager,
    required ZipFileEncoder zipFileEncoder,
  })  : _uuid = uuid,
        _softwareCsvManager = softwareCsvManager,
        _instructionCsvManager = instructionCsvManager,
        _zipFileEncoder = zipFileEncoder;

  @override
  Future<Software> save(Software software) async {
    UuidValue? softwareId = software.id;
    if (softwareId == null) {
      Software? existingSoftware = await findByName(software.name);
      if (existingSoftware != null) {
        throw StateError("Software with name '${software.name}' already"
            " exists");
      }
    }

    softwareId ??= _saveSoftware(software);

    if (software.releaseInstructions.isNotEmpty) {
      _saveInstructions(softwareId, software.releaseInstructions);
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
    List<SoftwareCsv> softwareCsv = _softwareCsvManager.readObjects();
    List<InstructionCsv> instructionsCsv = _instructionCsvManager.readObjects();

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

  UuidValue _saveSoftware(Software software) {
    UuidValue id = UuidValue.fromString(_uuid.v4());
    SoftwareCsv savedSoftware = SoftwareCsv(
      id: id,
      name: software.name,
      rootPath: software.rootPath.toFilePath(),
      releasePath: software.releasePath.toFilePath(),
    );

    _softwareCsvManager.appendObject(savedSoftware);
    return id;
  }

  @override
  Future<bool> delete(Software software) async {
    SoftwareCsv softwareCsv = SoftwareCsv(
      id: software.id!,
      name: software.name,
      rootPath: software.rootPath.toFilePath(),
      releasePath: software.releasePath.toFilePath(),
    );
    _softwareCsvManager.deleteObject(softwareCsv);

    List<InstructionCsv> instructionsCsv = _instructionsToCsv(
      software.id!,
      software.releaseInstructions,
    );
    _instructionCsvManager.deleteObjects(instructionsCsv);

    return true;
  }

  /// The [instructions] already without an id are inserted
  /// for the first time, while existing ones are overwritten.
  void _saveInstructions(
    UuidValue softwareId,
    List<Instruction> instructions,
  ) {
    List<InstructionCsv> instructionsToUpdate = instructions
        .where((i) => i.id != null)
        .map((e) => InstructionCsv(
              id: e.id!,
              softwareId: softwareId,
              name: e.name,
              arguments: e.arguments.join(","),
            ))
        .toList();
    if (instructionsToUpdate.isNotEmpty) {
      // TODO: make "update" working.
      // Updating instructions is broken and the order must be
      // preserved.
      //_instructionCsvManager.deleteObjects(instructionsToUpdate);
      //_instructionCsvManager.appendObjects(instructionsToUpdate);
    }

    List<InstructionCsv> instructionsToInsert = _instructionsToCsv(
      softwareId,
      instructions.where((i) => i.id == null).toList(),
    );
    if (instructionsToInsert.isNotEmpty) {
      _instructionCsvManager.appendObjects(instructionsToInsert);
    }
  }

  Software _csvToSoftware(
    SoftwareCsv softwareCsv,
    List<InstructionCsv> instructionsCsv,
  ) {
    Uri rootPath = Uri.directory(softwareCsv.rootPath);
    Uri releasePath = Uri.directory(softwareCsv.releasePath);
    return Software(
      id: softwareCsv.id,
      name: softwareCsv.name,
      rootPath: rootPath,
      releasePath: releasePath,
      releaseInstructions: instructionsCsv.map((e) {
        return _csvToInstruction(e);
      }).toList(),
    );
  }

  Instruction _csvToInstruction(InstructionCsv csv) {
    List<String> arguments = csv.arguments.split(",");

    if (csv.name.toLowerCase() == "copy") {
      return CopyInstruction(
        id: csv.id,
        sourcePath: Uri.file(arguments[0].replaceAll('"', '')),
        destinationPath: Uri.file(arguments[1].replaceAll('"', '')),
        os: Platform.operatingSystem,
      );
    }

    if (csv.name.toLowerCase() == "zip") {
      return ZipInstruction(
        id: csv.id,
        sourceDirectory: Directory(arguments[0].replaceAll('"', '')),
        destinationPath: Uri.file(arguments[1].replaceAll('"', '')),
        zipFileEncoder: _zipFileEncoder,
      );
    }

    throw UnsupportedError("The instruction '${csv.name}' is not supported and"
        " cannot be deserialized.");
  }

  List<InstructionCsv> _instructionsToCsv(
    UuidValue softwareId,
    List<Instruction> instructions,
  ) {
    return instructions
        .map(
          (e) => InstructionCsv(
            id: e.id ?? UuidValue.fromString(_uuid.v4()),
            softwareId: softwareId,
            name: e.name,
            arguments: e.arguments.join(","),
          ),
        )
        .toList();
  }
}
