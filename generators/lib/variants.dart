class Variant {
  final String name;
  final bool requireContext;
  final Map<String, String> defaults;

  Variant(this.name, this.requireContext, this.defaults);
}

Map<String, List<Variant>> variants = {
  "LdButton": [
    // Shape variants
    Variant("ghost", false, {
      "mode": "LdButtonMode.ghost",
    }),
    Variant("vague", false, {
      "mode": "LdButtonMode.vague",
    }),
    Variant("outline", false, {
      "mode": "LdButtonMode.outline",
    }),
    Variant("filled", false, {
      "mode": "LdButtonMode.filled",
    }),
    // Colored
    Variant("warning", true, {
      "color": "LdTheme.of(context).warning",
    }),
    Variant("error", true, {
      "color": "LdTheme.of(context).error",
    }),
    Variant("success", true, {
      "color": "LdTheme.of(context).success",
    }),
  ],
  "LdText": [
    Variant("p", false, {
      "type": "LdTextType.paragraph",
    }),
    Variant("pl", false, {
      "type": "LdTextType.paragraph",
      "size": "LdSize.l",
    }),
    Variant("ps", false, {
      "type": "LdTextType.paragraph",
      "size": "LdSize.s",
    }),
    Variant("pxs", false, {
      "type": "LdTextType.paragraph",
      "size": "LdSize.xs",
    }),
    Variant("hl", false, {
      "type": "LdTextType.headline",
      "size": "LdSize.l",
    }),
    Variant("h", false, {
      "type": "LdTextType.headline",
      "size": "LdSize.m",
    }),
    Variant("hs", false, {
      "type": "LdTextType.headline",
      "size": "LdSize.s",
    }),
    Variant("hxs", false, {
      "type": "LdTextType.headline",
      "size": "LdSize.xs",
    }),
    Variant("l", false, {
      "type": "LdTextType.label",
    }),
    Variant("ls", false, {
      "type": "LdTextType.label",
      "size": "LdSize.s",
    }),
    Variant("ll", false, {
      "type": "LdTextType.label",
      "size": "LdSize.l",
    }),
    Variant("lxs", false, {
      "type": "LdTextType.label",
      "size": "LdSize.xs",
    }),
    Variant("caption", false, {
      "type": "LdTextType.caption",
    }),
  ],
  "LdTag": [
    Variant("success", true, {
      "color": "LdTheme.of(context).success",
    }),
    Variant("warning", true, {
      "color": "LdTheme.of(context).warning",
    }),
    Variant("error", true, {
      "color": "LdTheme.of(context).error",
    }),
  ],
  "LdBadge": [
    Variant("success", true, {
      "color": "LdTheme.of(context).success",
    }),
    Variant("warning", true, {
      "color": "LdTheme.of(context).warning",
    }),
    Variant("error", true, {
      "color": "LdTheme.of(context).error",
    }),
  ],
  "LdCheckbox": [
    Variant("success", true, {
      "color": "LdTheme.of(context).success",
    }),
    Variant("warning", true, {
      "color": "LdTheme.of(context).warning",
    }),
    Variant("error", true, {
      "color": "LdTheme.of(context).error",
    }),
  ],
  "LdRadio": [
    Variant("success", true, {
      "color": "LdTheme.of(context).success",
    }),
    Variant("warning", true, {
      "color": "LdTheme.of(context).warning",
    }),
    Variant("error", true, {
      "color": "LdTheme.of(context).error",
    }),
  ],
};
