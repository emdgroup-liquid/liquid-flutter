class LdDocComponent {
  const LdDocComponent({
    required this.name,
    required this.isNullSafe,
    required this.description,
    required this.constructors,
    required this.properties,
    required this.methods,
  });

  final String name;

  final bool isNullSafe;

  final String description;

  final List<LdDocConstructor> constructors;

  final List<LdDocProperty> properties;

  final List<String> methods;
}

class LdDocProperty {
  const LdDocProperty({
    required this.name,
    required this.type,
    required this.description,
    required this.features,
  });

  final String name;

  final String type;

  final String description;

  final List<String> features;
}

class LdDocConstructor {
  const LdDocConstructor({
    required this.name,
    required this.signature,
    required this.features,
  });

  final String name;

  final List<LdDocParameter> signature;

  final List<String> features;
}

class LdDocParameter {
  const LdDocParameter({
    required this.name,
    required this.type,
    required this.description,
    required this.named,
    required this.required,
  });

  final String name;

  final String type;

  final String description;

  final bool named;

  final bool required;
}

const ldDocComponents = [
  LdDocComponent(
    name: 'LdLoader',
    isNullSafe: true,
    description: ' a loading indicator (indeterminate)',
    properties: [
      LdDocProperty(
        name: 'size',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'speed',
        type: 'Duration',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'neutral',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'neutral',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'speed',
            type: 'Duration',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdLoaderState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_animationController',
        type: 'AnimationController',
        description: '',
        features: ['late'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      'build',
    ],
  ),
  LdDocComponent(
    name: '_LoadingPainter',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'animation',
        type: 'Animation<double>',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'loaderSize',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'baseColor',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'accentColor',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'accentColor2',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'animation',
            type: 'Animation<double>',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'loaderSize',
            type: 'double',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'baseColor',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'accentColor',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'accentColor2',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      'paint',
      'shouldRepaint',
    ],
  ),
  LdDocComponent(
    name: 'LdHint',
    isNullSafe: true,
    description: ' A colored badge with an icon and a text',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'type',
        type: 'LdHintType',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'type',
            type: 'LdHintType',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdInfoIcon',
    isNullSafe: true,
    description: ' Draws an i in emd shapes',
    properties: [],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          )
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdExclamationIcon',
    isNullSafe: true,
    description: ' An exclamation icon in emd shapes',
    properties: [],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          )
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdCrossIcon',
    isNullSafe: true,
    description: ' A cross icon.',
    properties: [],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          )
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdDivider',
    isNullSafe: true,
    description: ' Divides some content with a horizontal',
    properties: [
      LdDocProperty(
        name: 'height',
        type: 'double?',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'height',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdCard',
    isNullSafe: true,
    description:
        ' A simple card component with a shadow to elevate it from the page. Header and Footer are optional and separated by color.',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'padding',
        type: 'EdgeInsets?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'header',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'footer',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'expandChild',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'flat',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'header',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'footer',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'flat',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'expandChild',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'padding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdMasterDetailBuilder',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'buildDetailTitle',
      'buildMasterTitle',
      'buildDetail',
      'buildMaster',
      'buildMasterActions',
      'buildDetailActions',
    ],
  ),
  LdDocComponent(
    name: 'LdMasterDetail',
    isNullSafe: true,
    description:
        ' A master detail view that shows a list of items on the left and a detail view on the right.\n The detail view is shown as a page or a dialog if the screen is small.',
    properties: [
      LdDocProperty(
        name: 'selectedItem',
        type: 'T?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'masterDetailFlex',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'builder',
        type: 'LdMasterDetailBuilder<T>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'navigator',
        type: 'NavigatorState?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'detailPresentationMode',
        type: 'MasterDetailPresentationMode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'layoutMode',
        type: 'MasterDetailLayoutMode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onSelectionChange',
        type: 'void Function(T?)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'customSplitPredicate',
        type: 'bool Function(SizingInformation)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'detailsUrlBuilder',
        type: 'Uri Function({T? item, required Uri uri})?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'detailsUrlParser',
        type: 'T? Function(Uri)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'builder',
            type: 'LdMasterDetailBuilder<T>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'detailPresentationMode',
            type: 'MasterDetailPresentationMode',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'layoutMode',
            type: 'MasterDetailLayoutMode',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'selectedItem',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'navigator',
            type: 'NavigatorState?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onSelectionChange',
            type: 'void Function(T?)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'masterDetailFlex',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'customSplitPredicate',
            type: 'bool Function(SizingInformation)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'detailsUrlBuilder',
            type: 'Uri Function({T? item, required Uri uri})?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'detailsUrlParser',
            type: 'T? Function(Uri)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdMasterDetailState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_selectedItem',
        type: 'T?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_inDetailView',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'useSplitView',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_navigator',
        type: 'NavigatorState',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      '_selectInitialItem',
      'didUpdateWidget',
      '_onDeselect',
      '_onSelect',
      '_onDialogDismiss',
      'onPop',
      '_didChangeSize',
      'buildMaster',
      'buildDetail',
      'buildContent',
      '_useSplitView',
      'build',
    ],
  ),
  LdDocComponent(
    name: '_DetailPage',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'builder',
        type: 'LdMasterDetailBuilder<dynamic>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'item',
        type: 'T',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'deselect',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'builder',
            type: 'LdMasterDetailBuilder<dynamic>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'item',
            type: 'T',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'deselect',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'ExpandablePageView',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'itemBuilder',
        type: 'Widget Function(BuildContext, int)',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'controller',
        type: 'PageController?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onPageChanged',
        type: 'void Function(int)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'reverse',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'itemBuilder',
            type: 'Widget Function(BuildContext, int)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'controller',
            type: 'PageController?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onPageChanged',
            type: 'void Function(int)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'reverse',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_ExpandablePageViewState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_pageController',
        type: 'PageController?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_heights',
        type: 'Map<int, double>',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_currentPage',
        type: 'int',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_currentHeight',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      'build',
      '_onSizeChange',
      '_itemBuilder',
      '_updatePage',
    ],
  ),
  LdDocComponent(
    name: 'SizeReportingWidget',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onSizeChange',
        type: 'void Function(Size)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onSizeChange',
            type: 'void Function(Size)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_SizeReportingWidgetState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_oldSize',
        type: 'Size?',
        description: '',
        features: [],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'build',
      '_notifySize',
    ],
  ),
  LdDocComponent(
    name: 'LdAppBar',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'context',
            type: 'BuildContext',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'title',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'actions',
            type: 'List<Widget>?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'leading',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'elevation',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'iconTheme',
            type: 'IconThemeData?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'primary',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'centerTitle',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'titleSpacing',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'toolbarOpacity',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'bottomOpacity',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'toolbarHeight',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'titleTextStyle',
            type: 'TextStyle?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'backgroundColor',
            type: 'Color?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'actionsIconTheme',
            type: 'IconThemeData?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'flexibleSpace',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'foregroundColor',
            type: 'Color?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'automaticallyImplyLeading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'clipBehavior',
            type: 'Clip?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'shape',
            type: 'ShapeBorder?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'toolbarTextStyle',
            type: 'TextStyle?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'leadingWidth',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'notificationPredicate',
            type: 'bool Function(ScrollNotification)',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'forceMaterialTransparency',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'scrolledUnderElevation',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'surfaceTintColor',
            type: 'Color?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'excludeHeaderSemantics',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdBreadcrumb',
    isNullSafe: true,
    description: ' A breadcrumb widget.',
    properties: [
      LdDocProperty(
        name: 'children',
        type: 'List<Widget>',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'children',
            type: 'List<Widget>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      LdDocConstructor(
        name: 'fromStrings',
        signature: [
          LdDocParameter(
            name: 'items',
            type: 'List<String>',
            description: '',
            named: false,
            required: true,
          )
        ],
        features: ['factory'],
      ),
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: '_LdPadding',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'balanced',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'balanced',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdIndicator',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'type',
        type: 'LdIndicatorType',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'customSize',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'type',
            type: 'LdIndicatorType',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'customSize',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdBadge',
    isNullSafe: true,
    description:
        ' A rounded fully opaque label with a background [color].\n Can be used to display a small amount of information.\n',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'symmetric',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'maxLines',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'symmetric',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'maxLines',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdDatePicker',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'minDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'maxDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'value',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'displayFormat',
        type: 'String',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'buttonMode',
        type: 'LdButtonMode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'useRootNavigator',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onChanged',
        type: 'void Function(DateTime?)',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_initialDate',
        type: 'DateTime',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'initialDateJiffy',
        type: 'Jiffy',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'initialDateString',
        type: 'String',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'value',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'minDate',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'maxDate',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'displayFormat',
            type: 'String',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'buttonMode',
            type: 'LdButtonMode',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onChanged',
            type: 'void Function(DateTime?)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'useRootNavigator',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: '_DatePickerSheet',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'value',
        type: 'DateTime',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onChanged',
        type: 'void Function(DateTime)',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'label',
        type: 'String',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'minDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'maxDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'dismiss',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'value',
            type: 'DateTime',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'label',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onChanged',
            type: 'void Function(DateTime)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'dismiss',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'minDate',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'maxDate',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_DatePickerSheetState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_selectedDate',
        type: 'DateTime',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: '_pageController',
        type: 'PageController?',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: '_animating',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_pageControllerIsValid',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_currentPage',
        type: 'int',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_viewDate',
        type: 'DateTime',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'showTodayButton',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'nextMonthIsValid',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'previousMonthIsValid',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'monthSince0',
      'initState',
      'didUpdateWidget',
      'dispose',
      'viewDate',
      '_buildMonthSelect',
      '_buildYearSelect',
      'isSelected',
      'containsValidDate',
      'isValidDate',
      'build',
    ],
  ),
  LdDocComponent(
    name: '_MonthView',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'viewDate',
        type: 'DateTime',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'selectedDate',
        type: 'DateTime',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onSelected',
        type: 'void Function(DateTime)',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'minDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'maxDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'viewDate',
            type: 'DateTime',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'selectedDate',
            type: 'DateTime',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onSelected',
            type: 'void Function(DateTime)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'minDate',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'maxDate',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [
      'isSameDay',
      'isToday',
      'isSelected',
      'isValidDate',
      '_buildWeekDayHeaders',
      '_buttonMode',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdSurfaceInfo',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'isSurface',
        type: 'bool',
        description: '',
        features: [],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'isSurface',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          )
        ],
        features: [],
      )
    ],
    methods: ['of'],
  ),
  LdDocComponent(
    name: 'LdAutoBackground',
    isNullSafe: true,
    description:
        ' A widget that will change its background color based on the parent surface',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'invert',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'invert',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdOrb',
    isNullSafe: true,
    description:
        ' an animated illustration of an orb filled with liquid that has some waves and a [filling] level.',
    properties: [
      LdDocProperty(
        name: 'size',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'filling',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'paintBackground',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'filling',
            type: 'double',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'size',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'paintBackground',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdOrbState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_animationController',
        type: 'AnimationController?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_tween',
        type: 'Tween<double>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_animation',
        type: 'Animation<double>?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_angle',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_streamSubscription',
        type: 'StreamSubscription<AccelerometerEvent>?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_fill',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'ReflectionPainter',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'theme',
        type: 'LdTheme',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'inset',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'orbSize',
        type: 'Size',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'theme',
            type: 'LdTheme',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'orbSize',
            type: 'Size',
            description: '',
            named: false,
            required: true,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      'shouldRepaint',
      'paint',
    ],
  ),
  LdDocComponent(
    name: '_OrbPainter',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_orbSize',
        type: 'Size',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'fillPercentage',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'paintBackground',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'animationProgress',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'theme',
        type: 'LdTheme',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'inset',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'width',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'height',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: '_orbSize',
            type: 'Size',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'fillPercentage',
            type: 'double',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'animationProgress',
            type: 'double',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'paintBackground',
            type: 'bool',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'theme',
            type: 'LdTheme',
            description: '',
            named: false,
            required: true,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      '_positionOnCircle',
      'paint',
      'shouldRepaint',
    ],
  ),
  LdDocComponent(
    name: 'LdCheckbox',
    isNullSafe: true,
    description: ' A checkbox control.',
    properties: [
      LdDocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'checked',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onChanged',
        type: 'dynamic Function(bool)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'checked',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onChanged',
            type: 'dynamic Function(bool)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdCheckboxState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'hovering',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'tapping',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdInput',
    isNullSafe: true,
    description: ' An input field',
    properties: [
      LdDocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'hint',
        type: 'String',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onChanged',
        type: 'dynamic Function(String?)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onBlur',
        type: 'dynamic Function(String?)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onSubmitted',
        type: 'dynamic Function(String?)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'controller',
        type: 'TextEditingController?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'autofillHints',
        type: 'Iterable<String>?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'obscureText',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'autofocus',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'textInputAction',
        type: 'TextInputAction?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'keyboardType',
        type: 'TextInputType?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'focusNode',
        type: 'FocusNode?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'valid',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'showClear',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'loading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'maxLines',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'minLines',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'hint',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'controller',
            type: 'TextEditingController?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'obscureText',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'maxLines',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'minLines',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'autofocus',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'showClear',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onBlur',
            type: 'dynamic Function(String?)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'valid',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'loading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'focusNode',
            type: 'FocusNode?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'autofillHints',
            type: 'Iterable<String>?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'textInputAction',
            type: 'TextInputAction?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onSubmitted',
            type: 'dynamic Function(String?)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'keyboardType',
            type: 'TextInputType?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onChanged',
            type: 'dynamic Function(String?)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdInputState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_focusNode',
        type: 'FocusNode',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: '_createdFocusNode',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_controller',
        type: 'TextEditingController',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: '_createdController',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_hovering',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'theme',
        type: 'LdTheme',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      '_onTextChange',
      '_onFocusChange',
      'cursorHeight',
      'contentPadding',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdSelectItem',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'value',
        type: 'T',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'key',
        type: 'Key?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'enabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'searchString',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'value',
            type: 'T',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'enabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'searchString',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdSelect',
    isNullSafe: true,
    description: ' a wrapper around [DropdownButton]',
    properties: [
      LdDocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'items',
        type: 'List<LdSelectItem<T>>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'placeholder',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onSurface',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'value',
        type: 'T?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'focusNode',
        type: 'FocusNode?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'valid',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onChange',
        type: 'dynamic Function(T)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'items',
            type: 'List<LdSelectItem<T>>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onChange',
            type: 'dynamic Function(T)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'placeholder',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'focusNode',
            type: 'FocusNode?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'value',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'valid',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onSurface',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdSelectState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'isOpen',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_focusNode',
        type: 'FocusNode?',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: '_controller',
        type: 'ScrollController',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      '_buildInitialItem',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdFormHint',
    isNullSafe: true,
    description: ' Hint for a form field',
    properties: [
      LdDocProperty(
        name: 'hint',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'type',
        type: 'LdHintType',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'hint',
            type: 'String',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'type',
            type: 'LdHintType',
            description: '',
            named: false,
            required: true,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdFormItem',
    isNullSafe: true,
    description: ' A form item in a [LdForm]',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'key',
        type: 'String',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'String',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: false,
            required: true,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdForm',
    isNullSafe: true,
    description: ' Liquid Design Form that wraps a [Form] widget',
    properties: [
      LdDocProperty(
        name: 'fields',
        type: 'List<LdFormItem>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'loading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'submitString',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'submitButtonMode',
        type: 'LdButtonMode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'hints',
        type: 'Map<String, LdFormHint>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onSubmit',
        type: 'Future<void> Function()?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'fields',
            type: 'List<LdFormItem>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'hints',
            type: 'Map<String, LdFormHint>',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'loading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onSubmit',
            type: 'Future<void> Function()?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'submitButtonMode',
            type: 'LdButtonMode',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'submitString',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdFormState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_loading',
        type: 'bool',
        description: '',
        features: [],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      '_buildHint',
      '_buildField',
      'didUpdateWidget',
      '_buildSubmit',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdInputColorBundle',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'backgroundIdle',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'backgroundHover',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'backgroundFocus',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'backgroundDisabled',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'borderIdle',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'borderHover',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'borderFocus',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'borderDisabled',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'textIdle',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'textHover',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'textFocus',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'textDisabled',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'placeholderIdle',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'placeholderHover',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'placeholderFocus',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'placeholderDisabled',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'iconIdle',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'iconHover',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'iconFocus',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'iconDisabled',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'backgroundIdle',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'backgroundHover',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'backgroundFocus',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'backgroundDisabled',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'borderIdle',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'borderHover',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'borderFocus',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'borderDisabled',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'textIdle',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'textHover',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'textFocus',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'textDisabled',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'placeholderIdle',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'placeholderHover',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'placeholderFocus',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'placeholderDisabled',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'iconIdle',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'iconHover',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'iconFocus',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'iconDisabled',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      ),
      LdDocConstructor(
        name: 'fromTheme',
        signature: [
          LdDocParameter(
            name: 'theme',
            type: 'LdTheme',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'onSurface',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'isValid',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['factory'],
      ),
    ],
    methods: ['fromTouchableStatus'],
  ),
  LdDocComponent(
    name: 'LdBlurringHeader',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'scrollController',
        type: 'ScrollController',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'borderRadius',
        type: 'BorderRadius?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'scrollController',
            type: 'ScrollController',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'borderRadius',
            type: 'BorderRadius?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdBlurringHeaderState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'scrollOffset',
        type: 'double',
        description: '',
        features: [],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      '_updateScrollOffset',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdCollapse',
    isNullSafe: true,
    description: ' A utility to collapse some content',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '/// Widget to collapse',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'collapsed',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'axis',
        type: 'Axis',
        description: '/// Which direction to collapse',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'collapsed',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'axis',
            type: 'Axis',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdCollapseState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_controller',
        type: 'AnimationController?',
        description: '',
        features: [],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'dispose',
      'initState',
      'build',
    ],
  ),
  LdDocComponent(
    name: '_Default',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: '_LdSizeItem',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'multiplier',
        type: 'int',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'multiplier',
            type: 'int',
            description: '',
            named: false,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdAutoSpace',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'children',
        type: 'List<Widget>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'defaultSpacing',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'crossAxisAlignment',
        type: 'CrossAxisAlignment',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'animate',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'children',
            type: 'List<Widget>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'defaultSpacing',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'crossAxisAlignment',
            type: 'CrossAxisAlignment',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'animate',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [
      '_generateSpacings',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdBundle',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'children',
        type: 'List<Widget>',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'children',
            type: 'List<Widget>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdRadio',
    isNullSafe: true,
    description: ' a radio box',
    properties: [
      LdDocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'checked',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onChanged',
        type: 'dynamic Function(bool)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'checked',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onChanged',
            type: 'dynamic Function(bool)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [
      '_onTap',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdSlider',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'onSlideComplete',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'hint',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onSlideComplete',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'hint',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdSliderState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_value',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_max',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_threshold',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_sliding',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_controller',
        type: 'AnimationController',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: '_opacityController',
        type: 'AnimationController',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: 'reachedThreshold',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      '_onDragStart',
      '_onDragUpdate',
      '_onDragEnd',
      'activeColor',
      'buildThumb',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdToggle',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'checked',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onChanged',
        type: 'dynamic Function(bool)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'checked',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onChanged',
            type: 'dynamic Function(bool)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdToggleState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_controller',
        type: 'AnimationController',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: '_theme',
        type: 'LdTheme',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_thumbSize',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_gap',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      'didUpdateWidget',
      '_updateStatus',
      '_onTap',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdMute',
    isNullSafe: true,
    description: ' LdMute allows you to use the LdTheme to make a muted text',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdTabs',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'children',
        type: 'List<Widget>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'controller',
        type: 'TabController?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'children',
            type: 'List<Widget>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'controller',
            type: 'TabController?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdTimePicker',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'useRootNavigator',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'value',
        type: 'TimeOfDay?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onChanged',
        type: 'void Function(TimeOfDay?)',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'minutePrecision',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'buttonMode',
        type: 'LdButtonMode',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'useRootNavigator',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onChanged',
            type: 'void Function(TimeOfDay?)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'buttonMode',
            type: 'LdButtonMode',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'value',
            type: 'TimeOfDay?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'minutePrecision',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdTimePickerWidget',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'minutePrecision',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'initialTime',
        type: 'TimeOfDay?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onTimeSelected',
        type: 'void Function(TimeOfDay)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'initialTime',
            type: 'TimeOfDay?',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onTimeSelected',
            type: 'void Function(TimeOfDay)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'minutePrecision',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdTimePickerWidgetState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_hourController',
        type: 'FixedExtentScrollController',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_minuteController',
        type: 'FixedExtentScrollController',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_hourFocusNode',
        type: 'FocusNode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_hourControllerText',
        type: 'TextEditingController',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_minuteControllerText',
        type: 'TextEditingController',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_time',
        type: 'TimeOfDay?',
        description: '',
        features: ['late'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      '_applyWheels',
      '_applyText',
      '_hourTextChanged',
      '_minuteTextChanged',
      '_submit',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdChoose',
    isNullSafe: true,
    description: ' A widget that presents a dropdown in a seperate page.',
    properties: [
      LdDocProperty(
        name: 'items',
        type: 'Iterable<LdSelectItem<T>>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'allowEmpty',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'mode',
        type: 'LdChooseMode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'multiple',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'value',
        type: 'Set<T>?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onChange',
        type: 'dynamic Function(Set<T>)',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'truncateDisplay',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'placeholder',
        type: 'Text?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'navigator',
        type: 'NavigatorState?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'enableSearch',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'items',
            type: 'Iterable<LdSelectItem<T>>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'allowEmpty',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'multiple',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'mode',
            type: 'LdChooseMode',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'navigator',
            type: 'NavigatorState?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onChange',
            type: 'dynamic Function(Set<T>)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'placeholder',
            type: 'Text?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'truncateDisplay',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'enableSearch',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'value',
            type: 'Set<T>?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdChooseState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_sheetKey',
        type: 'Key',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: '_enableSearch',
        type: 'bool',
        description: '',
        features: ['late'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      '_onTap',
      'build',
    ],
  ),
  LdDocComponent(
    name: '_LdChoosePage',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'label',
        type: 'String',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'label',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: '_LdChooseList',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'items',
        type: 'Iterable<LdSelectItem<T>>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'value',
        type: 'Set<T>?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'multiple',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'shrinkWrap',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onDismiss',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onChange',
        type: 'dynamic Function(Set<T>)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'enableSearch',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'allowEmpty',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'items',
            type: 'Iterable<LdSelectItem<T>>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'value',
            type: 'Set<T>?',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'multiple',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onChange',
            type: 'dynamic Function(Set<T>)?',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'allowEmpty',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onDismiss',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'shrinkWrap',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'enableSearch',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdChooseListState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_value',
        type: 'Set<T>',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_searchController',
        type: 'TextEditingController',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: '_searchResults',
        type: 'List<LdSelectItem<T>>?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_fuze',
        type: 'Fuzzy<LdSelectItem<T>>',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      '_onSearchQueryChanged',
      'initState',
      'dispose',
      '_onTap',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdFormLabel',
    isNullSafe: true,
    description:
        ' A label for a form field. This is a convenience widget that wraps a [Text]\n and [ldSpacerS]. THIS WIDGET contains outer padding.!',
    properties: [
      LdDocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'direction',
        type: 'Axis',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'direction',
            type: 'Axis',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdCol',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'title',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'sort',
        type: 'int Function(T, T)?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'weight',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'title',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'sort',
            type: 'int Function(T, T)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'weight',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdTable',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'columns',
        type: 'List<LdCol<T>>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'rows',
        type: 'List<T>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'buildRow',
        type: 'List<Widget> Function(T)',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onSelectChange',
        type: 'dynamic Function(T, bool)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'selectedRows',
        type: 'Set<T>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'allowSort',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'header',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'rowCount',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'density',
        type: 'LdTableDensity',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'columns',
            type: 'List<LdCol<T>>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'rows',
            type: 'List<T>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'buildRow',
            type: 'List<Widget> Function(T)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onSelectChange',
            type: 'dynamic Function(T, bool)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'selectedRows',
            type: 'Set<T>',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'header',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'allowSort',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'rowCount',
            type: 'int',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'density',
            type: 'LdTableDensity',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdTableState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'width',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_sortByCol',
        type: 'int',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_sortDir',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_sortedRows',
        type: 'List<T>',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: '_rowPadding',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_checkboxSize',
        type: 'LdSize',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'selectable',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      '_resort',
      '_colWidth',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdAvatar',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdText',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'text',
        type: 'String',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'textAlign',
        type: 'TextAlign?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'maxLines',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'lineHeight',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'overflow',
        type: 'TextOverflow?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'decoration',
        type: 'TextDecoration?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'fontWeight',
        type: 'FontWeight?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'color',
        type: 'Color?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'processLinks',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'type',
        type: 'LdTextType?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onLinkTap',
        type: 'void Function(String)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'text',
            type: 'String',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'textAlign',
            type: 'TextAlign?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'maxLines',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'overflow',
            type: 'TextOverflow?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'decoration',
            type: 'TextDecoration?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'type',
            type: 'LdTextType?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onLinkTap',
            type: 'void Function(String)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'fontWeight',
            type: 'FontWeight?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'lineHeight',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'processLinks',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'color',
            type: 'Color?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdReveal',
    isNullSafe: true,
    description:
        ' A utility to reveal some content, with a fade in and collapse effect',
    properties: [
      LdDocProperty(
        name: 'revealed',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'transformXOffset',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'transformYOffset',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'springConstant',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'dampingCoefficient',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'mass',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'initialRevealed',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'bufferSprings',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'revealed',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'transformXOffset',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'transformYOffset',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'initialRevealed',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'mass',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'bufferSprings',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'springConstant',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'dampingCoefficient',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      LdDocConstructor(
        name: 'quick',
        signature: [
          LdDocParameter(
            name: 'revealed',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'initialRevealed',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'transformXOffset',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'transformYOffset',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['factory'],
      ),
      LdDocConstructor(
        name: 'slow',
        signature: [
          LdDocParameter(
            name: 'revealed',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'initialRevealed',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'transformXOffset',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'transformYOffset',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['factory'],
      ),
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdButton',
    isNullSafe: true,
    description: ' A pressable button',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onPressed',
        type: 'Function',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'focusNode',
        type: 'FocusNode?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'trailing',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'leading',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'loading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'width',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'autoLoading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'progress',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'autoFocus',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'mode',
        type: 'LdButtonMode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'alignment',
        type: 'MainAxisAlignment?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'active',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'circular',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'borderRadius',
        type: 'BorderRadius?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'loadingText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'errorText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onPressed',
            type: 'Function',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'autoLoading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'borderRadius',
            type: 'BorderRadius?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'active',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'width',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'focusNode',
            type: 'FocusNode?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'autoFocus',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'alignment',
            type: 'MainAxisAlignment?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'leading',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'circular',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'loading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'loadingText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'errorText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'mode',
            type: 'LdButtonMode',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'progress',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'trailing',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdButtonState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_loading',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_failed',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_error',
        type: 'LdException?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_theme',
        type: 'LdTheme',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_child',
        type: 'Widget',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_trailing',
        type: 'Widget',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_alignment',
        type: 'MainAxisAlignment',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'centerText',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_buttonContent',
        type: 'Widget',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_leading',
        type: 'Widget',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_circular',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      '_loadingContent',
      '_onTap',
      'didUpdateWidget',
      'build',
    ],
  ),
  LdDocComponent(
    name: '_ButtonShape',
    isNullSafe: true,
    description: ' Build the button shape',
    properties: [
      LdDocProperty(
        name: 'mode',
        type: 'LdButtonMode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'colors',
        type: 'LdColorBundle',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'borderRadius',
        type: 'BorderRadius?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'center',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'width',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'circular',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'status',
        type: 'LdTouchableStatus',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'mode',
            type: 'LdButtonMode',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'colors',
            type: 'LdColorBundle',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'width',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'status',
            type: 'LdTouchableStatus',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'circular',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'center',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'borderRadius',
            type: 'BorderRadius?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [
      '_border',
      '_padding',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdSpringState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'position',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'force',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'velocity',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'isMoving',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'position',
            type: 'double',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'force',
            type: 'double',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'velocity',
            type: 'double',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'isMoving',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdSpring',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'mass',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'springConstant',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'dampingCoefficient',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'position',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'initialPosition',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'paused',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onAnimationEnd',
        type: 'void Function(BuildContext, LdSpringState)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, LdSpringState)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'mass',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'springConstant',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'dampingCoefficient',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'builder',
            type: 'Widget Function(BuildContext, LdSpringState)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'paused',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'position',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'initialPosition',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onAnimationEnd',
            type: 'void Function(BuildContext, LdSpringState)?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_Spring',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'timeStep',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'springConstant',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'dampingCoefficient',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'mass',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'targetPosition',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'position',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'velocity',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'acceleration',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'active',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'springForce',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'dampingForce',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'force',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'springConstant',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'dampingCoefficient',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'position',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'targetPosition',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'mass',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: ['update'],
  ),
  LdDocComponent(
    name: '_LdSpringState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_spring',
        type: '_Spring',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: '_ticker',
        type: 'Ticker?',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'didUpdateWidget',
      'update',
      'initState',
      'dispose',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdChainedSprings',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'count',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'mass',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'springConstant',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'dampingCoefficient',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'initialPosition',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'targetPosition',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'reversed',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, List<LdSpringState>)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'count',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'mass',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'springConstant',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'dampingCoefficient',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'builder',
            type: 'Widget Function(BuildContext, List<LdSpringState>)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'reversed',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'initialPosition',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'targetPosition',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdChainedSpringsState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_springs',
        type: 'List<_Spring>',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: '_ticker',
        type: 'Ticker?',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      '_createSprings',
      'didUpdateWidget',
      'update',
      'dispose',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdPortalEntry',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'scaleContent',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'key',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'hashCode',
        type: 'int',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'scaleContent',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: ['=='],
  ),
  LdDocComponent(
    name: 'LdPortalController',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_entries',
        type: 'List<LdPortalEntry>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'entries',
        type: 'List<LdPortalEntry>',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'scaleContent',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'open',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'registerEntry',
      'indexOf',
      'removeEntry',
      'of',
      'maybeOf',
    ],
  ),
  LdDocComponent(
    name: 'LdPortal',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'controller',
        type: 'LdPortalController?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'controller',
            type: 'LdPortalController?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'ProviderOrValue',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'value',
        type: 'T?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'create',
        type: 'T Function(BuildContext)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'dispose',
        type: 'void Function(BuildContext, T)?',
        description:
            '/// Dispose function for the provider, only used if [value] is null',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, Widget?)',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'child',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'value',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'create',
            type: 'T Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'dispose',
            type: 'void Function(BuildContext, T)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'builder',
            type: 'Widget Function(BuildContext, Widget?)',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdSwitch',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'onChanged',
        type: 'dynamic Function(T)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'children',
        type: 'Map<T, Widget>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'value',
        type: 'T',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'children',
            type: 'Map<T, Widget>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'value',
            type: 'T',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onChanged',
            type: 'dynamic Function(T)?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [
      'build',
      '_buildItem',
      '_onTap',
    ],
  ),
  LdDocComponent(
    name: 'LdRunnerLog',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'messages',
        type: 'List<String>',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'messages',
            type: 'List<String>',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdRunnerLogState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_node',
        type: 'FocusNode',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'dispose',
      'buildLine',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdRunnerStep',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'title',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'status',
        type: 'LdIndicatorType',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'trailing',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'isExpanded',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onPress',
        type: 'void Function()?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'children',
        type: 'List<Widget>',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'title',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'status',
            type: 'LdIndicatorType',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'trailing',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'isExpanded',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onPress',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'children',
            type: 'List<Widget>',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdContainer',
    isNullSafe: true,
    description:
        ' Allows you to horizontally center your content on a larger screen by padding it on the sides',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'padding',
        type: 'EdgeInsets?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'maxWidth',
        type: 'double',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'maxWidth',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'padding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdContextMenu',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'visible',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'dismissOnOutsideTap',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'listenForTaps',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'blurMode',
        type: 'LdContextMenuBlurMode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'zoomMode',
        type: 'LdContextZoomMode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, bool)',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'menuBuilder',
        type: 'Widget Function(BuildContext, void Function())',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'builder',
            type: 'Widget Function(BuildContext, bool)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'menuBuilder',
            type: 'Widget Function(BuildContext, void Function())',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'dismissOnOutsideTap',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'blurMode',
            type: 'LdContextMenuBlurMode',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'zoomMode',
            type: 'LdContextZoomMode',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'listenForTaps',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'visible',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdContextMenuState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_triggerKey',
        type: 'GlobalKey<State<StatefulWidget>>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_visible',
        type: 'bool',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: '_belowBottom',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_mobile',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_shouldBlur',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_shouldZoom',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'didUpdateWidget',
      '_dismiss',
      '_open',
      'buildTrigger',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdWindowFrame',
    isNullSafe: true,
    description:
        ' Show a frame around the window that has a surface color. Only is shown on\n Windows, Linux, and MacOS.',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'frameBuilder',
        type: 'Widget Function(BuildContext, Widget)',
        description:
            '/// The frameBuilder can be used to wrap the child in a frame. This is useful\n/// for wrapping it in a [MoveWindow] widget.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'title',
        type: 'Text',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'showWindowFrame',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'title',
            type: 'Text',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'frameBuilder',
            type: 'Widget Function(BuildContext, Widget)',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdSpacer',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'direction',
        type: 'Axis?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'direction',
            type: 'Axis?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdAccordion',
    isNullSafe: true,
    description: ' a collection of collapsible items in a group.',
    properties: [
      LdDocProperty(
        name: 'childBuilder',
        type: 'Widget Function(BuildContext, int)',
        description:
            '/// Function that is called to build each item in the accordion.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'headerBuilder',
        type: 'Widget Function(BuildContext, int)',
        description:
            '/// Function that is called to build each header in the accordion.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'itemCount',
        type: 'int',
        description: '/// The number of items in the accordion.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'initialOpenIndex',
        type: 'Set<int>',
        description:
            '/// The index of the items that should be open by default.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'headerPadding',
        type: 'EdgeInsets?',
        description: '/// The padding to apply to the header.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'childPadding',
        type: 'EdgeInsets?',
        description: '/// The padding to apply to the child.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'allowMultipleOpen',
        type: 'bool',
        description: '/// Whether or not multiple items can be open at once.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'speed',
        type: 'Duration',
        description: '/// The duration of the animation.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'curveExpand',
        type: 'Curve',
        description: '/// The curve to use when expanding.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'curveCollapse',
        type: 'Curve',
        description: '/// The curve to use when collapsing.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'elevateActive',
        type: 'bool',
        description: '/// Whether or not to elevate the active item.',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'childBuilder',
            type: 'Widget Function(BuildContext, int)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'headerBuilder',
            type: 'Widget Function(BuildContext, int)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'itemCount',
            type: 'int',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'allowMultipleOpen',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'childPadding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'curveCollapse',
            type: 'Curve',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'curveExpand',
            type: 'Curve',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'elevateActive',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'headerPadding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'initialOpenIndex',
            type: 'Set<int>',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'speed',
            type: 'Duration',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      LdDocConstructor(
        name: 'fromList',
        signature: [
          LdDocParameter(
            name: 'items',
            type: 'List<LdAccordionItem>',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'elevateActive',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'allowMultipleOpen',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'initialOpenIndex',
            type: 'Set<int>',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['factory'],
      ),
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: 'LdAccordionItem',
    isNullSafe: true,
    description:
        ' item of an accordion used in utility constructor [LdAccordion.fromList].',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'header',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'header',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: '_LdAccordionChild',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'header',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'elevateActive',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'speed',
        type: 'Duration',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'headerPadding',
        type: 'EdgeInsets',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'childPadding',
        type: 'EdgeInsets',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onPressed',
        type: 'dynamic Function()',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'curveExpand',
        type: 'Curve',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'curveCollapse',
        type: 'Curve',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'collapsed',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'collapsed',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'elevateActive',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onPressed',
            type: 'dynamic Function()',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'headerPadding',
            type: 'EdgeInsets',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'childPadding',
            type: 'EdgeInsets',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'speed',
            type: 'Duration',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'header',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'curveExpand',
            type: 'Curve',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'curveCollapse',
            type: 'Curve',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: '_LdAccordionState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'openIndex',
        type: 'Set<int>',
        description: '',
        features: [],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'build',
      'didUpdateWidget',
      'initState',
      '_onTap',
    ],
  ),
  LdDocComponent(
    name: 'LdTag',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onDismiss',
        type: 'Function?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onDismiss',
            type: 'Function?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [
      '_padding',
      '_fontSize',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdColorBundle',
    isNullSafe: true,
    description: ' Current active colors',
    properties: [
      LdDocProperty(
        name: 'surface',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'border',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'text',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'placeholder',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'icon',
        type: 'Color',
        description: '',
        features: ['late'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'surface',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'text',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'border',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'placeholder',
            type: 'Color',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'icon',
            type: 'Color?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdTouchableStatus',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'hovering',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'focus',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'active',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'hovering',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'focus',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'active',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdTouchableSurface',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'active',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'autoFocus',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'mode',
        type: 'LdTouchableSurfaceMode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'focusNode',
        type: 'FocusNode?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onTap',
        type: 'dynamic Function()',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, LdColorBundle, LdTouchableStatus)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onTap',
            type: 'dynamic Function()',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'builder',
            type:
                'Widget Function(BuildContext, LdColorBundle, LdTouchableStatus)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'focusNode',
            type: 'FocusNode?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'active',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'mode',
            type: 'LdTouchableSurfaceMode',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'autoFocus',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdTouchableSurfaceState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_hovering',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_pressed',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_hasFocus',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'active',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_colorBundle',
        type: 'LdColorBundle',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdDrawerHeader',
    isNullSafe: true,
    description:
        ' The header of a drawer, that contains the application or menu title',
    properties: [
      LdDocProperty(
        name: 'title',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'showBack',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'scrollController',
        type: 'ScrollController?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'title',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'showBack',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'scrollController',
            type: 'ScrollController?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdSectionHeader',
    isNullSafe: true,
    description: ' A title for a section in the drawer',
    properties: [
      LdDocProperty(
        name: 'text',
        type: 'String',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'text',
            type: 'String',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdDrawerItemSection',
    isNullSafe: true,
    description:
        ' A section in the drawer that can contain a collapsable sub-items',
    properties: [
      LdDocProperty(
        name: 'leading',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'trailing',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'active',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'initiallyExpanded',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'children',
        type: 'List<Widget>?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onTap',
        type: 'dynamic Function()?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'leading',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'trailing',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'initiallyExpanded',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onTap',
            type: 'dynamic Function()?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'active',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'children',
            type: 'List<Widget>?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdDrawerItemSectionState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_expanded',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_theme',
        type: 'LdTheme',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_trailingItem',
        type: 'Widget',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_isExpanded',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      '_leading',
      '_onTap',
      'buildItem',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdException',
    isNullSafe: true,
    description:
        ' A renderable exception. Has a message, more info, and a type (LdHintType).\n Can also contain a stack trace as well as the flag that the action causing\n the exception can be retried.',
    properties: [
      LdDocProperty(
        name: 'message',
        type: 'String',
        description: '/// The message of the exception.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'moreInfo',
        type: 'String?',
        description:
            '/// Additional information about the exception, e.g. a detailed explanation\n/// of what went wrong.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'canRetry',
        type: 'bool',
        description:
            '/// Whether the action causing the exception can be retried.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'type',
        type: 'LdHintType',
        description:
            '/// The type of the exception. By default, it is [LdHintType.error].',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'exception',
        type: 'dynamic',
        description: '/// The actual [Exception] that caused this exception.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'attempt',
        type: 'int?',
        description:
            '/// The number of attempts that have been made to resolve the exception.\n/// This can be useful for debugging.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'stackTrace',
        type: 'StackTrace?',
        description: '/// The stack trace of the exception.',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'message',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'canRetry',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'type',
            type: 'LdHintType',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'moreInfo',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'attempt',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'stackTrace',
            type: 'StackTrace?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'exception',
            type: 'dynamic',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: ['copyWith'],
  ),
  LdDocComponent(
    name: 'LdRetryConfig',
    isNullSafe: true,
    description: ' Configuration for retry behavior',
    properties: [
      LdDocProperty(
        name: 'maxAttempts',
        type: 'int',
        description:
            '/// Maximum number of attempts (including the initial attempt).\n/// If set to 1, the retry button will be hidden immediately.\n/// Defaults to 4 (i.e. 3 retries).',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'enableAutomaticRetries',
        type: 'bool',
        description: '/// Whether to enable automatic retries',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'baseDelay',
        type: 'Duration',
        description:
            '/// Base delay for retries (will be multiplied by exponential backoff)\n/// Can only be used in combination with [enableAutomaticRetries].',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'hideManualRetryButton',
        type: 'bool',
        description:
            '/// Whether to hide the manual retry button.\n/// Can only be used in combination with [enableAutomaticRetries].',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'useJitter',
        type: 'bool',
        description:
            '/// Whether to add jitter to retry delays\n/// Can only be used in combination with [enableAutomaticRetries].',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'maxAttempts',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'enableAutomaticRetries',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'hideManualRetryButton',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'baseDelay',
            type: 'Duration',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'useJitter',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      LdDocConstructor(
        name: 'noRetries',
        signature: [],
        features: ['factory'],
      ),
      LdDocConstructor(
        name: 'unlimitedManualRetries',
        signature: [],
        features: ['factory'],
      ),
      LdDocConstructor(
        name: 'defaultAutomaticRetries',
        signature: [
          LdDocParameter(
            name: 'baseDelay',
            type: 'Duration',
            description: '',
            named: true,
            required: false,
          )
        ],
        features: ['factory'],
      ),
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdExceptionMoreInfoButton',
    isNullSafe: true,
    description:
        ' LdExceptionMoreInfoButton is a button that will open a dialog with more info',
    properties: [
      LdDocProperty(
        name: 'error',
        type: 'LdException?',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'error',
            type: 'LdException?',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdExceptionMapperProvider',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'exceptionMapper',
        type: 'LdExceptionMapper?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'exceptionMapper',
            type: 'LdExceptionMapper?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdExceptionMapper',
    isNullSafe: true,
    description:
        ' A mapper that maps exceptions to LdExceptions that are displayed in the UI.\n You can provide your own exception mapper to handle custom exceptions.\n The default exception mapper will handle common exceptions like network errors.',
    properties: [
      LdDocProperty(
        name: 'localizations',
        type: 'LiquidLocalizations',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onException',
        type: 'LdException? Function(dynamic, {StackTrace? stackTrace})?',
        description:
            '/// A function that can be used to handle custom exceptions. If the function\n/// returns a non-null LdException, it will be used instead of the default\n/// exception mapper. Otherwise, the default exception mapper will be used.\n/// This function will never be called if the exception is already an LdException.',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'localizations',
            type: 'LiquidLocalizations',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onException',
            type: 'LdException? Function(dynamic, {StackTrace? stackTrace})?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [
      'of',
      'handle',
    ],
  ),
  LdDocComponent(
    name: 'LdExceptionDialog',
    isNullSafe: true,
    description: ' Renders an LdException in a dialog',
    properties: [
      LdDocProperty(
        name: 'error',
        type: 'LdException?',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'error',
            type: 'LdException?',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdExceptionView',
    isNullSafe: true,
    description: ' Renders an LdException',
    properties: [
      LdDocProperty(
        name: 'exception',
        type: 'LdException?',
        description: '/// The exception to render',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'retryController',
        type: 'LdRetryController?',
        description: '/// The controller for managing retry operations',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'retry',
        type: 'void Function()?',
        description:
            '/// A callback to retry the action that caused the exception\n/// If null, the retry button will not be displayed',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'direction',
        type: 'Axis',
        description:
            '/// The direction of the exception view, either [Axis.vertical] or\n/// [Axis.horizontal].',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'exception',
            type: 'LdException?',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'retryController',
            type: 'LdRetryController?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'retry',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'direction',
            type: 'Axis',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      LdDocConstructor(
        name: 'fromDynamic',
        signature: [
          LdDocParameter(
            name: 'error',
            type: 'dynamic',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'context',
            type: 'BuildContext',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'direction',
            type: 'Axis',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'retryController',
            type: 'LdRetryController?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'retry',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['factory'],
      ),
    ],
    methods: [
      'color',
      '_createRetryController',
      '_buildRetryButton',
      '_buildRetryIndicator',
      '_buildDialogButton',
      '_buildHorizontal',
      '_buildVertical',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdRetryState',
    isNullSafe: true,
    description: ' State object for retry operations',
    properties: [
      LdDocProperty(
        name: 'attempt',
        type: 'int',
        description: '/// Current attempt number (1-based)',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'remainingRetryTime',
        type: 'Duration?',
        description: '/// Remaining time until next retry',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'isRetrying',
        type: 'bool',
        description: '/// Whether retry is in progress',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'canRetry',
        type: 'bool',
        description: '/// Whether retry is enabled',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'totalRetryDelay',
        type: 'Duration?',
        description: '/// The total delay for the current retry',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'attempt',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'remainingRetryTime',
            type: 'Duration?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'isRetrying',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'canRetry',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'totalRetryDelay',
            type: 'Duration?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['copyWith'],
  ),
  LdDocComponent(
    name: 'LdRetryController',
    isNullSafe: true,
    description: ' Controller for managing retry operations',
    properties: [
      LdDocProperty(
        name: 'config',
        type: 'LdRetryConfig',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_stateController',
        type: 'StreamController<LdRetryState>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_retryTimer',
        type: 'Timer?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_state',
        type: 'LdRetryState',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_jitter',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onRetry',
        type: 'void Function()',
        description:
            '/// Function to be called when a retry should be executed',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_canRetryError',
        type: 'bool',
        description: '/// Whether an error happened that can be retried',
        features: [],
      ),
      LdDocProperty(
        name: 'stateStream',
        type: 'Stream<LdRetryState>',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'state',
        type: 'LdRetryState',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'showRetryIndicator',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'showRetryButton',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'onRetry',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'config',
            type: 'LdRetryConfig',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      '_setState',
      '_setupRetryTimer',
      '_getRetryDelay',
      '_retryTimerTick',
      '_executeRetry',
      'handleError',
      'retry',
      'reset',
      'notifyOperationStarted',
      'notifyOperationCompleted',
      'dispose',
    ],
  ),
  LdDocComponent(
    name: 'LdExceptionRetryIndicator',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'retryState',
        type: 'LdRetryState',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'remainingRetryTime',
        type: 'Duration',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'totalRetryDelay',
        type: 'Duration',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'progress',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'retryState',
            type: 'LdRetryState',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdListPage',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'newItems',
        type: 'List<T>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'hasMore',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'total',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'nextPageToken',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'error',
        type: 'Object?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'newItems',
            type: 'List<T>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'hasMore',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'total',
            type: 'int',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'error',
            type: 'Object?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'nextPageToken',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: '_ListItem',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'item',
        type: 'T?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'isSeparator',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'seperationCriterion',
        type: 'SeperationCriterion?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'item',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'isSeparator',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'seperationCriterion',
            type: 'SeperationCriterion?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdList',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'itemBuilder',
        type: 'Widget Function(BuildContext, T, int)',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'emptyBuilder',
        type: 'Widget Function(BuildContext, Future<void> Function())?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'errorBuilder',
        type: 'Widget Function(BuildContext, Object?, void Function())?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'assumedItemHeight',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'data',
        type: 'LdPaginator<T>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'loadingBuilder',
        type: 'Widget Function(BuildContext, int, int)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'areEqual',
        type: 'bool Function(T, T)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'groupingCriterion',
        type: 'GroupingCriterion Function(T)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'seperatorBuilder',
        type: 'Widget Function(BuildContext, GroupingCriterion)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'groupSequentialItems',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'shrinkWrap',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'physics',
        type: 'ScrollPhysics?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'header',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'primary',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'footer',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'retryConfig',
        type: 'LdRetryConfig?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'areEqual',
            type: 'bool Function(T, T)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'emptyBuilder',
            type: 'Widget Function(BuildContext, Future<void> Function())?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'errorBuilder',
            type: 'Widget Function(BuildContext, Object?, void Function())?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'header',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'loadingBuilder',
            type: 'Widget Function(BuildContext, int, int)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'assumedItemHeight',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'physics',
            type: 'ScrollPhysics?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'itemBuilder',
            type: 'Widget Function(BuildContext, T, int)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'data',
            type: 'LdPaginator<T>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'seperatorBuilder',
            type: 'Widget Function(BuildContext, GroupingCriterion)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'groupingCriterion',
            type: 'GroupingCriterion Function(T)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'primary',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'footer',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'groupSequentialItems',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'shrinkWrap',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'retryConfig',
            type: 'LdRetryConfig?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdListState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_groupedItems',
        type: 'List<_ListItem<T, GroupingCriterion>>',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_retryController',
        type: 'LdRetryController',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      '_groupItemsSequentially',
      '_groupItemsUniformly',
      'initState',
      'didUpdateWidget',
      'dispose',
      '_onDataChange',
      '_onRefresh',
      '_buildEmpty',
      '_buildLoadMore',
      '_buildError',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdPaginator',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'fetchListFunction',
        type: 'Future<LdListPage<T>> Function(int, int, String?)',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_currentList',
        type: 'List<T>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_currentPage',
        type: 'int',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_hasMoreData',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_totalItems',
        type: 'int',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_busy',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_error',
        type: 'Object?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'totalItems',
        type: 'int',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'remainingItems',
        type: 'int',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'currentList',
        type: 'List<T>',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'currentPage',
        type: 'int',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'hasMoreData',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'busy',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'error',
        type: 'Object?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'hasError',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'fetchListFunction',
            type: 'Future<LdListPage<T>> Function(int, int, String?)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'autoLoad',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      ),
      LdDocConstructor(
        name: 'fromList',
        signature: [
          LdDocParameter(
            name: 'list',
            type: 'List<T>',
            description: '',
            named: false,
            required: true,
          )
        ],
        features: ['factory'],
      ),
    ],
    methods: [
      'updateWhere',
      '_setError',
      '_setBusy',
      '_fetchNextPage',
      'nextPage',
      'refreshList',
      'reset',
    ],
  ),
  LdDocComponent(
    name: 'LdListEmpty',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'onRefresh',
        type: 'Function?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'text',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onRefresh',
            type: 'Function?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'text',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdListItemLoading',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'hasLeading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'hasTrailing',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'hasSubContent',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'hasSubtitle',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'hasLeading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'hasTrailing',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'hasSubContent',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'hasSubtitle',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdAnimatedLoadingGradient',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'height',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'width',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'width',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'height',
            type: 'double',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdAnimatedLoadingGradientState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'colorList',
        type: 'List<Color>',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: 'alignmentList',
        type: 'List<Alignment>',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'index',
        type: 'int',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'bottomColor',
        type: 'Color',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: 'topColor',
        type: 'Color',
        description: '',
        features: ['late'],
      ),
      LdDocProperty(
        name: 'begin',
        type: 'Alignment',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'end',
        type: 'Alignment',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdListSeperator',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onSurface',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onSurface',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdListItem',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'leading',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'trailing',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'padding',
        type: 'EdgeInsets?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'title',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'active',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'subtitle',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onTap',
        type: 'void Function()?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'width',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'selectDisabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onSelectionChange',
        type: 'void Function(bool)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'radioSelection',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'subContent',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'isSelected',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'trailingForward',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'tradeLeadingForSelectionControl',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'showSelectionControls',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'leading',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'trailing',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'title',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'active',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'isSelected',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'radioSelection',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'selectDisabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'trailingForward',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'showSelectionControls',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onSelectionChange',
            type: 'void Function(bool)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'tradeLeadingForSelectionControl',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'padding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onTap',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'subtitle',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'width',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'subContent',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdColor',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'shades',
        type: 'List<Color>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_center',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_darkCenter',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'luminanceThreshold',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disabledAlpha',
        type: 'int',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'shades',
            type: 'List<Color>',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: '_center',
            type: 'int',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: '_darkCenter',
            type: 'int',
            description: '',
            named: false,
            required: true,
          ),
          LdDocParameter(
            name: 'luminanceThreshold',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disabledAlpha',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [
      'center',
      'fromCenter',
      'fromDarkCenter',
      'moveRelative',
      'relative',
      'idle',
      'hover',
      'active',
      'focus',
      'locateColor',
      'toString',
      'contrastingText',
      'disabled',
    ],
  ),
  LdDocComponent(
    name: 'LdPalette',
    isNullSafe: true,
    description: ' Describes how to build a pallete of colors for a theme.',
    properties: [
      LdDocProperty(
        name: 'isDark',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'primary',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'secondary',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'success',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'warning',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'error',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'neutral',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'background',
        type: 'Color',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: 'surface',
        type: 'Color',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: 'border',
        type: 'Color',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: 'stroke',
        type: 'Color',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: 'text',
        type: 'Color',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: 'textMuted',
        type: 'Color',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'isDark',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'primary',
            type: 'LdColor',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'secondary',
            type: 'LdColor',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'success',
            type: 'LdColor',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'warning',
            type: 'LdColor',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'error',
            type: 'LdColor',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'neutral',
            type: 'LdColor',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdThemeProvider',
    isNullSafe: true,
    description:
        ' Provides a theme to all the components in the widget tree\n Theme can be accessed using LdTheme.of(context)',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'theme',
        type: 'LdTheme?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'brightnessMode',
        type: 'LdThemeBrightnessMode',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'darkPalette',
        type: 'LdPalette?',
        description:
            '/// The dark palette to use when [autoBrightness] is true defaults to [deepOcean]',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'lightPalette',
        type: 'LdPalette?',
        description:
            '/// The light palette to use when [autoBrightness] is true defaults to [ocean]',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'autoSize',
        type: 'bool',
        description:
            '/// If true the theme will change based on the type of the device\n/// will use LdThemeSize.m on mobile and LdThemeSize.s on desktop',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'theme',
            type: 'LdTheme?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'brightnessMode',
            type: 'LdThemeBrightnessMode',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'autoSize',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'darkPalette',
            type: 'LdPalette?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'lightPalette',
            type: 'LdPalette?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdThemeProviderState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_palette',
        type: 'LdPalette?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_themeSize',
        type: 'LdThemeSize?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_createdTheme',
        type: 'LdTheme?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_darkPalette',
        type: 'LdPalette',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_lightPalette',
        type: 'LdPalette',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_theme',
        type: 'LdTheme',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      '_getScreenRadius',
      'didChangePlatformBrightness',
      '_applyBrightness',
      'didUpdateWidget',
      'dispose',
      'themeChanged',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdTheme',
    isNullSafe: true,
    description:
        ' Provides a theme to all the components in the widget tree\n Theme can be accessed using LdTheme.of(context)',
    properties: [
      LdDocProperty(
        name: '_palette',
        type: 'LdPalette',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_defaultSize',
        type: 'LdThemeSize',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_sizingConfig',
        type: 'LdSizingConfig',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_screenRadius',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_fontFamily',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_headlineFontFamily',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_fontFamilyPackage',
        type: 'String?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'palette',
        type: 'LdPalette',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeSize',
        type: 'LdThemeSize',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'sizingConfig',
        type: 'LdSizingConfig',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'screenRadius',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'fontFamily',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'headlineFontFamily',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'fontFamilyPackage',
        type: 'String?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'borderWidth',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'isDark',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'absolute',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'primary',
        type: 'LdColor',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'secondary',
        type: 'LdColor',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'success',
        type: 'LdColor',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'warning',
        type: 'LdColor',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'error',
        type: 'LdColor',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'primaryColor',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'primaryColorText',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'secondaryColor',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'secondaryColorText',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'errorColor',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'errorColorText',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'successColor',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'successColorText',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'warningColor',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'warningColorText',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'background',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'text',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'textMuted',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'border',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'stroke',
        type: 'Color',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'surface',
        type: 'Color',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'radius',
      'setThemeSize',
      'balPad',
      'paddingSize',
      'labelSize',
      'paragraphSize',
      'headlineSize',
      'pad',
      'setPalette',
      'of',
      'neutralShade',
    ],
  ),
  LdDocComponent(
    name: 'LdSizingConfig',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'radiusXS',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'radiusS',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'radiusM',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'radiusL',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeSPaddingXS',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeSPaddingS',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeSPaddingM',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeSPaddingL',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeMPaddingXS',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeMPaddingS',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeMPaddingM',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeMPaddingL',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeLPaddingXS',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeLPaddingS',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeLPaddingM',
        type: 'double',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'themeLPaddingL',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'radiusXS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'radiusS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'radiusM',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'radiusL',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeSPaddingXS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeSPaddingS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeSPaddingM',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeSPaddingL',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeMPaddingXS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeMPaddingS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeMPaddingM',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeMPaddingL',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeLPaddingXS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeLPaddingS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeLPaddingM',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'themeLPaddingL',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdThemedAppBuilder',
    isNullSafe: true,
    description:
        ' Allows you to build a styled material app\n ```dart\n LdThemedAppBuilder((context,themeData) => MaterialApp(\n  theme: themeData,\n home: ....))\n ```',
    properties: [
      LdDocProperty(
        name: 'appBuilder',
        type: 'MaterialApp Function(BuildContext, ThemeData)',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'appBuilder',
            type: 'MaterialApp Function(BuildContext, ThemeData)',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_LdThemedAppBuilderState',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdSubmitBuilder',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'resultBuilder',
        type: 'Widget Function(BuildContext, T, LdSubmitController<T>)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'submitButtonBuilder',
        type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'loadingBuilder',
        type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'errorBuilder',
        type:
            'Widget Function(BuildContext, LdException, LdSubmitController<T>)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'resultBuilder',
            type: 'Widget Function(BuildContext, T, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'submitButtonBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'loadingBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'errorBuilder',
            type:
                'Widget Function(BuildContext, LdException, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdSubmit',
    isNullSafe: true,
    description:
        ' A component that handles making requests and displaying errors.\n You can use this component to wrap around a button that makes a request.\n It will handle the loading state and display errors.\n It also has a default exception mapper that will handle common exceptions.\n You can also provide your own exception mapper.\n The default builder is a button that will display a loading spinner when loading.',
    properties: [
      LdDocProperty(
        name: 'config',
        type: 'LdSubmitConfig<T>?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'controller',
        type: 'LdSubmitController<T>?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'builder',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'submitBuilder',
        type: 'Widget',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'config',
            type: 'LdSubmitConfig<T>?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'controller',
            type: 'LdSubmitController<T>?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'builder',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [
      '_buildProvider',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdSubmitInlineBuilder',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'showSubmitButton',
        type: 'bool?',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'resultBuilder',
            type: 'Widget Function(BuildContext, T, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'submitButtonBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'errorBuilder',
            type:
                'Widget Function(BuildContext, LdException, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'showSubmitButton',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [
      'buildSubmitButton',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdSubmitButton',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'controller',
        type: 'LdSubmitController<dynamic>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'leading',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'trailing',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'controller',
            type: 'LdSubmitController<dynamic>',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'leading',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'trailing',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdSubmitCenteredBuilder',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'resultBuilder',
            type: 'Widget Function(BuildContext, T, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'submitButtonBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'loadingBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'errorBuilder',
            type:
                'Widget Function(BuildContext, LdException, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdSubmitDialogBuilder',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'showSubmitButton',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'dialogKey',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'resultBuilder',
            type: 'Widget Function(BuildContext, T, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'errorBuilder',
            type:
                'Widget Function(BuildContext, LdException, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'loadingBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'submitButtonBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'showSubmitButton',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      'buildLoadingDialog',
      'buildErrorDialog',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdSubmitCustomBuilder',
    isNullSafe: true,
    description:
        ' A custom builder that allows you to build your own submit widget.',
    properties: [
      LdDocProperty(
        name: 'builder',
        type:
            'Widget Function(BuildContext, LdSubmitController<T>, LdSubmitStateType)',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'builder',
            type:
                'Widget Function(BuildContext, LdSubmitController<T>, LdSubmitStateType)',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdSubmitConfig',
    isNullSafe: true,
    description: ' A configuration for a submit action.',
    properties: [
      LdDocProperty(
        name: 'loadingText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'submitText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'allowResubmit',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'withHaptics',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'autoTrigger',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'timeout',
        type: 'Duration?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'allowCancel',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'action',
        type: 'Future<T> Function()',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onCanceled',
        type: 'void Function()?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'retryConfig',
        type: 'LdRetryConfig?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'loadingText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'submitText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'allowResubmit',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'withHaptics',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'autoTrigger',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'allowCancel',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onCanceled',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'timeout',
            type: 'Duration?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'retryConfig',
            type: 'LdRetryConfig?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'action',
            type: 'Future<T> Function()',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdSubmitState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_type',
        type: 'LdSubmitStateType',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_error',
        type: 'LdException?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_result',
        type: 'T?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'type',
        type: 'LdSubmitStateType',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'error',
        type: 'LdException?',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'result',
        type: 'T?',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'type',
            type: 'LdSubmitStateType',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'error',
            type: 'LdException?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'result',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      'toString',
      'copyWith',
    ],
  ),
  LdDocComponent(
    name: 'LdSubmitController',
    isNullSafe: true,
    description:
        ' Handles the lifecyle of a submit action. Pass a [LdSubmitConfig] to the\n controller to configure the submit action.\n Updated LdSubmitController that uses LdRetryController',
    properties: [
      LdDocProperty(
        name: 'config',
        type: 'LdSubmitConfig<T>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'exceptionMapper',
        type: 'LdExceptionMapper',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_stateController',
        type: 'StreamController<LdSubmitState<T>>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_retryController',
        type: 'LdRetryController',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: 'state',
        type: 'LdSubmitState<T>',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_disposed',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'retryController',
        type: 'LdRetryController',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'stateStream',
        type: 'Stream<LdSubmitState<T>>',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'canCancel',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_isError',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_isLoading',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_isResult',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_isIdle',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'canRetry',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'canRetrigger',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'canTrigger',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'disposed',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'exceptionMapper',
            type: 'LdExceptionMapper',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'config',
            type: 'LdSubmitConfig<T>',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      'init',
      '_setState',
      'cancel',
      '_trigger',
      'trigger',
      '_nextAttempt',
      'reset',
      'dispose',
    ],
  ),
  LdDocComponent(
    name: 'LdSubmitLoadingIndicator',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'loading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'loadingText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'direction',
        type: 'Axis',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'loading',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'loadingText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'direction',
            type: 'Axis',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LiquidLocalizationsDe',
    isNullSafe: true,
    description: ' The translations for German (`de`).',
    properties: [
      LdDocProperty(
        name: 'searchAgain',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'search',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'noItemsFound',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'cancel',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'confirm',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'ok',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'done',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'enterText',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'refresh',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'errorOccurred',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'failed',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'retry',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'choose',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'submit',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'selectDate',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'selectTime',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'unknownError',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'moreInfo',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'close',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'loading',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'networkError',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'timeoutError',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'formatError',
        type: 'String',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'locale',
            type: 'String',
            description: '',
            named: false,
            required: false,
          )
        ],
        features: [],
      )
    ],
    methods: ['retryIn'],
  ),
  LdDocComponent(
    name: 'LiquidLocalizations',
    isNullSafe: true,
    description:
        ' Callers can lookup localized strings with an instance of LiquidLocalizations\n returned by `LiquidLocalizations.of(context)`.\n\n Applications need to include `LiquidLocalizations.delegate()` in their app\'s\n `localizationDelegates` list, and the locales they support in the app\'s\n `supportedLocales` list. For example:\n\n ```dart\n import \'generated/liquid_localizations.dart\';\n\n return MaterialApp(\n   localizationsDelegates: LiquidLocalizations.localizationsDelegates,\n   supportedLocales: LiquidLocalizations.supportedLocales,\n   home: MyApplicationHome(),\n );\n ```\n\n ## Update pubspec.yaml\n\n Please make sure to update your pubspec.yaml to include the following\n packages:\n\n ```yaml\n dependencies:\n   # Internationalization support.\n   flutter_localizations:\n     sdk: flutter\n   intl: any # Use the pinned version from flutter_localizations\n\n   # Rest of dependencies\n ```\n\n ## iOS Applications\n\n iOS applications define key application metadata, including supported\n locales, in an Info.plist file that is built into the application bundle.\n To configure the locales supported by your app, you’ll need to edit this\n file.\n\n First, open your project’s ios/Runner.xcworkspace Xcode workspace file.\n Then, in the Project Navigator, open the Info.plist file under the Runner\n project’s Runner folder.\n\n Next, select the Information Property List item, select Add Item from the\n Editor menu, then select Localizations from the pop-up menu.\n\n Select and expand the newly-created Localizations item then, for each\n locale your application supports, add a new item and select the locale\n you wish to add from the pop-up menu in the Value field. This list should\n be consistent with the languages listed in the LiquidLocalizations.supportedLocales\n property.',
    properties: [
      LdDocProperty(
        name: 'localeName',
        type: 'String',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'delegate',
        type: 'LocalizationsDelegate<LiquidLocalizations>',
        description: '',
        features: [
          'static',
          'const',
        ],
      ),
      LdDocProperty(
        name: 'localizationsDelegates',
        type: 'List<LocalizationsDelegate<dynamic>>',
        description:
            '/// A list of this localizations delegate along with the default localizations\n/// delegates.\n///\n/// Returns a list of localizations delegates containing this delegate along with\n/// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,\n/// and GlobalWidgetsLocalizations.delegate.\n///\n/// Additional delegates can be added by appending to this list in\n/// MaterialApp. This list does not have to be used at all if a custom list\n/// of delegates is preferred or required.',
        features: [
          'static',
          'const',
        ],
      ),
      LdDocProperty(
        name: 'supportedLocales',
        type: 'List<Locale>',
        description:
            '/// A list of this localizations delegate\'s supported locales.',
        features: [
          'static',
          'const',
        ],
      ),
      LdDocProperty(
        name: 'searchAgain',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'search',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'noItemsFound',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'cancel',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'confirm',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'ok',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'done',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'enterText',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'refresh',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'errorOccurred',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'failed',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'retry',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'choose',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'submit',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'selectDate',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'selectTime',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'unknownError',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'moreInfo',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'close',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'loading',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'networkError',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'timeoutError',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'formatError',
        type: 'String',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'locale',
            type: 'String',
            description: '',
            named: false,
            required: true,
          )
        ],
        features: [],
      )
    ],
    methods: [
      'of',
      'retryIn',
    ],
  ),
  LdDocComponent(
    name: '_LiquidLocalizationsDelegate',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: ['const'],
      )
    ],
    methods: [
      'load',
      'isSupported',
      'shouldReload',
    ],
  ),
  LdDocComponent(
    name: 'LiquidLocalizationsEn',
    isNullSafe: true,
    description: ' The translations for English (`en`).',
    properties: [
      LdDocProperty(
        name: 'searchAgain',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'search',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'noItemsFound',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'cancel',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'confirm',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'ok',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'done',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'enterText',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'refresh',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'errorOccurred',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'failed',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'retry',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'choose',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'submit',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'selectDate',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'selectTime',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'unknownError',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'moreInfo',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'close',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'loading',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'networkError',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'timeoutError',
        type: 'String',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'formatError',
        type: 'String',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'locale',
            type: 'String',
            description: '',
            named: false,
            required: false,
          )
        ],
        features: [],
      )
    ],
    methods: ['retryIn'],
  ),
  LdDocComponent(
    name: 'LdNotification',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'message',
        type: 'String',
        description: '/// Message of the notification',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'subMessage',
        type: 'String?',
        description: '/// Submessage of the notification',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'duration',
        type: 'Duration?',
        description:
            '/// Duration of the notification. If null the notification will not be dismissed automatically',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '/// If the notification is a big notification',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'type',
        type: 'LdNotificationType',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'removing',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'didConfirm',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'key',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'canDismiss',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'showBackdrop',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'message',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'type',
            type: 'LdNotificationType',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'subMessage',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'canDismiss',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'removing',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'didConfirm',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'duration',
            type: 'Duration?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdInputNotification',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'inputKey',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'inputHint',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'inputLabel',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'inputType',
        type: 'TextInputType',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'submitText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'inputCompleter',
        type: 'Completer<String?>',
        description:
            '/// Completer that gets resolved when the user entered something in the input field',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'message',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'type',
            type: 'LdNotificationType',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'inputHint',
            type: 'String?',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'inputLabel',
            type: 'String?',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'submitText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'inputType',
            type: 'TextInputType',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'subMessage',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'canDismiss',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'duration',
            type: 'Duration?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdConfirmNotification',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'cancelKey',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'confirmKey',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'confirmText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'cancelText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'confirmationCompleter',
        type: 'Completer<bool?>',
        description:
            '/// Completer that gets resolved when the user confirms the notification or it is dismissed',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'message',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'type',
            type: 'LdNotificationType',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'subMessage',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'canDismiss',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'duration',
            type: 'Duration?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'confirmText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'cancelText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdAcknowledgeNotification',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'dismissKey',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'acknowledgeText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'message',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'type',
            type: 'LdNotificationType',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'subMessage',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'canDismiss',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'duration',
            type: 'Duration?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'acknowledgeText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [],
  ),
  LdDocComponent(
    name: 'LdNotificationProvider',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'notifier',
        type: 'LdNotificationsController?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'notifier',
            type: 'LdNotificationsController?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdNotificationPortal',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  LdDocComponent(
    name: 'LdNotificationWidget',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'notification',
        type: 'LdNotification',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'index',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'removing',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'didConfirm',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onDismiss',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onConfirm',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onCancel',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onSubmitInput',
        type: 'dynamic Function(String)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'notification',
            type: 'LdNotification',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'removing',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'didConfirm',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onConfirm',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onSubmitInput',
            type: 'dynamic Function(String)',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onCancel',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'index',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onDismiss',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: [
      '_colorBundle',
      '_theme',
      '_icon',
      '_buildConfirmationButtons',
      '_buildAcknowledgeButton',
      '_buildNotificationBody',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdNotificationsController',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_notifications',
        type: 'List<LdNotification>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'notifications',
        type: 'List<LdNotification>',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'error',
      'success',
      'warning',
      'confirm',
      'enterText',
      'addNotification',
      'onConfirmedNotification',
      'onInputSubmitted',
      'onDismissNotification',
      'onCancelledNotification',
      'clearNotifications',
      'of',
    ],
  ),
  LdDocComponent(
    name: 'ImplicitBlur',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'sigma',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'duration',
        type: 'Duration',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'sigma',
            type: 'double',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'duration',
            type: 'Duration',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_ImplicitBlurState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_controller',
        type: 'AnimationController',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      LdDocProperty(
        name: '_tween',
        type: 'Tween<double>',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      'didUpdateWidget',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'NotificationInput',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'notification',
        type: 'LdInputNotification',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onSubmitted',
        type: 'dynamic Function(String)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'notification',
            type: 'LdInputNotification',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'onSubmitted',
            type: 'dynamic Function(String)',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: '_NotificationInputState',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: '_controller',
        type: 'TextEditingController',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'dispose',
      'build',
    ],
  ),
  LdDocComponent(
    name: 'LdModalPage',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'builder',
        type: 'LdModal',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'key',
            type: 'LocalKey?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'name',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'builder',
            type: 'LdModal',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createRoute'],
  ),
  LdDocComponent(
    name: 'LdModal',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'modalContent',
        type: 'Widget Function(BuildContext)?',
        description: '/// The content of the sheet.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'contentSlivers',
        type: 'List<Widget> Function(BuildContext)?',
        description:
            '/// The slivers to be added to the sheet. Used instead of [modalContent] if provided.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'enableScaling',
        type: 'bool?',
        description:
            '/// Whether the sheet should scale the content behind when opened. Defaults to true on iOS mobile devices.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'userCanDismiss',
        type: 'bool',
        description: '/// Whether the sheet can be dismissed',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'showDismissButton',
        type: 'bool',
        description: '/// Whether to show the dismiss button',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'onDismiss',
        type: 'void Function()?',
        description: '/// Callback for when the sheet is dismissed.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'disableScrolling',
        type: 'bool',
        description:
            '/// Whether the sheet should disable scrolling. Defaults to false.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'actions',
        type: 'List<Widget> Function(BuildContext)?',
        description: '/// The actions to be added to the sheet.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'mode',
        type: 'LdModalTypeMode?',
        description: '/// The mode of the modal.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'index',
        type: 'int?',
        description:
            '/// Override the modal index. By default the LdPortalController will increment the index for each modal.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'key',
        type: 'Key?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'noHeader',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'padding',
        type: 'EdgeInsets?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'title',
        type: 'Widget?',
        description: '/// The title of the modal.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'injectables',
        type: 'List<ListenableProvider<Listenable?>> Function(BuildContext)?',
        description:
            '/// A list of listenables to be injected into the modal. That can be read\n/// from the various builder contexts, useful for updating the modal content\n/// based on external state like a viewmodel.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'size',
        type: 'LdSize?',
        description: '/// The size of the modal.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'fixedDialogSize',
        type: 'Size?',
        description: '/// Fixed dialog size',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'topRadius',
        type: 'double?',
        description: '/// The radius for the top of the modal.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'bottomRadius',
        type: 'double?',
        description: '/// The radius for the bottom of the modal.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'insets',
        type: 'EdgeInsets?',
        description:
            '/// The inset for the modal from the edges of the screen.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'useSafeArea',
        type: 'bool',
        description:
            '/// Whether the modal should use safe area. Defaults to true.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'showDragHandle',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'actionBar',
        type: 'Widget Function(BuildContext)?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_actionBarHeight',
        type: 'Map<LdThemeSize, double>',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_contentActionBarPadding',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: '_defaultSheetInset',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'shouldScale',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'barrierDismissible',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'enableDrag',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'isTopBarLayerAlwaysVisible',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: '_isMobile',
        type: 'bool',
        description: '',
        features: [],
      ),
      LdDocProperty(
        name: 'hasTopBarLayer',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'enableScaling',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'modalContent',
            type: 'Widget Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'userCanDismiss',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'disableScrolling',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'noHeader',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'showDragHandle',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'padding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'title',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'actions',
            type: 'List<Widget> Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'contentSlivers',
            type: 'List<Widget> Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'mode',
            type: 'LdModalTypeMode?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'showDismissButton',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'injectables',
            type:
                'List<ListenableProvider<Listenable?>> Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'onDismiss',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'actionBar',
            type: 'Widget Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'topRadius',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'bottomRadius',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'insets',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'useSafeArea',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'fixedDialogSize',
            type: 'Size?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'index',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      '_showDragHandle',
      'navbarHeight',
      'isSheet',
      '_getSheetType',
      '_autoShowsSheet',
      '_getInjectables',
      '_getTrailingNavBarWidget',
      '_getPageList',
      'hasSabGradient',
      '_getStickyActionBar',
      '_getTopBar',
      'asRoute',
      '_getContentDecorator',
      '_getModalBarrierColor',
      'show',
    ],
  ),
  LdDocComponent(
    name: 'LdSheetType',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'index',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'insets',
        type: 'EdgeInsets',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'theme',
            type: 'LdTheme',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'insets',
            type: 'EdgeInsets',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'topRadius',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'bottomRadius',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'index',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      'layoutModal',
      'positionModal',
    ],
  ),
  LdDocComponent(
    name: 'LdDialogType',
    isNullSafe: true,
    description: '',
    properties: [
      LdDocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'fixedSize',
        type: 'Size?',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'theme',
        type: 'LdTheme',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'index',
        type: 'int',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'theme',
            type: 'LdTheme',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'index',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'fixedSize',
            type: 'Size?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      'positionModal',
      'layoutModal',
    ],
  ),
  LdDocComponent(
    name: 'LdModalBuilder',
    isNullSafe: true,
    description:
        ' A utility widget that displays a sheet when a button is pressed. Attention: This requries are flutter_portal to be placed at the root of your application. See https://pub.dev/packages/flutter_portal',
    properties: [
      LdDocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, Future<dynamic> Function())',
        description:
            '/// The builder for the button that opens the sheet. Calll the `onPress` callback to open the sheet.',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'modal',
        type: 'LdModal',
        description: '',
        features: ['final'],
      ),
      LdDocProperty(
        name: 'useRootNavigator',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [
          LdDocParameter(
            name: 'builder',
            type: 'Widget Function(BuildContext, Future<dynamic> Function())',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'modal',
            type: 'LdModal',
            description: '',
            named: true,
            required: true,
          ),
          LdDocParameter(
            name: 'useRootNavigator',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          LdDocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      )
    ],
    methods: ['createState'],
  ),
  LdDocComponent(
    name: 'LdModalBuilderState',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      LdDocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'open',
      'build',
    ],
  ),
];
