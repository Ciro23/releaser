import 'dart:io';

import 'package:releaser/instruction/instruction.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_repository.dart';
import 'package:releaser/software/software_service.dart';

class SoftwareCsvService implements SoftwareService {
  final SoftwareRepository _softwareRepository;

  SoftwareCsvService(this._softwareRepository);

  @override
  Future<Software> save(Software software) {
    return _softwareRepository.save(software).then(
          (value) => _parseSoftware(value),
        );
  }

  @override
  Future<List<Software>> findAll() {
    return _softwareRepository.findAll().then(
          (value) => value.map(_parseSoftware).toList(),
        );
  }

  @override
  Future<Software?> findByName(String name) async {
    return _softwareRepository.findByName(name).then(
          (value) => value == null ? null : _parseSoftware(value),
        );
  }

  @override
  Future<Software?> findByNameForVersion(String name,
      {required String version}) {
    return _softwareRepository.findByName(name).then(
          (value) => value == null
              ? null
              : _parseSoftware(
                  value,
                  version: version,
                ),
        );
  }

  Software _parseSoftware(Software software, {String? version}) {
    List<Instruction> parsedInstructions = [];
    for (Instruction instruction in software.releaseInstructions) {
      List<String> parsedArguments = [];

      for (String argument in instruction.arguments) {
        String parsedArgument = _parseVariables(
          argument,
          software,
          version: version,
        );
        parsedArguments.add(parsedArgument);
      }

      Instruction parsedInstruction = instruction.create(
        instruction.id,
        parsedArguments,
      );
      parsedInstructions.add(parsedInstruction);
    }

    return Software(
      id: software.id,
      name: software.name,
      rootPath: software.rootPath,
      releasePath: software.releasePath,
      releaseInstructions: parsedInstructions,
    );
  }

  String _parseVariables(
    String text,
    Software software, {
    String? version,
  }) {
    String rootPath = software.rootPath.toFilePath(
      windows: Platform.isWindows,
    );
    String releasePath = software.releasePath.toFilePath(
      windows: Platform.isWindows,
    );

    String parsedVariables = text
        .replaceAll(r'${name}', software.name)
        .replaceAll(r'${root_path}', rootPath)
        .replaceAll(r'${dest_path}', releasePath);

    if (version != null) {
      return parsedVariables.replaceAll(r'${version}', version);
    }
    return parsedVariables;
  }
}
