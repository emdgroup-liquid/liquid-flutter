import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

// Create a value notifier provider to store and update the argument
class _ArgNotifier<Arg> extends ChangeNotifier {
  Arg? _arg;

  Arg? get arg => _arg;

  void setArg(Arg? value) {
    _arg = value;
    notifyListeners();
  }
}

typedef LdCrudActionButtonBuilder<T extends CrudItemMixin<T>> = Widget Function(
    LdCrudMasterDetailState<T> masterDetail, VoidCallback triggerAction);

class LdCrudAction<T extends CrudItemMixin<T>, Arg, Result> extends StatelessWidget {
  final LdCrudActionButtonBuilder<T> actionButtonBuilder;
  final FutureOr<Arg?> Function(LdCrudMasterDetailState<T> masterDetail) obtainArg;
  final FutureOr<Result> Function(LdCrudOperations<T> crud, Arg arg) action;
  final Function(LdCrudMasterDetailState<T> masterDetail, Arg arg, Result result)? onActionCompleted;

  /// Creates a new action for CRUD operations.
  /// [Arg] must be either [T] or [Iterable<T>].
  const LdCrudAction({
    required this.actionButtonBuilder,
    required this.action,
    required this.obtainArg,
    this.onActionCompleted,
    super.key,
  }) : assert(Arg == T || Arg == List<T>, 'Arg must be either T or Iterable<T> or List<T>');

  @override
  Widget build(BuildContext context) {
    // Create an _ArgNotifier provider that will store our argument
    return ChangeNotifierProvider<_ArgNotifier<Arg>>(
      create: (_) => _ArgNotifier<Arg>(),
      child: Builder(
        builder: (providerContext) {
          final masterDetail = context.read<LdCrudMasterDetailState<T>>();
          final argNotifier = Provider.of<_ArgNotifier<Arg>>(providerContext);

          // Inline helper function to build the submit button
          Widget _buildActionButton(
            LdSubmitController<Result> submitController,
          ) {
            return actionButtonBuilder(masterDetail, () async {
              // Get and store the argument immediately before triggering
              final obtainedArg = await obtainArg(masterDetail);
              if (obtainedArg == null) return;

              // Update the Provider with the new argument
              argNotifier.setArg(obtainedArg);
              submitController.trigger();
            });
          }

          final ldSubmitBuilder = masterDetail.widget.loadingIndicatorStyles
                  .contains(LoadingIndicatorStyle.dialogLoading)
              ? LdSubmitDialogBuilder<Result>(
                  submitButtonBuilder: (submitButtonContext, submitController) => _buildActionButton(submitController))
              : LdSubmitInlineBuilder<Result>(
                  submitButtonBuilder: (submitButtonContext, submitController) => _buildActionButton(submitController),
                  errorBuilder: (context, exception, submitController) => _buildActionButton(submitController),
                );

          return LdSubmit<Result>(
            builder: ldSubmitBuilder,
            config: LdSubmitConfig<Result>(
              action: () async {
                // Read the arg from the Provider
                final arg = argNotifier.arg;
                if (arg == null) {
                  throw LdException(message: "Operation failed: No argument available");
                }

                final listState = masterDetail.listState;
                _handleArgEvent(listState, arg, CrudItemStateEvent.loading());
                try {
                  final result = await action(
                    masterDetail.crud,
                    arg,
                  );
                  // if Result may not be void and result is null, throw an exception
                  if (result == null && Result == T) {
                    throw LdException(message: "Operation failed");
                  }
                  _handleArgEvent(
                    listState,
                    arg,
                    result == null
                        ? CrudItemStateEvent.deleted()
                        : CrudItemStateEvent.success(
                            result as T,
                          ),
                  );
                  onActionCompleted?.call(masterDetail, arg, result);
                  return result;
                } catch (error) {
                  _handleArgEvent(listState, arg, CrudItemStateEvent.error(error));
                  rethrow;
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _handleArgEvent(LdCrudListState<T> listState, Arg arg, CrudItemStateEvent<T> event) {
    if (arg is Iterable<T>) {
      if (event.type == CrudLoadingStateType.loading) {
        listState.handleItemStateEvent(
          null,
          CrudItemStateEvent.loading(),
        );
        return;
      }
      for (final item in arg) {
        listState.handleItemStateEvent(item, event);
      }
      return;
    } else if (arg is T) {
      if (event.type == CrudLoadingStateType.loading) {
        listState.handleItemStateEvent(arg, CrudItemStateEvent.loading(arg));
        return;
      }
      listState.handleItemStateEvent(arg, event);
    } else {
      throw LdException(
        message: "Arg must be either T or Iterable<T>",
      );
    }
  }

  static LdCrudAction<T, T, T> createItem<T extends CrudItemMixin<T>>({
    required FutureOr<T?> Function() getNewItem,
    Function(LdCrudMasterDetailState<T> masterDetail, T newItem)? onItemCreated,
    LdCrudActionButtonBuilder<T>? actionButtonBuilder,
  }) {
    return LdCrudAction<T, T, T>(
      actionButtonBuilder: actionButtonBuilder ??
          (masterDetail, triggerAction) => masterDetail.listState.selectedItemCount > 0
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: triggerAction,
                  icon: const Icon(Icons.add),
                ),
      action: (crud, newItem) => crud.create(newItem),
      onActionCompleted: (masterDetail, arg, result) => onItemCreated?.call(masterDetail, result),
      obtainArg: (masterDetail) async => getNewItem(),
    );
  }

  static LdCrudAction<T, T, T> updateItem<T extends CrudItemMixin<T>>({
    required FutureOr<T?> Function() getUpdatedItem,
    Function(LdCrudMasterDetailState<T> masterDetail, T updatedItem)? onItemUpdated,
    LdCrudActionButtonBuilder<T>? actionButtonBuilder,
  }) {
    return LdCrudAction<T, T, T>(
      actionButtonBuilder: actionButtonBuilder ??
          (context, triggerAction) => IconButton(
                onPressed: triggerAction,
                icon: const Icon(Icons.save),
              ),
      action: (crud, newItem) => crud.update(newItem),
      onActionCompleted: (masterDetail, arg, result) {
        final controller = masterDetail.controller;
        if (controller.getOpenItem()?.id == arg.id) {
          controller.openItem(result); // refresh the open item
        }
        onItemUpdated?.call(masterDetail, result);
      },
      obtainArg: (masterDetail) async => getUpdatedItem(),
    );
  }

  static LdCrudAction<T, T, void> deleteOpenItem<T extends CrudItemMixin<T>>({
    String? confirmationMessage,
    LdCrudActionButtonBuilder<T>? actionButtonBuilder,
  }) {
    return LdCrudAction<T, T, void>(
      actionButtonBuilder: actionButtonBuilder ??
          (masterDetail, triggerAction) => IconButton(
                onPressed: triggerAction,
                icon: const Icon(Icons.delete),
              ),
      action: (crud, item) => crud.delete(item),
      onActionCompleted: (masterDetail, arg, result) {
        final controller = masterDetail.controller;
        if (controller.getOpenItem()?.id == arg.id) {
          controller.closeItem();
        }
      },
      obtainArg: (masterDetail) async {
        if (confirmationMessage?.isNotEmpty ?? false) {
          final confirmed = await LdNotificationsController.of(masterDetail.context).confirm(confirmationMessage!);
          if (confirmed != true) return null;
        }
        return masterDetail.controller.getOpenItem();
      },
    );
  }

  static LdCrudAction<T, List<T>, void> deleteSelectedItems<T extends CrudItemMixin<T>>({
    String? confirmationMessage,
    LdCrudActionButtonBuilder<T>? actionButtonBuilder,
  }) {
    return LdCrudAction<T, List<T>, void>(
        actionButtonBuilder: actionButtonBuilder ??
            (masterDetail, triggerAction) => masterDetail.listState.selectedItemCount == 0
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: triggerAction,
                    icon: const Icon(Icons.delete_forever),
                  ),
        action: (crud, items) => crud.batchDelete(items),
        onActionCompleted: (masterDetail, arg, result) => masterDetail.listState.updateItemSelection({}),
        obtainArg: (masterDetail) async {
          if (confirmationMessage?.isNotEmpty ?? false) {
            final confirmed = await LdNotificationsController.of(masterDetail.context).confirm(confirmationMessage!);
            if (confirmed != true) return null;
          }
          return masterDetail.listState.selectedItems.toList();
        });
  }
}
