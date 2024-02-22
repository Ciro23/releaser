import 'package:releaser/software/software.dart';

abstract class SoftwareService {
  Future<Software> save(Software software);
  Future<List<Software>> findAll();
  Future<Software?> findByName(String name);
}