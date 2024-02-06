import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:releaser/software/software_repository.dart';

import '../software/software.dart';

class ListSoftwareCommand extends Command {
  final SoftwareRepository _softwareRepository;

  ListSoftwareCommand(this._softwareRepository);

  @override
  String get name => "list-software";

  @override
  String get description => "Show a list of all saved software";

  @override
  void run() async {
    List<Software> softwareList = await _softwareRepository.findAll();
    for (var element in softwareList) {
      stdout.writeln("Name: ${element.name}");
      stdout.writeln("Root Path: ${element.rootPath}");
      stdout.writeln("Release Path: ${element.releasePath}");
      stdout.writeln("Instructions: ${element.releaseInstructions}");
      stdout.writeln("");
    }
  }
}
