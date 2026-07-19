import 'package:liquid_flutter/liquid_flutter.dart';

class Project with Identifiable<int> {
  @override
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  Project(this.id, this.name, this.description, this.createdAt, this.updatedAt);
}

LdCallbackModel<Project, int, Project, Project> projectModel() => LdCallbackModel.fromList<Project, int>(
  list: [
    Project(1, "Project 1", "Description 1", DateTime.now(), DateTime.now()),
    Project(2, "Project 2", "Description 2", DateTime.now(), DateTime.now()),
    Project(3, "Project 3", "Description 3", DateTime.now(), DateTime.now()),
  ],
);

class File with Identifiable<String> {
  @override
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  File(this.id, this.name, this.description, this.createdAt, this.updatedAt);
}

LdCallbackModel<File, String, File, File> fileModel(String projectId) => LdCallbackModel.fromList<File, String>(
  list: [
    File("${projectId}1", "$projectId-File 1", "Description 1", DateTime.now(), DateTime.now()),
    File("${projectId}2", "$projectId-File 2", "Description 2", DateTime.now(), DateTime.now()),
    File("${projectId}3", "$projectId-File 3", "Description 3", DateTime.now(), DateTime.now()),
  ],
);
