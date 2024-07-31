import 'package:equatable/equatable.dart';

/// Specifies a compatibility layer between dart objects
/// of type [T] and the file system.
abstract class FileManager<T extends Equatable> {
  /// Writes the [objects] to the end of the file.
  void appendObjects(List<T> objects);

  /// Writes the [object] to the end of the file.
  void appendObject(T object);

  /// Reads all the objects from the file.
  List<T> readObjects();

  /// Deletes the [object] from the file.
  void deleteObjects(List<T> objects);

  /// Deletes the [object] from the file.
  void deleteObject(T object);
}
