import 'package:releaser/software/software.dart';

abstract class SoftwareRepository<T> {
  Future<Software> save(Software software);
  Future<List<Software>> findAll();
  Future<Software?> findByName(String name);
}
