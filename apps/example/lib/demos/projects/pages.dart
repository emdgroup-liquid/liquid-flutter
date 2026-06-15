import 'package:flutter/material.dart';
import 'package:liquid/demos/projects/repo.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ProjectMasterPage extends StatelessWidget {
  const ProjectMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyMasterPage<Project, int>(
      primaryAppBarConfig: LdAppBarConfig(title: Text("Projects")),
      buildItem: (context, item) => LdListItem(title: Text(item.value!.name), subtitle: Text(item.value!.description)),
    );
  }
}

class FileMasterPage extends StatelessWidget {
  const FileMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyMasterPage<File, String>(
      buildItem: (context, item) {
        return LdListItem(title: Text(item.value!.name), subtitle: Text(item.value!.description));
      },
      primaryAppBarConfig: LdAppBarConfig(title: Text("Files")),
    );
  }
}

class FileDetailPage extends StatelessWidget {
  const FileDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyDetailPage<File, String>(body: LdScaffoldBody(children: [Text("File Detail")]));
  }
}
