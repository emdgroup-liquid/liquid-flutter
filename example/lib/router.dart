import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/chemical_screen.dart';
import 'package:liquid/components/autospace.dart';
import 'package:liquid/components/button.dart';
import 'package:liquid/components/card.dart';
import 'package:liquid/components/choose.dart';
import 'package:liquid/components/context_menu.dart';
import 'package:liquid/components/date_time_pickers.dart';
import 'package:liquid/components/drawer.dart';
import 'package:liquid/components/icons.dart';
import 'package:liquid/components/indicator.dart';
import 'package:liquid/components/list.dart';
import 'package:liquid/components/list_full_screen.dart';
import 'package:liquid/components/loader.dart';
import 'package:liquid/components/master_detail.dart';
import 'package:liquid/components/material.dart';
import 'package:liquid/components/modal.dart';
import 'package:liquid/components/orb.dart';
import 'package:liquid/components/radio.dart';
import 'package:liquid/components/reveal.dart';
import 'package:liquid/components/runner.dart';
import 'package:liquid/components/select.dart';
import 'package:liquid/components/slider.dart';
import 'package:liquid/components/spring.dart';
import 'package:liquid/components/submit.dart';
import 'package:liquid/components/switch.dart';
import 'package:liquid/components/tab.dart';
import 'package:liquid/components/toggle.dart';
import 'package:liquid/demos/layout_documentation.dart';
import 'package:liquid/demos/radius_documentation.dart';
import 'package:liquid/demos/task_demo.dart';
import 'package:liquid/demos/theme.dart';
import 'package:liquid/demos/typography_documentation.dart';
import 'package:liquid/home.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'components/accordion.dart';
import 'components/badge.dart';
import 'components/breadcrumb.dart';
import 'components/checkbox.dart';
import 'components/divider.dart';
import 'components/form.dart';
import 'components/hint.dart';
import 'components/input.dart';
import 'components/notification.dart';
import 'components/table.dart';
import 'components/tag.dart';
import 'window/app_scaffold.dart';

class AppRouter {
  AppRouter();

  late final router =
      GoRouter(debugLogDiagnostics: true, initialLocation: "/", routes: [
    ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(title: const Text("Liquid Flutter"), child: child);
        },
        routes: [
          GoRoute(
            path: "/",
            pageBuilder: (context, state) =>
                NoTransitionPage<void>(key: state.pageKey, child: const Home()),
          ),
          GoRoute(
            path: "/chemical",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const ChemicalScreen()),
          ),
          GoRoute(
            path: "/task-demo",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const TaskDemo()),
          ),
          GoRoute(
            path: "/theme",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const ThemeDemo()),
          ),
          GoRoute(
            path: "/layout",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const LayoutDocumentation()),
          ),
          GoRoute(
            path: "/radius",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const RadiusDocumentation()),
          ),
          GoRoute(
            path: "/typography",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const TypographyDocumentation()),
          ),
          GoRoute(
            path: "/material",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const MaterialDocumentation()),
          ),

          /*GoRoute(
            path: "/tokens",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const TokensDemo()),
          ),*/
          GoRoute(
            path: "/components/button",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const ButtonDemo()),
          ),
          GoRoute(
            path: "/components/card",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const CardDemo()),
          ),
          GoRoute(
            path: "/components/action-runner",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const ActionRunnerDemo()),
          ),
          GoRoute(
            path: "/components/choose",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const ChooseDemo()),
          ),
          GoRoute(
            path: "/components/drawer",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const DrawerDemo()),
          ),
          GoRoute(
            path: "/components/toggle",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const ToggleDemo()),
          ),
          GoRoute(
            path: "/components/slider",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const LdSliderDemo()),
          ),
          GoRoute(
            path: "/components/switch",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const SwitchDemo()),
          ),
          GoRoute(
            path: "/components/select",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const SelectDemo()),
          ),
          GoRoute(
            path: "/components/badge",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const BadgeDemo()),
          ),
          GoRoute(
            path: "/components/breadcrumb",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const BreadcrumbDemo()),
          ),
          GoRoute(
            path: "/components/checkbox",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const CheckboxDemo()),
          ),
          GoRoute(
            path: "/components/context-menu",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const ContextMenuDemo()),
          ),
          GoRoute(
            path: "/components/date-time-picker",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const DateTimePickerDemo()),
          ),
          GoRoute(
            path: "/components/divider",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const DividerDemo()),
          ),
          GoRoute(
            path: "/components/form",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const FormDemo()),
          ),
          GoRoute(
            path: "/components/orb",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const OrbDemo()),
          ),
          GoRoute(
            path: "/components/loader",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const LoaderDemo()),
          ),
          GoRoute(
            path: "/components/reveal",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const LdRevealDemo()),
          ),
          GoRoute(
            path: "/components/radio",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const RadioDemo()),
          ),
          GoRoute(
            path: "/components/hint",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const HintDemo()),
          ),
          GoRoute(
            path: "/components/icon",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const IconDemo()),
          ),
          GoRoute(
            path: "/components/indicator",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const IndicatorDemo()),
          ),
          GoRoute(
            path: "/components/accordion",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const AccordionDemo()),
          ),
          GoRoute(
            path: "/components/autospace",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const AutoSpaceDemo()),
          ),
          GoRoute(
            path: "/components/input",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const InputDemo()),
          ),
          GoRoute(
            path: "/components/spring",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const Spring()),
          ),
          LdMasterDetail.createShellRoute<int>(
            child: const MasterDetailDemo(),
            routeConfig: LdMasterDetailShellRouteConfig<int>(
              basePath: "/components/master-detail",
              detailPath: "detail/:id",
              itemProvider: (id) => int.tryParse(id),
              itemIdGetter: (item) => item.toString(),
            ),
          ),
          GoRoute(
            path: "/components/notification",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const NotificationDemo()),
          ),
          GoRoute(
            path: "/components/submit",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const SubmitDemo()),
          ),
          GoRoute(
              path: "/components/modal",
              pageBuilder: (context, state) => NoTransitionPage<void>(
                    key: state.pageKey,
                    child: const ModalDemo(),
                  ),
              routes: [
                GoRoute(
                  path: "my-modal",
                  pageBuilder: (context, state) => LdModalPage(
                    builder: LdModal(
                      title: const Text("This is a title"),
                      modalContent: (context) {
                        return const Text("This is modal content");
                      },
                    ),
                  ),
                )
              ]),
          GoRoute(
            path: "/components/table",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const TableDemo()),
          ),
          GoRoute(
            path: "/components/tag",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const TagDemo()),
          ),
          GoRoute(
            path: "/components/list",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const ListDemo()),
          ),
          GoRoute(
            path: "/components/list-full-screen",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const ListFullScreen()),
          ),
          GoRoute(
            path: "/components/tabs",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const TabsDemo()),
          )
        ]),
  ]);
}
