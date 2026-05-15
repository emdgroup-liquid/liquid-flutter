part of 'list.dart';

class LdListConfig<T extends Identifiable<IdType>, IdType> {
  const LdListConfig({
    this.itemBuilder,
    this.paginator,
    this.areEqual,
    this.assumedItemHeight,
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

  final double? assumedItemHeight;

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
}

class LdListConfigProvider<T extends Identifiable<IdType>, IdType>
    extends StatelessWidget {
  const LdListConfigProvider({
    required this.config,
    required this.child,
    super.key,
  });

  final LdListConfig<T, IdType> config;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final parentConfig =
        Provider.of<LdListConfig<T, IdType>?>(context, listen: true);
    final mergedConfig = parentConfig != null
        ? LdListConfig<T, IdType>(
            itemBuilder: config.itemBuilder ?? parentConfig.itemBuilder,
            paginator: config.paginator ?? parentConfig.paginator,
            areEqual: config.areEqual ?? parentConfig.areEqual,
            assumedItemHeight:
                config.assumedItemHeight ?? parentConfig.assumedItemHeight,
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
    this.assumedItemHeight,
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

  final double? assumedItemHeight;

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
      assumedItemHeight: assumedItemHeight ?? config?.assumedItemHeight,
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
