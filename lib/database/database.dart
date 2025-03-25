import 'package:releaser/database/instruction_dao.dart';
import 'package:releaser/database/software_dao.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseManager {
  late Database db;

  /// Opens the database connection and initialize the tables
  /// if needed.
  /// [dbPath] is the path where the database is stored, along
  /// its name. E.g. /home/ciro23/.releaser/releaser.db
  DatabaseManager(String dbPath) {
    db = sqlite3.open(dbPath);
    db.execute('''
      CREATE TABLE IF NOT EXISTS software (
        id INTEGER PRIMARY KEY,
        name TEXT UNIQUE,
        root_path TEXT,
        release_path TEXT
      );
      CREATE TABLE IF NOT EXISTS instructions (
        id INTEGER PRIMARY KEY,
        software_id INTEGER,
        name TEXT,
        execution_order INTEGER,
        arguments TEXT
      );
    ''');
  }

  SoftwareDao get softwareDao {
    return SoftwareDao(db: db);
  }

  InstructionDao get instructionDao {
    return InstructionDao(db: db);
  }

  void close() {
    db.dispose();
  }
}
