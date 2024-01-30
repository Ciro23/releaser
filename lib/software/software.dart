import 'package:equatable/equatable.dart';
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

  @override
  List<Object?> get props => [
        id,
        name,
        rootPath,
        releasePath,
      ];
}
