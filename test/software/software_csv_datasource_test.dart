import 'package:csv/csv.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:releaser/paths/paths.dart';
import 'package:releaser/software/software.dart';
import 'package:releaser/software/software_csv_datasource.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'dart:io';

import 'software_csv_datasource_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<File>(),
  MockSpec<Uuid>(),
])
void main() {
  Uuid uuid = MockUuid();
  late File mockFile;
  late SoftwareCsvRepository softwareCsvRepository;

  List<UuidValue> ids = [
    UuidValue.fromString("29214dab-3ef1-47e1-9cfe-46baf19fb6f0"),
    UuidValue.fromString("229573d0-25fd-4de6-9b8b-e54f638f942b"),
  ];
  List<String> fileLines = [
    "${ids[0]},software1,root1,release1",
    "${ids[1]},software2,root2,release2"
  ];
  List<Software> software = [
    Software(
      id: ids[0],
      name: "software1",
      rootPath: "root1",
      releasePath: "release1",
    ),
    Software(
      id: ids[1],
      name: "software2",
      rootPath: "root2",
      releasePath: "release2",
    ),
  ];

  setUp(() {
    mockFile = MockFile();
    softwareCsvRepository = SoftwareCsvRepository(
      csvFile: mockFile,
      uuid: uuid,
      csvToListConverter: CsvToListConverter(),
      listToCsvConverter: ListToCsvConverter(),
    );
  });

  test("save", () async {
    Software expected = Software(
      id: ids[0],
      name: "software1",
      rootPath: "root1",
      releasePath: "release1",
    );

    when(uuid.v4()).thenReturn(ids[0].toString());

    Software actual = await softwareCsvRepository.save(software[0]);
    verify(
      mockFile.writeAsStringSync(fileLines[0] + Paths.getNewLine(),
          mode: FileMode.append),
    ).called(1);

    expect(actual, expected);
  });

  test("findAll", () async {
    List<Software> expected = software;
    mockFileReading(mockFile, fileLines);

    List<Software> actual = await softwareCsvRepository.findAll();
    expect(actual, expected);
  });

  test("findByName", () async {
    Software expected = software[0];
    mockFileReading(mockFile, fileLines);

    Software? actual = await softwareCsvRepository.findByName("software1");
    expect(actual, expected);
  });
}

void mockFileReading(File file, List<String> lines) {
  String fileContent = lines.join(Paths.getNewLine());
  when(file.readAsStringSync()).thenReturn(fileContent);
  when(file.existsSync()).thenReturn(true);
}
