import 'package:equatable/equatable.dart';
import 'package:uuid/uuid_value.dart';

/// Represents how a [Software] is stored in a CSV file.
class SoftwareCsv extends Equatable {
  final UuidValue id;
  final String name;
  final String rootPath;
  final String releasePath;

  SoftwareCsv({
    required this.id,
    required this.name,
    required this.rootPath,
    required this.releasePath,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        rootPath,
        releasePath,
      ];
}
