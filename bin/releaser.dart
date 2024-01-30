import 'dart:io';

import 'package:csv/csv.dart';
import 'package:releaser/paths/paths.dart';
import 'package:releaser/router/add_software_command.dart';
import 'package:releaser/router/menu_router.dart';
import 'package:releaser/software/software_csv_datasource.dart';
import 'package:releaser/software/software_repository.dart';
import 'package:uuid/uuid.dart';

void main(List<String> arguments) {
  Directory appDirectory = Directory(Paths.getReleaserPath());
  if (!appDirectory.existsSync()) {
    appDirectory.createSync(recursive: true);
  }

  String softwareFilePath = Paths.getSoftwarePath();
  SoftwareRepository softwareRepository = SoftwareCsvRepository(
    csvFile: File(softwareFilePath),
    uuid: Uuid(),
    csvToListConverter: CsvToListConverter(),
    listToCsvConverter: ListToCsvConverter(),
  );

  AddSoftwareCommand addSoftwareCommand = AddSoftwareCommand(softwareRepository);
  MenuRouter menuRouter = MenuRouter(addSoftwareCommand: addSoftwareCommand,);

  menuRouter.runSelectedAction(arguments);
}
