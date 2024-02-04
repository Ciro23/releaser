import 'package:releaser/csv/csv_manager.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_repository.dart';

import 'package:uuid/uuid.dart';


/// This implementation uses a CSV file to store the [Software]
/// objects.
class SoftwareCsvDataSource implements SoftwareRepository {
  final Uuid _uuid;
  final CsvManager<Software> _csvManager;

  final int _idIndex = 0;
  final int _nameIndex = 1;
  final int _rootPathIndex = 2;
  final int _releasePathIndex = 3;

  SoftwareCsvDataSource({
    required Uuid uuid,
    required CsvManager<Software> csvManager,
  })  : _uuid = uuid,
        _csvManager = csvManager;

  @override
  Future<Software> save(Software software) async {
    UuidValue id = UuidValue.fromString(_uuid.v4());
    Software savedSoftware = Software(
      id: id,
      name: software.name,
      rootPath: software.rootPath,
      releasePath: software.releasePath,
    );

    _csvManager.appendObject(savedSoftware);
    return savedSoftware;
  }

  @override
  Future<List<Software>> findAll() async {
    return _csvManager.readObjects(_readSoftwareFromCsv);
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
}
