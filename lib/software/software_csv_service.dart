import 'dart:io';

import 'package:releaser/instruction/instruction.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_repository.dart';
import 'package:releaser/software/software_service.dart';

/// The service layer handles business logic for handling
/// the use of "variables".
/// [Software] attributes can be used dynamically in
/// [Instruction.arguments], as all paths containing the placeholders
/// "${name}", "${root_path}" and "${dest_path}" will be parsed
/// using [Software] attribute values.
/// E.g. "/home/${name}/${dest_path}" will be parsed at runtime
/// using actual values.
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

  Software _parseSoftware(Software software) {
    List<Instruction> parsedInstructions = [];
    for (Instruction instruction in software.releaseInstructions) {
      List<String> parsedArguments = [];

      for (String argument in instruction.arguments) {
        String parsedArgument = _parseVariables(argument, software);
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

  String _parseVariables(String text, Software software) {
    String rootPath = software.rootPath.toFilePath(
      windows: Platform.isWindows,
    );
    String releasePath = software.releasePath.toFilePath(
      windows: Platform.isWindows,
    );

    return text
        .replaceAll(r'${name}', software.name)
        .replaceAll(r'${root_path}', rootPath)
        .replaceAll(r'${dest_path}', releasePath);
  }
}
