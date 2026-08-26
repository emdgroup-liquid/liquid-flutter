---
name: liquid_flutter-design
description: Use when building UI with Liquid Flutter components — covers layout, text, forms, lists, modals, primary navigation (tabs/rail), spacing, colors, typography, and common UI patterns.
---

# Liquid Flutter Design System

## Overview
The Liquid Flutter design system provides a comprehensive set of components and utilities for building consistent, beautiful Flutter applications. This guide helps agents quickly understand and apply the design system effectively.

## Core Components for General Tasks

### Layout Components
- **LdScaffold**: Main page scaffold with drawer support. Wrap the body with `LdAppBar` to add app bars. Use `drawer` / `drawerWidth` / `drawerMinWidth` when hosting a side panel (e.g. a rail).
- **LdAppBar**: App bar that wraps its `child`. Use `LdAppBar.top` / `LdAppBar.bottom` or nest bars for multiple edges.
- **LdScaffoldBody**: Body wrapper for scaffold content. Use `addContainer: true` for automatic container padding.
- **LdAutoSpace**: Automatically spaces children in a Column based on component types. Use for arranging items vertically with proper spacing.
- **LdBundle**: Wrapper that applies LdAutoSpace to its children. Use for grouping related content.
- **LdCard**: Card component with optional header/footer. When placing LdListItems in a Card, set `padding: EdgeInsets.zero` and use a Column.
- **LdContainer**: Container component with theme-aware styling.

### Navigation Components
- **LdNavigationTab**: Shared primary destination model (`label`, `icon`, `route`, optional `isActive`). Use the same list for bottom tabs and the side rail. Call `matches(context, activeRoute)` for highlight state (`*` wildcard suffix or custom `isActive`).
- **LdTabNavigation**: Horizontal tab bar (typically bottom on mobile). Pass `List<LdNavigationTab>`, `activeRoute` (or `pageController`), and `onTabPressed`. Wraps `child` like an app bar edge.
- **LdNavigationRail**: Vertical primary nav for `LdScaffold.drawer`. Same `LdNavigationTab` destinations. Width-responsive: compact square icon-over-label tiles when narrow; icon beside label when at/above `extendedBreakpoint` (default `LdNavigationRail.defaultExtendedBreakpoint`). Use `LdNavigationRail.defaultWidth` / `defaultMinWidth` with scaffold `drawerWidth` / `drawerMinWidth`. Optional `leading` / `trailing`.
- **LdDrawerItemSection** / **LdSectionHeader**: Hierarchical drawer content (nested sections, search-heavy nav). Prefer these for deep trees; prefer `LdNavigationRail` for flat primary destinations.

**App-owned chrome switch:** The app chooses tabs vs rail (e.g. mobile → `LdTabNavigation`, desktop → drawer + `LdNavigationRail`). Scaffold does not auto-switch.

### Text Components
- **LdText**: Primary text component. Use factory constructors:
  - `LdText.h()` / `LdText.hl()` / `LdText.hs()` / `LdText.hxs()` - Headlines (large, large, small, extra-small)
  - `LdText.p()` - Paragraphs (body text)
  - `LdText.l()` / `LdText.ls()` / `LdText.lxs()` - Labels (medium, small, extra-small)
  - `LdText.caption()` - Caption text (uppercase, muted)
- **Rule**: Always use LdText for labels and paragraphs unless the text is a child of another UI component like a button.

### Form Components
- **LdInput**: Text input field
- **LdButton**: Button component with variants
  - Mode variants: `LdButton.filled`, `LdButton.outline`, `LdButton.ghost`, `LdButton.vague`
    - To build an icon button you can simply pass an icon as child.
  - Color variants: `LdButton.warning`, `LdButton.error`, `LdButton.success`
- **LdCheckbox**: Checkbox input
- **LdRadio**: Radio button input
- **LdSwitch**: Toggle switch
- **LdSelect**: Dropdown select
- **LdSlider**: Slider input
- **LdDatePicker**: Date picker
- **LdTimePicker**: Time picker
- **LdDurationPicker**: Duration picker (`LdDuration`, ISO 8601)

### List Components
- **LdList**: List container
- **LdListItem**: List item component. When placing in LdCard, set Card padding to 0 and use Column.
- **LdListEmpty**: Empty state for lists
- **LdListItemLoading**: Loading state for lists (note: the class is `LdListItemLoading`, not `LdListLoading`)

### Feedback Components
- **LdNotification**: Notification component
- **LdHint**: Hint/info component
- **LdLoading**: Loading indicator
- **LdExceptionView**: Error/exception display

### Modal/Dialog Components
- **LdModalRoute**: Use for dialogs, modals, and sheets. Provides consistent modal behavior. Renders as a bottom sheet on narrow screens automatically.

### Other Common Components
- **LdBadge**: Badge component
- **LdTag**: Tag component
- **LdAvatar**: Avatar component, also used to place leading icons or initials in LdListItems
- **LdDivider**: Divider component
- **LdAccordion**: Accordion/collapsible component
- **LdBreadcrumb**: Breadcrumb navigation
- **LdTable**: Table component

## Spacing

### Padding
Apply padding using extension methods on Widget:
- `.padXS()` / `.padS()` / `.padM()` / `.padL()` - Symmetric padding (all sides)
- `.pad(LdSize.size)` - Custom size symmetric padding
- `.padBalXs()` / `.padBalS()` / `.padBalM()` / `.padBalL()` - Balanced padding (horizontal stronger than vertical)
- `.padBal(LdSize.size)` - Custom size balanced padding
- `.padVertical({size: LdSize.m})` - Vertical padding only
- `.padHorizontal({size: LdSize.m})` - Horizontal padding only
- `.insetLeft()` / `.insetRight()` / `.insetTop()` / `.insetBottom()` - Single side padding

**Alternative**: Use `LdTheme.of(context).pad(size)` method:
```dart
LdTheme.of(context).pad(size: LdSize.m)  // Returns EdgeInsets (named parameter)
LdTheme.of(context).balPad(LdSize.m)  // Returns balanced EdgeInsets (positional parameter)
```

### Spacers
Use spacer constants for spacing between widgets:
- `ldSpacerXS` / `ldSpacerS` / `ldSpacerM` / `ldSpacerL` - General spacers
- `ldHSpacerXS` / `ldHSpacerS` / `ldHSpacerM` / `ldHSpacerL` - Horizontal spacers
- `ldVSpacerXS` / `ldVSpacerS` / `ldVSpacerM` / `ldVSpacerL` - Vertical spacers

**Rule**: When arranging items in a Column, unless you require no spacing, use `LdAutoSpace()` which automatically applies appropriate spacing based on component types.

### Row/Column Spacing
For Row and Column widgets, use extension methods:
- `.spaceS()` / `.spaceM()` / `.spaceL()` - Applies spacing between children (available on both `Row` and `Column`)
- `.spaceXS()` - Available on `Row` only (not on `Column`)

## Text Usage

### When to Use LdText
- **Always** use LdText for standalone labels and paragraphs
- **Exception**: Don't use LdText when text is a child of another UI component (e.g., button labels)

### Text Shorthands
- `LdText.p()` - For paragraphs/body text
- `LdText.l()` - For labels
- `LdText.h()` - For headlines

### Example
```dart
LdAutoSpace(
  children: [
    LdText.h("Page Title"),
    LdText.p("This is paragraph text"),
    LdText.l("Label Text"),
    LdButton(
      child: Text("Button"), // OK - child of button
    ),
  ],
)
```

## Colors

### Retrieving Colors from Theme
Access colors via `LdTheme.of(context)`:

**Semantic Colors:**
- `theme.text` - Default text color
- `theme.textMuted` - Muted text color
- `theme.background` - Page background color
- `theme.surface` - Surface/elevated background color
- `theme.border` - Border color
- `theme.floatingBorder` - Floating element border color
- `theme.stroke` - Stroke color

**Primary Colors:**
- `theme.primaryColor` - Primary color
- `theme.primaryColorText` - Contrasting text for primary
- `theme.secondaryColor` - Secondary color
- `theme.secondaryColorText` - Contrasting text for secondary

**State Colors:**
- `theme.errorColor` / `theme.errorColorText` - Error state
- `theme.successColor` / `theme.successColorText` - Success state
- `theme.warningColor` / `theme.warningColorText` - Warning state

**Neutral Shades:**
- `theme.neutralShade(int shade)` - Get neutral shade (0-10, where 0 is lightest, 10 is darkest)

**Color Names:**
- `theme.primary` - Returns LdColor name
- `theme.secondary` - Returns LdColor name
- `theme.success` - Returns LdColor name
- `theme.warning` - Returns LdColor name
- `theme.error` - Returns LdColor name

### Example
```dart
Container(
  color: LdTheme.of(context).surface,
  child: LdText.p(
    "Text",
    color: LdTheme.of(context).text,
  ),
)
```

## Border Radius

Apply border radius using:
- `LdTheme.of(context).radius(LdSize.size)` - Returns BorderRadius
- `LdTheme.of(context).radiusSize(LdSize.size)` - Returns double

Available sizes: `LdSize.xs`, `LdSize.s`, `LdSize.m`, `LdSize.l`

### Example
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: LdTheme.of(context).radius(LdSize.m),
  ),
)
```

## Common Patterns

### Scaffold with AppBar
```dart
LdScaffold(
  body: LdAppBar.top(
    title: Text("Page Title"),
    child: LdScaffoldBody(
      addContainer: true,
      children: [
        // Content here
      ],
    ),
  ),
)
```

Note: `LdAppBar` wraps the body as a parent widget (`child:` parameter). The deprecated `appBars: [...]` list API is no longer used.

### Primary navigation: tabs vs rail
Share one `List<LdNavigationTab>` and pick chrome per platform/breakpoint:

```dart
final tabs = [
  LdNavigationTab(label: 'Home', icon: Icon(LucideIcons.house), route: '/home'),
  LdNavigationTab(label: 'Search', icon: Icon(LucideIcons.search), route: '/search'),
];

// Desktop / wide: rail in the resizable drawer
LdScaffold(
  drawerWidth: LdNavigationRail.defaultWidth,
  drawerMinWidth: LdNavigationRail.defaultMinWidth,
  drawer: LdNavigationRail(
    destinations: tabs,
    activeRoute: route,
    onDestinationSelected: go,
  ),
  body: content,
)

// Mobile: bottom tab bar wrapping body
LdScaffold(
  body: LdTabNavigation(
    tabs: tabs,
    activeRoute: route,
    onTabPressed: go,
    child: content,
  ),
)
```

Resizing the drawer reflows the rail (compact square tiles ↔ extended row). For hierarchical drawers with sections/search, use `LdDrawerItemSection` instead of the rail.

### Card with ListItems
```dart
LdCard(
  padding: EdgeInsets.zero, // Important: zero padding
  child: Column(
    children: [
      LdListItem(...),
      LdListItem(...),
    ],
  ),
)
```

### Modal/Dialog
```dart
// Use LdModalRoute for navigation-based modals
LdModalRoute(
  context: context,
  pageBuilder: (context) => LdScaffold(),
)
```

### Auto-Spaced Column
```dart
LdAutoSpace(
  children: [
    LdText.h("Title"),
    LdText.p("Description"),
    LdButton(...),
    ldSpacerM, // Manual spacer if needed
    LdCard(...),
  ],
)
```

### Navigation to Sub-Screens
To build a screen that navigates to sub-screens, place the links to sub pages in `LdListItem.trailingForward` and group them in an `LdCard`. Add a group name using `LdText.caption` above the `LdCard`.

## Size System

The design system uses `LdSize` enum:
- `LdSize.xs` - Extra small
- `LdSize.s` - Small
- `LdSize.m` - Medium (default)
- `LdSize.l` - Large

Most components accept a `size` parameter using `LdSize`.

## Icons

Prefer Lucide icons over `Icons` / `CupertinoIcons` where applicable. The `lucide_icons_flutter` package is a dependency of `liquid_flutter`.

## Best Practices

1. **Always use LdAutoSpace** for Columns unless you specifically need no spacing
2. **Use LdText** for all standalone text, except when inside other components
3. **Apply padding** using extension methods (`.padM()`) or `LdTheme.of(context).pad()`
4. **Use spacer constants** (`ldSpacerM`) for manual spacing when needed
5. **Set Card padding to zero** when containing ListItems
6. **Use LdScaffold with LdAppBar wrapping the body** for page structure
7. **Use LdModalRoute** for dialogs, modals, and sheets
8. **Retrieve colors** from `LdTheme.of(context)` rather than hardcoding
9. **Apply radius** using `LdTheme.of(context).radius()` for consistency
10. **Use Lucide icons** wherever possible instead of the default Icons or CupertinoIcons
11. **Primary nav**: Reuse `LdNavigationTab` for both `LdTabNavigation` and `LdNavigationRail`; app chooses which chrome to show. Use `drawerMinWidth: LdNavigationRail.defaultMinWidth` when the drawer hosts a rail.
