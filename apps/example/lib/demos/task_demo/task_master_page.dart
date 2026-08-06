import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class TaskMasterPage extends StatelessWidget {
  const TaskMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdListConfigProvider<Task, int>(
      // Match the loader to the item shape (leading avatar + subtitle) so the
      // placeholder occupies the same height and the list doesn't jump.
      config: LdListConfig<Task, int>(
        loadingBuilder: (context, position, totalItems) => const LdListItemLoading(hasLeading: true, hasSubtitle: true),
      ),
      child: Provider.value(
        value: LdMonkeyMasterAppbarConfig(
          appbarConfig: LdAppBarConfig(debugName: "Master App Bar Tasks", title: Text("Tasks")),
        ),
        child: LdMonkeyMasterPage<Task, int>(
          buildItem: (context, item) => LdListItem(
            title: Text(
              item.value!.task,
              style: TextStyle(decoration: item.value!.done ? TextDecoration.lineThrough : TextDecoration.none),
            ),
            subtitle: Text(
              "Due ${Jiffy.parseFromDateTime(item.value!.due).fromNow()}",
              style: TextStyle(
                color: switch (item.value!.due.isBefore(DateTime.now())) {
                  true => LdTheme.of(context).errorColor,
                  _ => null,
                },
              ),
            ),
            leading: LdAvatar(child: LdEmoji(item.value!.emoji)),
          ),
        ),
      ),
    );
  }
}
