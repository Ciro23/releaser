import 'package:equatable/equatable.dart';
import 'package:releaser/software/software_csv.dart';
import 'package:uuid/uuid.dart';

class Software extends Equatable {
  final UuidValue? id;
  final String name;
  final String rootPath;
  final String releasePath;

  Software({
    this.id,
    required this.name,
    required this.rootPath,
    required this.releasePath,
  });

  factory Software.fromCsv(SoftwareCsv csv) {
    return Software(
      id: csv.id,
      name: csv.name,
      rootPath: csv.rootPath,
      releasePath: csv.releasePath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        rootPath,
        releasePath,
      ];
}
