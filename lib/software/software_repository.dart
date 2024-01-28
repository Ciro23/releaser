import 'package:releaser/software/software.dart';

abstract class SoftwareRepository<T> {
  Future<T> save(Software software);
  Future<List<Software>> findAll();
  Future<Software?> findByName(String name);
}