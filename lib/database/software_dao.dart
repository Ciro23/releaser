import 'package:sqlite3/sqlite3.dart';

import 'software_entity.dart';

class SoftwareDao {
  final Database db;

  SoftwareDao({required this.db});

  SoftwareEntity insertSoftware(SoftwareEntity software) {
    db.execute(
        "INSERT INTO software (name, root_path, release_path) VALUES"
        "(?, ?, ?)",
        [
          software.name,
          software.rootPath,
          software.releasePath,
        ]);

    return SoftwareEntity(
      id: db.lastInsertRowId,
      name: software.name,
      rootPath: software.rootPath,
      releasePath: software.releasePath,
    );
  }

  SoftwareEntity updateSoftware(SoftwareEntity software) {
    db.execute(
        "UPDATE software SET name = ?, root_path = ?, release_path = ?"
        " WHERE id = ?",
        [
          software.name,
          software.rootPath,
          software.releasePath,
          software.id,
        ]);
    return software;
  }

  List<SoftwareEntity> selectAll() {
    ResultSet resultSet = db.select("SELECT * FROM software");
    List<SoftwareEntity> softwareListDb = [];

    for (Row row in resultSet) {
      SoftwareEntity softwareDb = SoftwareEntity(
        id: row['id'],
        name: row['name'],
        rootPath: row['root_path'],
        releasePath: row['release_path'],
      );
      softwareListDb.add(softwareDb);
    }

    return softwareListDb;
  }

  void deleteSoftwareById(int softwareId) {
    db.execute("DELETE FROM software WHERE id = ?", [softwareId]);
  }
}
