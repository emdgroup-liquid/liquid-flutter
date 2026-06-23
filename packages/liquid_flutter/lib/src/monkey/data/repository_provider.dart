import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Provides [repository] to context of [child]. Will attempt to watch for
/// [LdMonkeySortAndFilterState] and [LdMonkeySelection] and initialize the repository
/// with the sort and filter state and selection.
class LdRepositoryProvider<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final LdRepository<T, IdType> Function(BuildContext context) repositoryBuilder;
  final Widget child;

  const LdRepositoryProvider({
    super.key,
    required this.repositoryBuilder,
    required this.child,
  });

  @override
  State<LdRepositoryProvider<T, IdType>> createState() => _LdRepositoryProviderState<T, IdType>();
}

class _LdRepositoryProviderState<T extends Identifiable<IdType>, IdType>
    extends State<LdRepositoryProvider<T, IdType>> {
  late final LdRepository<T, IdType> _repository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  initState() {
    super.initState();
    _repository = widget.repositoryBuilder(context);
    WidgetsBinding.instance.addPostFrameCallback(_initRepository);
  }

  @override
  void dispose() {
    super.dispose();
    _repository.dispose();
  }

  // Reads sort and filters from the context and initializes the repository

  Future<void> _initRepository(Duration _) async {
    if (_repository.isGreedy) {
      await _repository.ensureGreedyLoaded(context);
      if (!mounted) {
        return;
      }
    }

    final selection = context.read<LdMonkeySelection<T, IdType>?>();
    if (selection != null && selection.viewing.isNotEmpty) {
      if (!_repository.isGreedy) {
        await _repository.initWithSelection(context, selection.viewing);
        if (!mounted) {
          return;
        }
      }
    } else if (!_repository.isGreedy) {
      await _repository.fetchPageAtOffset(
        context,
        0,
        reason: LdFetchReason.initial,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<LdRepository<T, IdType>>.value(
      value: _repository,
      child: widget.child,
    );
  }
}
