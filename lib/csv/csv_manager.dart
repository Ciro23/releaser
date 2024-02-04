import 'dart:io';

import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';

import '../paths/paths.dart';

class CsvManager<T extends Equatable> {
  /// All software data is stored in this file.
  final File _csvFile;

  final CsvToListConverter _csvToListConverter;
  final ListToCsvConverter _listToCsvConverter;

  CsvManager({
    required File csvFile,
    required CsvToListConverter csvToListConverter,
    required ListToCsvConverter listToCsvConverter,
    required ,
  })  : _csvFile = csvFile,
        _csvToListConverter = csvToListConverter,
        _listToCsvConverter = listToCsvConverter;

  void appendObjects(List<T> objects) {
    List<List<Object?>> propertiesOfObjects = objects.map((e) => e.props).toList();
    String csvContent = _listToCsvConverter.convert(propertiesOfObjects) + Paths.getNewLine();
    _csvFile.writeAsStringSync(csvContent, mode: FileMode.append);
  }

  void appendObject(T object) {
    appendObjects([object]);
  }

  /// Reads all the CSV lines in [_csvFile].
  /// [onBuildObjectFromCsv] is used to build the object
  /// from all the CSV properties.
  List<T> readObjects(T Function(List<dynamic>) onBuildObjectFromCsv) {
    List<List<dynamic>> csvLines = _readCsv();

    List<T> objects = [];

    for (var csvLine in csvLines) {
      T object = onBuildObjectFromCsv(csvLine);
      objects.add(object);
    }

    return objects;
  }

  List<List<dynamic>> _readCsv() {
    var csvContent = _getFileContent();
    return _csvToListConverter.convert(csvContent);
  }

  String _getFileContent() {
    if (!_csvFile.existsSync()) {
      _csvFile.createSync();
    }
    return _csvFile.readAsStringSync();
  }
}
