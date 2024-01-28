import 'package:csv/csv.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_repository.dart';

import 'dart:io';

import 'package:uuid/uuid.dart';

/// This implementation uses a CSV file to store the [Software]
/// objects.
class SoftwareCsvRepository implements SoftwareRepository {
  /// All software data is stored in this file.
  final File _csvFile;

  final Uuid _uuid;
  final CsvToListConverter _csvToListConverter;
  final ListToCsvConverter _listToCsvConverter;

  final int _idIndex = 0;
  final int _nameIndex = 1;
  final int _rootPathIndex = 2;
  final int _releasePathIndex = 3;

  SoftwareCsvRepository({
    required File csvFile,
    required Uuid uuid,
    required CsvToListConverter csvToListConverter,
    required ListToCsvConverter listToCsvConverter,
  })  : _csvFile = csvFile,
        _uuid = uuid,
        _csvToListConverter = csvToListConverter,
        _listToCsvConverter = listToCsvConverter;

  @override
  Future<Software> save(Software software) async {
    UuidValue id = UuidValue.fromString(_uuid.v4());
    Software savedSoftware = Software(
      id: id,
      name: software.name,
      rootPath: software.rootPath,
      releasePath: software.releasePath,
    );

    String csv = _listToCsvConverter.convert([
      savedSoftware.props
    ]);
    _csvFile.writeAsStringSync(csv, mode: FileMode.append);

    return savedSoftware;
  }

  @override
  Future<List<Software>> findAll() async {
    List<List<dynamic>> csvLines = _decodeCsv();
    List<Software> softwareList = [];

    for (var csvLine in csvLines) {
      Software software = _readSoftwareFromCsv(csvLine);
      softwareList.add(software);
    }

    return softwareList;
  }

  @override
  Future<Software?> findByName(String name) async {
    List<Software> softwareList = await findAll();
    return softwareList.where((s) => s.name == name).firstOrNull;
  }

  Software _readSoftwareFromCsv(List<dynamic> csvLine) {
    UuidValue id = UuidValue.fromString(csvLine[_idIndex]);
    String name = csvLine[_nameIndex];
    String rootPath = csvLine[_rootPathIndex];
    String releasePath = csvLine[_releasePathIndex];

    Software software = Software(
      id: id,
      name: name,
      rootPath: rootPath,
      releasePath: releasePath,
    );
    return software;
  }

  List<List<dynamic>> _decodeCsv() {
    var csvContent = _getFileContent();
    return _csvToListConverter.convert(csvContent);
  }

  String _getFileContent() {
    if (!_csvFile.existsSync()) {
      _csvFile.createSync();
    }
    return _csvFile.readAsStringSync();
  }
}
