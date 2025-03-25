import 'package:sqlite3/sqlite3.dart';

import 'instruction_entity.dart';

class InstructionDao {
  final Database db;

  InstructionDao({required this.db});

  List<InstructionEntity> insertInstructions(List<InstructionEntity> instructions) {
    db.execute("BEGIN TRANSACTION");
    PreparedStatement statement = db.prepare("INSERT INTO instructions"
        " (software_id, name, execution_order, arguments) VALUES (?, ?, ?, ?)");

    List<InstructionEntity> insertedInstructions = [];
    try {
      for (InstructionEntity instruction in instructions) {
        statement.execute([
          instruction.softwareId,
          instruction.name,
          instruction.executionOrder,
          instruction.arguments,
        ]);

        InstructionEntity insertedInstruction = InstructionEntity(
          id: db.lastInsertRowId,
          softwareId: instruction.softwareId,
          name: instruction.name,
          executionOrder: instruction.executionOrder,
          arguments: instruction.arguments,
        );
        insertedInstructions.add(insertedInstruction);
      }
      db.execute("COMMIT");
    } catch (e) {
      db.execute("ROLLBACK");
      rethrow;
    } finally {
      statement.dispose();
    }

    return insertedInstructions;
  }

  List<InstructionEntity> selectAll() {
    ResultSet resultSet = db.select("SELECT * FROM instructions");
    List<InstructionEntity> instructionsDb = [];

    for (Row row in resultSet) {
      InstructionEntity instructionDb = InstructionEntity(
        id: row['id'],
        softwareId: row['software_id'],
        name: row['name'],
        executionOrder: row['execution_order'],
        arguments: row['arguments'],
      );
      instructionsDb.add(instructionDb);
    }

    return instructionsDb;
  }

  void deleteInstructionsBySoftwareId(int softwareId) {
    db.execute("DELETE FROM instructions WHERE software_id = ?", [softwareId]);
  }
}
