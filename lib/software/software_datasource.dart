import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:releaser/database/database.dart';
import 'package:releaser/database/instruction_dao.dart';
import 'package:releaser/database/instruction_entity.dart';
import 'package:releaser/instruction/instruction_factory.dart';
import 'package:releaser/instruction/shell_instruction.dart';
import 'package:releaser/instruction/zip_instruction.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/database/software_entity.dart';
import 'package:releaser/software/software_repository.dart';

import 'package:uuid/uuid.dart';

import '../database/software_dao.dart';
import '../instruction/copy_instruction.dart';
import '../instruction/instruction.dart';

class SoftwareDataSource implements SoftwareRepository {
  final ZipFileEncoder zipFileEncoder;
  final SoftwareDao softwareDao;

  final InstructionDao instructionDao;
  final InstructionFactory instructionFactory;

  SoftwareDataSource({
    required this.zipFileEncoder,
    required this.softwareDao,
    required this.instructionDao,
    required this.instructionFactory,
  });

  @override
  Future<Software> save(Software software) async {
    if (software.id == null) {
      Software? existingSoftware = await findByName(software.name);
      if (existingSoftware != null) {
        throw StateError("Software with name '${software.name}' already"
            " exists");
      }

      return _insertSoftwareWithInstructions(software);
    }

    return _updateSoftware(software);
  }

  @override
  Future<List<Software>> findAll() async {
    List<SoftwareEntity> softwareDb = softwareDao.selectAll();
    List<InstructionEntity> instructionsDb = instructionDao.selectAll();

    List<Software> softwareList = [];
    for (final s in softwareDb) {
      List<InstructionEntity> softwareInstructions =
          instructionsDb.where((i) => i.softwareId == s.id).toList();

      Software software = _dbToSoftware(s, softwareInstructions);
      softwareList.add(software);
    }

    return softwareList;
  }

  @override
  Future<Software?> findByName(String name) async {
    List<Software> softwareList = await findAll();
    return softwareList.where((s) => s.name == name).firstOrNull;
  }

  @override
  Future<bool> delete(Software software) async {
    softwareDao.deleteSoftwareById(software.id!);
    return true;
  }

  Software _insertSoftwareWithInstructions(Software software) {
    SoftwareEntity softwareDb = _softwareToDb(software);
    SoftwareEntity insertedSoftware = softwareDao.insertSoftware(softwareDb);

    List<InstructionEntity> insertedInstructions = _insertInstructions(
      insertedSoftware.id!,
      software.releaseInstructions,
    );

    return _dbToSoftware(insertedSoftware, insertedInstructions);
  }

  List<InstructionEntity> _insertInstructions(
    int softwareId,
    List<Instruction> instructions,
  ) {
    List<InstructionEntity> instructionsDb = _instructionsToDb(
      softwareId,
      instructions,
    );
    return instructionDao.insertInstructions(instructionsDb);
  }

  Software _updateSoftware(Software software) {
    SoftwareEntity softwareDb = _softwareToDb(software);
    SoftwareEntity updatedSoftware = softwareDao.updateSoftware(softwareDb);

    List<InstructionEntity> updatedInstructions = _updateInstructions(
      updatedSoftware.id!,
      software.releaseInstructions,
    );

    return _dbToSoftware(updatedSoftware, updatedInstructions);
  }

  List<InstructionEntity> _updateInstructions(
    int softwareId,
    List<Instruction> instructions,
  ) {
    List<InstructionEntity> instructionsDb = _instructionsToDb(
      softwareId,
      instructions,
    );
    instructionDao.deleteInstructionsBySoftwareId(softwareId);
    return instructionDao.insertInstructions(instructionsDb);
  }

  SoftwareEntity _softwareToDb(Software software) {
    return SoftwareEntity(
      id: software.id,
      name: software.name,
      rootPath: software.rootPath.toFilePath(),
      releasePath: software.releasePath.toFilePath(),
    );
  }

  Software _dbToSoftware(
    SoftwareEntity softwareDb,
    List<InstructionEntity> instructionsDb,
  ) {
    Uri rootPath = Uri.directory(softwareDb.rootPath);
    Uri releasePath = Uri.directory(softwareDb.releasePath);
    return Software(
      id: softwareDb.id,
      name: softwareDb.name,
      rootPath: rootPath,
      releasePath: releasePath,
      releaseInstructions: instructionsDb.map((e) {
        return _dbToInstruction(e);
      }).toList(),
    );
  }

  List<InstructionEntity> _instructionsToDb(
    int softwareId,
    List<Instruction> instructions,
  ) {
    return instructions
        .map(
          (e) => InstructionEntity(
            id: e.id,
            softwareId: softwareId,
            name: e.name,
            executionOrder: e.executionOrder,
            arguments: e.arguments.join(","),
          ),
        )
        .toList();
  }

  Instruction _dbToInstruction(InstructionEntity db) {
    List<String> arguments = db.arguments.split(",");
    for (var argument in arguments) {
      argument.replaceAll('"', '');
    }

    return instructionFactory.createInstruction(
      db.name,
      db.id!,
      db.executionOrder,
      arguments,
    );
  }
}
