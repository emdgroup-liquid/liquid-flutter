import 'package:flutter/material.dart';
import 'package:liquid/demos/projects/repo.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class ProjectMasterPage extends StatelessWidget {
  const ProjectMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: LdMonkeyMasterAppbarConfig(appbarConfig: LdAppBarConfig(title: Text("Projects"))),
      child: LdMonkeyMasterPage<Project, int>(
        buildItem: (context, item) =>
            LdListItem(title: Text(item.value!.name), subtitle: Text(item.value!.description)),
      ),
    );
  }
}

class FileMasterPage extends StatelessWidget {
  const FileMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: LdMonkeyMasterAppbarConfig(appbarConfig: LdAppBarConfig(title: Text("Files"))),
      child: LdMonkeyMasterPage<File, String>(
        buildItem: (context, item) {
          return LdListItem(title: Text(item.value!.name), subtitle: Text(item.value!.description));
        },
      ),
    );
  }
}

class FileDetailPage extends StatelessWidget {
  const FileDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyDetailAppBars<File, String>(child: LdScaffoldBody(children: [Text("File Detail")]));
  }
}
