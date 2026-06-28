import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/chemical_screen.dart';
import 'package:liquid/components/data_display/avatar.dart';
import 'package:liquid/components/data_display/counter.dart';
import 'package:liquid/components/data_display/icon.dart';
import 'package:liquid/components/feedback/exception.dart';
import 'package:liquid/components/feedback/indicator.dart';
import 'package:liquid/components/feedback/loader.dart';
import 'package:liquid/components/feedback/reveal.dart';
import 'package:liquid/components/form_elements/choose.dart';
import 'package:liquid/components/form_elements/date_time_pickers.dart';
import 'package:liquid/components/form_elements/radio.dart';
import 'package:liquid/components/form_elements/select.dart';
import 'package:liquid/components/form_elements/slider.dart';
import 'package:liquid/components/form_elements/value_slider.dart';
import 'package:liquid/components/form_elements/submit.dart';
import 'package:liquid/components/form_elements/switch.dart';
import 'package:liquid/components/form_elements/toggle.dart';
import 'package:liquid/components/interaction/action_runner.dart';
import 'package:liquid/components/interaction/appbar_demo.dart';
import 'package:liquid/components/interaction/button.dart';
import 'package:liquid/components/interaction/context_menu.dart';
import 'package:liquid/components/interaction/modal.dart';
import 'package:liquid/components/interaction/orb.dart';
import 'package:liquid/components/interaction/speed_reader.dart';
import 'package:liquid/components/interaction/tab.dart';
import 'package:liquid/components/layout/autospace.dart';
import 'package:liquid/components/layout/card.dart';
import 'package:liquid/components/layout/drawer.dart';
import 'package:liquid/components/layout/list.dart';
import 'package:liquid/components/layout/list_item.dart';
import 'package:liquid/components/layout/multi_panel_layout.dart';
import 'package:liquid/components/layout/selectable_list.dart';
import 'package:liquid/components/layout/spring.dart';
import 'package:liquid/components/material.dart';

import 'package:liquid/demos/layout_documentation.dart';
import 'package:liquid/demos/movie_demo.dart';
import 'package:liquid/demos/projects/pages.dart';
import 'package:liquid/demos/projects/repo.dart';
import 'package:liquid/demos/radius_documentation.dart';
import 'package:liquid/demos/task_demo/create.dart';
import 'package:liquid/demos/task_demo/repository.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid/demos/task_demo/task_demo.dart';
import 'package:liquid/demos/theme.dart';
import 'package:liquid/demos/typography_documentation.dart';
import 'package:liquid/home.dart';
import 'package:liquid/patterns/monkey.dart';
import 'package:liquid/patterns/monkey_actions.dart';
import 'package:liquid/patterns/monkey_pattern.dart';
import 'package:liquid/patterns/monkey_detail_edit.dart';
import 'package:liquid/patterns/monkey_repository.dart';
import 'package:liquid/patterns/monkey_sorting_filtering.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'components/bento_gallery.dart';
import 'components/data_display/markdown.dart';
import 'components/data_display/table.dart';
import 'components/data_display/tag.dart';
import 'components/feedback/badge.dart';
import 'components/feedback/hint.dart';
import 'components/feedback/notification.dart';
import 'components/form_elements/checkbox.dart';
import 'components/form_elements/form.dart';
import 'components/form_elements/input.dart';
import 'components/form_elements/reactive_form.dart';
import 'components/interaction/breadcrumb.dart';
import 'components/layout/accordion.dart';
import 'components/layout/divider.dart';
import 'window/app_scaffold.dart';

final projectRouteConfig = LdMonkeyRouteConfig.identifiableInt<Project>(itemName: "project");

const projectMasterPath = "/projects";

final fileRouteConfig = LdMonkeyRouteConfig.identifiableString<File>(itemName: "file");

class AppRouter {
  AppRouter();

  late final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: "/",
    redirect: ldLocationLockRedirect,
    routes: [
      GoRoute(
        path: "/nav-test",
        pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const NavTest()),
      ),

      GoRoute(
        path: "/components/appbar",
        pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const AppBarDemo()),
      ),
      ShellRoute(
        pageBuilder: (context, state, child) => NoTransitionPage<void>(
          key: state.pageKey,
          child: AppScaffold(title: const Text("Liquid Flutter"), state: state, child: child),
        ),

        routes: [
          GoRoute(
            path: "/chemical",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const ChemicalScreen()),
          ),

          ...buildMonkeyRoutes<Task, int>(
            masterPath: "/task-demo",
            routeConfig: taskRouteConfig,
            sortOptionsBuilder: (_) async => taskSortOptions,
            actions: taskActions,
            filtersBuilder: (_) async => taskFilters,
            detailPage: TaskDetailPage(),
            createPage: const TaskCreatePage(),
            masterPage: TaskMasterPage(),
            modelBuilder: (context, state) => taskModel(context),
            reorderHandler: taskReorderHandler,
          ),

          ...buildMonkeyRoutes<MovieDemo, int>(
            masterPath: "/movie-demo",
            routeConfig: LdMonkeyRouteConfig.identifiableInt<MovieDemo>(itemName: "movie"),
            sortOptionsBuilder: (_) async => [],
            actions: movieActions,
            filtersBuilder: buildMovieFilters,
            detailPage: MovieDetailPage(),
            detailInDialog: true,
            masterPage: MovieMasterPage(),
            modelBuilder: (context, state) => movieModel(context),
          ),

          ...buildMonkeyRouteTree<Project, int>(
            masterPath: projectMasterPath,
            root: MonkeyRouteNode<Project, int>(
              routeConfig: projectRouteConfig,
              masterPage: ProjectMasterPage(),
              detailPage: FileMasterPage(),
              modelBuilder: (context, state) => projectModel(),
              filtersBuilder: (_) async => [],
              sortOptionsBuilder: (_) async => [],
              actions: const [],
              child: MonkeyRouteNode<File, String>(
                detailPathPrefix: 'files',
                routeConfig: fileRouteConfig,
                masterPage: FileMasterPage(),
                detailPage: FileDetailPage(),
                modelBuilder: (context, state) =>
                    fileModel(state.pathParameters[projectRouteConfig.viewingParamName]!),
                filtersBuilder: (_) async => [],
                sortOptionsBuilder: (_) async => [],
                actions: const [],
              ),
            ),
          ),

          GoRoute(
            path: "/",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const Home()),
          ),
          GoRoute(
            path: "/theme",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const ThemeDemo()),
          ),
          GoRoute(
            path: "/layout",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const LayoutDocumentation()),
          ),
          GoRoute(
            path: "/radius",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const RadiusDocumentation()),
          ),
          GoRoute(
            path: "/typography",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const TypographyDocumentation()),
          ),
          GoRoute(
            path: "/material",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const MaterialDocumentation()),
          ),
          GoRoute(
            path: "/patterns/monkey",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: MonkeyDemo()),
          ),
          GoRoute(
            path: "/patterns/monkey/repository",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const MonkeyRepositoryDemo()),
          ),
          GoRoute(
            path: "/patterns/monkey/pattern",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const MonkeyPatternDemo()),
          ),
          GoRoute(
            path: "/patterns/monkey/actions",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const MonkeyActionsDemo()),
          ),
          GoRoute(
            path: "/patterns/monkey/sorting-filtering",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const MonkeySortingFilteringDemo()),
          ),
          GoRoute(
            path: "/patterns/monkey/detail-edit",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const MonkeyDetailEditDemo()),
          ),
          GoRoute(
            path: "/components/button",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const ButtonDemo()),
          ),
          GoRoute(
            path: "/components/card",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const CardDemo()),
          ),
          GoRoute(
            path: "/components/action-runner",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const ActionRunnerDemo()),
          ),
          GoRoute(
            path: "/components/choose",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const ChooseDemo()),
          ),
          GoRoute(
            path: "/components/drawer",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const DrawerDemo()),
          ),
          GoRoute(
            path: "/components/multi-panel-layout",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const MultiPanelLayoutDemo()),
          ),
          GoRoute(
            path: "/components/toggle",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const ToggleDemo()),
          ),
          GoRoute(
            path: "/components/slider",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const LdSliderDemo()),
          ),
          GoRoute(
            path: "/components/value-slider",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const LdValueSliderDemo()),
          ),
          GoRoute(
            path: "/components/switch",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const SwitchDemo()),
          ),
          GoRoute(
            path: "/components/select",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const SelectDemo()),
          ),
          GoRoute(
            path: "/components/badge",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const BadgeDemo()),
          ),
          GoRoute(
            path: "/components/breadcrumb",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const BreadcrumbDemo()),
          ),
          GoRoute(
            path: "/components/checkbox",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const CheckboxDemo()),
          ),
          GoRoute(
            path: "/components/context-menu",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const ContextMenuDemo()),
          ),
          GoRoute(
            path: "/components/date-time-picker",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const DateTimePickerDemo()),
          ),
          GoRoute(
            path: "/components/divider",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const DividerDemo()),
          ),
          GoRoute(
            path: "/components/exception",
            pageBuilder: (context, state) {
              return NoTransitionPage<void>(key: state.pageKey, child: const ExceptionDemo());
            },
          ),
          GoRoute(
            path: "/components/form",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const FormDemo()),
          ),
          GoRoute(
            path: "/components/reactive_form",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const ReactiveFormDemo()),
          ),
          GoRoute(
            path: "/components/orb",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const OrbDemo()),
          ),
          GoRoute(
            path: "/components/speed-reader",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const SpeedReaderDemo()),
          ),
          GoRoute(
            path: "/components/loader",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const LoaderDemo()),
          ),
          GoRoute(
            path: "/components/reveal",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const LdRevealDemo()),
          ),
          GoRoute(
            path: "/components/radio",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const RadioDemo()),
          ),
          GoRoute(
            path: "/components/hint",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const HintDemo()),
          ),
          GoRoute(
            path: "/components/avatar",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const AvatarDemo()),
          ),
          GoRoute(
            path: "/components/icon",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const IconDemo()),
          ),
          GoRoute(
            path: "/components/indicator",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const IndicatorDemo()),
          ),
          GoRoute(
            path: "/components/accordion",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const AccordionDemo()),
          ),
          GoRoute(
            path: "/components/autospace",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const AutoSpaceDemo()),
          ),
          GoRoute(
            path: "/components/input",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const InputDemo()),
          ),
          GoRoute(
            path: "/components/spring",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const Spring()),
          ),
          GoRoute(
            path: "/components/notification",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const NotificationDemo()),
          ),
          GoRoute(
            path: "/components/submit",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const SubmitDemo()),
          ),
          GoRoute(
            path: "/components/modal",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const ModalDemo()),
            routes: [
              GoRoute(
                path: "my-modal",
                pageBuilder: (context, state) => LdModalPage(
                  builder: (context) => LdModalRoute(
                    context: context,
                    pageBuilder: (context) => LdScaffold(
                      body: LdAppBar(
                        title: const Text("This is a title"),
                        child: LdScaffoldBody(children: [LdText("This is modal content")]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: "/components/table",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const TableDemo()),
          ),
          GoRoute(
            path: "/components/counter",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const CounterDemo()),
          ),
          GoRoute(
            path: "/components/tag",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const TagDemo()),
          ),
          GoRoute(
            path: "/components/tab",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const TabsDemo()),
          ),
          GoRoute(
            path: "/components/list",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const ListDemo()),
          ),
          GoRoute(
            path: "/components/list-item",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const ListItemDemo()),
          ),
          GoRoute(
            path: "/components/selectable-list",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const SelectableListDemo()),
          ),
          GoRoute(
            path: "/components/bento-gallery",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const BentoGallery()),
          ),
          GoRoute(
            path: "/components/markdown",
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const MarkdownDemo()),
          ),
        ],
      ),
    ],
  );
}

class NavTest extends StatelessWidget {
  const NavTest({super.key});

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      drawer: LdScaffold(
        body: LdAppBar(
          title: Text("Drawer"),
          child: LdButton(child: Text("Pop"), onPressed: () => context.pop()),
        ),
      ),
      body: LdAppBar(title: Text("Nav Test"), child: LdText("Nav Test")),
    );
  }
}
