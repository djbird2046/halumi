import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:halumi/core/persistence/hive_boxes.dart';
import 'package:halumi/core/repositories/project_repository.dart';

void main() {
  late Directory tempDir;
  late Box box;
  late ProjectRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('halumi_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox(HiveBoxes.projects);
    repository = ProjectRepository(box);
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  test('returns empty list when box is empty', () {
    final projects = repository.loadProjects();
    expect(projects, isEmpty);
  });

  test('add, rename, delete project persists in box', () async {
    final initial = repository.loadProjects();
    expect(initial.length, 0);

    final added = await repository.addProject('New Project');
    expect(added.length, 1);
    final newId = added.first.id;
    expect(added.first.name, 'New Project');

    final renamed = await repository.renameProject(
      id: newId,
      name: 'Updated Name',
    );
    expect(renamed.firstWhere((p) => p.id == newId).name, 'Updated Name');

    final afterDelete = await repository.deleteProject(newId);
    expect(afterDelete.length, 0);
  });

  test('rename trims empty name to Untitled', () async {
    final added = await repository.addProject('Temp');
    final newId = added.first.id;

    final renamed = await repository.renameProject(id: newId, name: '   ');
    expect(renamed.firstWhere((p) => p.id == newId).name, 'Untitled');
  });
}
