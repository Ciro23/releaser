import 'package:releaser/csv/csv_manager.dart';
import 'package:releaser/software/software_csv.dart';
import 'package:uuid/uuid_value.dart';

class SoftwareCsvManager extends CsvManager<SoftwareCsv> {
  SoftwareCsvManager({
    required csvFile,
    required csvToListConverter,
    required listToCsvConverter,
  }) : super(
          csvFile: csvFile,
          csvToListConverter: csvToListConverter,
          listToCsvConverter: listToCsvConverter,
          onBuildObject: readSoftwareFromCsvLine,
        );

  static SoftwareCsv readSoftwareFromCsvLine(List<dynamic> csvLine) {
    final int softwareIdIndex = 0;
    final int softwareNameIndex = 1;
    final int softwareRootPathIndex = 2;
    final int softwareReleasePathIndex = 3;

    UuidValue id = UuidValue.fromString(csvLine[softwareIdIndex]);
    String name = csvLine[softwareNameIndex];
    String rootPath = csvLine[softwareRootPathIndex];
    String releasePath = csvLine[softwareReleasePathIndex];

    return SoftwareCsv(
      id: id,
      name: name,
      rootPath: rootPath,
      releasePath: releasePath,
    );
  }
}
