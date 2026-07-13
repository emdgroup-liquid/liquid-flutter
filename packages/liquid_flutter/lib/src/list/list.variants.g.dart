part of 'list.dart';

class LdListConfig<T extends Identifiable<IdType>, IdType> {
  const LdListConfig({
    this.itemBuilder,
    this.paginator,
    this.areEqual,
    this.emptyBuilder,
    this.errorBuilder,
    this.footer,
    this.groupHeaderBuilder,
    this.groupingCriterion,
    this.header,
    this.loadingBuilder,
    this.padding,
    this.physics,
    this.primary,
    this.retryConfig,
    this.scrollController,
    this.separatorBuilder,
    this.shrinkWrap,
  });

  final Widget Function(BuildContext, LdPaginatorLoadedItem<T>, int)?
      itemBuilder;

  final LdPaginator<T, IdType>? paginator;

  final bool Function(T, T)? areEqual;

  final Widget Function(BuildContext, Future<void> Function(BuildContext))?
      emptyBuilder;

  final Widget Function(BuildContext, Object?, void Function())? errorBuilder;

  final Widget? footer;

  final Widget Function(BuildContext, dynamic, List<LdPaginatorItem<T>>)?
      groupHeaderBuilder;

  final dynamic Function(T)? groupingCriterion;

  final Widget? header;

  final Widget Function(BuildContext, int, int)? loadingBuilder;

  final EdgeInsets? padding;

  final ScrollPhysics? physics;

  final bool? primary;

  final LdRetryConfig? retryConfig;

  final ScrollController? scrollController;

  final Widget Function(BuildContext)? separatorBuilder;

  final bool? shrinkWrap;

  LdListConfig<T, IdType> copyWith({
    Widget Function(BuildContext, LdPaginatorLoadedItem<T>, int)? itemBuilder,
    LdPaginator<T, IdType>? paginator,
    bool Function(T, T)? areEqual,
    Widget Function(BuildContext, Future<void> Function(BuildContext))?
        emptyBuilder,
    Widget Function(BuildContext, Object?, void Function())? errorBuilder,
    Widget? footer,
    Widget Function(BuildContext, dynamic, List<LdPaginatorItem<T>>)?
        groupHeaderBuilder,
    dynamic Function(T)? groupingCriterion,
    Widget? header,
    Widget Function(BuildContext, int, int)? loadingBuilder,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    bool? primary,
    LdRetryConfig? retryConfig,
    ScrollController? scrollController,
    Widget Function(BuildContext)? separatorBuilder,
    bool? shrinkWrap,
  }) {
    return LdListConfig<T, IdType>(
      itemBuilder: itemBuilder ?? this.itemBuilder,
      paginator: paginator ?? this.paginator,
      areEqual: areEqual ?? this.areEqual,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      footer: footer ?? this.footer,
      groupHeaderBuilder: groupHeaderBuilder ?? this.groupHeaderBuilder,
      groupingCriterion: groupingCriterion ?? this.groupingCriterion,
      header: header ?? this.header,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      padding: padding ?? this.padding,
      physics: physics ?? this.physics,
      primary: primary ?? this.primary,
      retryConfig: retryConfig ?? this.retryConfig,
      scrollController: scrollController ?? this.scrollController,
      separatorBuilder: separatorBuilder ?? this.separatorBuilder,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
    );
  }

  LdListConfig<T, IdType> merge(LdListConfig<T, IdType>? other) {
    if (other == null) return this;
    return LdListConfig<T, IdType>(
      itemBuilder: other.itemBuilder ?? this.itemBuilder,
      paginator: other.paginator ?? this.paginator,
      areEqual: other.areEqual ?? this.areEqual,
      emptyBuilder: other.emptyBuilder ?? this.emptyBuilder,
      errorBuilder: other.errorBuilder ?? this.errorBuilder,
      footer: other.footer ?? this.footer,
      groupHeaderBuilder: other.groupHeaderBuilder ?? this.groupHeaderBuilder,
      groupingCriterion: other.groupingCriterion ?? this.groupingCriterion,
      header: other.header ?? this.header,
      loadingBuilder: other.loadingBuilder ?? this.loadingBuilder,
      padding: other.padding ?? this.padding,
      physics: other.physics ?? this.physics,
      primary: other.primary ?? this.primary,
      retryConfig: other.retryConfig ?? this.retryConfig,
      scrollController: other.scrollController ?? this.scrollController,
      separatorBuilder: other.separatorBuilder ?? this.separatorBuilder,
      shrinkWrap: other.shrinkWrap ?? this.shrinkWrap,
    );
  }
}

class LdListConfigProvider<T extends Identifiable<IdType>, IdType>
    extends StatelessWidget {
  const LdListConfigProvider({
    required this.config,
    required this.child,
    this.ignoreParent = false,
    super.key,
  });

  final LdListConfig<T, IdType> config;

  final Widget child;

  final bool ignoreParent;

  @override
  Widget build(BuildContext context) {
    if (ignoreParent) {
      return Provider<LdListConfig<T, IdType>>.value(
        value: config,
        child: child,
      );
    }
    final parentConfig =
        Provider.of<LdListConfig<T, IdType>?>(context, listen: true);
    final mergedConfig = parentConfig != null
        ? LdListConfig<T, IdType>(
            itemBuilder: config.itemBuilder ?? parentConfig.itemBuilder,
            paginator: config.paginator ?? parentConfig.paginator,
            areEqual: config.areEqual ?? parentConfig.areEqual,
            emptyBuilder: config.emptyBuilder ?? parentConfig.emptyBuilder,
            errorBuilder: config.errorBuilder ?? parentConfig.errorBuilder,
            footer: config.footer ?? parentConfig.footer,
            groupHeaderBuilder:
                config.groupHeaderBuilder ?? parentConfig.groupHeaderBuilder,
            groupingCriterion:
                config.groupingCriterion ?? parentConfig.groupingCriterion,
            header: config.header ?? parentConfig.header,
            loadingBuilder:
                config.loadingBuilder ?? parentConfig.loadingBuilder,
            padding: config.padding ?? parentConfig.padding,
            physics: config.physics ?? parentConfig.physics,
            primary: config.primary ?? parentConfig.primary,
            retryConfig: config.retryConfig ?? parentConfig.retryConfig,
            scrollController:
                config.scrollController ?? parentConfig.scrollController,
            separatorBuilder:
                config.separatorBuilder ?? parentConfig.separatorBuilder,
            shrinkWrap: config.shrinkWrap ?? parentConfig.shrinkWrap)
        : config;
    return Provider<LdListConfig<T, IdType>>.value(
      value: mergedConfig,
      child: child,
    );
  }
}

class LdList<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const LdList({
    this.itemBuilder,
    this.paginator,
    this.areEqual,
    this.emptyBuilder,
    this.errorBuilder,
    this.footer,
    this.groupHeaderBuilder,
    this.groupingCriterion,
    this.header,
    this.loadingBuilder,
    this.padding,
    this.physics,
    this.primary,
    this.retryConfig,
    this.scrollController,
    this.separatorBuilder,
    this.shrinkWrap,
    super.key,
  });

  final Widget Function(BuildContext, LdPaginatorLoadedItem<T>, int)?
      itemBuilder;

  final Widget Function(BuildContext, Future<void> Function(BuildContext))?
      emptyBuilder;

  final Widget Function(BuildContext, Object?, void Function())? errorBuilder;

  final Widget Function(BuildContext, int, int)? loadingBuilder;

  final dynamic Function(T)? groupingCriterion;

  final Widget Function(BuildContext, dynamic, List<LdPaginatorItem<T>>)?
      groupHeaderBuilder;

  final Widget Function(BuildContext)? separatorBuilder;

  final LdPaginator<T, IdType>? paginator;

  final ScrollController? scrollController;

  final bool Function(T, T)? areEqual;

  final bool? shrinkWrap;

  final ScrollPhysics? physics;

  final bool? primary;

  final Widget? header;

  final Widget? footer;

  final LdRetryConfig? retryConfig;

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<LdListConfig<T, IdType>?>(context, listen: true);
    assert(config?.itemBuilder != null || itemBuilder != null,
        "Parameter itemBuilder is required and it was neither provided nor directly passed");
    assert(config?.paginator != null || paginator != null,
        "Parameter paginator is required and it was neither provided nor directly passed");
    return LdListWidget(
      itemBuilder: itemBuilder ?? config!.itemBuilder!,
      paginator: paginator ?? config!.paginator!,
      areEqual: areEqual ?? config?.areEqual,
      emptyBuilder: emptyBuilder ?? config?.emptyBuilder,
      errorBuilder: errorBuilder ?? config?.errorBuilder,
      footer: footer ?? config?.footer,
      groupHeaderBuilder: groupHeaderBuilder ?? config?.groupHeaderBuilder,
      groupingCriterion: groupingCriterion ?? config?.groupingCriterion,
      header: header ?? config?.header,
      loadingBuilder: loadingBuilder ?? config?.loadingBuilder,
      padding: padding ?? config?.padding ?? EdgeInsets.zero,
      physics: physics ?? config?.physics,
      primary: primary ?? config?.primary ?? false,
      retryConfig: retryConfig ?? config?.retryConfig,
      scrollController: scrollController ?? config?.scrollController,
      separatorBuilder: separatorBuilder ?? config?.separatorBuilder,
      shrinkWrap: shrinkWrap ?? config?.shrinkWrap ?? false,
    );
  }
}
