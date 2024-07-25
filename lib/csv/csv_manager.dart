import 'dart:io';

import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';

import 'file_manager.dart';


/// Stores and retrieves objects using a CSV file.
class CsvManager<T extends Equatable> implements FileManager<T> {
  /// All software data is stored in this file.
  final File _csvFile;

  final CsvToListConverter _csvToListConverter;
  final ListToCsvConverter _listToCsvConverter;
  final T Function(List<dynamic>) _onBuildObject;

  CsvManager({
    required File csvFile,
    required CsvToListConverter csvToListConverter,
    required ListToCsvConverter listToCsvConverter,
    required T Function(List<dynamic>) onBuildObject,
  })  : _csvFile = csvFile,
        _csvToListConverter = csvToListConverter,
        _listToCsvConverter = listToCsvConverter,
        _onBuildObject = onBuildObject;

  @override
  void appendObjects(List<T> objects) {
    String csvContent = _serializeObjects(objects);
    _csvFile.writeAsStringSync(csvContent, mode: FileMode.append);
  }

  @override
  void appendObject(T object) {
    appendObjects([object]);
  }

  @override
  List<T> readObjects() {
    List<List<dynamic>> csvLines = _readCsv();

    List<T> objects = [];
    for (var csvLine in csvLines) {
      T object = _onBuildObject(csvLine);
      objects.add(object);
    }

    return objects;
  }

  @override
  void deleteObjects(List<T> objects) {
    List<T> savedObjects = readObjects();
    for (var object in objects) {
      for (var savedObject in savedObjects) {
        if (savedObject == object) {
          savedObjects.remove(savedObject);
          break;
        }
      }
    }

    String csvContent = _serializeObjects(savedObjects);
    _csvFile.writeAsStringSync(csvContent, mode: FileMode.write);
  }

  @override
  void deleteObject(T object) {
    deleteObjects([object]);
  }

  String _serializeObjects(List<T> objects) {
    List<List<Object?>> propertiesOfObjects = objects.map((e) => e.props).toList();
    String csvContent = _listToCsvConverter.convert(propertiesOfObjects) + Platform.lineTerminator;
    return csvContent;
  }

  /// Parse the [_csvFile] and return its content as
  /// a list of all object attributes for each object.
  List<List<dynamic>> _readCsv() {
    var csvContent = _getFileContent();
    return _csvToListConverter.convert(csvContent, eol: Platform.lineTerminator);
  }

  /// Returns the raw content of the [_csvFile].
  String _getFileContent() {
    if (!_csvFile.existsSync()) {
      _csvFile.createSync();
    }
    return _csvFile.readAsStringSync();
  }
}
