import 'package:csv/csv.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:releaser/application/process_runner.dart';
import 'package:releaser/csv/csv_manager.dart';
import 'package:releaser/instruction/copy_instruction.dart';
import 'package:releaser/instruction/instruction.dart';
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
  late File softwareFile;
  late File instructionFile;
  late SoftwareCsvDataSource softwareCsvRepository;

  List<Instruction> instructions = [
    CopyInstruction(
      processRunner: ProcessRunner(),
      buildPath: "build/path",
      destinationPath: "dest/path",
      os: "macos",
    ),
  ];

  List<UuidValue> softwareIds = [
    UuidValue.fromString("29214dab-3ef1-47e1-9cfe-46baf19fb6f0"),
    UuidValue.fromString("229573d0-25fd-4de6-9b8b-e54f638f942b"),
  ];

  List<String> instructionFileLines = [
    "${softwareIds[0]},Copy,\"build/path,dest/path\"",
    "${softwareIds[1]},Copy,\"build/path,dest/path\""
  ];

  List<String> softwareFileLines = [
    "${softwareIds[0]},software1,root1,release1",
    "${softwareIds[1]},software2,root2,release2"
  ];

  List<Software> software = [
    Software(
      id: softwareIds[0],
      name: "software1",
      rootPath: "root1",
      releasePath: "release1",
      releaseInstructions: instructions,
    ),
    Software(
      id: softwareIds[1],
      name: "software2",
      rootPath: "root2",
      releasePath: "release2",
      releaseInstructions: instructions,
    ),
  ];

  setUp(() {
    softwareFile = MockFile();
    instructionFile = MockFile();

    final csvToList = CsvToListConverter();
    final listToCsv = ListToCsvConverter();

    softwareCsvRepository = SoftwareCsvDataSource(
      uuid: uuid,
      softwareCsvManager: CsvManager(
        csvFile: softwareFile,
        csvToListConverter: csvToList,
        listToCsvConverter: listToCsv,
      ),
      instructionCsvManager: CsvManager(
        csvFile: instructionFile,
        csvToListConverter: csvToList,
        listToCsvConverter: listToCsv,
      ),
    );
  });

  test("save", () async {
    Software expected = Software(
      id: software[0].id,
      name: software[0].name,
      rootPath: software[0].rootPath,
      releasePath: software[0].releasePath,
      releaseInstructions: software[0].releaseInstructions,
    );

    when(uuid.v4()).thenReturn(software[0].id.toString());

    Software actual = await softwareCsvRepository.save(software[0]);
    verify(
      softwareFile.writeAsStringSync(
        softwareFileLines[0] + Platform.lineTerminator,
        mode: FileMode.append,
      ),
    ).called(1);

    verify(
      instructionFile.writeAsStringSync(
        instructionFileLines[0] + Platform.lineTerminator,
        mode: FileMode.append,
      ),
    ).called(1);

    expect(actual, expected);
  });

  test("findAll", () async {
    List<Software> expected = software;
    mockFileReading(softwareFile, softwareFileLines);
    mockFileReading(instructionFile, instructionFileLines);

    List<Software> actual = await softwareCsvRepository.findAll();
    expect(actual, expected);
  });

  test("findByName", () async {
    Software expected = software[0];
    mockFileReading(softwareFile, softwareFileLines);
    mockFileReading(instructionFile, instructionFileLines);

    Software? actual = await softwareCsvRepository.findByName("software1");
    expect(actual, expected);
  });
}

void mockFileReading(File file, List<String> lines) {
  String fileContent = lines.join(Platform.lineTerminator);
  when(file.readAsStringSync()).thenReturn(fileContent);
  when(file.existsSync()).thenReturn(true);
}
