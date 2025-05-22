class DocComponent {
  const DocComponent({
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
  final List<DocConstructor> constructors;
  final List<DocProperty> properties;
  final List<String> methods;

  // Convert a DocComponent instance to a Map<String, dynamic>
  Map<String, dynamic> toJson() => {
        'name': name,
        'isNullSafe': isNullSafe,
        'description': description,
        'constructors': constructors.map((constructor) => constructor.toJson()).toList(),
        'properties': properties.map((property) => property.toJson()).toList(),
        'methods': methods,
      };

  // Create a DocComponent instance from a Map<String, dynamic>
  factory DocComponent.fromJson(Map<String, dynamic> json) {
    return DocComponent(
      name: json['name'] as String,
      isNullSafe: json['isNullSafe'] as bool,
      description: json['description'] as String,
      constructors: (json['constructors'] as List)
          .map((item) => DocConstructor.fromJson(item as Map<String, dynamic>))
          .toList(),
      properties: (json['properties'] as List)
          .map((item) => DocProperty.fromJson(item as Map<String, dynamic>))
          .toList(),
      methods: (json['methods'] as List).map((item) => item as String).toList(),
    );
  }
}

class DocProperty {
  const DocProperty({
    required this.name,
    required this.type,
    required this.description,
    required this.features,
  });

  final String name;
  final String type;
  final String description;
  final List<String> features;

  // Convert a DocProperty instance to a Map<String, dynamic>
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'description': description,
        'features': features,
      };

  // Create a DocProperty instance from a Map<String, dynamic>
  factory DocProperty.fromJson(Map<String, dynamic> json) {
    return DocProperty(
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      features: (json['features'] as List).map((item) => item as String).toList(),
    );
  }
}

class DocConstructor {
  const DocConstructor({
    required this.name,
    required this.signature,
    required this.features,
  });

  final String name;
  final List<DocParameter> signature;
  final List<String> features;

  // Convert a DocConstructor instance to a Map<String, dynamic>
  Map<String, dynamic> toJson() => {
        'name': name,
        'signature': signature.map((parameter) => parameter.toJson()).toList(),
        'features': features,
      };

  // Create a DocConstructor instance from a Map<String, dynamic>
  factory DocConstructor.fromJson(Map<String, dynamic> json) {
    return DocConstructor(
      name: json['name'] as String,
      signature: (json['signature'] as List)
          .map((item) => DocParameter.fromJson(item as Map<String, dynamic>))
          .toList(),
      features: (json['features'] as List).map((item) => item as String).toList(),
    );
  }
}

class DocParameter {
  const DocParameter({
    required this.name,
    required this.type,
    required this.description,
    required this.named,
    required this.required,
  });

  final String name;
  final String description;
  final String type;
  final bool named;
  final bool required;

  // Convert a DocParameter instance to a Map<String, dynamic>
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'description': description,
        'named': named,
        'required': required,
      };

  // Create a DocParameter instance from a Map<String, dynamic>
  factory DocParameter.fromJson(Map<String, dynamic> json) {
    return DocParameter(
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      named: json['named'] as bool,
      required: json['required'] as bool,
    );
  }
}

const docComponents = [
  DocComponent(
    name: 'SizeReportingWidget',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onSizeChange',
        type: 'void Function(Size)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onSizeChange',
            type: 'void Function(Size)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: '_SizeReportingWidgetState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_oldSize',
        type: 'Size?',
        description: '',
        features: [],
      )
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdDrawerItemSection',
    isNullSafe: true,
    description:
        ' A section in the drawer that can contain a collapsable sub-items',
    properties: [
      DocProperty(
        name: 'leading',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'trailing',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'active',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'initiallyExpanded',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'children',
        type: 'List<Widget>?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onTap',
        type: 'dynamic Function()?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'leading',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'trailing',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'initiallyExpanded',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onTap',
            type: 'dynamic Function()?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'active',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'children',
            type: 'List<Widget>?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdDrawerItemSectionState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_expanded',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_theme',
        type: 'LdTheme',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_trailingItem',
        type: 'Widget',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_isExpanded',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdSectionHeader',
    isNullSafe: true,
    description: ' A title for a section in the drawer',
    properties: [
      DocProperty(
        name: 'text',
        type: 'String',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'text',
            type: 'String',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdDrawerHeader',
    isNullSafe: true,
    description:
        ' The header of a drawer, that contains the application or menu title',
    properties: [
      DocProperty(
        name: 'title',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'showBack',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'scrollController',
        type: 'ScrollController?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'title',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'showBack',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'scrollController',
            type: 'ScrollController?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LiquidLocalizations',
    isNullSafe: true,
    description:
        ' Callers can lookup localized strings with an instance of LiquidLocalizations\n returned by `LiquidLocalizations.of(context)`.\n\n Applications need to include `LiquidLocalizations.delegate()` in their app\'s\n `localizationDelegates` list, and the locales they support in the app\'s\n `supportedLocales` list. For example:\n\n ```dart\n import \'generated/liquid_localizations.dart\';\n\n return MaterialApp(\n   localizationsDelegates: LiquidLocalizations.localizationsDelegates,\n   supportedLocales: LiquidLocalizations.supportedLocales,\n   home: MyApplicationHome(),\n );\n ```\n\n ## Update pubspec.yaml\n\n Please make sure to update your pubspec.yaml to include the following\n packages:\n\n ```yaml\n dependencies:\n   # Internationalization support.\n   flutter_localizations:\n     sdk: flutter\n   intl: any # Use the pinned version from flutter_localizations\n\n   # Rest of dependencies\n ```\n\n ## iOS Applications\n\n iOS applications define key application metadata, including supported\n locales, in an Info.plist file that is built into the application bundle.\n To configure the locales supported by your app, you’ll need to edit this\n file.\n\n First, open your project’s ios/Runner.xcworkspace Xcode workspace file.\n Then, in the Project Navigator, open the Info.plist file under the Runner\n project’s Runner folder.\n\n Next, select the Information Property List item, select Add Item from the\n Editor menu, then select Localizations from the pop-up menu.\n\n Select and expand the newly-created Localizations item then, for each\n locale your application supports, add a new item and select the locale\n you wish to add from the pop-up menu in the Value field. This list should\n be consistent with the languages listed in the LiquidLocalizations.supportedLocales\n property.',
    properties: [
      DocProperty(
        name: 'localeName',
        type: 'String',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'delegate',
        type: 'LocalizationsDelegate<LiquidLocalizations>',
        description: '',
        features: [
          'static',
          'const',
        ],
      ),
      DocProperty(
        name: 'localizationsDelegates',
        type: 'List<LocalizationsDelegate<dynamic>>',
        description:
            '/// A list of this localizations delegate along with the default localizations\n/// delegates.\n///\n/// Returns a list of localizations delegates containing this delegate along with\n/// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,\n/// and GlobalWidgetsLocalizations.delegate.\n///\n/// Additional delegates can be added by appending to this list in\n/// MaterialApp. This list does not have to be used at all if a custom list\n/// of delegates is preferred or required.',
        features: [
          'static',
          'const',
        ],
      ),
      DocProperty(
        name: 'supportedLocales',
        type: 'List<Locale>',
        description:
            '/// A list of this localizations delegate\'s supported locales.',
        features: [
          'static',
          'const',
        ],
      ),
      DocProperty(
        name: 'searchAgain',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'search',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'noItemsFound',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'cancel',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'confirm',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'ok',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'done',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'enterText',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'refresh',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'errorOccurred',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'failed',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'retry',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'choose',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'submit',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'selectDate',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'selectTime',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'unknownError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'moreInfo',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'close',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'clearError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'loading',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'networkError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'timeoutError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'formatError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'createNew',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'delete',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'deleteSelected',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'edit',
        type: 'String',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
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
  DocComponent(
    name: '_LiquidLocalizationsDelegate',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LiquidLocalizationsDe',
    isNullSafe: true,
    description: ' The translations for German (`de`).',
    properties: [
      DocProperty(
        name: 'searchAgain',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'search',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'noItemsFound',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'cancel',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'confirm',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'ok',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'done',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'enterText',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'refresh',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'errorOccurred',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'failed',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'retry',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'choose',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'submit',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'selectDate',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'selectTime',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'unknownError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'moreInfo',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'close',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'clearError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'loading',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'networkError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'timeoutError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'formatError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'createNew',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'delete',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'deleteSelected',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'edit',
        type: 'String',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
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
  DocComponent(
    name: 'LiquidLocalizationsEn',
    isNullSafe: true,
    description: ' The translations for English (`en`).',
    properties: [
      DocProperty(
        name: 'searchAgain',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'search',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'noItemsFound',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'cancel',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'confirm',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'ok',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'done',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'enterText',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'refresh',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'errorOccurred',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'failed',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'retry',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'choose',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'submit',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'selectDate',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'selectTime',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'unknownError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'moreInfo',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'close',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'clearError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'loading',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'networkError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'timeoutError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'formatError',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'createNew',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'delete',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'deleteSelected',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'edit',
        type: 'String',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
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
  DocComponent(
    name: '_Default',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [],
  ),
  DocComponent(
    name: '_LdSizeItem',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'multiplier',
        type: 'int',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdAutoSpace',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'children',
        type: 'List<Widget>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'defaultSpacing',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'crossAxisAlignment',
        type: 'CrossAxisAlignment',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'animate',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'children',
            type: 'List<Widget>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'defaultSpacing',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'crossAxisAlignment',
            type: 'CrossAxisAlignment',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'animate',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdBundle',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'children',
        type: 'List<Widget>',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'children',
            type: 'List<Widget>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdInputColorBundle',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'backgroundIdle',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'backgroundHover',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'backgroundFocus',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'backgroundDisabled',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'borderIdle',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'borderHover',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'borderFocus',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'borderDisabled',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'textIdle',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'textHover',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'textFocus',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'textDisabled',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'placeholderIdle',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'placeholderHover',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'placeholderFocus',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'placeholderDisabled',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'iconIdle',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'iconHover',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'iconFocus',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'iconDisabled',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'backgroundIdle',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'backgroundHover',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'backgroundFocus',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'backgroundDisabled',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'borderIdle',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'borderHover',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'borderFocus',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'borderDisabled',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'textIdle',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'textHover',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'textFocus',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'textDisabled',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'placeholderIdle',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'placeholderHover',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'placeholderFocus',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'placeholderDisabled',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'iconIdle',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'iconHover',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'iconFocus',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'iconDisabled',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['const'],
      ),
      DocConstructor(
        name: 'fromTheme',
        signature: [
          DocParameter(
            name: 'theme',
            type: 'LdTheme',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'onSurface',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSelectItem',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'value',
        type: 'T',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'key',
        type: 'Key?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'enabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'searchString',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'value',
            type: 'T',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'enabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSelect',
    isNullSafe: true,
    description: ' a wrapper around [DropdownButton]',
    properties: [
      DocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'items',
        type: 'List<LdSelectItem<T>>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'placeholder',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onSurface',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'value',
        type: 'T?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'focusNode',
        type: 'FocusNode?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'valid',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onChange',
        type: 'dynamic Function(T)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'items',
            type: 'List<LdSelectItem<T>>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onChange',
            type: 'dynamic Function(T)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'placeholder',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'focusNode',
            type: 'FocusNode?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'value',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'valid',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onSurface',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdSelectState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'isOpen',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_focusNode',
        type: 'FocusNode?',
        description: '',
        features: ['late'],
      ),
      DocProperty(
        name: '_overlayController',
        type: 'OverlayPortalController',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_controller',
        type: 'ScrollController',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_menuKey',
        type: 'GlobalKey<State<StatefulWidget>>',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'dispose',
      '_insetDropdownSafely',
      '_buildInitialItem',
      'build',
    ],
  ),
  DocComponent(
    name: 'LdText',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'text',
        type: 'String',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'textAlign',
        type: 'TextAlign?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'maxLines',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'lineHeight',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'overflow',
        type: 'TextOverflow?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'decoration',
        type: 'TextDecoration?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'fontWeight',
        type: 'FontWeight?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'Color?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'processLinks',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'type',
        type: 'LdTextType?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onLinkTap',
        type: 'void Function(String)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'text',
            type: 'String',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'textAlign',
            type: 'TextAlign?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'maxLines',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'overflow',
            type: 'TextOverflow?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'decoration',
            type: 'TextDecoration?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'type',
            type: 'LdTextType?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onLinkTap',
            type: 'void Function(String)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'fontWeight',
            type: 'FontWeight?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'lineHeight',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'processLinks',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSubmitLoadingIndicator',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'loading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'loadingText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'direction',
        type: 'Axis',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'loading',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'loadingText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSubmitDialogBuilder',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'showSubmitButton',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'dialogKey',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'resultBuilder',
            type: 'Widget Function(BuildContext, T, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'errorBuilder',
            type:
                'Widget Function(BuildContext, LdException, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'loadingBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'submitButtonBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSubmitCustomBuilder',
    isNullSafe: true,
    description:
        ' A custom builder that allows you to build your own submit widget.',
    properties: [
      DocProperty(
        name: 'builder',
        type:
            'Widget Function(BuildContext, LdSubmitController<T>, LdSubmitStateType)',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSubmitCenteredBuilder',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'resultBuilder',
            type: 'Widget Function(BuildContext, T, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'submitButtonBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'loadingBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSubmitInlineBuilder',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'showSubmitButton',
        type: 'bool?',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'resultBuilder',
            type: 'Widget Function(BuildContext, T, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'submitButtonBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'errorBuilder',
            type:
                'Widget Function(BuildContext, LdException, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSubmitButton',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'controller',
        type: 'LdSubmitController<dynamic>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'leading',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'trailing',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'controller',
            type: 'LdSubmitController<dynamic>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'leading',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'trailing',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSubmitController',
    isNullSafe: true,
    description:
        ' Handles the lifecyle of a submit action. Pass a [LdSubmitConfig] to the\n controller to configure the submit action.\n Updated LdSubmitController that uses LdRetryController',
    properties: [
      DocProperty(
        name: 'config',
        type: 'LdSubmitConfig<T>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'exceptionMapper',
        type: 'LdExceptionMapper',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_stateController',
        type: 'StreamController<LdSubmitState<T>>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_retryController',
        type: 'LdRetryController',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: 'state',
        type: 'LdSubmitState<T>',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_disposed',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'retryController',
        type: 'LdRetryController',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'stateStream',
        type: 'Stream<LdSubmitState<T>>',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'canCancel',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_isError',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_isLoading',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_isResult',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_isIdle',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'canRetry',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'canRetrigger',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'canTrigger',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'disposed',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'exceptionMapper',
            type: 'LdExceptionMapper',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSubmitConfig',
    isNullSafe: true,
    description: ' A configuration for a submit action.',
    properties: [
      DocProperty(
        name: 'loadingText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'submitText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'allowResubmit',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'withHaptics',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'autoTrigger',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'timeout',
        type: 'Duration?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'allowCancel',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'action',
        type: 'Future<T> Function()',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onCanceled',
        type: 'void Function()?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'retryConfig',
        type: 'LdRetryConfig?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'loadingText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'submitText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'allowResubmit',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'withHaptics',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'autoTrigger',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'allowCancel',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onCanceled',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'timeout',
            type: 'Duration?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'retryConfig',
            type: 'LdRetryConfig?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSubmitState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_type',
        type: 'LdSubmitStateType',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_error',
        type: 'LdException?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_result',
        type: 'T?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'type',
        type: 'LdSubmitStateType',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'error',
        type: 'LdException?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'result',
        type: 'T?',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'type',
            type: 'LdSubmitStateType',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'error',
            type: 'LdException?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSubmitBuilder',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'resultBuilder',
        type: 'Widget Function(BuildContext, T, LdSubmitController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'submitButtonBuilder',
        type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'loadingBuilder',
        type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'errorBuilder',
        type:
            'Widget Function(BuildContext, LdException, LdSubmitController<T>)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'resultBuilder',
            type: 'Widget Function(BuildContext, T, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'submitButtonBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'loadingBuilder',
            type: 'Widget Function(BuildContext, LdSubmitController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSubmit',
    isNullSafe: true,
    description:
        ' A component that handles making requests and displaying errors.\n You can use this component to wrap around a button that makes a request.\n It will handle the loading state and display errors.\n It also has a default exception mapper that will handle common exceptions.\n You can also provide your own exception mapper.\n The default builder is a button that will display a loading spinner when loading.',
    properties: [
      DocProperty(
        name: 'config',
        type: 'LdSubmitConfig<T>?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'controller',
        type: 'LdSubmitController<T>?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'builder',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'submitBuilder',
        type: 'Widget',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'config',
            type: 'LdSubmitConfig<T>?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'controller',
            type: 'LdSubmitController<T>?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdFormHint',
    isNullSafe: true,
    description: ' Hint for a form field',
    properties: [
      DocProperty(
        name: 'hint',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'type',
        type: 'LdHintType',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'hint',
            type: 'String',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdFormItem',
    isNullSafe: true,
    description: ' A form item in a [LdForm]',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'key',
        type: 'String',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'String',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdForm',
    isNullSafe: true,
    description: ' Liquid Design Form that wraps a [Form] widget',
    properties: [
      DocProperty(
        name: 'fields',
        type: 'List<LdFormItem>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'loading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'submitString',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'submitButtonMode',
        type: 'LdButtonMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'hints',
        type: 'Map<String, LdFormHint>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onSubmit',
        type: 'Future<void> Function()?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'fields',
            type: 'List<LdFormItem>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'hints',
            type: 'Map<String, LdFormHint>',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'loading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onSubmit',
            type: 'Future<void> Function()?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'submitButtonMode',
            type: 'LdButtonMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'submitString',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdFormState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_loading',
        type: 'bool',
        description: '',
        features: [],
      )
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdToggle',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'checked',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onChanged',
        type: 'dynamic Function(bool)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'checked',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onChanged',
            type: 'dynamic Function(bool)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdToggleState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_controller',
        type: 'AnimationController',
        description: '',
        features: ['late'],
      ),
      DocProperty(
        name: '_theme',
        type: 'LdTheme',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_thumbSize',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_gap',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdBadge',
    isNullSafe: true,
    description:
        ' A rounded fully opaque label with a background [color].\n Can be used to display a small amount of information.\n',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'symmetric',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'maxLines',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'symmetric',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'maxLines',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdPortalEntry',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'scaleContent',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'key',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'hashCode',
        type: 'int',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdPortalController',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_entries',
        type: 'List<LdPortalEntry>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'entries',
        type: 'List<LdPortalEntry>',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'scaleContent',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'open',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdPortal',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'controller',
        type: 'LdPortalController?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'ProviderOrValue',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'value',
        type: 'T?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'create',
        type: 'T Function(BuildContext)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'dispose',
        type: 'void Function(BuildContext, T)?',
        description:
            '/// Dispose function for the provider, only used if [value] is null',
        features: ['final'],
      ),
      DocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, Widget?)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'child',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'value',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'create',
            type: 'T Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'dispose',
            type: 'void Function(BuildContext, T)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdRunnerLog',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'messages',
        type: 'List<String>',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdRunnerLogState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_node',
        type: 'FocusNode',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdRunnerStep',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'title',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'status',
        type: 'LdIndicatorType',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'trailing',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isExpanded',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onPress',
        type: 'void Function()?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'children',
        type: 'List<Widget>',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'title',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'status',
            type: 'LdIndicatorType',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'trailing',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'isExpanded',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onPress',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdCrudMasterList',
    isNullSafe: true,
    description:
        ' A wrapper around [LdSelectableList] that handles selection and item actions based\n on the [LdCrudListState] of a [LdCrudMasterDetail]. It can be a good fit\n for a master list in a [LdCrudMasterDetail].\n\n For more complex use cases, you might want to use a custom master list\n implementation.',
    properties: [
      DocProperty(
        name: 'openItem',
        type: 'T?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'controller',
        type: 'LdMasterDetailController<T>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'listState',
        type: 'LdCrudListState<T>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'titleBuilder',
        type: 'Widget Function(BuildContext, T, T)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'subtitleBuilder',
        type: 'Widget Function(BuildContext, T, T)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'subContentBuilder',
        type: 'Widget Function(BuildContext, T, T)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'leadingBuilder',
        type: 'Widget Function(BuildContext, T, T)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'trailingBuilder',
        type: 'Widget Function(BuildContext, T, T)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'assumedItemHeight',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isSeparatePage',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'showLoadingIndicator',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'contextActionsBuilder',
        type: 'List<Widget> Function(BuildContext, T, Set<T>)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'controller',
            type: 'LdMasterDetailController<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'titleBuilder',
            type: 'Widget Function(BuildContext, T, T)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'listState',
            type: 'LdCrudListState<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'openItem',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'isSeparatePage',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'subtitleBuilder',
            type: 'Widget Function(BuildContext, T, T)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'subContentBuilder',
            type: 'Widget Function(BuildContext, T, T)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'leadingBuilder',
            type: 'Widget Function(BuildContext, T, T)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'trailingBuilder',
            type: 'Widget Function(BuildContext, T, T)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'assumedItemHeight',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'showLoadingIndicator',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'contextActionsBuilder',
            type: 'List<Widget> Function(BuildContext, T, Set<T>)?',
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
      '_wrapListItemWithContextMenu',
    ],
  ),
  DocComponent(
    name: 'LdMasterDetailShellRouteConfig',
    isNullSafe: true,
    description: ' Configuration for a master detail shell route.',
    properties: [
      DocProperty(
        name: '_id',
        type: 'String',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'detailPath',
        type: 'String',
        description:
            '/// The path, if the detail view is shown (either as a page, dialog, or in\n/// a separate view).',
        features: ['final'],
      ),
      DocProperty(
        name: 'itemToPath',
        type: 'String Function(T)',
        description: '/// A function to get the item ID from an item.',
        features: ['final'],
      ),
      DocProperty(
        name: 'pathToItem',
        type: 'FutureOr<T?> Function(String)',
        description:
            '/// A function to retrieve an item from a path parameter.',
        features: ['final'],
      ),
      DocProperty(
        name: 'id',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'detailPathParam',
        type: 'String',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'detailPath',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'itemToPath',
            type: 'String Function(T)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'pathToItem',
            type: 'FutureOr<T?> Function(String)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'id',
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
  DocComponent(
    name: 'LdMasterDetailBuilders',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'buildDetailTitle',
        type:
            'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMasterTitle',
        type:
            'Widget Function(BuildContext, T?, bool, LdMasterDetailController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetail',
        type:
            'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMaster',
        type:
            'Widget Function(BuildContext, T?, bool, LdMasterDetailController<T>)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMasterActions',
        type:
            'List<Widget> Function(BuildContext, T?, bool, LdMasterDetailController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetailActions',
        type:
            'List<Widget> Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isMasterAppBarLoading',
        type: 'bool Function(T?)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isDetailAppBarLoading',
        type: 'bool Function(T?)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'injectables',
        type: 'List<InheritedProvider<dynamic>> Function(BuildContext)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'buildDetailTitle',
            type:
                'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildMasterTitle',
            type:
                'Widget Function(BuildContext, T?, bool, LdMasterDetailController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildDetail',
            type:
                'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'buildMaster',
            type:
                'Widget Function(BuildContext, T?, bool, LdMasterDetailController<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'buildMasterActions',
            type:
                'List<Widget> Function(BuildContext, T?, bool, LdMasterDetailController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildDetailActions',
            type:
                'List<Widget> Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'isMasterAppBarLoading',
            type: 'bool Function(T?)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'isDetailAppBarLoading',
            type: 'bool Function(T?)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'injectables',
            type: 'List<InheritedProvider<dynamic>> Function(BuildContext)?',
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
  DocComponent(
    name: 'LdMasterDetail',
    isNullSafe: true,
    description:
        ' A master detail view that shows a list of items on the left and a detail view on the right.\n The detail view is shown as a page or a dialog if the screen is small.',
    properties: [
      DocProperty(
        name: 'routeConfigId',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'openItem',
        type: 'T?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'masterDetailFlex',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'navigator',
        type: 'NavigatorState?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'detailPresentationMode',
        type: 'MasterDetailPresentationMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'layoutMode',
        type: 'MasterDetailLayoutMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onOpenItemChange',
        type: 'void Function(T?)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'customSplitPredicate',
        type: 'bool Function(SizingInformation)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isMasterAppBarLoading',
        type: 'bool Function(T?)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isDetailAppBarLoading',
        type: 'bool Function(T?)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetailTitle',
        type:
            'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMasterTitle',
        type:
            'Widget Function(BuildContext, T?, bool, LdMasterDetailController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetail',
        type:
            'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMaster',
        type:
            'Widget Function(BuildContext, T?, bool, LdMasterDetailController<T>)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMasterActions',
        type:
            'List<Widget> Function(BuildContext, T?, bool, LdMasterDetailController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetailActions',
        type:
            'List<Widget> Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'injectables',
        type: 'List<InheritedProvider<dynamic>> Function(BuildContext)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'routeConfigId',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildDetailTitle',
            type:
                'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildMasterTitle',
            type:
                'Widget Function(BuildContext, T?, bool, LdMasterDetailController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildDetail',
            type:
                'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'buildMaster',
            type:
                'Widget Function(BuildContext, T?, bool, LdMasterDetailController<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'buildMasterActions',
            type:
                'List<Widget> Function(BuildContext, T?, bool, LdMasterDetailController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildDetailActions',
            type:
                'List<Widget> Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'detailPresentationMode',
            type: 'MasterDetailPresentationMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'layoutMode',
            type: 'MasterDetailLayoutMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'openItem',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'navigator',
            type: 'NavigatorState?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onOpenItemChange',
            type: 'void Function(T?)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'masterDetailFlex',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'customSplitPredicate',
            type: 'bool Function(SizingInformation)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'isMasterAppBarLoading',
            type: 'bool Function(T?)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'isDetailAppBarLoading',
            type: 'bool Function(T?)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'injectables',
            type: 'List<InheritedProvider<dynamic>> Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      DocConstructor(
        name: 'builders',
        signature: [
          DocParameter(
            name: 'builders',
            type: 'LdMasterDetailBuilders<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'openItem',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'masterDetailFlex',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'navigator',
            type: 'NavigatorState?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'detailPresentationMode',
            type: 'MasterDetailPresentationMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'layoutMode',
            type: 'MasterDetailLayoutMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onOpenItemChange',
            type: 'void Function(T?)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'customSplitPredicate',
            type: 'bool Function(SizingInformation)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'routeConfigId',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['factory'],
      ),
    ],
    methods: [
      'createShellRoute',
      'createCompositeShellRoute',
      'createState',
    ],
  ),
  DocComponent(
    name: '_LdMasterDetailState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_openItem',
        type: 'T?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_routeConfig',
        type:
            'MapEntry<String, Map<String, LdMasterDetailShellRouteConfig<dynamic>>>?',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_controller',
        type: 'LdMasterDetailController<T>',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_inDetailView',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'useSplitView',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_detailRouteConfig',
        type: 'LdMasterDetailShellRouteConfig<T>?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'isMasterAppBarLoading',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'isDetailsAppBarLoading',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_navigator',
        type: 'NavigatorState',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      '_getInjectables',
      'initState',
      '_openInitialItem',
      '_handleInitialRoute',
      'didUpdateWidget',
      '_onCloseItem',
      '_onOpenItem',
      '_onDialogDismiss',
      'onPop',
      '_didChangeSize',
      'buildMaster',
      'buildMasterActions',
      'buildDetail',
      'buildDetailActions',
      'buildContent',
      '_useSplitView',
      'build',
      '_buildDetailPage',
    ],
  ),
  DocComponent(
    name: '_DetailPage',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'buildDetailTitle',
        type:
            'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetail',
        type:
            'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetailActions',
        type:
            'List<Widget> Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'item',
        type: 'T',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'controller',
        type: 'LdMasterDetailController<T>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isDetailsAppBarLoading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'buildDetailTitle',
            type:
                'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildDetail',
            type:
                'Widget Function(BuildContext, T, bool, LdMasterDetailController<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'buildDetailActions',
            type:
                'List<Widget> Function(BuildContext, T, bool, LdMasterDetailController<T>)?',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'item',
            type: 'T',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'controller',
            type: 'LdMasterDetailController<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'isDetailsAppBarLoading',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdCrudOperations',
    isNullSafe: true,
    description:
        ' Defines a repository that can perform CRUD operations on a given type [T]\n and fetch a list of items of type [T].',
    properties: [
      DocProperty(
        name: 'fetchAll',
        type:
            'Future<LdListPage<T>> Function({required int offset, required int pageSize, String? pageToken})',
        description: '',
        features: [],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'create',
      'update',
      'delete',
      'batchDelete',
    ],
  ),
  DocComponent(
    name: 'LdCrudMasterDetailBuilders',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'buildDetailTitle',
        type:
            'Widget Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMasterTitle',
        type:
            'Widget Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetail',
        type:
            'Widget Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMaster',
        type:
            'Widget Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMasterActions',
        type:
            'List<Widget> Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetailActions',
        type:
            'List<Widget> Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'buildDetailTitle',
            type:
                'Widget Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildMasterTitle',
            type:
                'Widget Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildDetail',
            type:
                'Widget Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'buildMaster',
            type:
                'Widget Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'buildMasterActions',
            type:
                'List<Widget> Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildDetailActions',
            type:
                'List<Widget> Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
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
  DocComponent(
    name: 'LdCrudMasterDetail',
    isNullSafe: true,
    description:
        ' [LdCrudMasterDetail] is a wrapper around [LdMasterDetail] that provides CRUD\n functionality for a list of items of type [T].\n\n It handles various CRUD operations like create, update, delete, and fetch\n and also performs the usual UI operations like selecting and deselecting\n items or updating the UI based on the state and result of a CRUD operation.',
    properties: [
      DocProperty(
        name: 'crud',
        type: 'LdCrudOperations<T>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'defaultActionSettings',
        type: 'LdCrudActionSettings',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetailTitle',
        type:
            'Widget Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMasterTitle',
        type:
            'Widget Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetail',
        type:
            'Widget Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMaster',
        type:
            'Widget Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildMasterActions',
        type:
            'List<Widget> Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildDetailActions',
        type:
            'List<Widget> Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isMasterAppBarLoading',
        type: 'bool Function(T?, LdCrudListState<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isDetailAppBarLoading',
        type: 'bool Function(T?, LdCrudListState<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'masterDetailBuilder',
        type:
            'LdMasterDetail<T> Function(BuildContext, LdMasterDetailBuilders<T>)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'crud',
            type: 'LdCrudOperations<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'masterDetailBuilder',
            type:
                'LdMasterDetail<T> Function(BuildContext, LdMasterDetailBuilders<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'buildDetail',
            type:
                'Widget Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'buildMaster',
            type:
                'Widget Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'buildDetailTitle',
            type:
                'Widget Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildMasterTitle',
            type:
                'Widget Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildMasterActions',
            type:
                'List<Widget> Function(BuildContext, T?, T?, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buildDetailActions',
            type:
                'List<Widget> Function(BuildContext, T, T, bool, LdMasterDetailController<T>, LdCrudListState<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'defaultActionSettings',
            type: 'LdCrudActionSettings',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'isMasterAppBarLoading',
            type: 'bool Function(T?, LdCrudListState<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'isDetailAppBarLoading',
            type: 'bool Function(T?, LdCrudListState<T>)?',
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
  DocComponent(
    name: 'LdCrudMasterDetailState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'crud',
        type: 'LdCrudOperations<T>',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_listState',
        type: 'LdCrudListState<T>',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: 'listState',
        type: 'LdCrudListState<T>',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      '_isMasterAppBarLoading',
      '_isDetailAppBarLoading',
      'initState',
      'build',
      '_wrapCrudMasterBuilder',
      '_wrapCrudDetailBuilder',
      '_wrapCrudActionWithKey',
      '_wrapBuildMasterActions',
      '_wrapBuildDetailActions',
    ],
  ),
  DocComponent(
    name: 'LdCrudDeleteAction',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'item',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'confirmationMessage',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'builder',
            type:
                'Widget Function(LdCrudMasterDetailState<T>, void Function())?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: ['_defaultBuilder'],
  ),
  DocComponent(
    name: 'LdContextAwareCrudActionBuilder',
    isNullSafe: true,
    description:
        ' A builder that creates context-aware widgets based on the ancestor widget context.\n Similar to Flutter\'s Builder widget but with built-in logic for different UI contexts.\n\n It offers some default builders if you provide [actionIcon] and [actionText].\n If you provide [appBarActionBuilder], [contextMenuActionBuilder], or [defaultBuilder], they will override the\n default behavior.',
    properties: [
      DocProperty(
        name: 'appBarActionBuilder',
        type: 'Widget Function(BuildContext, void Function())?',
        description: '/// Builder function for app bar context',
        features: ['final'],
      ),
      DocProperty(
        name: 'contextMenuActionBuilder',
        type: 'Widget Function(BuildContext, void Function())?',
        description: '/// Builder function for context menu',
        features: ['final'],
      ),
      DocProperty(
        name: 'defaultBuilder',
        type: 'Widget Function(BuildContext, void Function())?',
        description: '/// Default builder function for other contexts',
        features: ['final'],
      ),
      DocProperty(
        name: 'triggerAction',
        type: 'void Function()',
        description:
            '/// The action to trigger when the widget is interacted with',
        features: ['final'],
      ),
      DocProperty(
        name: 'masterDetail',
        type: 'LdCrudMasterDetailState<T>',
        description:
            '/// The master detail state for accessing multi-select mode and other state',
        features: ['final'],
      ),
      DocProperty(
        name: 'actionIcon',
        type: 'IconData?',
        description:
            '/// Icon to use in the app bar and context menu default builders',
        features: ['final'],
      ),
      DocProperty(
        name: 'actionText',
        type: 'String?',
        description: '/// Text to display in context menu and default button',
        features: ['final'],
      ),
      DocProperty(
        name: 'hideInAppBarInSingleSelectMode',
        type: 'bool',
        description: '/// Icon to use in the app bar context',
        features: ['final'],
      ),
      DocProperty(
        name: 'hideInContextMenuInSingleSelectMode',
        type: 'bool',
        description:
            '/// Whether to hide the widget in single-select mode when in context menu',
        features: ['final'],
      ),
      DocProperty(
        name: 'hideInAppBarInMultiSelectMode',
        type: 'bool?',
        description:
            '/// Whether to hide the widget in single-select mode when in app bar',
        features: ['final'],
      ),
      DocProperty(
        name: 'hideInContextMenuInMultiSelectMode',
        type: 'bool?',
        description:
            '/// Whether to hide the widget in multi-select mode when in context menu',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'triggerAction',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'masterDetail',
            type: 'LdCrudMasterDetailState<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'appBarActionBuilder',
            type: 'Widget Function(BuildContext, void Function())?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'contextMenuActionBuilder',
            type: 'Widget Function(BuildContext, void Function())?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'defaultBuilder',
            type: 'Widget Function(BuildContext, void Function())?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'actionIcon',
            type: 'IconData?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'actionText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'hideInAppBarInSingleSelectMode',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'hideInContextMenuInSingleSelectMode',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'hideInAppBarInMultiSelectMode',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'hideInContextMenuInMultiSelectMode',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      DocConstructor(
        name: 'create',
        signature: [
          DocParameter(
            name: 'masterDetail',
            type: 'LdCrudMasterDetailState<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'triggerAction',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['factory'],
      ),
      DocConstructor(
        name: 'edit',
        signature: [
          DocParameter(
            name: 'masterDetail',
            type: 'LdCrudMasterDetailState<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'triggerAction',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['factory'],
      ),
      DocConstructor(
        name: 'delete',
        signature: [
          DocParameter(
            name: 'masterDetail',
            type: 'LdCrudMasterDetailState<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'triggerAction',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['factory'],
      ),
      DocConstructor(
        name: 'deleteMultiple',
        signature: [
          DocParameter(
            name: 'masterDetail',
            type: 'LdCrudMasterDetailState<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'triggerAction',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: ['factory'],
      ),
    ],
    methods: ['build'],
  ),
  DocComponent(
    name: 'LdCrudActionSettings',
    isNullSafe: true,
    description:
        ' Settings to configure the behavior of CRUD actions.\n [showLoadingDialog] controls whether to show a loading dialog during the action.\n [errorNotificationMessage] is a message to be displayed in case of an error.\n You can customize these settings when creating a [LdCrudAction].\n The default settings (from [LdCrudMasterDetail]) are used if not provided.',
    properties: [
      DocProperty(
        name: 'showLoadingDialog',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'errorNotificationMessage',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'showLoadingDialog',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'errorNotificationMessage',
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
  DocComponent(
    name: 'LdCrudAction',
    isNullSafe: true,
    description:
        ' A widget that provides a CRUD action button for a [LdCrudMasterDetail].\n It handles the action logic and provides a button to trigger the action.\n\n There are several built-in actions available, such as:\n - [LdCrudCreateAction]\n - [LdCrudUpdateAction]\n - [LdCrudDeleteAction]\n - [LdCrudDeleteSelectedAction]\n\n You can create custom actions by providing your own [action] and [obtainArg].\n\n When the button is pressed, it will first obtain the argument using [obtainArg],\n then trigger the action using [action]. If the action is successful, it will\n call [onActionCompleted] with the result.\n\n It uses [LdSubmit] to handle the loading state and error handling.',
    properties: [
      DocProperty(
        name: 'builder',
        type: 'Widget Function(LdCrudMasterDetailState<T>, void Function())',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'obtainArg',
        type:
            'FutureOr<Arg?> Function(LdCrudMasterDetailState<T>, LdMasterDetailController<T>)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'action',
        type: 'FutureOr<Result> Function(LdCrudOperations<T>, Arg)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onActionCompleted',
        type:
            'dynamic Function(LdCrudMasterDetailState<T>, LdMasterDetailController<T>, Arg, Result)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'settings',
        type: 'LdCrudActionSettings?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'builder',
            type:
                'Widget Function(LdCrudMasterDetailState<T>, void Function())',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'action',
            type: 'FutureOr<Result> Function(LdCrudOperations<T>, Arg)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'obtainArg',
            type:
                'FutureOr<Arg?> Function(LdCrudMasterDetailState<T>, LdMasterDetailController<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onActionCompleted',
            type:
                'dynamic Function(LdCrudMasterDetailState<T>, LdMasterDetailController<T>, Arg, Result)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'settings',
            type: 'LdCrudActionSettings?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdCrudActionState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_obtainedArg',
        type: 'Arg?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_submitController',
        type: 'LdSubmitController<Result>?',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'build',
      '_buildSubmitButton',
      '_buildErrorButton',
      '_showErrorDialog',
      '_handleArgEvent',
      'dispose',
    ],
  ),
  DocComponent(
    name: 'LdCrudCreateAction',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'getNewItem',
            type: 'FutureOr<T?> Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onItemCreated',
            type: 'dynamic Function(LdCrudMasterDetailState<T>, T)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'builder',
            type:
                'Widget Function(LdCrudMasterDetailState<T>, void Function())?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: ['_defaultBuilder'],
  ),
  DocComponent(
    name: 'LdMasterDetailController',
    isNullSafe: true,
    description:
        ' A controller for managing the state of a master-detail view.\n\n Right now, this controller provides methods to interact with the master-detail state,\n allowing [LdMasterDetailBuilder]s to open, close, and query the currently open item.',
    properties: [
      DocProperty(
        name: 'getOpenItem',
        type: 'T? Function()',
        description:
            '/// Returns the currently open item, or null if no item is open.',
        features: ['final'],
      ),
      DocProperty(
        name: '_onOpenItem',
        type: 'Future<bool> Function(T)',
        description:
            '/// Opens an item in the detail view.\n///\n/// Returns a Future<bool> indicating whether the operation was successful.',
        features: ['final'],
      ),
      DocProperty(
        name: '_onCloseItem',
        type: 'void Function()',
        description: '/// Closes the currently open item.',
        features: ['final'],
      ),
      DocProperty(
        name: 'isItemOpen',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'getOpenItem',
            type: 'T? Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onOpenItem',
            type: 'Future<bool> Function(T)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onCloseItem',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      'openItem',
      'closeItem',
    ],
  ),
  DocComponent(
    name: 'LdCrudUpdateAction',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'getUpdatedItem',
            type: 'FutureOr<T?> Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onItemUpdated',
            type: 'dynamic Function(LdCrudMasterDetailState<T>, T)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'actionButtonBuilder',
            type:
                'Widget Function(LdCrudMasterDetailState<T>, void Function())?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: ['_defaultBuilder'],
  ),
  DocComponent(
    name: 'LdCrudDeleteSelectedAction',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'confirmationMessage',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'actionButtonBuilder',
            type:
                'Widget Function(LdCrudMasterDetailState<T>, void Function())?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: ['_defaultBuilder'],
  ),
  DocComponent(
    name: 'LdCard',
    isNullSafe: true,
    description:
        ' A simple card component with a shadow to elevate it from the page. Header and Footer are optional and separated by color.',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'padding',
        type: 'EdgeInsets?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'header',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'footer',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'expandChild',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'flat',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'header',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'footer',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'flat',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'expandChild',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'padding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdButton',
    isNullSafe: true,
    description: ' A pressable button',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onPressed',
        type: 'Function',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'focusNode',
        type: 'FocusNode?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'trailing',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'leading',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'loading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'width',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'autoLoading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'progress',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'autoFocus',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'mode',
        type: 'LdButtonMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'alignment',
        type: 'MainAxisAlignment?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'active',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'circular',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'borderRadius',
        type: 'BorderRadius?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'loadingText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'errorText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onPressed',
            type: 'Function',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'autoLoading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'borderRadius',
            type: 'BorderRadius?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'active',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'width',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'focusNode',
            type: 'FocusNode?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'autoFocus',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'alignment',
            type: 'MainAxisAlignment?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'leading',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'circular',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'loading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'loadingText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'errorText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'mode',
            type: 'LdButtonMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'progress',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'trailing',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdButtonState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_loading',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_failed',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_error',
        type: 'LdException?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_theme',
        type: 'LdTheme',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_child',
        type: 'Widget',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_trailing',
        type: 'Widget',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_alignment',
        type: 'MainAxisAlignment',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'centerText',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_buttonContent',
        type: 'Widget',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_leading',
        type: 'Widget',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_circular',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: '_ButtonShape',
    isNullSafe: true,
    description: ' Build the button shape',
    properties: [
      DocProperty(
        name: 'mode',
        type: 'LdButtonMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'colors',
        type: 'LdColorBundle',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'borderRadius',
        type: 'BorderRadius?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'center',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'width',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'circular',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'status',
        type: 'LdTouchableStatus',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'mode',
            type: 'LdButtonMode',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'colors',
            type: 'LdColorBundle',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'width',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'status',
            type: 'LdTouchableStatus',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'circular',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'center',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdBlurringHeader',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'scrollController',
        type: 'ScrollController',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'borderRadius',
        type: 'BorderRadius?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'scrollController',
            type: 'ScrollController',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdBlurringHeaderState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'scrollOffset',
        type: 'double',
        description: '',
        features: [],
      )
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdContainer',
    isNullSafe: true,
    description:
        ' Allows you to horizontally center your content on a larger screen by padding it on the sides',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'padding',
        type: 'EdgeInsets?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'maxWidth',
        type: 'double',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'maxWidth',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'padding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdPalette',
    isNullSafe: true,
    description: ' Describes how to build a pallete of colors for a theme.',
    properties: [
      DocProperty(
        name: 'isDark',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'primary',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'secondary',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'success',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'warning',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'error',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'neutral',
        type: 'LdColor',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'background',
        type: 'Color',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: 'surface',
        type: 'Color',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: 'border',
        type: 'Color',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: 'stroke',
        type: 'Color',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: 'text',
        type: 'Color',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
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
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'isDark',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'primary',
            type: 'LdColor',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'secondary',
            type: 'LdColor',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'success',
            type: 'LdColor',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'warning',
            type: 'LdColor',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'error',
            type: 'LdColor',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdColor',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'shades',
        type: 'List<Color>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_center',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_darkCenter',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'luminanceThreshold',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabledAlpha',
        type: 'int',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'shades',
            type: 'List<Color>',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: '_center',
            type: 'int',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: '_darkCenter',
            type: 'int',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'luminanceThreshold',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdCheckbox',
    isNullSafe: true,
    description: ' A checkbox control.',
    properties: [
      DocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'checked',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onChanged',
        type: 'dynamic Function(bool)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'checked',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onChanged',
            type: 'dynamic Function(bool)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdCheckboxState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'hovering',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'tapping',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: ['build'],
  ),
  DocComponent(
    name: 'LdTimePicker',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'useRootNavigator',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'value',
        type: 'TimeOfDay?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onChanged',
        type: 'void Function(TimeOfDay?)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'minutePrecision',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buttonMode',
        type: 'LdButtonMode',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'useRootNavigator',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onChanged',
            type: 'void Function(TimeOfDay?)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buttonMode',
            type: 'LdButtonMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'value',
            type: 'TimeOfDay?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdTimePickerWidget',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'minutePrecision',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'initialTime',
        type: 'TimeOfDay?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onTimeSelected',
        type: 'void Function(TimeOfDay)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'initialTime',
            type: 'TimeOfDay?',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onTimeSelected',
            type: 'void Function(TimeOfDay)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'minutePrecision',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdTimePickerWidgetState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_hourController',
        type: 'FixedExtentScrollController',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_minuteController',
        type: 'FixedExtentScrollController',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_hourFocusNode',
        type: 'FocusNode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_hourControllerText',
        type: 'TextEditingController',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_minuteControllerText',
        type: 'TextEditingController',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_time',
        type: 'TimeOfDay?',
        description: '',
        features: ['late'],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdRadio',
    isNullSafe: true,
    description: ' a radio box',
    properties: [
      DocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'checked',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onChanged',
        type: 'dynamic Function(bool)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'checked',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onChanged',
            type: 'dynamic Function(bool)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdTouchableSurface',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'active',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'autoFocus',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'mode',
        type: 'LdTouchableSurfaceMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'focusNode',
        type: 'FocusNode?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onTap',
        type: 'dynamic Function()',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onLongPress',
        type: 'dynamic Function()?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, LdColorBundle, LdTouchableStatus)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onTap',
            type: 'dynamic Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onLongPress',
            type: 'dynamic Function()?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'builder',
            type:
                'Widget Function(BuildContext, LdColorBundle, LdTouchableStatus)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'focusNode',
            type: 'FocusNode?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'active',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'mode',
            type: 'LdTouchableSurfaceMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdTouchableSurfaceState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_hovering',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_pressed',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_hasFocus',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_focusNode',
        type: 'FocusNode?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_createdFocusNode',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'active',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_colorBundle',
        type: 'LdColorBundle',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      '_safeSetState',
      'dispose',
      'build',
    ],
  ),
  DocComponent(
    name: 'LdColorBundle',
    isNullSafe: true,
    description: ' Current active colors',
    properties: [
      DocProperty(
        name: 'surface',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'border',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'text',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'placeholder',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'icon',
        type: 'Color',
        description: '',
        features: ['late'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'surface',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'text',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'border',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'placeholder',
            type: 'Color',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdTouchableStatus',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'hovering',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'focus',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'active',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'hovering',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'focus',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'active',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdAccordion',
    isNullSafe: true,
    description: ' a collection of collapsible items in a group.',
    properties: [
      DocProperty(
        name: 'childBuilder',
        type: 'Widget Function(BuildContext, int)',
        description:
            '/// Function that is called to build each item in the accordion.',
        features: ['final'],
      ),
      DocProperty(
        name: 'headerBuilder',
        type: 'Widget Function(BuildContext, int)',
        description:
            '/// Function that is called to build each header in the accordion.',
        features: ['final'],
      ),
      DocProperty(
        name: 'itemCount',
        type: 'int',
        description: '/// The number of items in the accordion.',
        features: ['final'],
      ),
      DocProperty(
        name: 'initialOpenIndex',
        type: 'Set<int>',
        description:
            '/// The index of the items that should be open by default.',
        features: ['final'],
      ),
      DocProperty(
        name: 'headerPadding',
        type: 'EdgeInsets?',
        description: '/// The padding to apply to the header.',
        features: ['final'],
      ),
      DocProperty(
        name: 'childPadding',
        type: 'EdgeInsets?',
        description: '/// The padding to apply to the child.',
        features: ['final'],
      ),
      DocProperty(
        name: 'allowMultipleOpen',
        type: 'bool',
        description: '/// Whether or not multiple items can be open at once.',
        features: ['final'],
      ),
      DocProperty(
        name: 'speed',
        type: 'Duration',
        description: '/// The duration of the animation.',
        features: ['final'],
      ),
      DocProperty(
        name: 'curveExpand',
        type: 'Curve',
        description: '/// The curve to use when expanding.',
        features: ['final'],
      ),
      DocProperty(
        name: 'curveCollapse',
        type: 'Curve',
        description: '/// The curve to use when collapsing.',
        features: ['final'],
      ),
      DocProperty(
        name: 'wrapActiveInCard',
        type: 'bool',
        description: '/// Whether or not to wrap the active item in a card.',
        features: ['final'],
      ),
      DocProperty(
        name: 'flatCard',
        type: 'bool',
        description: '/// Whether or not to use a flat card.',
        features: ['final'],
      ),
      DocProperty(
        name: 'shrinkWrap',
        type: 'bool',
        description:
            '/// Whether or not to shrink the accordion to the content.',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'childBuilder',
            type: 'Widget Function(BuildContext, int)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'headerBuilder',
            type: 'Widget Function(BuildContext, int)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'itemCount',
            type: 'int',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'allowMultipleOpen',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'childPadding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'curveCollapse',
            type: 'Curve',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'curveExpand',
            type: 'Curve',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'headerPadding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'initialOpenIndex',
            type: 'Set<int>',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'wrapActiveInCard',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'flatCard',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'speed',
            type: 'Duration',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'shrinkWrap',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      DocConstructor(
        name: 'fromList',
        signature: [
          DocParameter(
            name: 'items',
            type: 'List<LdAccordionItem>',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'wrapActiveInCard',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'flatCard',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'allowMultipleOpen',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdAccordionItem',
    isNullSafe: true,
    description:
        ' item of an accordion used in utility constructor [LdAccordion.fromList].',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'header',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdAccordionChild',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'header',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'wrapActiveInCard',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'speed',
        type: 'Duration',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'headerPadding',
        type: 'EdgeInsets',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'childPadding',
        type: 'EdgeInsets',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onPressed',
        type: 'dynamic Function()',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'curveExpand',
        type: 'Curve',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'curveCollapse',
        type: 'Curve',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'collapsed',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'flatCard',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'collapsed',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'wrapActiveInCard',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'flatCard',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onPressed',
            type: 'dynamic Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'headerPadding',
            type: 'EdgeInsets',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'childPadding',
            type: 'EdgeInsets',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'speed',
            type: 'Duration',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'header',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'curveExpand',
            type: 'Curve',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'curveCollapse',
            type: 'Curve',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdAccordionState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'openIndex',
        type: 'Set<int>',
        description: '',
        features: [],
      )
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdTabs',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'children',
        type: 'List<Widget>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'controller',
        type: 'TabController?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'children',
            type: 'List<Widget>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdAvatar',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'circular',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'circular',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
    methods: ['build'],
  ),
  DocComponent(
    name: 'LdDatePicker',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'minDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'maxDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'value',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'displayFormat',
        type: 'String',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buttonMode',
        type: 'LdButtonMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'useRootNavigator',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onChanged',
        type: 'void Function(DateTime?)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_initialDate',
        type: 'DateTime',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'initialDateJiffy',
        type: 'Jiffy',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'initialDateString',
        type: 'String',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'value',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'minDate',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'maxDate',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'displayFormat',
            type: 'String',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'buttonMode',
            type: 'LdButtonMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onChanged',
            type: 'void Function(DateTime?)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_DatePickerSheet',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'value',
        type: 'DateTime',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onChanged',
        type: 'void Function(DateTime)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'label',
        type: 'String',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'minDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'maxDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'dismiss',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'value',
            type: 'DateTime',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'label',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onChanged',
            type: 'void Function(DateTime)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'dismiss',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'minDate',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_DatePickerSheetState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_selectedDate',
        type: 'DateTime',
        description: '',
        features: ['late'],
      ),
      DocProperty(
        name: '_pageController',
        type: 'PageController?',
        description: '',
        features: ['late'],
      ),
      DocProperty(
        name: '_animating',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_pageControllerIsValid',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_currentPage',
        type: 'int',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_viewDate',
        type: 'DateTime',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'showTodayButton',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'nextMonthIsValid',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'previousMonthIsValid',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: '_MonthView',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'viewDate',
        type: 'DateTime',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'selectedDate',
        type: 'DateTime',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onSelected',
        type: 'void Function(DateTime)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'minDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'maxDate',
        type: 'DateTime?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'viewDate',
            type: 'DateTime',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'selectedDate',
            type: 'DateTime',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onSelected',
            type: 'void Function(DateTime)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'minDate',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'maxDate',
            type: 'DateTime?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdTag',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onDismiss',
        type: 'Function?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onDismiss',
            type: 'Function?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdContextMenu',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'visible',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'dismissOnOutsideTap',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'listenForTaps',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'blurMode',
        type: 'LdContextMenuBlurMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'zoomMode',
        type: 'LdContextZoomMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'positionMode',
        type: 'LdContextPositionMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, bool, void Function())',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'menuBuilder',
        type: 'Widget Function(BuildContext, void Function())',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'builder',
            type: 'Widget Function(BuildContext, bool, void Function())',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'menuBuilder',
            type: 'Widget Function(BuildContext, void Function())',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'dismissOnOutsideTap',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'blurMode',
            type: 'LdContextMenuBlurMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'zoomMode',
            type: 'LdContextZoomMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'listenForTaps',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'visible',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'positionMode',
            type: 'LdContextPositionMode',
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
  DocComponent(
    name: '_LdContextMenuState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_triggerKey',
        type: 'GlobalKey<State<StatefulWidget>>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_overlayPortalController',
        type: 'OverlayPortalController',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_triggerBox',
        type: 'RenderBox?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_menuKey',
        type: 'GlobalKey<State<StatefulWidget>>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_visible',
        type: 'bool',
        description: '',
        features: ['late'],
      ),
      DocProperty(
        name: '_cursorPosition',
        type: 'Offset?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_mobile',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_shouldBlur',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_shouldZoom',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_effectivePositionMode',
        type: 'LdContextPositionMode',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'didUpdateWidget',
      '_dismiss',
      '_resizeMenuToScreen',
      '_insetMenuPositionToScreen',
      '_getMenuPosition',
      '_open',
      '_buildTriggerDetector',
      '_buildZoom',
      'build',
    ],
  ),
  DocComponent(
    name: '_PostFrameCallback',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'postFrameCallback',
        type: 'void Function(GlobalKey<State<StatefulWidget>>)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'postFrameCallback',
            type: 'void Function(GlobalKey<State<StatefulWidget>>)',
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
  DocComponent(
    name: '_PostFrameCallbackState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_key',
        type: 'GlobalKey<State<StatefulWidget>>',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdCol',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'title',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'sort',
        type: 'int Function(T, T)?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'weight',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'title',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'sort',
            type: 'int Function(T, T)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdTable',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'columns',
        type: 'List<LdCol<T>>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'rows',
        type: 'List<T>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'buildRow',
        type: 'List<Widget> Function(T)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onSelectChange',
        type: 'dynamic Function(T, bool)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'selectedRows',
        type: 'Set<T>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'allowSort',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'header',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'rowCount',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'density',
        type: 'LdTableDensity',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'columns',
            type: 'List<LdCol<T>>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'rows',
            type: 'List<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'buildRow',
            type: 'List<Widget> Function(T)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onSelectChange',
            type: 'dynamic Function(T, bool)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'selectedRows',
            type: 'Set<T>',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'header',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'allowSort',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'rowCount',
            type: 'int',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdTableState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'width',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_sortByCol',
        type: 'int',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_sortDir',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_sortedRows',
        type: 'List<T>',
        description: '',
        features: ['late'],
      ),
      DocProperty(
        name: '_rowPadding',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_checkboxSize',
        type: 'LdSize',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'selectable',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'ExpandablePageView',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'itemBuilder',
        type: 'Widget Function(BuildContext, int)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'controller',
        type: 'PageController?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onPageChanged',
        type: 'void Function(int)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'reverse',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'itemBuilder',
            type: 'Widget Function(BuildContext, int)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'controller',
            type: 'PageController?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onPageChanged',
            type: 'void Function(int)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'reverse',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_ExpandablePageViewState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_pageController',
        type: 'PageController?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_heights',
        type: 'Map<int, double>',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_currentPage',
        type: 'int',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_currentHeight',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdSpringState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'position',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'force',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'velocity',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isMoving',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'position',
            type: 'double',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'force',
            type: 'double',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'velocity',
            type: 'double',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSpring',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'mass',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'springConstant',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'dampingCoefficient',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'position',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'initialPosition',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'paused',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onAnimationEnd',
        type: 'void Function(BuildContext, LdSpringState)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, LdSpringState)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'mass',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'springConstant',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'dampingCoefficient',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'builder',
            type: 'Widget Function(BuildContext, LdSpringState)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'paused',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'position',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'initialPosition',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_Spring',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'timeStep',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'springConstant',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'dampingCoefficient',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'mass',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'targetPosition',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'position',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'velocity',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'acceleration',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'active',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'springForce',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'dampingForce',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'force',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'springConstant',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'dampingCoefficient',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'position',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'targetPosition',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdSpringState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_spring',
        type: '_Spring',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_ticker',
        type: 'Ticker?',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdChainedSprings',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'count',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'mass',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'springConstant',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'dampingCoefficient',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'initialPosition',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'targetPosition',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'reversed',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, List<LdSpringState>)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'count',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'mass',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'springConstant',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'dampingCoefficient',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'builder',
            type: 'Widget Function(BuildContext, List<LdSpringState>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'reversed',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'initialPosition',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdChainedSpringsState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_springs',
        type: 'List<_Spring>',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_ticker',
        type: 'Ticker?',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdHint',
    isNullSafe: true,
    description: ' A colored badge with an icon and a text',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'type',
        type: 'LdHintType',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'crossAxisAlignment',
        type: 'CrossAxisAlignment',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'type',
            type: 'LdHintType',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'crossAxisAlignment',
            type: 'CrossAxisAlignment',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdInfoIcon',
    isNullSafe: true,
    description: ' Draws an i in emd shapes',
    properties: [],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
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
  DocComponent(
    name: 'LdExclamationIcon',
    isNullSafe: true,
    description: ' An exclamation icon in emd shapes',
    properties: [],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
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
  DocComponent(
    name: 'LdCrossIcon',
    isNullSafe: true,
    description: ' A cross icon.',
    properties: [],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
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
  DocComponent(
    name: 'LdBreadcrumb',
    isNullSafe: true,
    description: ' A breadcrumb widget.',
    properties: [
      DocProperty(
        name: 'children',
        type: 'List<Widget>',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'children',
            type: 'List<Widget>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      DocConstructor(
        name: 'fromStrings',
        signature: [
          DocParameter(
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
  DocComponent(
    name: 'LdInput',
    isNullSafe: true,
    description: ' An input field',
    properties: [
      DocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'hint',
        type: 'String',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onChanged',
        type: 'dynamic Function(String?)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onBlur',
        type: 'dynamic Function(String?)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onSubmitted',
        type: 'dynamic Function(String?)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'controller',
        type: 'TextEditingController?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'autofillHints',
        type: 'Iterable<String>?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'obscureText',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'autofocus',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'textInputAction',
        type: 'TextInputAction?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'keyboardType',
        type: 'TextInputType?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'focusNode',
        type: 'FocusNode?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'valid',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'showClear',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'loading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'trailingHint',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'maxLines',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'minLines',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'hint',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'controller',
            type: 'TextEditingController?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'obscureText',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'maxLines',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'minLines',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'autofocus',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'showClear',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onBlur',
            type: 'dynamic Function(String?)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'valid',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'loading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'focusNode',
            type: 'FocusNode?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'autofillHints',
            type: 'Iterable<String>?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'textInputAction',
            type: 'TextInputAction?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onSubmitted',
            type: 'dynamic Function(String?)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'keyboardType',
            type: 'TextInputType?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onChanged',
            type: 'dynamic Function(String?)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'trailingHint',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdInputState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_focusNode',
        type: 'FocusNode',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_createdFocusNode',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_controller',
        type: 'TextEditingController',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_createdController',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_hovering',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
      'build',
    ],
  ),
  DocComponent(
    name: 'LdShortcutIndicator',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'shortcut',
        type: 'SingleActivator',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'shortcut',
            type: 'SingleActivator',
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
  DocComponent(
    name: 'LdSlider',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'onSlideComplete',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'hint',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onSlideComplete',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'hint',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdSliderState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_value',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_max',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_threshold',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_sliding',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_controller',
        type: 'AnimationController?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_opacityController',
        type: 'AnimationController?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_reachedThreshold',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_thumbSize',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_thumbPadding',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
      '_activeColor',
      '_borderColor',
      '_buildThumb',
      'build',
    ],
  ),
  DocComponent(
    name: 'LdThemedAppBuilder',
    isNullSafe: true,
    description:
        ' Allows you to build a styled material app\n ```dart\n LdThemedAppBuilder((context,themeData) => MaterialApp(\n  theme: themeData,\n home: ....))\n ```',
    properties: [
      DocProperty(
        name: 'appBuilder',
        type: 'MaterialApp Function(BuildContext, ThemeData)',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdThemedAppBuilderState',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdThemeProvider',
    isNullSafe: true,
    description:
        ' Provides a theme to all the components in the widget tree\n Theme can be accessed using LdTheme.of(context)',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'theme',
        type: 'LdTheme?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'brightnessMode',
        type: 'LdThemeBrightnessMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'darkPalette',
        type: 'LdPalette?',
        description:
            '/// The dark palette to use when [autoBrightness] is true defaults to [deepOcean]',
        features: ['final'],
      ),
      DocProperty(
        name: 'lightPalette',
        type: 'LdPalette?',
        description:
            '/// The light palette to use when [autoBrightness] is true defaults to [ocean]',
        features: ['final'],
      ),
      DocProperty(
        name: 'autoSize',
        type: 'bool',
        description:
            '/// If true the theme will change based on the type of the device\n/// will use LdThemeSize.m on mobile and LdThemeSize.s on desktop',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'theme',
            type: 'LdTheme?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'brightnessMode',
            type: 'LdThemeBrightnessMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'autoSize',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'darkPalette',
            type: 'LdPalette?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdThemeProviderState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_palette',
        type: 'LdPalette?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_themeSize',
        type: 'LdThemeSize?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_createdTheme',
        type: 'LdTheme?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_darkPalette',
        type: 'LdPalette',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_lightPalette',
        type: 'LdPalette',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_theme',
        type: 'LdTheme',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdTheme',
    isNullSafe: true,
    description:
        ' Provides a theme to all the components in the widget tree\n Theme can be accessed using LdTheme.of(context)',
    properties: [
      DocProperty(
        name: '_palette',
        type: 'LdPalette',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_defaultSize',
        type: 'LdThemeSize',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_sizingConfig',
        type: 'LdSizingConfig',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_screenRadius',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_fontFamily',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_headlineFontFamily',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_fontFamilyPackage',
        type: 'String?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'palette',
        type: 'LdPalette',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeSize',
        type: 'LdThemeSize',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'sizingConfig',
        type: 'LdSizingConfig',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'screenRadius',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'fontFamily',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'headlineFontFamily',
        type: 'String',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'fontFamilyPackage',
        type: 'String?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'borderWidth',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'isDark',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'absolute',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'primary',
        type: 'LdColor',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'secondary',
        type: 'LdColor',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'success',
        type: 'LdColor',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'warning',
        type: 'LdColor',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'error',
        type: 'LdColor',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'primaryColor',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'primaryColorText',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'secondaryColor',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'secondaryColorText',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'errorColor',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'errorColorText',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'successColor',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'successColorText',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'warningColor',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'warningColorText',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'background',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'text',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'textMuted',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'border',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'stroke',
        type: 'Color',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'surface',
        type: 'Color',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdSizingConfig',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'radiusXS',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'radiusS',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'radiusM',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'radiusL',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeSPaddingXS',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeSPaddingS',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeSPaddingM',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeSPaddingL',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeMPaddingXS',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeMPaddingS',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeMPaddingM',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeMPaddingL',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeLPaddingXS',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeLPaddingS',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeLPaddingM',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'themeLPaddingL',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'radiusXS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'radiusS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'radiusM',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'radiusL',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'themeSPaddingXS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'themeSPaddingS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'themeSPaddingM',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'themeSPaddingL',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'themeMPaddingXS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'themeMPaddingS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'themeMPaddingM',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'themeMPaddingL',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'themeLPaddingXS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'themeLPaddingS',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'themeLPaddingM',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdChoose',
    isNullSafe: true,
    description: ' A widget that presents a dropdown in a seperate page.',
    properties: [
      DocProperty(
        name: 'items',
        type: 'Iterable<LdSelectItem<T>>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'allowEmpty',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'mode',
        type: 'LdChooseMode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'useRootNavigator',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'multiple',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'value',
        type: 'Set<T>?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onChange',
        type: 'dynamic Function(Set<T>)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'truncateDisplay',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'placeholder',
        type: 'Text?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'enableSearch',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'items',
            type: 'Iterable<LdSelectItem<T>>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'allowEmpty',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'useRootNavigator',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'multiple',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'mode',
            type: 'LdChooseMode',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onChange',
            type: 'dynamic Function(Set<T>)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'placeholder',
            type: 'Text?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'truncateDisplay',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'enableSearch',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'value',
            type: 'Set<T>?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdChooseState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_sheetKey',
        type: 'Key',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_enableSearch',
        type: 'bool',
        description: '',
        features: ['late'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'didUpdateWidget',
      'dispose',
      '_onTap',
      'build',
    ],
  ),
  DocComponent(
    name: '_LdChoosePage',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'label',
        type: 'String',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'label',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdChooseList',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'items',
        type: 'Iterable<LdSelectItem<T>>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'value',
        type: 'Set<T>?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'multiple',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'shrinkWrap',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onDismiss',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onChange',
        type: 'dynamic Function(Set<T>)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'enableSearch',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'allowEmpty',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'items',
            type: 'Iterable<LdSelectItem<T>>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'value',
            type: 'Set<T>?',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'multiple',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onChange',
            type: 'dynamic Function(Set<T>)?',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'allowEmpty',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onDismiss',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'shrinkWrap',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'enableSearch',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdChooseListState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_value',
        type: 'Set<T>',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_searchController',
        type: 'TextEditingController',
        description: '',
        features: ['late'],
      ),
      DocProperty(
        name: '_searchResults',
        type: 'List<LdSelectItem<T>>?',
        description: '',
        features: [],
      ),
      DocProperty(
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
      DocConstructor(
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
  DocComponent(
    name: '_LdPadding',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'balanced',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdAnimatedLoadingGradient',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'height',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'width',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'width',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdAnimatedLoadingGradientState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'colorList',
        type: 'List<Color>',
        description: '',
        features: ['late'],
      ),
      DocProperty(
        name: 'alignmentList',
        type: 'List<Alignment>',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'index',
        type: 'int',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'bottomColor',
        type: 'Color',
        description: '',
        features: ['late'],
      ),
      DocProperty(
        name: 'topColor',
        type: 'Color',
        description: '',
        features: ['late'],
      ),
      DocProperty(
        name: 'begin',
        type: 'Alignment',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'end',
        type: 'Alignment',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdPaginator',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'fetchListFunction',
        type:
            'Future<LdListPage<T>> Function({required int offset, required int pageSize, String? pageToken})',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'pageSize',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'initialOffset',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'debounceTime',
        type: 'Duration',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_items',
        type: 'List<T?>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_requestedOffsets',
        type: 'Set<int>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_debounceTimer',
        type: 'Timer?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_totalItems',
        type: 'int',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_busy',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_error',
        type: 'Object?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_currentOperation',
        type: 'Completer<dynamic>?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'items',
        type: 'List<T?>',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'currentItemCount',
        type: 'int',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'totalItems',
        type: 'int',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'busy',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'error',
        type: 'Object?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'hasError',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'fetchListFunction',
            type:
                'Future<LdListPage<T>> Function({required int offset, required int pageSize, String? pageToken})',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'pageSize',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'autoLoad',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'initialOffset',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'debounceTime',
            type: 'Duration',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      ),
      DocConstructor(
        name: 'fromList',
        signature: [
          DocParameter(
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
      '_setError',
      '_setBusy',
      'getAllLoadedItems',
      'isItemLoaded',
      'getItemAt',
      '_fetchItemsAtOffset',
      'fetchItemsAtOffset',
      'fetchPageAtOffset',
      'refreshList',
      'reset',
      '_reset',
      '_debounce',
      '_safeExecute',
      '_debounceAndSafeExecute',
    ],
  ),
  DocComponent(
    name: 'LdCrudListState',
    isNullSafe: true,
    description:
        ' Extends [LdPaginator] to add CRUD operations and item states.',
    properties: [
      DocProperty(
        name: 'itemStates',
        type: 'Map<dynamic, LdSubmitState<T>>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_selectedItems',
        type: 'Set<T>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'selectedItems',
        type: 'Set<T>',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'selectedItemCount',
        type: 'int',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'isMultiSelectMode',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'fetchListFunction',
            type:
                'Future<LdListPage<T>> Function({required int offset, required int pageSize, String? pageToken})',
            description: '',
            named: true,
            required: true,
          )
        ],
        features: [],
      )
    ],
    methods: [
      'updateItemSelection',
      'handleItemStateEvent',
      'clearItemState',
      'getItemOptimistically',
      'getItemError',
      'isItemLoading',
      'isItemSelected',
      '_add',
      '_update',
      '_delete',
    ],
  ),
  DocComponent(
    name: 'LdListSeperator',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onSurface',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onSurface',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_ListItem',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'item',
        type: 'T?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'type',
        type: '_ListItemType',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'separationCriterion',
        type: 'SeparationCriterion?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'position',
        type: 'int?',
        description:
            '/// The position that this item belongs to.\n/// Can be null for separator items.\n/// For regular items:\n/// - If item is null but position is not, the item is yet to be loaded\n/// - If both item and position are null, it\'s likely a separator',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'item',
            type: 'T?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'type',
            type: '_ListItemType',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'separationCriterion',
            type: 'SeparationCriterion?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'position',
            type: 'int?',
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
  DocComponent(
    name: 'LdList',
    isNullSafe: true,
    description:
        ' A sophisticated list widget that supports:\n - Pagination with loading indicators\n - Item grouping with custom separators\n - Bidirectional scrolling\n - Error handling and retry mechanisms\n - Pull-to-refresh functionality\n - Empty state handling',
    properties: [
      DocProperty(
        name: 'itemBuilder',
        type: 'Widget Function(BuildContext, T, int)',
        description: '/// Function that builds a [T] in the list.',
        features: ['final'],
      ),
      DocProperty(
        name: 'emptyBuilder',
        type: 'Widget Function(BuildContext, Future<void> Function())?',
        description:
            '/// Built when there are no items call [refresh] to trigger [paginator]\'s refresh\n/// function',
        features: ['final'],
      ),
      DocProperty(
        name: 'errorBuilder',
        type: 'Widget Function(BuildContext, Object?, void Function())?',
        description:
            '/// Built when an error occurs while loading data [error] is the error that\n/// occurred and [retry] is a callback to retry the operation.',
        features: ['final'],
      ),
      DocProperty(
        name: 'loadingBuilder',
        type: 'Widget Function(BuildContext, int, int)?',
        description:
            '/// Built when there are missing items that are being loaded',
        features: ['final'],
      ),
      DocProperty(
        name: 'groupingCriterion',
        type: 'GroupingCriterion Function(T)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'groupHeaderBuilder',
        type: 'Widget Function(BuildContext, GroupingCriterion)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'separatorBuilder',
        type: 'Widget Function(BuildContext)?',
        description:
            '/// Built between items. Not called between items and group headers.',
        features: ['final'],
      ),
      DocProperty(
        name: 'paginator',
        type: 'LdPaginator<T>',
        description: '/// The paginator to use',
        features: ['final'],
      ),
      DocProperty(
        name: 'scrollController',
        type: 'ScrollController?',
        description:
            '/// The scroll controller to use.\n/// If not provided, the list will use the primary scroll controller if [primary] is true.\n/// Otherwise, it will create a new scroll controller.',
        features: ['final'],
      ),
      DocProperty(
        name: 'assumedItemHeight',
        type: 'double?',
        description:
            '/// The assumed height of an item. Is used to calculate the scroll space\n/// to virtually allocate for items that are not yet loaded.',
        features: ['final'],
      ),
      DocProperty(
        name: 'areEqual',
        type: 'bool Function(T, T)?',
        description: '/// Function that checks if two items are equal.',
        features: ['final'],
      ),
      DocProperty(
        name: 'shrinkWrap',
        type: 'bool',
        description:
            '/// Whether the list should be wrapped in a shrink-wrap container.',
        features: ['final'],
      ),
      DocProperty(
        name: 'physics',
        type: 'ScrollPhysics?',
        description: '/// The physics of the list.',
        features: ['final'],
      ),
      DocProperty(
        name: 'primary',
        type: 'bool',
        description:
            '/// Whether the list is the primary scroll view of the screen.',
        features: ['final'],
      ),
      DocProperty(
        name: 'header',
        type: 'Widget?',
        description: '/// A widget that is displayed at the top of the list.',
        features: ['final'],
      ),
      DocProperty(
        name: 'footer',
        type: 'Widget?',
        description:
            '/// A widget that is displayed at the bottom of the list.',
        features: ['final'],
      ),
      DocProperty(
        name: 'retryConfig',
        type: 'LdRetryConfig?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'scrollController',
            type: 'ScrollController?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'areEqual',
            type: 'bool Function(T, T)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'emptyBuilder',
            type: 'Widget Function(BuildContext, Future<void> Function())?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'errorBuilder',
            type: 'Widget Function(BuildContext, Object?, void Function())?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'header',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'loadingBuilder',
            type: 'Widget Function(BuildContext, int, int)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'assumedItemHeight',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'physics',
            type: 'ScrollPhysics?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'itemBuilder',
            type: 'Widget Function(BuildContext, T, int)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'paginator',
            type: 'LdPaginator<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'groupHeaderBuilder',
            type: 'Widget Function(BuildContext, GroupingCriterion)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'groupingCriterion',
            type: 'GroupingCriterion Function(T)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'separatorBuilder',
            type: 'Widget Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'primary',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'footer',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'shrinkWrap',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdListState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_groupedItems',
        type: 'List<_ListItem<T, GroupingCriterion>>',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_scrollController',
        type: 'ScrollController',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_assumeItemKey',
        type: 'GlobalKey<State<StatefulWidget>>?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_retryController',
        type: 'LdRetryController',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_effectiveAssumedHeight',
        type: 'double?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'calculatedItemHeight',
        type: 'double?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_scrollPhysics',
        type: 'ScrollPhysics',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      '_initializeRetryController',
      '_setupDataListener',
      'didUpdateWidget',
      '_shouldRegroupItems',
      '_shouldUpdateDataListener',
      'dispose',
      '_groupItems',
      '_onDataChange',
      '_updateRetryControllerState',
      '_onRefresh',
      '_updateGroupedItems',
      '_createInterspersedList',
      '_buildListView',
      '_buildSlivers',
      '_buildListItems',
      '_buildListItem',
      '_buildPlaceholderItem',
      '_buildActualItem',
      '_buildEmpty',
      '_buildLoader',
      '_buildLoadMore',
      '_buildError',
      '_maybePerformInitialScroll',
      'build',
    ],
  ),
  DocComponent(
    name: 'LdListItem',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'leading',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'trailing',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'padding',
        type: 'EdgeInsets?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'title',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'active',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'subtitle',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onTap',
        type: 'void Function()?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onLongPress',
        type: 'void Function()?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'width',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'selectDisabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onSelectionChange',
        type: 'void Function(bool)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'radioSelection',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'borderRadius',
        type: 'BorderRadius?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'subContent',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isSelected',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'trailingForward',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'tradeLeadingForSelectionControl',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'showBothTrailingAndTrailingForward',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'showSelectionControls',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'leading',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'trailing',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'title',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'active',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'isSelected',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'radioSelection',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'selectDisabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'trailingForward',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'borderRadius',
            type: 'BorderRadius?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'showSelectionControls',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onSelectionChange',
            type: 'void Function(bool)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'tradeLeadingForSelectionControl',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'padding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onTap',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onLongPress',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'subtitle',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'width',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'subContent',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'showBothTrailingAndTrailingForward',
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
  DocComponent(
    name: 'LdSelectableList',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'itemBuilder',
        type:
            'Widget Function({required BuildContext context, required int index, required bool isMultiSelect, required T item, required void Function(bool) onSelectionChange, required void Function() onTap, required bool selected})',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'listBuilder',
        type:
            'LdList<T, GroupingCriterion> Function(BuildContext, ScrollController, Widget Function(BuildContext, T, int))',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'multiSelect',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'paginator',
        type: 'LdPaginator<T>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onSelectionChange',
        type: 'void Function(Set<T>)?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'itemBuilder',
            type:
                'Widget Function({required BuildContext context, required int index, required bool isMultiSelect, required T item, required void Function(bool) onSelectionChange, required void Function() onTap, required bool selected})',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'listBuilder',
            type:
                'LdList<T, GroupingCriterion> Function(BuildContext, ScrollController, Widget Function(BuildContext, T, int))',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onSelectionChange',
            type: 'void Function(Set<T>)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'multiSelect',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'paginator',
            type: 'LdPaginator<T>',
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
  DocComponent(
    name: '_LdSelectableListState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_selectedItems',
        type: '_SetNotifier<T>',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_dragRectItems',
        type: '_SetNotifier<T>',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_changeNotifier',
        type: 'ChangeNotifier',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_focusNode',
        type: 'FocusNode',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_scrollController',
        type: 'ScrollController',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_itemKeys',
        type: 'Map<T, GlobalKey<State<StatefulWidget>>>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_rootKey',
        type: 'GlobalKey<State<StatefulWidget>>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_shiftPressed',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_ctrlPressed',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'isMultiSelect',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'setState',
      'dispose',
      'didUpdateWidget',
      'isSelected',
      'onTap',
      '_selectRange',
      'onSelectionChange',
      '_onUpdateDragRect',
      '_onEndDrag',
      '_onCancel',
      '_onKeyEvent',
      'build',
    ],
  ),
  DocComponent(
    name: '_SetNotifier',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'allowMultiple',
        type: 'bool',
        description: '',
        features: [],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'value',
            type: 'Set<T>?',
            description: '',
            named: false,
            required: false,
          ),
          DocParameter(
            name: 'allowMultiple',
            type: 'bool',
            description: '',
            named: false,
            required: false,
          ),
        ],
        features: [],
      )
    ],
    methods: [
      'add',
      'toggle',
      'remove',
      'clear',
      'addAll',
      'contains',
    ],
  ),
  DocComponent(
    name: '_DragRect',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'onUpdateRect',
        type: 'void Function(Rect)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onEndDrag',
        type: 'void Function(Rect)',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onCancel',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'onUpdateRect',
            type: 'void Function(Rect)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onEndDrag',
            type: 'void Function(Rect)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onCancel',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: '_DragRectState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_dragStartOffset',
        type: 'Offset?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_dragEndOffset',
        type: 'Offset?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_overlayPortalController',
        type: 'OverlayPortalController',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_dragRect',
        type: 'Rect?',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: ['build'],
  ),
  DocComponent(
    name: 'LdListPage',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'newItems',
        type: 'List<T>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'hasMore',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'total',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'nextPageToken',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'error',
        type: 'Object?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'newItems',
            type: 'List<T>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'hasMore',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'total',
            type: 'int',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'error',
            type: 'Object?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'nextPageToken',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      ),
      DocConstructor(
        name: 'fromList',
        signature: [
          DocParameter(
            name: 'items',
            type: 'List<T>',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'offset',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'pageSize',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['factory'],
      ),
    ],
    methods: ['copyWith'],
  ),
  DocComponent(
    name: 'LdListItemToggle',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'leading',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'title',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'subtitle',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'checked',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onChanged',
        type: 'void Function(bool)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'borderRadius',
        type: 'BorderRadius?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'padding',
        type: 'EdgeInsets?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'leading',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'title',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'subtitle',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'checked',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onChanged',
            type: 'void Function(bool)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'padding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
    methods: ['build'],
  ),
  DocComponent(
    name: 'LdListItemLoading',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'hasLeading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'hasTrailing',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'hasSubContent',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'hasSubtitle',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'hasLeading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'hasTrailing',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'hasSubContent',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdListEmpty',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'onRefresh',
        type: 'Function?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'text',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onRefresh',
            type: 'Function?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdWindowFrame',
    isNullSafe: true,
    description:
        ' Show a frame around the window that has a surface color. Only is shown on\n Windows, Linux, and MacOS.',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'frameBuilder',
        type: 'Widget Function(BuildContext, Widget)',
        description:
            '/// The frameBuilder can be used to wrap the child in a frame. This is useful\n/// for wrapping it in a [MoveWindow] widget.',
        features: ['final'],
      ),
      DocProperty(
        name: 'title',
        type: 'Text',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'showWindowFrame',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'title',
            type: 'Text',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdIndicator',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'type',
        type: 'LdIndicatorType',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'customSize',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'type',
            type: 'LdIndicatorType',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdMute',
    isNullSafe: true,
    description: ' LdMute allows you to use the LdTheme to make a muted text',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdFormLabel',
    isNullSafe: true,
    description:
        ' A label for a form field. This is a convenience widget that wraps a [Text]\n and [ldSpacerS]. THIS WIDGET contains outer padding.!',
    properties: [
      DocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'direction',
        type: 'Axis',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'direction',
            type: 'Axis',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdDivider',
    isNullSafe: true,
    description: ' Divides some content with a horizontal',
    properties: [
      DocProperty(
        name: 'height',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'insetForLeading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'height',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'insetForLeading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdCollapse',
    isNullSafe: true,
    description: ' A utility to collapse some content',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '/// Widget to collapse',
        features: ['final'],
      ),
      DocProperty(
        name: 'collapsed',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'axis',
        type: 'Axis',
        description: '/// Which direction to collapse',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'collapsed',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'axis',
            type: 'Axis',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdCollapseState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_controller',
        type: 'AnimationController?',
        description: '',
        features: [],
      )
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdOrb',
    isNullSafe: true,
    description:
        ' an animated illustration of an orb filled with liquid that has some waves and a [filling] level.',
    properties: [
      DocProperty(
        name: 'size',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'filling',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'paintBackground',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'filling',
            type: 'double',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'size',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'paintBackground',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdOrbState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_animationController',
        type: 'AnimationController?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_tween',
        type: 'Tween<double>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_animation',
        type: 'Animation<double>?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_angle',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_streamSubscription',
        type: 'StreamSubscription<AccelerometerEvent>?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_fill',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'ReflectionPainter',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'theme',
        type: 'LdTheme',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'inset',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'orbSize',
        type: 'Size',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'theme',
            type: 'LdTheme',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: '_OrbPainter',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_orbSize',
        type: 'Size',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'fillPercentage',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'paintBackground',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'animationProgress',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'theme',
        type: 'LdTheme',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'inset',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'width',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'height',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: '_orbSize',
            type: 'Size',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'fillPercentage',
            type: 'double',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'animationProgress',
            type: 'double',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'paintBackground',
            type: 'bool',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'MeasureSizeRenderObject',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'oldSize',
        type: 'Size?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'sizeNotifier',
        type: 'ValueNotifier<Size>',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'sizeNotifier',
            type: 'ValueNotifier<Size>',
            description: '',
            named: false,
            required: true,
          )
        ],
        features: [],
      )
    ],
    methods: ['performLayout'],
  ),
  DocComponent(
    name: 'MeasureSize',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'sizeNotifier',
        type: 'ValueNotifier<Size>',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'sizeNotifier',
            type: 'ValueNotifier<Size>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
    methods: [
      'createRenderObject',
      'updateRenderObject',
    ],
  ),
  DocComponent(
    name: 'LdSheetType',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'index',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'insets',
        type: 'EdgeInsets',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'theme',
            type: 'LdTheme',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'insets',
            type: 'EdgeInsets',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'topRadius',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'bottomRadius',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdDialogType',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'fixedSize',
        type: 'Size?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'theme',
        type: 'LdTheme',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'index',
        type: 'int',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'theme',
            type: 'LdTheme',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'index',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdModalBuilder',
    isNullSafe: true,
    description:
        ' A utility widget that displays a sheet when a button is pressed. Attention: This requries are flutter_portal to be placed at the root of your application. See https://pub.dev/packages/flutter_portal',
    properties: [
      DocProperty(
        name: 'builder',
        type: 'Widget Function(BuildContext, Future<dynamic> Function())',
        description:
            '/// The builder for the button that opens the sheet. Calll the `onPress` callback to open the sheet.',
        features: ['final'],
      ),
      DocProperty(
        name: 'modal',
        type: 'LdModal',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'useRootNavigator',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'builder',
            type: 'Widget Function(BuildContext, Future<dynamic> Function())',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'modal',
            type: 'LdModal',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'useRootNavigator',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdModalBuilderState',
    isNullSafe: true,
    description: '',
    properties: [],
    constructors: [
      DocConstructor(
        name: '',
        signature: [],
        features: [],
      )
    ],
    methods: [
      'initState',
      'open',
      'dispose',
      'build',
    ],
  ),
  DocComponent(
    name: 'LdModalPage',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'builder',
        type: 'LdModal',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'LocalKey?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'name',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdModal',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'modalContent',
        type: 'Widget Function(BuildContext)?',
        description: '/// The content of the sheet.',
        features: ['final'],
      ),
      DocProperty(
        name: 'contentSlivers',
        type: 'List<Widget> Function(BuildContext)?',
        description:
            '/// The slivers to be added to the sheet. Used instead of [modalContent] if provided.',
        features: ['final'],
      ),
      DocProperty(
        name: 'enableScaling',
        type: 'bool?',
        description:
            '/// Whether the sheet should scale the content behind when opened. Defaults to true on iOS mobile devices.',
        features: ['final'],
      ),
      DocProperty(
        name: 'userCanDismiss',
        type: 'bool',
        description: '/// Whether the sheet can be dismissed',
        features: ['final'],
      ),
      DocProperty(
        name: 'showDismissButton',
        type: 'bool',
        description: '/// Whether to show the dismiss button',
        features: ['final'],
      ),
      DocProperty(
        name: 'onDismiss',
        type: 'void Function()?',
        description: '/// Callback for when the sheet is dismissed.',
        features: ['final'],
      ),
      DocProperty(
        name: 'disableScrolling',
        type: 'bool',
        description:
            '/// Whether the sheet should disable scrolling. Defaults to false.',
        features: ['final'],
      ),
      DocProperty(
        name: 'actions',
        type: 'List<Widget> Function(BuildContext)?',
        description: '/// The actions to be added to the sheet.',
        features: ['final'],
      ),
      DocProperty(
        name: 'mode',
        type: 'LdModalTypeMode?',
        description: '/// The mode of the modal.',
        features: ['final'],
      ),
      DocProperty(
        name: 'index',
        type: 'int?',
        description:
            '/// Override the modal index. By default the LdPortalController will increment the index for each modal.',
        features: ['final'],
      ),
      DocProperty(
        name: 'key',
        type: 'Key?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'noHeader',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'contentPadding',
        type: 'EdgeInsets?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'headerPadding',
        type: 'EdgeInsets?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'actionBarPadding',
        type: 'EdgeInsets?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'title',
        type: 'Widget?',
        description: '/// The title of the modal.',
        features: ['final'],
      ),
      DocProperty(
        name: 'injectables',
        type: 'List<InheritedProvider<dynamic>> Function(BuildContext)?',
        description:
            '/// A list of listenables to be injected into the modal. That can be read\n/// from the various builder contexts, useful for updating the modal content\n/// based on external state like a viewmodel.',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize?',
        description: '/// The size of the modal.',
        features: ['final'],
      ),
      DocProperty(
        name: 'fixedDialogSize',
        type: 'Size?',
        description: '/// Fixed dialog size',
        features: ['final'],
      ),
      DocProperty(
        name: 'topRadius',
        type: 'double?',
        description: '/// The radius for the top of the modal.',
        features: ['final'],
      ),
      DocProperty(
        name: 'bottomRadius',
        type: 'double?',
        description: '/// The radius for the bottom of the modal.',
        features: ['final'],
      ),
      DocProperty(
        name: 'insets',
        type: 'EdgeInsets?',
        description:
            '/// The inset for the modal from the edges of the screen.',
        features: ['final'],
      ),
      DocProperty(
        name: 'useSafeArea',
        type: 'bool',
        description:
            '/// Whether the modal should use safe area. Defaults to true.',
        features: ['final'],
      ),
      DocProperty(
        name: 'showDragHandle',
        type: 'bool?',
        description: '/// Whether to show the drag handle. Defaults to true.',
        features: ['final'],
      ),
      DocProperty(
        name: 'actionBar',
        type: 'Widget Function(BuildContext)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'shouldScale',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_enableDrag',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'enableScaling',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'modalContent',
            type: 'Widget Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'userCanDismiss',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'disableScrolling',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'noHeader',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'showDragHandle',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'contentPadding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'headerPadding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'title',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'actions',
            type: 'List<Widget> Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'contentSlivers',
            type: 'List<Widget> Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'mode',
            type: 'LdModalTypeMode?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'showDismissButton',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'injectables',
            type: 'List<InheritedProvider<dynamic>> Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onDismiss',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'actionBar',
            type: 'Widget Function(BuildContext)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'actionBarPadding',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'topRadius',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'bottomRadius',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'insets',
            type: 'EdgeInsets?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'useSafeArea',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'fixedDialogSize',
            type: 'Size?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
      '_autoShowsSheet',
      '_isSheet',
      '_hasSabGradient',
      '_getSheetType',
      '_getInjectables',
      '_getTrailingNavBarWidget',
      '_navigationBarPadding',
      '_contentPadding',
      '_sabPadding',
      '_getPageList',
      '_getStickyActionBar',
      'asRoute',
      '_getContentDecorator',
      '_getModalBarrierColor',
      'show',
    ],
  ),
  DocComponent(
    name: '_LdActionBarGradient',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          )
        ],
        features: ['const'],
      )
    ],
    methods: ['build'],
  ),
  DocComponent(
    name: 'LdSwitch',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'onChanged',
        type: 'dynamic Function(T)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'children',
        type: 'Map<T, Widget>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'label',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'disabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'value',
        type: 'T',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'children',
            type: 'Map<T, Widget>',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'value',
            type: 'T',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'disabled',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'label',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdExceptionRetryIndicator',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'retryState',
        type: 'LdRetryState',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'remainingRetryTime',
        type: 'Duration',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'totalRetryDelay',
        type: 'Duration',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'progress',
        type: 'double',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdExceptionMapperProvider',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'exceptionMapper',
        type: 'LdExceptionMapper?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdExceptionMapper',
    isNullSafe: true,
    description:
        ' A mapper that maps exceptions to LdExceptions that are displayed in the UI.\n You can provide your own exception mapper to handle custom exceptions.\n The default exception mapper will handle common exceptions like network errors.',
    properties: [
      DocProperty(
        name: 'localizations',
        type: 'LiquidLocalizations',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onException',
        type: 'LdException? Function(dynamic, {StackTrace? stackTrace})?',
        description:
            '/// A function that can be used to handle custom exceptions. If the function\n/// returns a non-null LdException, it will be used instead of the default\n/// exception mapper. Otherwise, the default exception mapper will be used.\n/// This function will never be called if the exception is already an LdException.',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'localizations',
            type: 'LiquidLocalizations',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdExceptionMoreInfoButton',
    isNullSafe: true,
    description:
        ' LdExceptionMoreInfoButton is a button that will open a dialog with more info',
    properties: [
      DocProperty(
        name: 'error',
        type: 'LdException?',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdExceptionDialog',
    isNullSafe: true,
    description: ' Renders an LdException in a dialog',
    properties: [
      DocProperty(
        name: 'error',
        type: 'LdException',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'primaryButton',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'error',
            type: 'LdException',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'primaryButton',
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
      'build',
      'show',
    ],
  ),
  DocComponent(
    name: 'LdException',
    isNullSafe: true,
    description:
        ' A renderable exception. Has a message, more info, and a type (LdHintType).\n Can also contain a stack trace as well as the flag that the action causing\n the exception can be retried.',
    properties: [
      DocProperty(
        name: 'message',
        type: 'String',
        description: '/// The message of the exception.',
        features: ['final'],
      ),
      DocProperty(
        name: 'moreInfo',
        type: 'String?',
        description:
            '/// Additional information about the exception, e.g. a detailed explanation\n/// of what went wrong.',
        features: ['final'],
      ),
      DocProperty(
        name: 'canRetry',
        type: 'bool',
        description:
            '/// Whether the action causing the exception can be retried.',
        features: ['final'],
      ),
      DocProperty(
        name: 'type',
        type: 'LdHintType',
        description:
            '/// The type of the exception. By default, it is [LdHintType.error].',
        features: ['final'],
      ),
      DocProperty(
        name: 'exception',
        type: 'dynamic',
        description: '/// The actual [Exception] that caused this exception.',
        features: ['final'],
      ),
      DocProperty(
        name: 'attempt',
        type: 'int?',
        description:
            '/// The number of attempts that have been made to resolve the exception.\n/// This can be useful for debugging.',
        features: ['final'],
      ),
      DocProperty(
        name: 'stackTrace',
        type: 'StackTrace?',
        description: '/// The stack trace of the exception.',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'message',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'canRetry',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'type',
            type: 'LdHintType',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'moreInfo',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'attempt',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'stackTrace',
            type: 'StackTrace?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'exception',
            type: 'dynamic',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: [],
      ),
      DocConstructor(
        name: 'fromDynamic',
        signature: [
          DocParameter(
            name: 'context',
            type: 'BuildContext',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'e',
            type: 'dynamic',
            description: '',
            named: false,
            required: true,
          ),
        ],
        features: ['factory'],
      ),
    ],
    methods: ['copyWith'],
  ),
  DocComponent(
    name: 'LdRetryConfig',
    isNullSafe: true,
    description: ' Configuration for retry behavior',
    properties: [
      DocProperty(
        name: 'maxAttempts',
        type: 'int',
        description:
            '/// Maximum number of attempts (including the initial attempt).\n/// If set to 1, the retry button will be hidden immediately.\n/// Defaults to 4 (i.e. 3 retries).',
        features: ['final'],
      ),
      DocProperty(
        name: 'enableAutomaticRetries',
        type: 'bool',
        description: '/// Whether to enable automatic retries',
        features: ['final'],
      ),
      DocProperty(
        name: 'baseDelay',
        type: 'Duration',
        description:
            '/// Base delay for retries (will be multiplied by exponential backoff)\n/// Can only be used in combination with [enableAutomaticRetries].',
        features: ['final'],
      ),
      DocProperty(
        name: 'hideManualRetryButton',
        type: 'bool',
        description:
            '/// Whether to hide the manual retry button.\n/// Can only be used in combination with [enableAutomaticRetries].',
        features: ['final'],
      ),
      DocProperty(
        name: 'useJitter',
        type: 'bool',
        description:
            '/// Whether to add jitter to retry delays\n/// Can only be used in combination with [enableAutomaticRetries].',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'maxAttempts',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'enableAutomaticRetries',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'hideManualRetryButton',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'baseDelay',
            type: 'Duration',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'useJitter',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      DocConstructor(
        name: 'noRetries',
        signature: [],
        features: ['factory'],
      ),
      DocConstructor(
        name: 'unlimitedManualRetries',
        signature: [],
        features: ['factory'],
      ),
      DocConstructor(
        name: 'defaultAutomaticRetries',
        signature: [
          DocParameter(
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
  DocComponent(
    name: 'LdExceptionView',
    isNullSafe: true,
    description: ' Renders an LdException',
    properties: [
      DocProperty(
        name: 'exception',
        type: 'LdException?',
        description: '/// The exception to render',
        features: ['final'],
      ),
      DocProperty(
        name: 'retryController',
        type: 'LdRetryController?',
        description: '/// The controller for managing retry operations',
        features: ['final'],
      ),
      DocProperty(
        name: 'retry',
        type: 'void Function()?',
        description:
            '/// A callback to retry the action that caused the exception\n/// If null, the retry button will not be displayed',
        features: ['final'],
      ),
      DocProperty(
        name: 'direction',
        type: 'Axis',
        description:
            '/// The direction of the exception view, either [Axis.vertical] or\n/// [Axis.horizontal].',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'exception',
            type: 'LdException?',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'retryController',
            type: 'LdRetryController?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'retry',
            type: 'void Function()?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'direction',
            type: 'Axis',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      DocConstructor(
        name: 'fromDynamic',
        signature: [
          DocParameter(
            name: 'error',
            type: 'dynamic',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'context',
            type: 'BuildContext',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'direction',
            type: 'Axis',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'retryController',
            type: 'LdRetryController?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdRetryState',
    isNullSafe: true,
    description: ' State object for retry operations',
    properties: [
      DocProperty(
        name: 'attempt',
        type: 'int',
        description: '/// Current attempt number (1-based)',
        features: ['final'],
      ),
      DocProperty(
        name: 'remainingRetryTime',
        type: 'Duration?',
        description: '/// Remaining time until next retry',
        features: ['final'],
      ),
      DocProperty(
        name: 'isRetrying',
        type: 'bool',
        description: '/// Whether retry is in progress',
        features: ['final'],
      ),
      DocProperty(
        name: 'canRetry',
        type: 'bool',
        description: '/// Whether retry is enabled',
        features: ['final'],
      ),
      DocProperty(
        name: 'totalRetryDelay',
        type: 'Duration?',
        description: '/// The total delay for the current retry',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'attempt',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'remainingRetryTime',
            type: 'Duration?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'isRetrying',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'canRetry',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdRetryController',
    isNullSafe: true,
    description: ' Controller for managing retry operations',
    properties: [
      DocProperty(
        name: 'config',
        type: 'LdRetryConfig',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_stateController',
        type: 'StreamController<LdRetryState>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: '_retryTimer',
        type: 'Timer?',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_state',
        type: 'LdRetryState',
        description: '',
        features: [],
      ),
      DocProperty(
        name: '_jitter',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onRetry',
        type: 'void Function()',
        description:
            '/// Function to be called when a retry should be executed',
        features: ['final'],
      ),
      DocProperty(
        name: 'stateStream',
        type: 'Stream<LdRetryState>',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'state',
        type: 'LdRetryState',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'showRetryIndicator',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'showRetryButton',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'onRetry',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdLoader',
    isNullSafe: true,
    description: ' a loading indicator (indeterminate)',
    properties: [
      DocProperty(
        name: 'size',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'speed',
        type: 'Duration',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'neutral',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'neutral',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: '_LdLoaderState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_animationController',
        type: 'AnimationController',
        description: '',
        features: ['late'],
      )
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: '_LoadingPainter',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'animation',
        type: 'Animation<double>',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'loaderSize',
        type: 'double',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'baseColor',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'accentColor',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'accentColor2',
        type: 'Color',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'animation',
            type: 'Animation<double>',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'loaderSize',
            type: 'double',
            description: '',
            named: false,
            required: true,
          ),
          DocParameter(
            name: 'baseColor',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'accentColor',
            type: 'Color',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdReveal',
    isNullSafe: true,
    description:
        ' A utility to reveal some content, with a fade in and collapse effect',
    properties: [
      DocProperty(
        name: 'revealed',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'transformXOffset',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'transformYOffset',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'springConstant',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'dampingCoefficient',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'mass',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'initialRevealed',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'bufferSprings',
        type: 'int?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'revealed',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'transformXOffset',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'transformYOffset',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'initialRevealed',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'mass',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'bufferSprings',
            type: 'int?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'springConstant',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'dampingCoefficient',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['const'],
      ),
      DocConstructor(
        name: 'quick',
        signature: [
          DocParameter(
            name: 'revealed',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'initialRevealed',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'transformXOffset',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'transformYOffset',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
        ],
        features: ['factory'],
      ),
      DocConstructor(
        name: 'slow',
        signature: [
          DocParameter(
            name: 'revealed',
            type: 'bool',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'initialRevealed',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'transformXOffset',
            type: 'double',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdNotificationProvider',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'notifier',
        type: 'LdNotificationsController?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'notifier',
            type: 'LdNotificationsController?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdNotificationPortal',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdNotificationWidget',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'notification',
        type: 'LdNotification',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'index',
        type: 'int',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'removing',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'didConfirm',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onDismiss',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onConfirm',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onCancel',
        type: 'void Function()',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onSubmitInput',
        type: 'dynamic Function(String)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'notification',
            type: 'LdNotification',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'removing',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'didConfirm',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'onConfirm',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onSubmitInput',
            type: 'dynamic Function(String)',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'onCancel',
            type: 'void Function()',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'index',
            type: 'int',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdNotification',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'message',
        type: 'String',
        description: '/// Message of the notification',
        features: ['final'],
      ),
      DocProperty(
        name: 'subMessage',
        type: 'String?',
        description: '/// Submessage of the notification',
        features: ['final'],
      ),
      DocProperty(
        name: 'duration',
        type: 'Duration?',
        description:
            '/// Duration of the notification. If null the notification will not be dismissed automatically',
        features: ['final'],
      ),
      DocProperty(
        name: 'color',
        type: 'LdColor?',
        description: '/// If the notification is a big notification',
        features: ['final'],
      ),
      DocProperty(
        name: 'type',
        type: 'LdNotificationType',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'removing',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'didConfirm',
        type: 'bool',
        description: '',
        features: [],
      ),
      DocProperty(
        name: 'key',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'canDismiss',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'showBackdrop',
        type: 'bool',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'message',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'type',
            type: 'LdNotificationType',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'subMessage',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'canDismiss',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'removing',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'didConfirm',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdInputNotification',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'inputKey',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'inputHint',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'inputLabel',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'inputType',
        type: 'TextInputType',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'submitText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'inputCompleter',
        type: 'Completer<String?>',
        description:
            '/// Completer that gets resolved when the user entered something in the input field',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'message',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'type',
            type: 'LdNotificationType',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'inputHint',
            type: 'String?',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'inputLabel',
            type: 'String?',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'submitText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'inputType',
            type: 'TextInputType',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'subMessage',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'canDismiss',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdConfirmNotification',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'cancelKey',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'confirmKey',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'confirmText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'cancelText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'confirmationCompleter',
        type: 'Completer<bool?>',
        description:
            '/// Completer that gets resolved when the user confirms the notification or it is dismissed',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'message',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'type',
            type: 'LdNotificationType',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'subMessage',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'canDismiss',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'duration',
            type: 'Duration?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'confirmText',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdAcknowledgeNotification',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'dismissKey',
        type: 'Key',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'acknowledgeText',
        type: 'String?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'message',
            type: 'String',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'type',
            type: 'LdNotificationType',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'subMessage',
            type: 'String?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'color',
            type: 'LdColor?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'canDismiss',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'duration',
            type: 'Duration?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdNotificationsController',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_notifications',
        type: 'List<LdNotification>',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'notifications',
        type: 'List<LdNotification>',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'ImplicitBlur',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'sigma',
        type: 'double',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'duration',
        type: 'Duration',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'sigma',
            type: 'double',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: '_ImplicitBlurState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_controller',
        type: 'AnimationController',
        description: '',
        features: [
          'final',
          'late',
        ],
      ),
      DocProperty(
        name: '_tween',
        type: 'Tween<double>',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'NotificationInput',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'notification',
        type: 'LdInputNotification',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'onSubmitted',
        type: 'dynamic Function(String)',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'notification',
            type: 'LdInputNotification',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: '_NotificationInputState',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: '_controller',
        type: 'TextEditingController',
        description: '',
        features: ['final'],
      )
    ],
    constructors: [
      DocConstructor(
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
  DocComponent(
    name: 'LdSpacer',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'size',
        type: 'LdSize',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'direction',
        type: 'Axis?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'size',
            type: 'LdSize',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
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
  DocComponent(
    name: 'LdSurfaceInfo',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'isSurface',
        type: 'bool',
        description: '',
        features: [],
      )
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
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
  DocComponent(
    name: 'LdAutoBackground',
    isNullSafe: true,
    description:
        ' A widget that will change its background color based on the parent surface',
    properties: [
      DocProperty(
        name: 'child',
        type: 'Widget',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'invert',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'isSurface',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'borderRadius',
        type: 'BorderRadius?',
        description: '',
        features: ['final'],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'child',
            type: 'Widget',
            description: '',
            named: true,
            required: true,
          ),
          DocParameter(
            name: 'invert',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'borderRadius',
            type: 'BorderRadius?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'isSurface',
            type: 'bool?',
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
  DocComponent(
    name: 'LdAppBar',
    isNullSafe: true,
    description: '',
    properties: [
      DocProperty(
        name: 'title',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'actions',
        type: 'List<Widget>?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'leading',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'elevation',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'iconTheme',
        type: 'IconThemeData?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'primary',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'centerTitle',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'titleSpacing',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'toolbarOpacity',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'bottomOpacity',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'toolbarHeight',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'titleTextStyle',
        type: 'TextStyle?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'backgroundColor',
        type: 'Color?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'actionsIconTheme',
        type: 'IconThemeData?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'flexibleSpace',
        type: 'Widget?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'foregroundColor',
        type: 'Color?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'automaticallyImplyLeading',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'clipBehavior',
        type: 'Clip?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'shape',
        type: 'ShapeBorder?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'toolbarTextStyle',
        type: 'TextStyle?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'leadingWidth',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'notificationPredicate',
        type: 'bool Function(ScrollNotification)?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'forceMaterialTransparency',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'scrolledUnderElevation',
        type: 'double?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'surfaceTintColor',
        type: 'Color?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'excludeHeaderSemantics',
        type: 'bool?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'context',
        type: 'BuildContext?',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'loading',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'actionsDisabled',
        type: 'bool',
        description: '',
        features: ['final'],
      ),
      DocProperty(
        name: 'preferredSize',
        type: 'Size',
        description: '',
        features: [],
      ),
    ],
    constructors: [
      DocConstructor(
        name: '',
        signature: [
          DocParameter(
            name: 'key',
            type: 'Key?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'context',
            type: 'BuildContext?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'title',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'actions',
            type: 'List<Widget>?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'leading',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'elevation',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'iconTheme',
            type: 'IconThemeData?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'primary',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'centerTitle',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'titleSpacing',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'toolbarOpacity',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'bottomOpacity',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'toolbarHeight',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'titleTextStyle',
            type: 'TextStyle?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'backgroundColor',
            type: 'Color?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'actionsIconTheme',
            type: 'IconThemeData?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'flexibleSpace',
            type: 'Widget?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'foregroundColor',
            type: 'Color?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'automaticallyImplyLeading',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'clipBehavior',
            type: 'Clip?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'shape',
            type: 'ShapeBorder?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'toolbarTextStyle',
            type: 'TextStyle?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'leadingWidth',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'notificationPredicate',
            type: 'bool Function(ScrollNotification)?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'forceMaterialTransparency',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'scrolledUnderElevation',
            type: 'double?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'surfaceTintColor',
            type: 'Color?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'excludeHeaderSemantics',
            type: 'bool?',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'loading',
            type: 'bool',
            description: '',
            named: true,
            required: false,
          ),
          DocParameter(
            name: 'actionsDisabled',
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
];
