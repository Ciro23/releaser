import 'package:equatable/equatable.dart';

/// Represents how a [Software] is stored in a the database.
class SoftwareEntity extends Equatable {
  final int? id;
  final String name;
  final String rootPath;
  final String releasePath;

  SoftwareEntity({
    required this.id,
    required this.name,
    required this.rootPath,
    required this.releasePath,
  });

  @override
  List<Object?> get props => [id, name, rootPath, releasePath];
}
