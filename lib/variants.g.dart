import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdCheckboxSuccess extends LdCheckbox {
  LdCheckboxSuccess({
    String? label,
    required bool checked,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    LdSize size = LdSize.s,
    bool disabled = false,
    Key? key,
    required BuildContext context,
  }) : super(
            label: label,
            checked: checked,
            onChanged: onChanged,
            color: LdTheme.of(context).success,
            size: size,
            disabled: disabled,
            key: key);
}

class LdCheckboxWarning extends LdCheckbox {
  LdCheckboxWarning({
    String? label,
    required bool checked,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    LdSize size = LdSize.s,
    bool disabled = false,
    Key? key,
    required BuildContext context,
  }) : super(
            label: label,
            checked: checked,
            onChanged: onChanged,
            color: LdTheme.of(context).warning,
            size: size,
            disabled: disabled,
            key: key);
}

class LdCheckboxError extends LdCheckbox {
  LdCheckboxError({
    String? label,
    required bool checked,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    LdSize size = LdSize.s,
    bool disabled = false,
    Key? key,
    required BuildContext context,
  }) : super(
            label: label,
            checked: checked,
            onChanged: onChanged,
            color: LdTheme.of(context).error,
            size: size,
            disabled: disabled,
            key: key);
}

class LdButtonGhost extends LdButton {
  const LdButtonGhost({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
  }) : super(
            child: child,
            onPressed: onPressed,
            autoLoading: autoLoading,
            borderRadius: borderRadius,
            color: color,
            active: active,
            width: width,
            disabled: disabled,
            focusNode: focusNode,
            autoFocus: autoFocus,
            alignment: alignment,
            leading: leading,
            circular: circular,
            loading: loading,
            loadingText: loadingText,
            errorText: errorText,
            mode: LdButtonMode.ghost,
            progress: progress,
            size: size,
            trailing: trailing,
            key: key);
}

class LdButtonVague extends LdButton {
  const LdButtonVague({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
  }) : super(
            child: child,
            onPressed: onPressed,
            autoLoading: autoLoading,
            borderRadius: borderRadius,
            color: color,
            active: active,
            width: width,
            disabled: disabled,
            focusNode: focusNode,
            autoFocus: autoFocus,
            alignment: alignment,
            leading: leading,
            circular: circular,
            loading: loading,
            loadingText: loadingText,
            errorText: errorText,
            mode: LdButtonMode.vague,
            progress: progress,
            size: size,
            trailing: trailing,
            key: key);
}

class LdButtonOutline extends LdButton {
  const LdButtonOutline({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
  }) : super(
            child: child,
            onPressed: onPressed,
            autoLoading: autoLoading,
            borderRadius: borderRadius,
            color: color,
            active: active,
            width: width,
            disabled: disabled,
            focusNode: focusNode,
            autoFocus: autoFocus,
            alignment: alignment,
            leading: leading,
            circular: circular,
            loading: loading,
            loadingText: loadingText,
            errorText: errorText,
            mode: LdButtonMode.outline,
            progress: progress,
            size: size,
            trailing: trailing,
            key: key);
}

class LdButtonFilled extends LdButton {
  const LdButtonFilled({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
  }) : super(
            child: child,
            onPressed: onPressed,
            autoLoading: autoLoading,
            borderRadius: borderRadius,
            color: color,
            active: active,
            width: width,
            disabled: disabled,
            focusNode: focusNode,
            autoFocus: autoFocus,
            alignment: alignment,
            leading: leading,
            circular: circular,
            loading: loading,
            loadingText: loadingText,
            errorText: errorText,
            mode: LdButtonMode.filled,
            progress: progress,
            size: size,
            trailing: trailing,
            key: key);
}

class LdButtonWarning extends LdButton {
  LdButtonWarning({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
    required BuildContext context,
  }) : super(
            child: child,
            onPressed: onPressed,
            autoLoading: autoLoading,
            borderRadius: borderRadius,
            color: LdTheme.of(context).warning,
            active: active,
            width: width,
            disabled: disabled,
            focusNode: focusNode,
            autoFocus: autoFocus,
            alignment: alignment,
            leading: leading,
            circular: circular,
            loading: loading,
            loadingText: loadingText,
            errorText: errorText,
            mode: mode,
            progress: progress,
            size: size,
            trailing: trailing,
            key: key);
}

class LdButtonError extends LdButton {
  LdButtonError({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
    required BuildContext context,
  }) : super(
            child: child,
            onPressed: onPressed,
            autoLoading: autoLoading,
            borderRadius: borderRadius,
            color: LdTheme.of(context).error,
            active: active,
            width: width,
            disabled: disabled,
            focusNode: focusNode,
            autoFocus: autoFocus,
            alignment: alignment,
            leading: leading,
            circular: circular,
            loading: loading,
            loadingText: loadingText,
            errorText: errorText,
            mode: mode,
            progress: progress,
            size: size,
            trailing: trailing,
            key: key);
}

class LdButtonSuccess extends LdButton {
  LdButtonSuccess({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
    required BuildContext context,
  }) : super(
            child: child,
            onPressed: onPressed,
            autoLoading: autoLoading,
            borderRadius: borderRadius,
            color: LdTheme.of(context).success,
            active: active,
            width: width,
            disabled: disabled,
            focusNode: focusNode,
            autoFocus: autoFocus,
            alignment: alignment,
            leading: leading,
            circular: circular,
            loading: loading,
            loadingText: loadingText,
            errorText: errorText,
            mode: mode,
            progress: progress,
            size: size,
            trailing: trailing,
            key: key);
}

class LdRadioSuccess extends LdRadio {
  LdRadioSuccess({
    String? label,
    required bool checked,
    LdSize size = LdSize.s,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    bool disabled = false,
    Key? key,
    required BuildContext context,
  }) : super(
            label: label,
            checked: checked,
            size: size,
            onChanged: onChanged,
            color: LdTheme.of(context).success,
            disabled: disabled,
            key: key);
}

class LdRadioWarning extends LdRadio {
  LdRadioWarning({
    String? label,
    required bool checked,
    LdSize size = LdSize.s,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    bool disabled = false,
    Key? key,
    required BuildContext context,
  }) : super(
            label: label,
            checked: checked,
            size: size,
            onChanged: onChanged,
            color: LdTheme.of(context).warning,
            disabled: disabled,
            key: key);
}

class LdRadioError extends LdRadio {
  LdRadioError({
    String? label,
    required bool checked,
    LdSize size = LdSize.s,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    bool disabled = false,
    Key? key,
    required BuildContext context,
  }) : super(
            label: label,
            checked: checked,
            size: size,
            onChanged: onChanged,
            color: LdTheme.of(context).error,
            disabled: disabled,
            key: key);
}

class LdTagSuccess extends LdTag {
  LdTagSuccess({
    Key? key,
    required Widget child,
    LdColor? color,
    Function? onDismiss,
    LdSize size = LdSize.m,
    required BuildContext context,
  }) : super(
            key: key,
            child: child,
            color: LdTheme.of(context).success,
            onDismiss: onDismiss,
            size: size);
}

class LdTagWarning extends LdTag {
  LdTagWarning({
    Key? key,
    required Widget child,
    LdColor? color,
    Function? onDismiss,
    LdSize size = LdSize.m,
    required BuildContext context,
  }) : super(
            key: key,
            child: child,
            color: LdTheme.of(context).warning,
            onDismiss: onDismiss,
            size: size);
}

class LdTagError extends LdTag {
  LdTagError({
    Key? key,
    required Widget child,
    LdColor? color,
    Function? onDismiss,
    LdSize size = LdSize.m,
    required BuildContext context,
  }) : super(
            key: key,
            child: child,
            color: LdTheme.of(context).error,
            onDismiss: onDismiss,
            size: size);
}

class LdTextP extends LdText {
  const LdTextP(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: size,
            type: LdTextType.paragraph,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextPl extends LdText {
  const LdTextPl(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: LdSize.l,
            type: LdTextType.paragraph,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextPs extends LdText {
  const LdTextPs(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: LdSize.s,
            type: LdTextType.paragraph,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextPxs extends LdText {
  const LdTextPxs(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: LdSize.xs,
            type: LdTextType.paragraph,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextHl extends LdText {
  const LdTextHl(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: LdSize.l,
            type: LdTextType.headline,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextH extends LdText {
  const LdTextH(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: LdSize.m,
            type: LdTextType.headline,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextHs extends LdText {
  const LdTextHs(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: LdSize.s,
            type: LdTextType.headline,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextHxs extends LdText {
  const LdTextHxs(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: LdSize.xs,
            type: LdTextType.headline,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextL extends LdText {
  const LdTextL(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: size,
            type: LdTextType.label,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextLs extends LdText {
  const LdTextLs(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: LdSize.s,
            type: LdTextType.label,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextLl extends LdText {
  const LdTextLl(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: LdSize.l,
            type: LdTextType.label,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextLxs extends LdText {
  const LdTextLxs(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: LdSize.xs,
            type: LdTextType.label,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdTextCaption extends LdText {
  const LdTextCaption(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    LdSize size = LdSize.m,
    LdTextType? type = LdTextType.paragraph,
    void Function(String)? onLinkTap,
    FontWeight? fontWeight,
    double? lineHeight,
    bool processLinks = false,
    Color? color,
  }) : super(text,
            key: key,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            decoration: decoration,
            size: size,
            type: LdTextType.caption,
            onLinkTap: onLinkTap,
            fontWeight: fontWeight,
            lineHeight: lineHeight,
            processLinks: processLinks,
            color: color);
}

class LdBadgeSuccess extends LdBadge {
  LdBadgeSuccess({
    required Widget child,
    LdColor? color,
    LdSize size = LdSize.m,
    bool symmetric = false,
    int? maxLines = 1,
    Key? key,
    required BuildContext context,
  }) : super(
            child: child,
            color: LdTheme.of(context).success,
            size: size,
            symmetric: symmetric,
            maxLines: maxLines,
            key: key);
}

class LdBadgeWarning extends LdBadge {
  LdBadgeWarning({
    required Widget child,
    LdColor? color,
    LdSize size = LdSize.m,
    bool symmetric = false,
    int? maxLines = 1,
    Key? key,
    required BuildContext context,
  }) : super(
            child: child,
            color: LdTheme.of(context).warning,
            size: size,
            symmetric: symmetric,
            maxLines: maxLines,
            key: key);
}

class LdBadgeError extends LdBadge {
  LdBadgeError({
    required Widget child,
    LdColor? color,
    LdSize size = LdSize.m,
    bool symmetric = false,
    int? maxLines = 1,
    Key? key,
    required BuildContext context,
  }) : super(
            child: child,
            color: LdTheme.of(context).error,
            size: size,
            symmetric: symmetric,
            maxLines: maxLines,
            key: key);
}
