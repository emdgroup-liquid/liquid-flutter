import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Mounts [model] and its [LdListController] in the widget tree.
class LdMonkeyDataProvider<T extends Identifiable<IdType>, IdType, TModel extends LdModel<T, IdType, Object?, Object?>>
    extends StatefulWidget {
  final TModel Function(BuildContext context) modelBuilder;
  final Widget child;

  const LdMonkeyDataProvider({
    super.key,
    required this.modelBuilder,
    required this.child,
  });

  @override
  State<LdMonkeyDataProvider<T, IdType, TModel>> createState() => _LdMonkeyDataProviderState<T, IdType, TModel>();
}

class _LdMonkeyDataProviderState<T extends Identifiable<IdType>, IdType,
    TModel extends LdModel<T, IdType, Object?, Object?>> extends State<LdMonkeyDataProvider<T, IdType, TModel>> {
  late final TModel _model;
  late final LdListController<T, IdType> _listController;

  @override
  void initState() {
    super.initState();
    _model = widget.modelBuilder(context);
    _listController = LdListController(_model);
    WidgetsBinding.instance.addPostFrameCallback(_initListController);
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _initListController(Duration _) async {
    if (_listController.isGreedy) {
      await _listController.ensureGreedyLoaded(context);
      if (!mounted) {
        return;
      }
    }

    final selection = context.read<LdMonkeySelection<T, IdType>?>();
    if (selection != null && selection.viewing.isNotEmpty) {
      if (!_listController.isGreedy) {
        await _listController.initWithSelection(context, selection.viewing);
        if (!mounted) {
          return;
        }
      }
    } else if (!_listController.isGreedy) {
      await _listController.fetchPageAtOffset(
        context,
        0,
        reason: LdFetchReason.initial,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TModel>.value(value: _model),
        Provider<LdModel<T, IdType, Object?, Object?>>.value(value: _model),
        ListenableProvider<LdListController<T, IdType>>.value(value: _listController),
      ],
      child: widget.child,
    );
  }
}
