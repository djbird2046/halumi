import 'package:hive/hive.dart';

import '../models/project.dart';
import '../persistence/hive_boxes.dart';

class ProjectRepository {
  ProjectRepository(this.box);

  final Box box;

  List<Project> loadProjects() {
    final stored = box.get(HiveKeys.projectsList) as List<dynamic>?;
    final projects =
        stored
            ?.map(
              (raw) => Project.fromMap(Map<String, dynamic>.from(raw as Map)),
            )
            .toList() ??
        [];

    return projects;
  }

  Future<List<Project>> addProject(String name) async {
    final projects = loadProjects();
    final newProject = Project(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    projects.insert(0, newProject);
    await saveProjects(projects);
    return projects;
  }

  Future<List<Project>> renameProject({
    required String id,
    required String name,
  }) async {
    final projects = loadProjects();
    final project = projects.firstWhere(
      (p) => p.id == id,
      orElse: () => projects.first,
    );
    project.name = name.trim().isEmpty ? 'Untitled' : name.trim();
    await saveProjects(projects);
    return projects;
  }

  Future<List<Project>> deleteProject(String id) async {
    final projects = loadProjects();
    projects.removeWhere((p) => p.id == id);
    await saveProjects(projects);
    return projects;
  }

  Future<void> saveProjects(List<Project> projects) async {
    await box.put(
      HiveKeys.projectsList,
      projects.map((p) => p.toMap()).toList(),
    );
  }
}
