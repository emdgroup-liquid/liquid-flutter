import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/chemical_screen.dart';
import 'package:liquid/components/layout/autospace.dart';
import 'package:liquid/components/interaction/button.dart';
import 'package:liquid/components/layout/card.dart';
import 'package:liquid/components/form_elements/choose.dart';
import 'package:liquid/components/interaction/context_menu.dart';
import 'package:liquid/components/form_elements/date_time_pickers.dart';
import 'package:liquid/components/layout/drawer.dart';
import 'package:liquid/components/feedback/exception.dart';
import 'package:liquid/components/data_display/icon.dart';
import 'package:liquid/components/feedback/indicator.dart';
import 'package:liquid/components/layout/list.dart';
import 'package:liquid/components/layout/list_full_screen.dart';
import 'package:liquid/components/feedback/loader.dart';
import 'package:liquid/components/layout/list_item.dart';
import 'package:liquid/components/layout/master_detail.dart';
import 'package:liquid/components/layout/selectable_list.dart';
import 'package:liquid/components/material.dart';
import 'package:liquid/components/interaction/modal.dart';
import 'package:liquid/components/interaction/orb.dart';
import 'package:liquid/components/form_elements/radio.dart';
import 'package:liquid/components/feedback/reveal.dart';
import 'package:liquid/components/interaction/action_runner.dart';
import 'package:liquid/components/form_elements/select.dart';
import 'package:liquid/components/form_elements/slider.dart';
import 'package:liquid/components/layout/spring.dart';
import 'package:liquid/components/form_elements/submit.dart';
import 'package:liquid/components/form_elements/switch.dart';
import 'package:liquid/components/tab.dart';
import 'package:liquid/components/form_elements/toggle.dart';
import 'package:liquid/demos/layout_documentation.dart';
import 'package:liquid/demos/radius_documentation.dart';
import 'package:liquid/demos/task_demo.dart';
import 'package:liquid/demos/theme.dart';
import 'package:liquid/demos/typography_documentation.dart';
import 'package:liquid/home.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'components/layout/accordion.dart';
import 'components/feedback/badge.dart';
import 'components/interaction/breadcrumb.dart';
import 'components/form_elements/checkbox.dart';
import 'components/layout/divider.dart';
import 'components/form_elements/form.dart';
import 'components/feedback/hint.dart';
import 'components/form_elements/input.dart';
import 'components/feedback/notification.dart';
import 'components/form_elements/reactive_form.dart';
import 'components/data_display/table.dart';
import 'components/data_display/tag.dart';
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
            path: "/components/exception",
            pageBuilder: (context, state) {
              return NoTransitionPage<void>(
                key: state.pageKey,
                child: const ExceptionDemo(),
              );
            },
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
          GoRoute(
            path: "/components/master-detail",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const MasterDetailDemo()),
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
            path: "/components/list-item",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const ListItemDemo()),
          ),
          GoRoute(
            path: "/components/selectable-list",
            pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey, child: const SelectableListDemo()),
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
          ),
          GoRoute(
              path: "/components/reactive_form",
              pageBuilder: (context, state) {
                return NoTransitionPage<void>(
                    key: state.pageKey, child: const ReactiveFormDemo());
              }),
        ]),
  ]);
}
