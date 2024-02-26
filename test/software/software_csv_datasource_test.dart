import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:releaser/application/process_runner.dart';
import 'package:releaser/csv/csv_manager.dart';
import 'package:releaser/csv/instruction_csv_manager.dart';
import 'package:releaser/csv/software_csv_manager.dart';
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
  // Dependencies
  final Uuid uuid = MockUuid();
  final ZipFileEncoder zipFileEncoder = ZipFileEncoder();
  late File softwareFile;
  late File instructionFile;

  // System under test
  late SoftwareCsvDataSource softwareCsvRepository;

  List<Instruction> instructions = [
    CopyInstruction(
      processRunner: ProcessRunner(),
      sourcePath: "build/path",
      destinationPath: "dest/path",
      os: "macos",
    ),
  ];

  List<UuidValue> softwareIds = [
    UuidValue.fromString("29214dab-3ef1-47e1-9cfe-46baf19fb6f0"),
    UuidValue.fromString("229573d0-25fd-4de6-9b8b-e54f638f942b"),
  ];

  // How instructions are stored in the csv file.
  List<String> instructionFileLines = [
    "${softwareIds[0]},Copy,\"build/path,dest/path\"",
    "${softwareIds[1]},Copy,\"build/path,dest/path\""
  ];

  // How software are stored in the csv file.
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
    Software( // Does not have an id, represents a new software
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
      softwareCsvManager: SoftwareCsvManager(
        csvFile: softwareFile,
        csvToListConverter: csvToList,
        listToCsvConverter: listToCsv,
      ),
      instructionCsvManager: InstructionCsvManager(
        csvFile: instructionFile,
        csvToListConverter: csvToList,
        listToCsvConverter: listToCsv,
      ), zipFileEncoder: zipFileEncoder,
    );
  });

  test("saving a new software should save both software and"
      " its instructions", () async {
    int softwareIndex = 1;
    Software expected = Software(
      id: softwareIds[softwareIndex],
      name: software[softwareIndex].name,
      rootPath: software[softwareIndex].rootPath,
      releasePath: software[softwareIndex].releasePath,
      releaseInstructions: software[softwareIndex].releaseInstructions,
    );

    when(uuid.v4()).thenReturn(softwareIds[softwareIndex].toString());

    Software actual = await softwareCsvRepository.save(software[softwareIndex]);
    verify(
      softwareFile.writeAsStringSync(
        softwareFileLines[softwareIndex] + Platform.lineTerminator,
        mode: FileMode.append,
      ),
    ).called(1);

    verify(
      instructionFile.writeAsStringSync(
        instructionFileLines[softwareIndex] + Platform.lineTerminator,
        mode: FileMode.append,
      ),
    ).called(1);

    expect(actual, expected);
  });

  test("saving an existing software should only save"
      " its instructions", () async {
    int softwareIndex = 0;
    Software expected = software[softwareIndex];

    when(uuid.v4()).thenReturn(softwareIds[softwareIndex].toString());

    Software actual = await softwareCsvRepository.save(software[softwareIndex]);
    verify(
      instructionFile.writeAsStringSync(
        instructionFileLines[softwareIndex] + Platform.lineTerminator,
        mode: FileMode.append,
      ),
    ).called(1);

    expect(actual, expected);
  });

  test("findAll", () async {
    List<Software> expected = [];
    for (int i = 0; i < software.length; i++) {
      expected.add(Software(
        id: softwareIds[i],
        name: software[i].name,
        rootPath: software[i].rootPath,
        releasePath: software[i].releasePath,
        releaseInstructions: software[i].releaseInstructions,
      ));
    }

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
