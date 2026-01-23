import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';

class AvatarDemo extends StatefulWidget {
  const AvatarDemo({super.key});

  @override
  State<AvatarDemo> createState() => _AvatarDemoState();
}

class _AvatarDemoState extends State<AvatarDemo> {
  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/data_display/avatar.dart",
      title: "LdAvatar",
      text:
          "Avatars are visual representations of users, entities, or content. They can display icons, text, or images and come in different sizes and shapes. Avatars can be circular or rounded square, and support various color variants including success, warning, and error states."
          " Avatars automatically adapt their appearance based on the theme and can be configured globally using LdAvatarConfigProvider for consistent styling across multiple avatars.",
      demo: LdAutoSpace(
        children: [
          ComponentWell(
            title: const Text("Default Avatar"),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LdAvatar(child: const Icon(LdIcons.user)),
                LdAvatar(child: const Text("AB")),
                LdAvatar(child: const Text("JD")),
                LdAvatar(emoji: true, child: const LdText("😊")),
              ],
            ).spaceM(),
          ),
          ComponentWell(
            title: const Text("Sizes"),
            description: const Text(
              "Passing `size: LdSize.s`, `size: LdSize.m`, or `size: LdSize.l` to the `LdAvatar` widget will change the size of the avatar.",
            ),
            child: LdAutoSpace(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LdAvatar(size: LdSize.s, child: const Icon(LdIcons.user)),
                    LdAvatar(size: LdSize.m, child: const Icon(LdIcons.user)),
                    LdAvatar(size: LdSize.l, child: const Icon(LdIcons.user)),
                  ],
                ).spaceM(),
              ],
            ),
          ),
          ComponentWell(
            title: const Text("Circular Avatars"),
            description: const Text("Passing `circular: true` to the `LdAvatar` widget will make the avatar circular."),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LdAvatar(circular: true, child: const Icon(LdIcons.user)),
                LdAvatar(circular: true, child: const Text("AB")),
                LdAvatar(circular: true, child: const Text("JD")),
              ],
            ).spaceM(),
          ),
          ComponentWell(
            title: const Text("Color Variants"),
            child: LdAutoSpace(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LdAvatar.success(child: const Icon(LdIcons.checkmark)),
                    LdAvatar.warning(child: const Icon(LdIcons.attention)),
                    LdAvatar.error(child: const Icon(LdIcons.cross)),
                  ],
                ).spaceM(),
                LdText.p("Success, Warning, and Error variants"),
              ],
            ),
          ),
          ComponentWell(
            title: const Text("Custom Colors"),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LdAvatar(color: LdTheme.of(context).primary, child: const Icon(LdIcons.user)),
                LdAvatar(color: LdTheme.of(context).secondary, child: const Text("AB")),
              ],
            ).spaceM(),
          ),
          ComponentWell(
            title: const Text("With LdAvatarConfigProvider"),
            child: LdAvatarConfigProvider(
              config: const LdAvatarConfig(size: LdSize.l, circular: true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LdAvatar(child: const Icon(LdIcons.user)),
                  LdAvatar(child: const Text("AB")),
                  LdAvatar(child: const Text("JD")),
                ],
              ).spaceM(),
            ),
          ),
        ],
      ),
    );
  }
}
