import 'package:releaser/software/software.dart';

/// The service layer handles business logic for handling
/// the use of "variables".
/// [Software] attributes can be used dynamically in
/// [Instruction.arguments], as all paths containing the placeholders
/// "${name}", "${root_path}" and "${dest_path}" will be parsed
/// using [Software] attribute values.
/// E.g. "/home/${name}/${dest_path}" will be parsed at runtime
/// using actual values.
/// In some cases it's also possible to parse the value of
/// the version used during release.
abstract class SoftwareService {
  Future<Software> save(Software software);
  Future<List<Software>> findAll();
  Future<Software?> findByName(String name);

  /// Used for parsing the variable for the version used during release,
  /// as it cannot be known in advance.
  Future<Software?> findByNameForVersion(
    String name, {
    required String version,
  });
}
